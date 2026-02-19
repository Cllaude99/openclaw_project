# OpenClaw 한국어 정보 비서

개인 AI 뉴스/정보 큐레이션 봇입니다. Telegram을 통해 매일 자동 브리핑을 받고, 필요할 때 개별 정보를 즉시 조회할 수 있습니다.

## 제공 정보

| 스킬 | 설명 | 데이터 소스 |
|------|------|------------|
| 🌤 날씨 | 한국 주요 도시 현재 날씨 및 예보 | Open-Meteo |
| 💰 금융 | USD/KRW 환율, KOSPI/KOSDAQ | Open ExchangeRate, Yahoo Finance |
| 🪙 암호화폐 | BTC, ETH, XRP, SOL KRW 시세 | Upbit |
| 💻 기술 뉴스 | Hacker News Top 10 한국어 요약 | Hacker News API |
| 📰 뉴스 | 한국/국제 주요 뉴스 요약 | 연합뉴스, 매일경제 RSS |
| 💼 채용 | IT 기업 채용 정보 안내 | 직접 URL |

> 모든 데이터 소스는 **무료**이며 API 키가 필요 없습니다.

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
- AI 모델 API 접근 (Anthropic API 키 또는 Claude Code Max Plan 토큰)

### 설치 절차

```bash
# 1. 저장소 클론
git clone https://github.com/Cllaude99/openclaw_project.git
cd openclaw_project

# 2. 설치 스크립트 실행 (OpenClaw CLI + 의존성 확인)
chmod +x setup.sh
bash setup.sh

# 3. 환경변수 설정
cp .env.example .env
vi .env
# TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID 입력

# 4. OpenClaw 초기 설정
openclaw onboard --accept-risk --workspace $(pwd)

# 5. Telegram 채널 등록
openclaw channels add --channel telegram --token <YOUR_BOT_TOKEN>

# 6. AI 모델 설정 (아래 중 택 1)
#   a) Claude Code Max Plan 사용 시: onboard 과정에서 자동 연동
#   b) Anthropic API 키 사용 시: 환경변수 ANTHROPIC_API_KEY 설정
#   c) OpenRouter 무료 모델 사용 시: openclaw models scan --set-default

# 7. Gateway 설치 및 시작
openclaw gateway install
openclaw gateway start

# 8. Telegram에서 봇에게 메시지 전송 → 페어링 코드 확인
# 봇이 페어링 코드를 응답하면:
openclaw pairing approve telegram <PAIRING_CODE>

# 9. (선택) 크론 헬스체크 등록
bash cron/setup_cron.sh
```

### Telegram 봇 생성 및 채팅 ID 확인

1. [@BotFather](https://t.me/BotFather)에게 `/newbot` → 봇 이름/유저네임 입력 → 토큰 복사
2. `t.me/<봇유저네임>` 접속 → Start → "hello" 전송
3. 브라우저에서 `https://api.telegram.org/bot<TOKEN>/getUpdates` 접속
4. JSON의 `"chat":{"id":숫자}` 가 채팅 ID

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
├── openclaw.json          # 프로젝트 설정 (스킬, 크론 정의)
├── SOUL.md                # 에이전트 성격 및 포맷 규칙
├── IDENTITY.md            # 에이전트 정체성
├── AGENTS.md              # 워크스페이스 규칙
├── USER.md                # 사용자 정보
├── TOOLS.md               # 데이터 수집 스크립트 목록
├── HEARTBEAT.md           # 주기 작업 설정
├── .env.example           # 환경변수 템플릿
├── setup.sh               # 설치 스크립트
├── skills/
│   ├── weather-kr/        # 날씨 (Open-Meteo)
│   ├── finance-kr/        # 환율 + 주가 (ExchangeRate + Yahoo)
│   ├── crypto-kr/         # 암호화폐 (Upbit)
│   ├── tech-news/         # IT 뉴스 (Hacker News)
│   ├── news-summary/      # 일반 뉴스 (RSS)
│   ├── jobs-kr/           # 채용 정보
│   └── daily-digest/      # 종합 브리핑
└── cron/
    └── setup_cron.sh      # 크론 헬스체크 등록
```

## 운영

### Gateway 상태 확인
```bash
openclaw status --deep
openclaw gateway status
```

### 자동 실행 (LaunchAgent)
- Mac이 켜져 있는 한 Gateway가 자동 실행/재시작됨
- Mac 재부팅 후에도 자동 시작 (RunAtLoad)
- 잠자기(sleep) 상태에서는 동작 안 함

### 로그 확인
```bash
openclaw logs --follow                              # 실시간 로그
cat ~/.openclaw/logs/gateway.log | tail -50          # Gateway 로그
cat ~/.openclaw/logs/gateway.err.log | tail -20      # 에러 로그
```

## 스크립트 개별 테스트

```bash
bash skills/weather-kr/scripts/fetch_weather.sh | jq .
bash skills/finance-kr/scripts/fetch_exchange.sh | jq .
bash skills/finance-kr/scripts/fetch_stocks.sh | jq .
bash skills/crypto-kr/scripts/fetch_crypto.sh | jq .
bash skills/tech-news/scripts/fetch_hn.sh | jq .
bash skills/news-summary/scripts/fetch_news.sh | jq .
bash skills/jobs-kr/scripts/fetch_jobs.sh | jq .
```

## 커스터마이징

`.env` 파일에서 설정 변경:

```env
WEATHER_CITIES=Seoul,Busan,Jeju          # 날씨 조회 도시
CRYPTO_SYMBOLS=BTC,ETH,XRP,SOL,DOGE     # 관심 암호화폐
STOCK_INDICES=^KS11,^KQ11,^GSPC,^IXIC   # 주가 지수
```

## 라이선스

MIT
