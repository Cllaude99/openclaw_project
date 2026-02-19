#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# IT 기업 채용 페이지 접근성 확인
# ===================================================

# 회사별 채용 페이지
declare -a COMPANIES=(
  "네이버|https://recruit.navercorp.com/rcrt/list.do"
  "카카오|https://careers.kakao.com/jobs"
  "라인|https://careers.linecorp.com/ko/jobs"
  "쿠팡|https://www.coupang.jobs/kr/jobs/"
  "배달의민족|https://career.woowahan.com/"
  "토스|https://toss.im/career/jobs"
  "당근마켓|https://about.daangn.com/jobs/"
)

# 채용 플랫폼
declare -a PLATFORMS=(
  "원티드|https://www.wanted.co.kr/jobsfeed"
  "로켓펀치|https://www.rocketpunch.com/jobs"
  "프로그래머스|https://career.programmers.co.kr/"
)

RESULTS="["
FIRST=true

for entry in "${COMPANIES[@]}"; do
  IFS='|' read -r name url <<< "$entry"

  # URL 접근 가능 여부 확인 (HEAD 요청)
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
    -H "User-Agent: Mozilla/5.0" \
    -L "$url" 2>/dev/null || echo "000")

  if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 400 ]; then
    STATUS="accessible"
  else
    STATUS="unavailable"
  fi

  COMPANY_JSON=$(jq -n \
    --arg name "$name" \
    --arg careers_url "$url" \
    --arg status "$STATUS" \
    --arg http_code "$HTTP_CODE" \
    '{ name: $name, careers_url: $careers_url, status: $status, http_code: $http_code }')

  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    RESULTS+=","
  fi
  RESULTS+="$COMPANY_JSON"
done

RESULTS+="]"

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
  --argjson companies "$RESULTS" \
  --argjson platforms "$PLATFORM_RESULTS" \
  --arg fetched_at "$FETCHED_AT" \
  '{ companies: $companies, platforms: $platforms, fetched_at: $fetched_at }'
