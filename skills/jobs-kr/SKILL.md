---
name: jobs-kr
description: 한국 주요 IT 기업의 채용 정보를 수집하여 안내합니다
emoji: 💼
requires:
  - curl
---

# IT 기업 채용 정보 스킬

## 사용 시점

사용자가 다음 키워드를 언급할 때:
- "채용", "취업", "공고", "구인", "이직"
- 특정 회사명 + 채용 (예: "네이버 채용", "카카오 채용")

## 데이터 수집 방법

```bash
bash skills/jobs-kr/scripts/fetch_jobs.sh
```

### 채용 페이지 소스

| 회사 | 채용 페이지 |
|------|------------|
| 네이버 | https://recruit.navercorp.com/rcrt/list.do |
| 카카오 | https://careers.kakao.com/jobs |
| 라인 | https://careers.linecorp.com/ko/jobs |
| 쿠팡 | https://www.coupang.jobs/kr/jobs/ |
| 배달의민족 | https://career.woowahan.com/ |
| 토스 | https://toss.im/career/jobs |
| 당근마켓 | https://about.daangn.com/jobs/ |

### 출력 형식 (JSON)
```json
{
  "companies": [
    {
      "name": "네이버",
      "careers_url": "https://recruit.navercorp.com/rcrt/list.do",
      "status": "accessible",
      "note": ""
    }
  ],
  "fetched_at": "2025-01-15T09:30:00+09:00"
}
```

## AI 처리 지침

이 스킬은 채용 페이지의 접근성을 확인하고, AI가 해당 정보를 기반으로 안내합니다.

1. **URL 제공**: 각 회사의 채용 페이지 링크를 직접 제공
2. **카테고리 분류**: 개발, 데이터, AI/ML, 인프라, 프론트엔드, 백엔드 등
3. **추가 리소스**: 원티드, 로켓펀치, 프로그래머스 등 채용 플랫폼 안내
4. **트렌드**: 현재 수요가 많은 직군 안내

## 응답 형식

### 주간 채용 브리핑
```
💼 IT 채용 정보 (이번 주)

🏢 주요 기업 채용 페이지
• 네이버: recruit.navercorp.com
• 카카오: careers.kakao.com
• 라인: careers.linecorp.com
• 쿠팡: coupang.jobs
• 배민: career.woowahan.com
• 토스: toss.im/career
• 당근: about.daangn.com/jobs

📋 채용 플랫폼
• 원티드: wanted.co.kr
• 로켓펀치: rocketpunch.com
• 프로그래머스: programmers.co.kr

💡 채용 페이지를 직접 방문하여 최신 공고를 확인하세요.
```

### 개별 조회용
```
💼 채용 정보 (기준: 09:30 KST)

특정 회사나 직군을 말씀하시면 해당 채용 페이지를 안내해드립니다.
현재 확인 가능한 채용 페이지 목록:

[회사별 링크 + 접근 상태]
```

## 주의사항

- 채용 페이지는 구조가 자주 변경되므로 URL 접근성만 확인
- 구체적인 포지션 정보는 AI가 웹 검색으로 보충 가능
- "채용 정보는 각 회사 공식 페이지에서 최종 확인하세요" 안내 포함
- 급여 정보는 공개된 경우에만 언급
