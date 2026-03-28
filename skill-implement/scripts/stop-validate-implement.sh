#!/bin/bash
# stop-validate-implement.sh - Stop 훅에서 호출되는 자동 검증 래퍼
# 가장 최근 생성된 docs/features/ 디렉토리를 찾아 validate-implement.sh 실행

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate-implement.sh"

# validate-implement.sh 존재 확인
if [[ ! -x "$VALIDATE_SCRIPT" ]]; then
    echo "⚠️ validate-implement.sh not found: $VALIDATE_SCRIPT"
    exit 0
fi

# 가장 최근 수정된 docs/features/YYYY-MM-DD-*/PROGRESS.md 찾기 (구현 중인 feature)
LATEST_PROGRESS=$(find docs/features -maxdepth 2 -name "PROGRESS.md" -type f 2>/dev/null | while read -r f; do
    echo "$(stat -f '%m' "$f" 2>/dev/null || stat -c '%Y' "$f" 2>/dev/null) $f"
done | sort -rn | head -1 | awk '{print $2}')

if [[ -z "$LATEST_PROGRESS" ]]; then
    # PROGRESS.md가 없으면 PLAN.md로 폴백
    LATEST_PLAN=$(find docs/features -maxdepth 2 -name "PLAN.md" -type f 2>/dev/null | while read -r f; do
        echo "$(stat -f '%m' "$f" 2>/dev/null || stat -c '%Y' "$f" 2>/dev/null) $f"
    done | sort -rn | head -1 | awk '{print $2}')

    if [[ -z "$LATEST_PLAN" ]]; then
        echo "ℹ️ docs/features/*/PROGRESS.md 또는 PLAN.md 파일을 찾을 수 없습니다."
        exit 0
    fi
    FEATURE_DIR="$(dirname "$LATEST_PLAN")"
else
    FEATURE_DIR="$(dirname "$LATEST_PROGRESS")"
fi

echo ""
echo "🔍 구현 검증 실행: $FEATURE_DIR"
echo ""

"$VALIDATE_SCRIPT" "$FEATURE_DIR" || true
