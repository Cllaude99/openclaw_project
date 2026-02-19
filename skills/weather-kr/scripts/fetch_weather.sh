#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 한국 주요 도시 날씨 조회 — Open-Meteo API
# API 키 불필요, 무료
# ===================================================

# 도시별 좌표 (이름,위도,경도)
CITIES=(
  "서울,37.5665,126.9780"
  "부산,35.1796,129.0756"
  "대구,35.8714,128.6014"
  "인천,37.4563,126.7052"
  "광주,35.1595,126.8526"
  "대전,36.3504,127.3845"
  "제주,33.4996,126.5312"
)

# 환경변수로 도시 제한 가능
if [ -n "${WEATHER_CITIES:-}" ]; then
  FILTER_CITIES="$WEATHER_CITIES"
else
  FILTER_CITIES=""
fi

# WMO Weather Code → 한국어 설명
weather_desc() {
  local code=$1
  case $code in
    0) echo "맑음";;
    1) echo "대체로 맑음";;
    2) echo "구름 조금";;
    3) echo "흐림";;
    45|48) echo "안개";;
    51|53|55) echo "이슬비";;
    56|57) echo "얼어붙는 이슬비";;
    61|63|65) echo "비";;
    66|67) echo "얼어붙는 비";;
    71|73|75) echo "눈";;
    77) echo "싸락눈";;
    80|81|82) echo "소나기";;
    85|86) echo "눈보라";;
    95) echo "뇌우";;
    96|99) echo "우박 동반 뇌우";;
    *) echo "알 수 없음";;
  esac
}

# JSON 결과 시작
RESULTS="["
FIRST=true

for city_data in "${CITIES[@]}"; do
  IFS=',' read -r name lat lon <<< "$city_data"

  # 필터링: 환경변수에 지정된 도시만 조회
  if [ -n "$FILTER_CITIES" ]; then
    # 영문 도시명 매핑
    case "$name" in
      "서울") eng="Seoul";;
      "부산") eng="Busan";;
      "대구") eng="Daegu";;
      "인천") eng="Incheon";;
      "광주") eng="Gwangju";;
      "대전") eng="Daejeon";;
      "제주") eng="Jeju";;
      *) eng="$name";;
    esac
    if ! echo "$FILTER_CITIES" | grep -qi "$eng"; then
      continue
    fi
  fi

  # Open-Meteo API 호출
  RESPONSE=$(curl -s --max-time 10 \
    "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,apparent_temperature,weather_code,relative_humidity_2m,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=Asia/Seoul&forecast_days=2")

  if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
    continue
  fi

  # JSON 파싱
  CURRENT_TEMP=$(echo "$RESPONSE" | jq -r '.current.temperature_2m // empty')
  FEELS_LIKE=$(echo "$RESPONSE" | jq -r '.current.apparent_temperature // empty')
  WEATHER_CODE=$(echo "$RESPONSE" | jq -r '.current.weather_code // 0')
  HUMIDITY=$(echo "$RESPONSE" | jq -r '.current.relative_humidity_2m // empty')
  WIND=$(echo "$RESPONSE" | jq -r '.current.wind_speed_10m // empty')
  TODAY_MAX=$(echo "$RESPONSE" | jq -r '.daily.temperature_2m_max[0] // empty')
  TODAY_MIN=$(echo "$RESPONSE" | jq -r '.daily.temperature_2m_min[0] // empty')
  TOMORROW_MAX=$(echo "$RESPONSE" | jq -r '.daily.temperature_2m_max[1] // empty')
  TOMORROW_MIN=$(echo "$RESPONSE" | jq -r '.daily.temperature_2m_min[1] // empty')
  PRECIP_PROB=$(echo "$RESPONSE" | jq -r '.daily.precipitation_probability_max[0] // 0')

  DESC=$(weather_desc "$WEATHER_CODE")

  # JSON 객체 생성
  CITY_JSON=$(jq -n \
    --arg name "$name" \
    --argjson current_temp "${CURRENT_TEMP:-null}" \
    --argjson feels_like "${FEELS_LIKE:-null}" \
    --argjson weather_code "${WEATHER_CODE:-0}" \
    --arg weather_desc "$DESC" \
    --argjson humidity "${HUMIDITY:-null}" \
    --argjson wind_speed "${WIND:-null}" \
    --argjson today_max "${TODAY_MAX:-null}" \
    --argjson today_min "${TODAY_MIN:-null}" \
    --argjson tomorrow_max "${TOMORROW_MAX:-null}" \
    --argjson tomorrow_min "${TOMORROW_MIN:-null}" \
    --argjson precipitation_prob "${PRECIP_PROB:-0}" \
    '{
      name: $name,
      current_temp: $current_temp,
      feels_like: $feels_like,
      weather_code: $weather_code,
      weather_desc: $weather_desc,
      humidity: $humidity,
      wind_speed: $wind_speed,
      today_max: $today_max,
      today_min: $today_min,
      tomorrow_max: $tomorrow_max,
      tomorrow_min: $tomorrow_min,
      precipitation_prob: $precipitation_prob
    }')

  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    RESULTS+=","
  fi
  RESULTS+="$CITY_JSON"
done

RESULTS+="]"

# 최종 출력
FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')

jq -n \
  --argjson cities "$RESULTS" \
  --arg fetched_at "$FETCHED_AT" \
  '{ cities: $cities, fetched_at: $fetched_at }'
