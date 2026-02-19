#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 환율 조회 — Open ExchangeRate API
# API 키 불필요, 무료
# ===================================================

# API 호출
RESPONSE=$(curl -s --max-time 10 \
  "https://open.er-api.com/v6/latest/USD")

if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
  echo '{"error": "ExchangeRate API 호출 실패"}'
  exit 1
fi

# 결과 확인
RESULT=$(echo "$RESPONSE" | jq -r '.result // "error"')
if [ "$RESULT" != "success" ]; then
  echo '{"error": "ExchangeRate API 응답 오류"}'
  exit 1
fi

# 주요 환율 추출
KRW=$(echo "$RESPONSE" | jq -r '.rates.KRW // 0')
JPY=$(echo "$RESPONSE" | jq -r '.rates.JPY // 0')
EUR=$(echo "$RESPONSE" | jq -r '.rates.EUR // 0')
CNY=$(echo "$RESPONSE" | jq -r '.rates.CNY // 0')
GBP=$(echo "$RESPONSE" | jq -r '.rates.GBP // 0')

# 크로스 환율 계산 (1 외화 = ? 원)
if [ "$JPY" != "0" ]; then
  JPY_KRW=$(echo "scale=2; $KRW / $JPY * 100" | bc)
else
  JPY_KRW="0"
fi

if [ "$EUR" != "0" ]; then
  EUR_KRW=$(echo "scale=2; $KRW / $EUR" | bc)
else
  EUR_KRW="0"
fi

if [ "$CNY" != "0" ]; then
  CNY_KRW=$(echo "scale=2; $KRW / $CNY" | bc)
else
  CNY_KRW="0"
fi

if [ "$GBP" != "0" ]; then
  GBP_KRW=$(echo "scale=2; $KRW / $GBP" | bc)
else
  GBP_KRW="0"
fi

FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')
UPDATE_TIME=$(echo "$RESPONSE" | jq -r '.time_last_update_utc // ""')

jq -n \
  --arg base "USD" \
  --argjson krw "$KRW" \
  --argjson jpy "$JPY" \
  --argjson eur "$EUR" \
  --argjson cny "$CNY" \
  --argjson gbp "$GBP" \
  --argjson usd_krw "$KRW" \
  --argjson jpy_krw "$JPY_KRW" \
  --argjson eur_krw "$EUR_KRW" \
  --argjson cny_krw "$CNY_KRW" \
  --argjson gbp_krw "$GBP_KRW" \
  --arg fetched_at "$FETCHED_AT" \
  --arg api_update "$UPDATE_TIME" \
  '{
    base: $base,
    rates: { KRW: $krw, JPY: $jpy, EUR: $eur, CNY: $cny, GBP: $gbp },
    cross_rates: {
      USD_KRW: $usd_krw,
      JPY_100_KRW: $jpy_krw,
      EUR_KRW: $eur_krw,
      CNY_KRW: $cny_krw,
      GBP_KRW: $gbp_krw
    },
    fetched_at: $fetched_at,
    api_update: $api_update
  }'
