#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 한국 뉴스 RSS 수집
# API 키 불필요, 무료
# macOS bash 3 호환 (declare -A 미사용)
# ===================================================

# RSS 소스 목록 (이름|URL)
RSS_SOURCES=(
  "Google News KR|https://news.google.com/rss?hl=ko&gl=KR&ceid=KR:ko"
  "연합뉴스|https://www.yonhapnewstv.co.kr/browse/feed/"
  "매일경제|https://www.mk.co.kr/rss/30000001/"
)

MAX_ARTICLES=10

# 결과 수집
RESULTS="["
FIRST_SOURCE=true

for entry in "${RSS_SOURCES[@]}"; do
  IFS='|' read -r source_name url <<< "$entry"

  # RSS 피드 가져오기
  XML=$(curl -s --max-time 10 -L \
    -H "User-Agent: Mozilla/5.0 (compatible; OpenClaw/1.0)" \
    "$url" 2>/dev/null || echo "")

  if [ -z "$XML" ]; then
    continue
  fi

  # 아이템 파싱
  ARTICLES="["
  FIRST_ARTICLE=true
  ARTICLE_COUNT=0

  TITLES=()
  LINKS=()
  DATES=()

  # title 추출 — macOS sed 호환
  while IFS= read -r title; do
    title=$(echo "$title" | sed 's/<!\[CDATA\[//g; s/\]\]>//g; s/<[^>]*>//g' | xargs)
    [ -n "$title" ] && TITLES+=("$title")
  done < <(echo "$XML" | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' | tail -n +2 | head -n "$MAX_ARTICLES")

  # link 추출
  while IFS= read -r link; do
    link=$(echo "$link" | sed 's/<!\[CDATA\[//g; s/\]\]>//g' | xargs)
    [ -n "$link" ] && LINKS+=("$link")
  done < <(echo "$XML" | sed -n 's/.*<link>\(.*\)<\/link>.*/\1/p' | tail -n +2 | head -n "$MAX_ARTICLES")

  # pubDate 추출
  while IFS= read -r pubdate; do
    DATES+=("$pubdate")
  done < <(echo "$XML" | sed -n 's/.*<pubDate>\(.*\)<\/pubDate>.*/\1/p' | head -n "$MAX_ARTICLES")

  for i in "${!TITLES[@]}"; do
    if [ "$ARTICLE_COUNT" -ge "$MAX_ARTICLES" ]; then
      break
    fi

    ARTICLE_JSON=$(jq -n \
      --arg title "${TITLES[$i]:-}" \
      --arg link "${LINKS[$i]:-}" \
      --arg pubDate "${DATES[$i]:-}" \
      --arg source "$source_name" \
      '{ title: $title, link: $link, pubDate: $pubDate, source: $source }')

    if [ "$FIRST_ARTICLE" = true ]; then
      FIRST_ARTICLE=false
    else
      ARTICLES+=","
    fi
    ARTICLES+="$ARTICLE_JSON"
    ARTICLE_COUNT=$((ARTICLE_COUNT + 1))
  done

  ARTICLES+="]"

  SOURCE_JSON=$(jq -n \
    --arg name "$source_name" \
    --argjson articles "$ARTICLES" \
    '{ name: $name, articles: $articles }')

  if [ "$FIRST_SOURCE" = true ]; then
    FIRST_SOURCE=false
  else
    RESULTS+=","
  fi
  RESULTS+="$SOURCE_JSON"
done

RESULTS+="]"

FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')

jq -n \
  --argjson sources "$RESULTS" \
  --arg fetched_at "$FETCHED_AT" \
  '{ sources: $sources, fetched_at: $fetched_at }'
