#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 암호화폐 KRW 시세 조회 — Upbit API
# API 키 불필요, 무료
# ===================================================

# 기본 코인 목록
SYMBOLS="${CRYPTO_SYMBOLS:-BTC,ETH,XRP,SOL}"

# 코인 한국어 이름 매핑
coin_name() {
  case $1 in
    BTC) echo "비트코인";;
    ETH) echo "이더리움";;
    XRP) echo "리플";;
    SOL) echo "솔라나";;
    DOGE) echo "도지코인";;
    ADA) echo "에이다";;
    AVAX) echo "아발란체";;
    DOT) echo "폴카닷";;
    MATIC) echo "폴리곤";;
    LINK) echo "체인링크";;
    *) echo "$1";;
  esac
}

# 마켓 코드 생성 (KRW-BTC,KRW-ETH,...)
MARKETS=""
IFS=',' read -ra COIN_ARRAY <<< "$SYMBOLS"
for coin in "${COIN_ARRAY[@]}"; do
  coin=$(echo "$coin" | tr -d ' ')
  if [ -n "$MARKETS" ]; then
    MARKETS+=","
  fi
  MARKETS+="KRW-${coin}"
done

# Upbit API 호출
RESPONSE=$(curl -s --max-time 10 \
  "https://api.upbit.com/v1/ticker?markets=${MARKETS}")

if [ $? -ne 0 ] || [ -z "$RESPONSE" ] || [ "$RESPONSE" = "null" ]; then
  echo '{"error": "Upbit API 호출 실패", "coins": [], "fetched_at": ""}'
  exit 1
fi

# JSON 파싱 및 변환
RESULTS="["
FIRST=true

for coin in "${COIN_ARRAY[@]}"; do
  coin=$(echo "$coin" | tr -d ' ')
  MARKET="KRW-${coin}"

  # 해당 코인 데이터 추출
  COIN_DATA=$(echo "$RESPONSE" | jq -r --arg m "$MARKET" '.[] | select(.market == $m)')

  if [ -z "$COIN_DATA" ]; then
    continue
  fi

  PRICE=$(echo "$COIN_DATA" | jq -r '.trade_price')
  CHANGE=$(echo "$COIN_DATA" | jq -r '.change')
  CHANGE_RATE=$(echo "$COIN_DATA" | jq -r '.signed_change_rate')
  CHANGE_PRICE=$(echo "$COIN_DATA" | jq -r '.signed_change_price')
  HIGH=$(echo "$COIN_DATA" | jq -r '.high_price')
  LOW=$(echo "$COIN_DATA" | jq -r '.low_price')
  VOLUME=$(echo "$COIN_DATA" | jq -r '.acc_trade_volume_24h')
  TIMESTAMP=$(echo "$COIN_DATA" | jq -r '.timestamp')

  NAME=$(coin_name "$coin")

  COIN_JSON=$(jq -n \
    --arg symbol "$coin" \
    --arg name "$NAME" \
    --argjson price "$PRICE" \
    --arg change "$CHANGE" \
    --argjson change_rate "$CHANGE_RATE" \
    --argjson change_price "$CHANGE_PRICE" \
    --argjson high_24h "$HIGH" \
    --argjson low_24h "$LOW" \
    --arg volume_24h "$VOLUME" \
    --arg timestamp "$TIMESTAMP" \
    '{
      symbol: $symbol,
      name: $name,
      price: $price,
      change: $change,
      change_rate: $change_rate,
      change_price: $change_price,
      high_24h: $high_24h,
      low_24h: $low_24h,
      volume_24h: $volume_24h,
      timestamp: $timestamp
    }')

  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    RESULTS+=","
  fi
  RESULTS+="$COIN_JSON"
done

RESULTS+="]"

FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')

jq -n \
  --argjson coins "$RESULTS" \
  --arg fetched_at "$FETCHED_AT" \
  '{ coins: $coins, fetched_at: $fetched_at }'
