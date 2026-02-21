#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# IT 기업 채용 페이지 접근성 확인
# 빅테크 + 핀테크 기업, Frontend 특화 플랫폼
# ===================================================

# 빅테크 기업 채용 페이지
declare -a BIGTECH=(
  "네이버|https://recruit.navercorp.com/rcrt/list.do"
  "카카오|https://careers.kakao.com/jobs"
  "라인|https://careers.linecorp.com/ko/jobs"
  "배달의민족|https://career.woowahan.com/"
  "당근마켓|https://about.daangn.com/jobs/"
)

# 핀테크 기업 채용 페이지
declare -a FINTECH=(
  "토스 (비바리퍼블리카)|https://toss.im/career/jobs"
  "카카오페이|https://careers.kakaopay.com/"
  "뱅크샐러드|https://banksalad.com/career"
  "두나무|https://dunamu.com/careers"
  "핀다|https://finda.co.kr/careers"
  "페이히어|https://payhere.in/careers"
  "8퍼센트|https://8percent.kr/careers"
  "핀크|https://finnq.com/careers"
  "데일리펀딩|https://dailyfunding.kr/careers"
)

# 채용 플랫폼 — Frontend 특화
declare -a PLATFORMS=(
  "원티드 Frontend|https://www.wanted.co.kr/wdlist/518/669"
  "프로그래머스|https://career.programmers.co.kr/job"
  "로켓펀치|https://www.rocketpunch.com/jobs"
)

# URL 접근성 확인 함수
check_url() {
  local name="$1"
  local url="$2"
  local category="$3"

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
    -H "User-Agent: Mozilla/5.0" \
    -L "$url" 2>/dev/null || echo "000")

  if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 400 ]; then
    STATUS="accessible"
  else
    STATUS="unavailable"
  fi

  jq -n \
    --arg name "$name" \
    --arg careers_url "$url" \
    --arg status "$STATUS" \
    --arg http_code "$HTTP_CODE" \
    --arg category "$category" \
    '{ name: $name, careers_url: $careers_url, status: $status, http_code: $http_code, category: $category }'
}

# 빅테크 기업 체크
BIGTECH_RESULTS="["
FIRST=true
for entry in "${BIGTECH[@]}"; do
  IFS='|' read -r name url <<< "$entry"
  RESULT=$(check_url "$name" "$url" "bigtech")

  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    BIGTECH_RESULTS+=","
  fi
  BIGTECH_RESULTS+="$RESULT"
done
BIGTECH_RESULTS+="]"

# 핀테크 기업 체크
FINTECH_RESULTS="["
FIRST=true
for entry in "${FINTECH[@]}"; do
  IFS='|' read -r name url <<< "$entry"
  RESULT=$(check_url "$name" "$url" "fintech")

  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    FINTECH_RESULTS+=","
  fi
  FINTECH_RESULTS+="$RESULT"
done
FINTECH_RESULTS+="]"

# 플랫폼 목록
PLATFORM_RESULTS="["
FIRST=true
for entry in "${PLATFORMS[@]}"; do
  IFS='|' read -r name url <<< "$entry"

  PLATFORM_JSON=$(jq -n \
    --arg name "$name" \
    --arg url "$url" \
    '{ name: $name, url: $url }')

  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    PLATFORM_RESULTS+=","
  fi
  PLATFORM_RESULTS+="$PLATFORM_JSON"
done
PLATFORM_RESULTS+="]"

FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')

jq -n \
  --argjson bigtech "$BIGTECH_RESULTS" \
  --argjson fintech "$FINTECH_RESULTS" \
  --argjson platforms "$PLATFORM_RESULTS" \
  --arg fetched_at "$FETCHED_AT" \
  '{ bigtech: $bigtech, fintech: $fintech, platforms: $platforms, fetched_at: $fetched_at }'
