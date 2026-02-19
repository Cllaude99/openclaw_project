#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# Hacker News Top Stories 조회
# API 키 불필요, 무료
# ===================================================

TOP_N="${HN_TOP_N:-10}"

# Top Stories ID 목록 가져오기
TOP_IDS=$(curl -s --max-time 10 \
  "https://hacker-news.firebaseio.com/v0/topstories.json")

if [ $? -ne 0 ] || [ -z "$TOP_IDS" ] || [ "$TOP_IDS" = "null" ]; then
  echo '{"error": "Hacker News API 호출 실패", "stories": []}'
  exit 1
fi

# 상위 N개 ID 추출
IDS=$(echo "$TOP_IDS" | jq -r ".[0:${TOP_N}] | .[]")

RESULTS="["
FIRST=true

for id in $IDS; do
  # 개별 아이템 조회
  ITEM=$(curl -s --max-time 5 \
    "https://hacker-news.firebaseio.com/v0/item/${id}.json")

  if [ $? -ne 0 ] || [ -z "$ITEM" ] || [ "$ITEM" = "null" ]; then
    continue
  fi

  TITLE=$(echo "$ITEM" | jq -r '.title // ""')
  URL=$(echo "$ITEM" | jq -r '.url // ""')
  SCORE=$(echo "$ITEM" | jq -r '.score // 0')
  COMMENTS=$(echo "$ITEM" | jq -r '.descendants // 0')
  BY=$(echo "$ITEM" | jq -r '.by // ""')

  STORY_JSON=$(jq -n \
    --argjson id "$id" \
    --arg title "$TITLE" \
    --arg url "$URL" \
    --argjson score "$SCORE" \
    --argjson comments "$COMMENTS" \
    --arg by "$BY" \
    --arg hn_url "https://news.ycombinator.com/item?id=${id}" \
    '{
      id: $id,
      title: $title,
      url: $url,
      score: $score,
      comments: $comments,
      by: $by,
      hn_url: $hn_url
    }')

  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    RESULTS+=","
  fi
  RESULTS+="$STORY_JSON"
done

RESULTS+="]"

FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')

jq -n \
  --argjson stories "$RESULTS" \
  --arg fetched_at "$FETCHED_AT" \
  '{ stories: $stories, fetched_at: $fetched_at }'
