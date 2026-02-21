#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 국내 IT 기업 테크블로그 RSS 수집
# API 키 불필요, 무료
# macOS bash 3 호환
# ===================================================

# 테크블로그 RSS 소스 (이름|URL)
BLOG_SOURCES=(
  "Naver D2|https://d2.naver.com/d2.atom"
  "카카오 테크|https://tech.kakao.com/feed/"
  "토스 테크|https://toss.tech/rss.xml"
  "우아한형제들 (배민)|https://techblog.woowahan.com/feed/"
  "라인 엔지니어링|https://techblog.lycorp.co.jp/ko/feed/index.xml"
  "당근 테크|https://medium.com/feed/daangn"
  "NHN Cloud|https://meetup.nhncloud.com/rss"
  "데브시스터즈|https://tech.devsisters.com/rss.xml"
  "뱅크샐러드|https://blog.banksalad.com/rss.xml"
  "요기요 테크|https://techblog.yogiyo.co.kr/feed"
)

MAX_ARTICLES=5  # 블로그당 최대 기사 수

RESULTS="["
FIRST_SOURCE=true

for entry in "${BLOG_SOURCES[@]}"; do
  IFS='|' read -r blog_name url <<< "$entry"

  # RSS/Atom 피드 가져오기
  XML=$(curl -s --max-time 10 -L \
    -H "User-Agent: Mozilla/5.0 (compatible; OpenClaw/1.0)" \
    "$url" 2>/dev/null || echo "")

  if [ -z "$XML" ]; then
    continue
  fi

  ARTICLES="["
  FIRST_ARTICLE=true
  ARTICLE_COUNT=0

  TITLES=()
  LINKS=()
  DATES=()

  # RSS <title> 추출
  while IFS= read -r title; do
    title=$(echo "$title" | sed 's/<!\[CDATA\[//g; s/\]\]>//g; s/<[^>]*>//g' | xargs)
    [ -n "$title" ] && TITLES+=("$title")
  done < <(echo "$XML" | sed -n 's/.*<title[^>]*>\(.*\)<\/title>.*/\1/p' | tail -n +2 | head -n "$MAX_ARTICLES")

  # RSS <link> 추출 (Atom: href 속성도 처리)
  while IFS= read -r link; do
    link=$(echo "$link" | sed 's/<!\[CDATA\[//g; s/\]\]>//g; s/.*href="\([^"]*\)".*/\1/; s/<[^>]*>//g' | xargs)
    [ -n "$link" ] && LINKS+=("$link")
  done < <(echo "$XML" | sed -n 's/.*<link[^>]*>\(.*\)<\/link>.*/\1/p; s/.*<link[^>]*href="\([^"]*\)"[^>]*\/>.*/\1/p' | tail -n +2 | head -n "$MAX_ARTICLES")

  # pubDate / updated 추출
  while IFS= read -r pubdate; do
    DATES+=("$pubdate")
  done < <(echo "$XML" | sed -n 's/.*<pubDate>\(.*\)<\/pubDate>.*/\1/p; s/.*<published>\(.*\)<\/published>.*/\1/p; s/.*<updated>\(.*\)<\/updated>.*/\1/p' | head -n "$MAX_ARTICLES")

  for i in "${!TITLES[@]}"; do
    if [ "$ARTICLE_COUNT" -ge "$MAX_ARTICLES" ]; then
      break
    fi

    ARTICLE_JSON=$(jq -n \
      --arg title "${TITLES[$i]:-}" \
      --arg link "${LINKS[$i]:-}" \
      --arg pubDate "${DATES[$i]:-}" \
      --arg blog "$blog_name" \
      '{ title: $title, link: $link, pubDate: $pubDate, blog: $blog }')

    if [ "$FIRST_ARTICLE" = true ]; then
      FIRST_ARTICLE=false
    else
      ARTICLES+=","
    fi
    ARTICLES+="$ARTICLE_JSON"
    ARTICLE_COUNT=$((ARTICLE_COUNT + 1))
  done

  ARTICLES+="]"

  # 기사가 0개인 블로그는 건너뛰기
  if [ "$ARTICLE_COUNT" -eq 0 ]; then
    continue
  fi

  BLOG_JSON=$(jq -n \
    --arg name "$blog_name" \
    --argjson articles "$ARTICLES" \
    --argjson count "$ARTICLE_COUNT" \
    '{ name: $name, article_count: $count, articles: $articles }')

  if [ "$FIRST_SOURCE" = true ]; then
    FIRST_SOURCE=false
  else
    RESULTS+=","
  fi
  RESULTS+="$BLOG_JSON"
done

RESULTS+="]"

FETCHED_AT=$(TZ='Asia/Seoul' date '+%Y-%m-%dT%H:%M:%S+09:00')

jq -n \
  --argjson blogs "$RESULTS" \
  --arg fetched_at "$FETCHED_AT" \
  '{ blogs: $blogs, fetched_at: $fetched_at }'
