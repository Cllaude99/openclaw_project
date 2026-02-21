#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 암호화폐 시장 분석 데이터 수집 — CoinGecko API
# API 키 불필요, 무료
# 시가총액, 변동률(1h/24h/7d), 거래량 등 트렌드 데이터
# ===================================================

# CoinGecko API 엔드포인트
API_URL="https://api.coingecko.com/api/v3/coins/markets"
PARAMS="vs_currency=krw&order=market_cap_desc&per_page=20&sparkline=false&price_change_percentage=1h,24h,7d"

# API 호출
RESPONSE=$(curl -s --max-time 15 \
  -H "Accept: application/json" \
  "${API_URL}?${PARAMS}")

if [ $? -ne 0 ] || [ -z "$RESPONSE" ] || [ "$RESPONSE" = "null" ]; then
  echo '{"error": "CoinGecko API 호출 실패", "coins": [], "fetched_at": ""}'
  exit 1
fi

# 에러 응답 체크
if echo "$RESPONSE" | jq -e '.status.error_code' > /dev/null 2>&1; then
  echo '{"error": "CoinGecko API 오류", "coins": [], "fetched_at": ""}'
  exit 1
fi

# JSON 변환 — 상위 20개 코인의 분석 데이터 추출
RESULTS=$(echo "$RESPONSE" | jq '[.[] | {
  id: .id,
  symbol: (.symbol | ascii_upcase),
  name: .name,
  current_price: .current_price,
  market_cap: .market_cap,
  market_cap_rank: .market_cap_rank,
  total_volume: .total_volume,
  price_change_1h: .price_change_percentage_1h_in_currency,
  price_change_24h: .price_change_percentage_24h_in_currency,
  price_change_7d: .price_change_percentage_7d_in_currency,
  high_24h: .high_24h,
  low_24h: .low_24h,
  circulating_supply: .circulating_supply,
  ath: .ath,
  ath_change_percentage: .ath_change_percentage
}]')

FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')

jq -n \
  --argjson coins "$RESULTS" \
  --arg fetched_at "$FETCHED_AT" \
  '{ coins: $coins, fetched_at: $fetched_at }'
