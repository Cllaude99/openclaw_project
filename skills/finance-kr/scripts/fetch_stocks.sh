#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# KOSPI/KOSDAQ 지수 조회 — Yahoo Finance (비공식 API)
# API 키 불필요
# ===================================================

INDICES="${STOCK_INDICES:-^KS11,^KQ11}"

# 지수 한국어 이름 매핑
index_name() {
  case $1 in
    "^KS11") echo "KOSPI";;
    "^KQ11") echo "KOSDAQ";;
    "^KS200") echo "KOSPI 200";;
    "^GSPC") echo "S&P 500";;
    "^DJI") echo "다우존스";;
    "^IXIC") echo "나스닥";;
    *) echo "$1";;
  esac
}

RESULTS="["
FIRST=true

IFS=',' read -ra INDEX_ARRAY <<< "$INDICES"
for symbol in "${INDEX_ARRAY[@]}"; do
  symbol=$(echo "$symbol" | tr -d ' ')
  NAME=$(index_name "$symbol")

  # Yahoo Finance API 호출
  # URL 인코딩: ^는 %5E
  ENCODED=$(echo "$symbol" | sed 's/\^/%5E/g')
  RESPONSE=$(curl -s --max-time 10 \
    -H "User-Agent: Mozilla/5.0" \
    "https://query1.finance.yahoo.com/v8/finance/chart/${ENCODED}?range=1d&interval=1d")

  if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
    continue
  fi

  # 에러 체크
  ERROR=$(echo "$RESPONSE" | jq -r '.chart.error // empty')
  if [ -n "$ERROR" ] && [ "$ERROR" != "null" ]; then
    continue
  fi

  # 데이터 파싱
  PRICE=$(echo "$RESPONSE" | jq -r '.chart.result[0].meta.regularMarketPrice // empty')
  PREV_CLOSE=$(echo "$RESPONSE" | jq -r '.chart.result[0].meta.chartPreviousClose // empty')

  if [ -z "$PRICE" ] || [ -z "$PREV_CLOSE" ]; then
    continue
  fi

  # 변동 계산
  CHANGE=$(echo "scale=2; $PRICE - $PREV_CLOSE" | bc)
  if [ "$PREV_CLOSE" != "0" ]; then
    CHANGE_PCT=$(echo "scale=2; ($PRICE - $PREV_CLOSE) / $PREV_CLOSE * 100" | bc)
  else
    CHANGE_PCT="0"
  fi

  INDEX_JSON=$(jq -n \
    --arg symbol "$symbol" \
    --arg name "$NAME" \
    --argjson price "$PRICE" \
    --argjson change "$CHANGE" \
    --argjson change_percent "$CHANGE_PCT" \
    --argjson prev_close "$PREV_CLOSE" \
    '{
      symbol: $symbol,
      name: $name,
      price: $price,
      change: $change,
      change_percent: $change_percent,
      prev_close: $prev_close
    }')

  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    RESULTS+=","
  fi
  RESULTS+="$INDEX_JSON"
done

RESULTS+="]"

FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')

jq -n \
  --argjson indices "$RESULTS" \
  --arg fetched_at "$FETCHED_AT" \
  '{ indices: $indices, fetched_at: $fetched_at }'
