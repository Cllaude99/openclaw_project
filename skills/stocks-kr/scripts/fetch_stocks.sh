#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 국내/해외 주요 주식 시세 조회 — Yahoo Finance v8 Chart API
# API 키 불필요, 무료
# 종목별 개별 호출 (v8은 배치 미지원)
# ===================================================

# 국내 주식 (Yahoo Finance 심볼|한국어 이름)
KR_STOCKS=(
  "005930.KS|삼성전자"
  "000660.KS|SK하이닉스"
  "035420.KS|NAVER"
  "035720.KS|카카오"
  "005380.KS|현대자동차"
  "000270.KS|기아"
  "068270.KS|셀트리온"
  "055550.KS|신한지주"
  "105560.KS|KB금융"
  "028260.KS|삼성물산"
  "012330.KS|현대모비스"
  "051910.KS|LG화학"
  "006400.KS|삼성SDI"
  "003670.KS|포스코퓨처엠"
  "247540.KS|에코프로비엠"
)

# 해외 주식 (미국)
US_STOCKS=(
  "AAPL|애플"
  "MSFT|마이크로소프트"
  "NVDA|엔비디아"
  "GOOGL|알파벳 (구글)"
  "AMZN|아마존"
  "META|메타"
  "TSLA|테슬라"
  "TSM|TSMC"
  "AVGO|브로드컴"
  "AMD|AMD"
)

# 지수
INDICES=(
  "^KS11|KOSPI"
  "^KQ11|KOSDAQ"
  "^GSPC|S&P 500"
  "^IXIC|나스닥"
)

# Yahoo Finance v8 Chart API로 개별 종목 조회
fetch_one() {
  local symbol="$1"
  local name="$2"
  local category="$3"

  # URL 인코딩 (^ → %5E)
  local encoded_symbol="${symbol//^/%5E}"

  local RESP
  RESP=$(curl -s --max-time 10 \
    -H "User-Agent: Mozilla/5.0" \
    "https://query1.finance.yahoo.com/v8/finance/chart/${encoded_symbol}?interval=1d&range=5d&includePrePost=false" \
    2>/dev/null || echo "")

  if [ -z "$RESP" ]; then
    return
  fi

  # 에러 체크
  if echo "$RESP" | jq -e '.chart.error' > /dev/null 2>&1; then
    local ERR_CODE
    ERR_CODE=$(echo "$RESP" | jq -r '.chart.error.code // empty')
    if [ -n "$ERR_CODE" ] && [ "$ERR_CODE" != "null" ]; then
      return
    fi
  fi

  # 메타 데이터 추출
  local META
  META=$(echo "$RESP" | jq -r '.chart.result[0].meta // empty' 2>/dev/null)
  if [ -z "$META" ] || [ "$META" = "null" ]; then
    return
  fi

  # 최근 거래일의 고가/저가/거래량 추출
  local DAY_HIGH DAY_LOW VOLUME
  DAY_HIGH=$(echo "$RESP" | jq -r '[.chart.result[0].indicators.quote[0].high[] // empty] | last' 2>/dev/null || echo "null")
  DAY_LOW=$(echo "$RESP" | jq -r '[.chart.result[0].indicators.quote[0].low[] // empty] | last' 2>/dev/null || echo "null")
  VOLUME=$(echo "$RESP" | jq -r '[.chart.result[0].indicators.quote[0].volume[] // empty] | last' 2>/dev/null || echo "null")

  echo "$META" | jq \
    --arg kr_name "$name" \
    --arg category "$category" \
    --arg day_high "$DAY_HIGH" \
    --arg day_low "$DAY_LOW" \
    --arg volume "$VOLUME" \
    '{
      symbol: .symbol,
      name: $kr_name,
      price: .regularMarketPrice,
      prev_close: .chartPreviousClose,
      change: ((.regularMarketPrice // 0) - (.chartPreviousClose // 0)),
      change_percent: (if .chartPreviousClose > 0 then (((.regularMarketPrice - .chartPreviousClose) / .chartPreviousClose) * 100) else 0 end),
      day_high: ($day_high | tonumber? // null),
      day_low: ($day_low | tonumber? // null),
      volume: ($volume | tonumber? // null),
      week52_high: .fiftyTwoWeekHigh,
      week52_low: .fiftyTwoWeekLow,
      currency: .currency,
      category: $category
    }'
}

# 카테고리별 수집 함수
fetch_category() {
  local category="$1"
  shift
  local entries=("$@")

  local RESULTS="["
  local FIRST=true

  for entry in "${entries[@]}"; do
    IFS='|' read -r symbol name <<< "$entry"

    local STOCK_JSON
    STOCK_JSON=$(fetch_one "$symbol" "$name" "$category")

    if [ -z "$STOCK_JSON" ]; then
      continue
    fi

    if [ "$FIRST" = true ]; then
      FIRST=false
    else
      RESULTS+=","
    fi
    RESULTS+="$STOCK_JSON"
  done

  RESULTS+="]"
  echo "$RESULTS"
}

# 병렬화는 하지 않음 (API rate limit 고려)
INDICES_JSON=$(fetch_category "index" "${INDICES[@]}")
KR_JSON=$(fetch_category "kr" "${KR_STOCKS[@]}")
US_JSON=$(fetch_category "us" "${US_STOCKS[@]}")

FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')

jq -n \
  --argjson indices "$INDICES_JSON" \
  --argjson kr_stocks "$KR_JSON" \
  --argjson us_stocks "$US_JSON" \
  --arg fetched_at "$FETCHED_AT" \
  '{ indices: $indices, kr_stocks: $kr_stocks, us_stocks: $us_stocks, fetched_at: $fetched_at }'
