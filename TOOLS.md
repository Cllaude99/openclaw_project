# TOOLS.md - 데이터 수집 스크립트

이 프로젝트의 스킬들은 `skills/` 디렉토리의 bash 스크립트로 외부 API 데이터를 수집합니다.

## 스크립트 목록

| 스크립트 | API | 용도 |
|---------|-----|------|
| `skills/crypto-kr/scripts/fetch_crypto.sh` | Upbit | BTC/ETH 등 10개 코인 KRW 시세 |
| `skills/crypto-kr/scripts/fetch_crypto_analysis.sh` | CoinGecko | 시가총액·변동률·거래량 분석 데이터 |
| `skills/stocks-kr/scripts/fetch_stocks.sh` | Yahoo Finance | 국내 15종목 + 해외 10종목 + 지수 4개 |
| `skills/tech-news/scripts/fetch_hn.sh` | Hacker News | Top 10 기술 뉴스 |
| `skills/tech-blog-kr/scripts/fetch_tech_blogs.sh` | RSS/Atom | 국내 10개 테크블로그 최신 글 |
| `skills/news-summary/scripts/fetch_news.sh` | 연합뉴스/매일경제/한경/조선 RSS | 국내 뉴스 (5개 소스) |
| `skills/jobs-kr/scripts/fetch_jobs.sh` | 직접 URL | 빅테크+핀테크 채용 페이지 |

## 환경변수 커스터마이징

```
CRYPTO_SYMBOLS=BTC,ETH,XRP,SOL,DOGE,ADA,AVAX,DOT,LINK,POL   # 관심 암호화폐
```

## 의존성

모든 스크립트는 `curl` + `jq`만 필요하며, API 키 없이 동작합니다.
