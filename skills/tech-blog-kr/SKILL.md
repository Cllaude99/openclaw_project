---
name: tech-blog-kr
description: 국내 IT 기업 테크블로그의 최신 글을 RSS로 수집하여 안내합니다
emoji: 📝
requires:
  - curl
  - jq
---

# 테크블로그 스킬

## 사용 시점

사용자가 다음 키워드를 언급할 때:
- "테크블로그", "기술블로그", "기술 글", "기술 아티클"
- "네이버 D2", "카카오 테크", "토스 테크", "배민 기술블로그"
- "개발 블로그", "엔지니어링 블로그"

## 데이터 수집 방법

```bash
bash skills/tech-blog-kr/scripts/fetch_tech_blogs.sh
```

### 테크블로그 소스 (10개)

| 블로그 | RSS URL |
|--------|---------|
| Naver D2 | `d2.naver.com/d2.atom` |
| 카카오 테크 | `tech.kakao.com/feed/` |
| 토스 테크 | `toss.tech/rss.xml` |
| 우아한형제들 (배민) | `techblog.woowahan.com/feed/` |
| 라인 엔지니어링 | `techblog.lycorp.co.jp/ko/feed/index.xml` |
| 당근 테크 | `medium.com/feed/daangn` |
| NHN Cloud | `meetup.nhncloud.com/rss` |
| 데브시스터즈 | `tech.devsisters.com/rss.xml` |
| 뱅크샐러드 | `blog.banksalad.com/rss.xml` |
| 요기요 테크 | `techblog.yogiyo.co.kr/feed` |

모두 무료이며 API 키가 필요 없습니다.

### 출력 형식 (JSON)
```json
{
  "blogs": [
    {
      "name": "카카오 테크",
      "article_count": 5,
      "articles": [
        {
          "title": "카카오의 대규모 트래픽 처리 방법",
          "link": "https://tech.kakao.com/...",
          "pubDate": "Fri, 14 Feb 2025 09:00:00 +0900",
          "blog": "카카오 테크"
        }
      ]
    }
  ],
  "fetched_at": "2025-01-15T09:30:00+09:00"
}
```

## AI 처리 지침

스크립트가 반환한 RSS 데이터를 받으면:

1. **최신순 정렬**: 전체 블로그의 글을 발행일 기준으로 최신순 정렬
2. **카테고리 태깅**: Frontend, Backend, DevOps, Data, AI/ML, Mobile 등 기술 분야 태깅
3. **요약 작성**: 제목 + 핵심 기술 키워드 1줄 요약
4. **하이라이트**: 특히 주목할 글 (최신 트렌드, 유용한 실전 노하우)에 표시
5. **링크 제공**: 원문 링크를 반드시 포함

## 응답 형식

### 브리핑용 (최신 5개)
```
📝 테크블로그
1. [카카오] 대규모 트래픽 처리 전략 — Backend
   → tech.kakao.com/...
2. [토스] React Server Components 도입기 — Frontend
   → toss.tech/...
3. [배민] Kubernetes 비용 최적화 — DevOps
   → techblog.woowahan.com/...
4. [네이버] 검색 랭킹 모델 개선 — AI/ML
   → d2.naver.com/...
5. [당근] 실시간 채팅 아키텍처 — Backend
   → medium.com/daangn/...
```

**중요**: 브리핑/개별 조회 모두 각 글마다 원문 링크를 반드시 포함한다. 링크는 스크립트 JSON의 `link` 필드에서 가져온다.

### 개별 조회용 (상세)
```
📝 테크블로그 최신 글 (기준: 09:30 KST)

🔥 주목할 글
• [토스] React Server Components 도입기
  RSC 마이그레이션 과정과 성능 개선 사례
  → toss.tech/article/...

📌 최신 글

[카카오 테크]
• 대규모 트래픽 처리 전략 — Kafka + Redis 활용
  → tech.kakao.com/...

[우아한형제들]
• Kubernetes 비용 최적화 사례
  → techblog.woowahan.com/...

[Naver D2]
• 검색 랭킹 모델 A/B 테스트 방법론
  → d2.naver.com/...
  ...
```

## 주의사항

- RSS 피드는 블로그마다 갱신 주기가 다름 (주 1~2회 ~ 월 1~2회)
- Atom 형식과 RSS 형식 모두 처리 가능
- 블로그당 최대 5개 글 수집 (너무 오래된 글 방지)
- 피드 접근 불가 시 해당 블로그는 건너뛰고 나머지 정상 출력
