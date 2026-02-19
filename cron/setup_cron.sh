#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# OpenClaw 크론 작업 등록 스크립트
# ===================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

# --- OpenClaw 확인 ---
if ! command -v openclaw >/dev/null 2>&1; then
  echo "ERROR: openclaw이 설치되지 않았습니다. setup.sh를 먼저 실행해주세요."
  exit 1
fi

# --- .env 로드 ---
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

info "크론 작업을 등록합니다..."
echo ""

# --- 크론 작업 목록 ---
# OpenClaw의 cron 설정은 openclaw.json에 정의되어 있습니다.
# 이 스크립트는 시스템 crontab에 OpenClaw 프로세스 관리 작업을 등록합니다.

# OpenClaw 프로세스 확인 및 재시작 스크립트 생성
HEALTH_CHECK="$PROJECT_DIR/cron/health_check.sh"
cat > "$HEALTH_CHECK" << 'HEALTH_EOF'
#!/usr/bin/env bash
# OpenClaw 프로세스 헬스 체크 및 자동 재시작

PROJECT_DIR="$(dirname "$(dirname "$0")")"
LOG_FILE="$PROJECT_DIR/logs/openclaw.log"
mkdir -p "$PROJECT_DIR/logs"

# .env 로드
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

# OpenClaw 프로세스 확인
if ! pgrep -f "openclaw" > /dev/null 2>&1; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] OpenClaw 프로세스가 중단됨. 재시작 중..." >> "$LOG_FILE"
  cd "$PROJECT_DIR" && nohup openclaw start >> "$LOG_FILE" 2>&1 &
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] OpenClaw 재시작 완료 (PID: $!)" >> "$LOG_FILE"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] OpenClaw 정상 실행 중" >> "$LOG_FILE"
fi
HEALTH_EOF
chmod +x "$HEALTH_CHECK"

# --- 크론 등록 ---
CRON_MARKER="# OpenClaw Health Check"
CRON_JOB="*/5 * * * * $HEALTH_CHECK"

# 기존 크론 백업 및 업데이트
EXISTING_CRON=$(crontab -l 2>/dev/null || echo "")

if echo "$EXISTING_CRON" | grep -q "$CRON_MARKER"; then
  warn "이미 등록된 크론 작업이 있습니다. 업데이트합니다."
  # 기존 OpenClaw 관련 항목 제거
  CLEANED_CRON=$(echo "$EXISTING_CRON" | grep -v "$CRON_MARKER" | grep -v "health_check.sh")
  echo "$CLEANED_CRON
$CRON_MARKER
$CRON_JOB" | crontab -
else
  echo "$EXISTING_CRON
$CRON_MARKER
$CRON_JOB" | crontab -
fi

info "크론 작업 등록 완료!"
echo ""
info "등록된 작업:"
info "  • 헬스 체크: 5분마다 OpenClaw 프로세스 확인 및 재시작"
echo ""
info "OpenClaw 내장 크론 (openclaw.json에서 관리):"
info "  • 아침 브리핑: 매일 07:00 KST"
info "  • 점심 뉴스:   매일 12:30 KST"
info "  • 장 마감 요약: 평일 18:00 KST"
info "  • 채용 정보:   월요일 09:00 KST"
echo ""
info "현재 크론 목록 확인: crontab -l"
info "OpenClaw 크론 확인: openclaw cron list"
