---
name: tech-news
description: Hacker News 인기 글 Top 10을 한국어로 요약합니다
emoji: 💻
requires:
  - curl
  - jq
---

# IT/기술 뉴스 스킬

## 사용 시점

사용자가 다음 키워드를 언급할 때:
- "기술 뉴스", "IT 뉴스", "테크 뉴스", "해커뉴스", "HN"
- "개발 소식", "프로그래밍 뉴스"

## 데이터 수집 방법

```bash
bash skills/tech-news/scripts/fetch_hn.sh
```

### Hacker News API
- Top Stories: `https://hacker-news.firebaseio.com/v0/topstories.json`
- 개별 아이템: `https://hacker-news.firebaseio.com/v0/item/{id}.json`
- 무료, API 키 불필요

### 출력 형식 (JSON)
```json
{
  "stories": [
    {
      "id": 12345678,
      "title": "Show HN: A new programming language",
      "url": "https://example.com/article",
      "score": 350,
      "comments": 120,
      "by": "username",
      "hn_url": "https://news.ycombinator.com/item?id=12345678"
    }
  ],
  "fetched_at": "2025-01-15T09:30:00+09:00"
}
```

## AI 처리 지침

스크립트가 반환한 영문 데이터를 받으면:

1. **제목 번역**: 각 글의 title을 자연스러운 한국어로 번역
2. **카테고리 분류**: AI/ML, 웹개발, 보안, 언어/도구, 스타트업, 기타
3. **간단 요약**: URL 기반으로 핵심 내용 1-2줄 요약 (URL이 없으면 제목 기반)
4. **주목도 표시**: score 350+ 🔥, 200+ ⭐, 100+ 📌

## 응답 형식

### 브리핑용 (Top 5)
```
💻 기술 뉴스 (Hacker News)
1. 🔥 새로운 프로그래밍 언어 출시 — 타입 안전성 강화 (⬆350 💬120)
   🔗 원문 | 💬 HN
2. ⭐ AI 코드 리뷰 도구 비교 분석 (⬆250 💬85)
   🔗 원문 | 💬 HN
3. ⭐ PostgreSQL 17의 주요 변경사항 (⬆210 💬60)
   🔗 원문 | 💬 HN
4. 📌 구글, 새 오픈소스 프로젝트 공개 (⬆150 💬45)
   🔗 원문 | 💬 HN
5. 📌 2025년 프론트엔드 트렌드 전망 (⬆130 💬90)
   🔗 원문 | 💬 HN
```

**중요**: 브리핑/개별 조회 모두 각 기사마다 원문 URL과 HN 토론 URL을 반드시 포함한다.

### 개별 조회용 (Top 10, 상세)
```
💻 기술 뉴스 Top 10 (기준: 09:30 KST)

1. 🔥 새로운 프로그래밍 언어 출시
   타입 안전성과 메모리 관리를 동시에 해결하는 새 언어가 공개됨
   ⬆350 💬120 | 🔗 링크 | 💬 HN 토론

2. ⭐ AI 코드 리뷰 도구 비교 분석
   GitHub Copilot, Cursor 등 5개 도구 실사용 비교
   ⬆250 💬85 | 🔗 링크 | 💬 HN 토론
   ...
```

## 주의사항

- Hacker News API는 요청 제한이 느슨하나 Top 10만 조회하여 최소화
- 영문 제목은 반드시 한국어로 번역
- HN 토론 링크와 원문 링크를 모두 제공
- 동일 뉴스가 반복되지 않도록 이전 브리핑과 비교 가능
