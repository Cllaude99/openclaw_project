---
name: jobs-kr
description: 한국 빅테크 + 핀테크 기업의 Frontend 중심 채용 정보를 안내합니다
emoji: 💼
requires:
  - curl
---

# IT 기업 채용 정보 스킬

## 사용 시점

사용자가 다음 키워드를 언급할 때:
- "채용", "취업", "공고", "구인", "이직"
- "프론트엔드", "Frontend", "React", "Next.js", "TypeScript"
- 특정 회사명 + 채용 (예: "토스 채용", "카카오 채용")
- "핀테크 채용", "핀테크 이직"

## 데이터 수집 방법

```bash
bash skills/jobs-kr/scripts/fetch_jobs.sh
```

### 채용 페이지 소스

#### 빅테크 기업
| 회사 | 채용 페이지 |
|------|------------|
| 네이버 | https://recruit.navercorp.com/rcrt/list.do |
| 카카오 | https://careers.kakao.com/jobs |
| 라인 | https://careers.linecorp.com/ko/jobs |
| 배달의민족 | https://career.woowahan.com/ |
| 당근마켓 | https://about.daangn.com/jobs/ |

#### 핀테크 기업
| 회사 | 채용 페이지 |
|------|------------|
| 토스 (비바리퍼블리카) | https://toss.im/career/jobs |
| 카카오페이 | https://careers.kakaopay.com/ |
| 뱅크샐러드 | https://banksalad.com/career |
| 두나무 | https://dunamu.com/careers |
| 핀다 | https://finda.co.kr/careers |
| 페이히어 | https://payhere.in/careers |
| 8퍼센트 | https://8percent.kr/careers |
| 핀크 | https://finnq.com/careers |
| 데일리펀딩 | https://dailyfunding.kr/careers |

#### 채용 플랫폼 (Frontend 특화)
| 플랫폼 | URL |
|--------|-----|
| 원티드 Frontend | https://www.wanted.co.kr/wdlist/518/669 |
| 프로그래머스 | https://career.programmers.co.kr/job |
| 로켓펀치 | https://www.rocketpunch.com/jobs |

### 출력 형식 (JSON)
```json
{
  "bigtech": [
    {
      "name": "네이버",
      "careers_url": "https://recruit.navercorp.com/rcrt/list.do",
      "status": "accessible",
      "http_code": "200",
      "category": "bigtech"
    }
  ],
  "fintech": [
    {
      "name": "토스 (비바리퍼블리카)",
      "careers_url": "https://toss.im/career/jobs",
      "status": "accessible",
      "http_code": "200",
      "category": "fintech"
    }
  ],
  "platforms": [
    { "name": "원티드 Frontend", "url": "https://www.wanted.co.kr/wdlist/518/669" }
  ],
  "fetched_at": "2025-01-15T09:30:00+09:00"
}
```

## AI 처리 지침

1. **Frontend 포지션 우선**: "Frontend", "프론트엔드", "React", "Next.js", "TypeScript" 키워드 중심으로 안내
2. **빅테크/핀테크 구분**: 카테고리별 별도 섹션으로 안내
3. **클릭 가능한 링크 필수**: 모든 채용 페이지 URL을 클릭 가능한 전체 URL로 제공 (축약하지 않음)
4. **플랫폼 안내**: Frontend 특화 검색 URL도 전체 링크로 안내
5. **트렌드**: 현재 수요가 많은 직군/기술 스택 안내

## 응답 형식

### 주간 채용 브리핑
```
💼 IT 채용 정보 (이번 주)

🏢 빅테크 기업
• 네이버: https://recruit.navercorp.com/rcrt/list.do
• 카카오: https://careers.kakao.com/jobs
• 라인: https://careers.linecorp.com/ko/jobs
• 배민: https://career.woowahan.com/
• 당근: https://about.daangn.com/jobs/

🏦 핀테크 기업
• 토스: https://toss.im/career/jobs
• 카카오페이: https://careers.kakaopay.com/
• 뱅크샐러드: https://banksalad.com/career
• 두나무: https://dunamu.com/careers
• 핀다: https://finda.co.kr/careers
• 페이히어: https://payhere.in/careers
• 8퍼센트: https://8percent.kr/careers
• 핀크: https://finnq.com/careers
• 데일리펀딩: https://dailyfunding.kr/careers

📋 Frontend 채용 플랫폼
• 원티드 Frontend: https://www.wanted.co.kr/wdlist/518/669
• 프로그래머스: https://career.programmers.co.kr/job
• 로켓펀치: https://www.rocketpunch.com/jobs

💡 채용 페이지를 직접 방문하여 최신 공고를 확인하세요.
```

**중요**: 모든 URL은 https:// 포함 전체 주소로 제공하여 클릭 가능하도록 한다. 절대 축약하지 않는다.

### 개별 조회용
```
💼 채용 정보 (기준: 09:30 KST)

특정 회사나 직군을 말씀하시면 해당 채용 페이지를 안내해드립니다.
Frontend / React / Next.js / TypeScript 포지션을 중점적으로 안내합니다.

[회사별 링크 + 접근 상태]
```

## 주의사항

- 채용 페이지는 구조가 자주 변경되므로 URL 접근성만 확인
- 구체적인 포지션 정보는 AI가 웹 검색으로 보충 가능
- "채용 정보는 각 회사 공식 페이지에서 최종 확인하세요" 안내 포함
- 급여 정보는 공개된 경우에만 언급
