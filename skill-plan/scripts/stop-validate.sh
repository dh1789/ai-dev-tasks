#!/bin/bash
# stop-validate.sh - Stop 훅에서 호출되는 자동 검증 래퍼
# 가장 최근 생성된 docs/features/ 디렉토리를 찾아 validate-plan.sh 실행

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate-plan.sh"

# validate-plan.sh 존재 확인
if [[ ! -x "$VALIDATE_SCRIPT" ]]; then
    echo "⚠️ validate-plan.sh not found: $VALIDATE_SCRIPT"
    exit 0
fi

# 가장 최근 수정된 docs/features/YYYY-MM-DD-*/PLAN.md 찾기
LATEST_PLAN=$(find docs/features -maxdepth 2 -name "PLAN.md" -type f 2>/dev/null | while read -r f; do
    echo "$(stat -f '%m' "$f" 2>/dev/null || stat -c '%Y' "$f" 2>/dev/null) $f"
done | sort -rn | head -1 | awk '{print $2}')

if [[ -z "$LATEST_PLAN" ]]; then
    echo "ℹ️ docs/features/*/PLAN.md 파일을 찾을 수 없습니다."
    exit 0
fi

FEATURE_DIR="$(dirname "$LATEST_PLAN")"
echo ""
echo "🔍 자동 검증 실행: $FEATURE_DIR"
echo ""

"$VALIDATE_SCRIPT" "$FEATURE_DIR"
