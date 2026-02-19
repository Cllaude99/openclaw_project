---
name: finance-kr
description: USD/KRW 환율 및 KOSPI/KOSDAQ 지수를 제공합니다
emoji: 💰
requires:
  - curl
  - jq
---

# 한국 금융 정보 스킬

## 사용 시점

사용자가 다음 키워드를 언급할 때:
- "환율", "달러", "엔화", "유로", "원달러"
- "코스피", "코스닥", "주식", "주가", "KOSPI", "KOSDAQ"
- "금융", "시장"

## 데이터 수집 방법

### 환율 조회
```bash
bash skills/finance-kr/scripts/fetch_exchange.sh
```

### 주가지수 조회
```bash
bash skills/finance-kr/scripts/fetch_stocks.sh
```

### 환율 API (Open ExchangeRate)
- 엔드포인트: `https://open.er-api.com/v6/latest/USD`
- 무료, API 키 불필요
- USD 기준 → KRW, JPY, EUR, CNY 환산

### 주가지수 API (Yahoo Finance 비공식)
- 엔드포인트: `https://query1.finance.yahoo.com/v8/finance/chart/{symbol}`
- ^KS11 (KOSPI), ^KQ11 (KOSDAQ)
- 무료, API 키 불필요

### 환율 출력 형식
```json
{
  "base": "USD",
  "rates": {
    "KRW": 1350.50,
    "JPY": 156.20,
    "EUR": 0.92,
    "CNY": 7.25
  },
  "cross_rates": {
    "USD_KRW": 1350.50,
    "JPY_KRW": 8.65,
    "EUR_KRW": 1468.00,
    "CNY_KRW": 186.27
  },
  "fetched_at": "2025-01-15T09:30:00+09:00"
}
```

### 주가지수 출력 형식
```json
{
  "indices": [
    {
      "symbol": "^KS11",
      "name": "KOSPI",
      "price": 2650.25,
      "change": 15.30,
      "change_percent": 0.58,
      "prev_close": 2634.95
    }
  ],
  "fetched_at": "2025-01-15T09:30:00+09:00"
}
```

## 응답 형식

### 브리핑용
```
💰 금융
• 원/달러: 1,350.50원 (▲ 5.20원)
• 엔/원: 8.65원 | 유로/원: 1,468.00원
• KOSPI: 2,650.25 (▲ 0.58%)
• KOSDAQ: 890.15 (▼ 0.32%)
```

### 개별 조회용 (환율)
```
💰 환율 정보 (기준: 09:30 KST)

🇺🇸 USD/KRW: 1,350.50원
🇯🇵 100 JPY/KRW: 865.00원
🇪🇺 EUR/KRW: 1,468.00원
🇨🇳 CNY/KRW: 186.27원
```

## 주의사항

- 환율 데이터는 하루 1-2회 갱신 (실시간이 아님)
- Yahoo Finance API는 비공식이므로 변경될 수 있음
- 주말/공휴일에는 전일 종가를 표시
- 장중에는 실시간 지수, 장 마감 후에는 종가를 표시
- 항상 "투자 판단은 개인의 책임입니다" 면책 문구 포함
