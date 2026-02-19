#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# OpenClaw 한국어 정보 비서 — 설치 스크립트
# ===================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# --- 1. 의존성 확인 ---
info "의존성을 확인합니다..."

command -v node  >/dev/null 2>&1 || error "Node.js가 필요합니다. https://nodejs.org 에서 설치해주세요."
command -v npm   >/dev/null 2>&1 || error "npm이 필요합니다."
command -v curl  >/dev/null 2>&1 || error "curl이 필요합니다."
command -v jq    >/dev/null 2>&1 || error "jq가 필요합니다. brew install jq 또는 apt install jq"

NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VER" -lt 18 ]; then
  error "Node.js 18 이상이 필요합니다. 현재: $(node -v)"
fi

info "Node.js $(node -v), npm $(npm -v), curl, jq — 확인 완료"

# --- 2. OpenClaw 설치 확인 ---
if ! command -v openclaw >/dev/null 2>&1; then
  info "OpenClaw를 설치합니다..."
  npm install -g openclaw
else
  info "OpenClaw 이미 설치됨: $(openclaw --version 2>/dev/null || echo 'unknown')"
fi

# --- 3. 환경 변수 파일 ---
if [ ! -f "$SCRIPT_DIR/.env" ]; then
  cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
  warn ".env 파일이 생성되었습니다. 필수 값을 입력해주세요:"
  warn "  $SCRIPT_DIR/.env"
  warn "  → TELEGRAM_BOT_TOKEN"
  warn "  → ANTHROPIC_API_KEY"
  warn "  → TELEGRAM_CHAT_ID"
fi

# --- 4. 스크립트 실행 권한 ---
info "스크립트에 실행 권한을 부여합니다..."
find "$SCRIPT_DIR/skills" -name "*.sh" -exec chmod +x {} \;
chmod +x "$SCRIPT_DIR/cron/setup_cron.sh"

# --- 5. 스크립트 동작 검증 ---
info "데이터 수집 스크립트를 검증합니다..."

SCRIPTS=(
  "skills/weather-kr/scripts/fetch_weather.sh"
  "skills/crypto-kr/scripts/fetch_crypto.sh"
  "skills/finance-kr/scripts/fetch_exchange.sh"
  "skills/finance-kr/scripts/fetch_stocks.sh"
  "skills/tech-news/scripts/fetch_hn.sh"
  "skills/news-summary/scripts/fetch_news.sh"
)

PASS=0
FAIL=0
for script in "${SCRIPTS[@]}"; do
  FULL="$SCRIPT_DIR/$script"
  if [ -f "$FULL" ]; then
    if bash "$FULL" >/dev/null 2>&1; then
      info "  ✓ $script"
      PASS=$((PASS + 1))
    else
      warn "  ✗ $script (실행 실패 — 네트워크 문제일 수 있음)"
      FAIL=$((FAIL + 1))
    fi
  else
    warn "  - $script (파일 없음)"
    FAIL=$((FAIL + 1))
  fi
done

info "검증 완료: ${PASS}개 성공, ${FAIL}개 실패"

# --- 6. 설치 완료 ---
echo ""
info "=============================="
info " OpenClaw 한국어 정보 비서 설치 완료!"
info "=============================="
echo ""
info "다음 단계:"
info "  1. .env 파일에 API 키를 입력하세요"
info "  2. openclaw deploy  — 스킬 배포"
info "  3. openclaw start   — 봇 시작"
info "  4. bash cron/setup_cron.sh  — 크론 작업 등록"
echo ""
