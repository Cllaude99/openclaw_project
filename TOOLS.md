# TOOLS.md - 데이터 수집 스크립트

이 프로젝트의 스킬들은 `skills/` 디렉토리의 bash 스크립트로 외부 API 데이터를 수집합니다.

## 스크립트 목록

| 스크립트 | API | 용도 |
|---------|-----|------|
| `skills/weather-kr/scripts/fetch_weather.sh` | Open-Meteo | 서울/부산/제주 날씨 |
| `skills/finance-kr/scripts/fetch_exchange.sh` | Open ExchangeRate | USD/KRW 환율 |
| `skills/finance-kr/scripts/fetch_stocks.sh` | Yahoo Finance | KOSPI/KOSDAQ 지수 |
| `skills/crypto-kr/scripts/fetch_crypto.sh` | Upbit | BTC/ETH/XRP/SOL KRW 시세 |
| `skills/tech-news/scripts/fetch_hn.sh` | Hacker News | Top 10 기술 뉴스 |
| `skills/news-summary/scripts/fetch_news.sh` | 연합뉴스/매일경제 RSS | 국내 뉴스 |
| `skills/jobs-kr/scripts/fetch_jobs.sh` | 직접 URL | IT 기업 채용 페이지 |

## 환경변수 커스터마이징

```
WEATHER_CITIES=Seoul,Busan,Jeju     # 날씨 조회 도시
CRYPTO_SYMBOLS=BTC,ETH,XRP,SOL     # 관심 암호화폐
STOCK_INDICES=^KS11,^KQ11           # 주가 지수
```

## 의존성

모든 스크립트는 `curl` + `jq`만 필요하며, API 키 없이 동작합니다.
