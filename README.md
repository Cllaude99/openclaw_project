# OpenClaw 한국어 정보 비서

개인 AI 뉴스/정보 큐레이션 봇입니다. Telegram을 통해 매일 자동 브리핑을 받고, 필요할 때 개별 정보를 즉시 조회할 수 있습니다.

## 제공 정보

| 스킬 | 설명 | 데이터 소스 |
|------|------|------------|
| 🌤 날씨 | 한국 주요 도시 현재 날씨 및 예보 | Open-Meteo |
| 💰 금융 | USD/KRW 환율, KOSPI/KOSDAQ | Open ExchangeRate, Yahoo Finance |
| 🪙 암호화폐 | BTC, ETH, XRP, SOL KRW 시세 | Upbit |
| 💻 기술 뉴스 | Hacker News Top 10 한국어 요약 | Hacker News API |
| 📰 뉴스 | 한국/국제 주요 뉴스 요약 | Google News, 연합뉴스, 매일경제 RSS |
| 💼 채용 | IT 기업 채용 정보 안내 | 직접 URL |

> 모든 데이터 소스는 **무료**이며 API 키가 필요 없습니다 (Telegram, Anthropic 제외).

## 자동 브리핑 스케줄

| 시간 (KST) | 내용 |
|------------|------|
| 매일 07:00 | 날씨 + 금융 + 코인 + 뉴스 종합 |
| 매일 12:30 | IT 뉴스 + 국내 뉴스 |
| 평일 18:00 | 금융 시장 + 코인 시세 |
| 월요일 09:00 | IT 기업 채용 정보 |

## 설치

### 사전 요구사항

- Node.js 18+
- jq (`brew install jq` 또는 `apt install jq`)
- curl
- Telegram 봇 토큰 ([@BotFather](https://t.me/BotFather)에서 생성)
- Anthropic API 키 ([console.anthropic.com](https://console.anthropic.com))

### 설치 절차

```bash
# 1. 저장소 클론
git clone <repo-url> openclaw-kr
cd openclaw-kr

# 2. 설치 스크립트 실행
chmod +x setup.sh
bash setup.sh

# 3. 환경변수 설정
vi .env
# TELEGRAM_BOT_TOKEN, ANTHROPIC_API_KEY, TELEGRAM_CHAT_ID 입력

# 4. 봇 시작
openclaw start

# 5. (선택) 크론 작업 등록
bash cron/setup_cron.sh
```

### Telegram 채팅 ID 확인 방법

1. Telegram에서 봇에게 아무 메시지를 보냅니다
2. 브라우저에서 아래 URL을 열어 `chat.id`를 확인합니다:
   ```
   https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
   ```

## 사용법

Telegram에서 봇에게 메시지를 보내면 됩니다:

| 메시지 예시 | 실행 스킬 |
|------------|----------|
| "날씨" / "서울 날씨" | weather-kr |
| "환율" / "달러" / "코스피" | finance-kr |
| "코인" / "비트코인" | crypto-kr |
| "IT뉴스" / "해커뉴스" | tech-news |
| "뉴스" / "오늘 소식" | news-summary |
| "채용" / "취업" | jobs-kr |
| "브리핑" / "요약" | daily-digest |

## 프로젝트 구조

```
├── openclaw.json          # OpenClaw 설정
├── SOUL.md                # 에이전트 성격 정의
├── .env.example           # 환경변수 템플릿
├── setup.sh               # 설치 스크립트
├── skills/
│   ├── weather-kr/        # 날씨
│   ├── finance-kr/        # 환율 + 주가
│   ├── crypto-kr/         # 암호화폐
│   ├── tech-news/         # IT 뉴스
│   ├── news-summary/      # 일반 뉴스
│   ├── jobs-kr/           # 채용 정보
│   └── daily-digest/      # 종합 브리핑
└── cron/
    └── setup_cron.sh      # 크론 작업 등록
```

## 스크립트 개별 테스트

각 데이터 수집 스크립트를 독립적으로 실행하여 테스트할 수 있습니다:

```bash
# 날씨
bash skills/weather-kr/scripts/fetch_weather.sh | jq .

# 환율
bash skills/finance-kr/scripts/fetch_exchange.sh | jq .

# 주가지수
bash skills/finance-kr/scripts/fetch_stocks.sh | jq .

# 암호화폐
bash skills/crypto-kr/scripts/fetch_crypto.sh | jq .

# 기술 뉴스
bash skills/tech-news/scripts/fetch_hn.sh | jq .

# 일반 뉴스
bash skills/news-summary/scripts/fetch_news.sh | jq .

# 채용 정보
bash skills/jobs-kr/scripts/fetch_jobs.sh | jq .
```

## 커스터마이징

### 날씨 도시 변경

`.env`에서 `WEATHER_CITIES`를 수정합니다:

```env
WEATHER_CITIES=Seoul,Busan,Jeju
```

### 관심 암호화폐 변경

```env
CRYPTO_SYMBOLS=BTC,ETH,XRP,SOL,DOGE
```

### 주가지수 추가

```env
STOCK_INDICES=^KS11,^KQ11,^GSPC,^IXIC
```

## 라이선스

MIT
