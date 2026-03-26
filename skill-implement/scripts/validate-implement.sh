#!/bin/bash
# validate-implement.sh - Implement Skill 결과물 검증 스크립트
# 사용법: ./validate-implement.sh <feature-directory>
# 예: ./validate-implement.sh docs/features/2026-01-08-ubuntu-offline-upgrade/

set -uo pipefail

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 결과 카운터
PASS=0
FAIL=0
WARN=0

# 결과 출력 함수
pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASS++))
}

fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAIL++))
}

warn() {
    echo -e "${YELLOW}⚠️ WARN${NC}: $1"
    ((WARN++))
}

info() {
    echo -e "${BLUE}ℹ️ INFO${NC}: $1"
}

# 사용법 출력
usage() {
    echo "사용법: $0 <feature-directory>"
    echo "예: $0 docs/features/2026-01-08-ubuntu-offline-upgrade/"
    exit 1
}

# 인자 확인
if [[ $# -lt 1 ]]; then
    usage
fi

FEATURE_DIR="$1"

echo ""
echo "========================================"
echo "Implement Skill 검증 시작"
echo "대상: $FEATURE_DIR"
echo "========================================"
echo ""

# ─────────────────────────────────────────
# 1. 필수 파일 검증
# ─────────────────────────────────────────
echo "📁 [1/7] 필수 파일 검증"
echo "────────────────────────"

# 디렉토리 존재 확인
if [[ -d "$FEATURE_DIR" ]]; then
    pass "디렉토리 존재: $FEATURE_DIR"
else
    fail "디렉토리 없음: $FEATURE_DIR"
    echo "검증 중단 - 디렉토리가 없습니다."
    exit 1
fi

# PLAN.md 존재 확인
PLAN_FILE="$FEATURE_DIR/PLAN.md"
if [[ -f "$PLAN_FILE" ]]; then
    pass "PLAN.md 존재"
else
    fail "PLAN.md 없음 (implement 스킬 실행 전제조건)"
fi

# PROGRESS.md 존재 확인
PROGRESS_FILE="$FEATURE_DIR/PROGRESS.md"
if [[ -f "$PROGRESS_FILE" ]]; then
    pass "PROGRESS.md 존재"
else
    fail "PROGRESS.md 없음 (implement 스킬이 생성해야 함)"
    echo ""
    warn "PROGRESS.md가 없으면 implement 스킬이 실행되지 않았거나 실패한 것입니다."
    echo ""
fi

echo ""

# ─────────────────────────────────────────
# 2. Phase 완료 상태 검증
# ─────────────────────────────────────────
echo "📊 [2/7] Phase 완료 상태 검증"
echo "────────────────────────"

if [[ -f "$PLAN_FILE" ]]; then
    # PLAN.md에서 총 Phase 수 확인
    TOTAL_PHASES=$(grep -cE "^###\s+Phase\s+[0-9]+:" "$PLAN_FILE" 2>/dev/null || echo "0")
    info "PLAN.md 총 Phase 수: $TOTAL_PHASES"
fi

if [[ -f "$PROGRESS_FILE" ]]; then
    # PROGRESS.md에서 완료된 Phase 수 확인
    COMPLETED_PHASES=$(grep -cE "(Phase.*완료|Phase.*✅|completed)" "$PROGRESS_FILE" 2>/dev/null | tail -1 || echo "0")
    COMPLETED_PHASES=$(echo "$COMPLETED_PHASES" | tr -d '[:space:]')

    if [[ "$COMPLETED_PHASES" -gt 0 ]]; then
        pass "완료된 Phase: $COMPLETED_PHASES개"
    else
        warn "완료된 Phase 없음"
    fi

    # 진행 중인 Phase 확인
    IN_PROGRESS=$(grep -cE "(진행 중|🔄|in.progress)" "$PROGRESS_FILE" 2>/dev/null | tail -1 || echo "0")
    IN_PROGRESS=$(echo "$IN_PROGRESS" | tr -d '[:space:]')
    if [[ "$IN_PROGRESS" -gt 0 ]]; then
        info "진행 중인 Phase 있음"
    fi

    # 실패한 Phase 확인
    FAILED_PHASES=$(grep -cE "(실패|❌|failed|error)" "$PROGRESS_FILE" 2>/dev/null || echo "0")
    if [[ "$FAILED_PHASES" -gt 0 ]]; then
        fail "실패한 Phase 있음: $FAILED_PHASES개"
    else
        pass "실패한 Phase 없음"
    fi
else
    warn "PROGRESS.md 없음 - Phase 상태 확인 불가"
fi

echo ""

# ─────────────────────────────────────────
# 3. 테스트 결과 검증
# ─────────────────────────────────────────
echo "🧪 [3/7] 테스트 결과 검증"
echo "────────────────────────"

if [[ -f "$PROGRESS_FILE" ]]; then
    # 테스트 통과 기록 확인
    if grep -qiE "(테스트.*통과|tests?.*pass|✅.*테스트|테스트.*✅)" "$PROGRESS_FILE"; then
        pass "테스트 통과 기록 존재"
    else
        warn "테스트 통과 기록 없음"
    fi

    # 테스트 실패 기록 확인
    if grep -qiE "(테스트.*실패|tests?.*fail|❌.*테스트)" "$PROGRESS_FILE"; then
        fail "테스트 실패 기록 있음"
    else
        pass "테스트 실패 기록 없음"
    fi

    # 100% 통과 확인
    if grep -qE "([0-9]+/\1|100%)" "$PROGRESS_FILE"; then
        pass "전체 테스트 통과 기록"
    fi
else
    warn "PROGRESS.md 없음 - 테스트 결과 확인 불가"
fi

echo ""

# ─────────────────────────────────────────
# 4. 커버리지 검증
# ─────────────────────────────────────────
echo "📈 [4/7] 커버리지 검증"
echo "────────────────────────"

if [[ -f "$PROGRESS_FILE" ]]; then
    # 커버리지 정보 추출
    COVERAGE=$(grep -oE "커버리지[:\s]*[0-9]+%|coverage[:\s]*[0-9]+%" "$PROGRESS_FILE" | grep -oE "[0-9]+" | head -1)

    if [[ -n "$COVERAGE" ]]; then
        if [[ "$COVERAGE" -ge 80 ]]; then
            pass "커버리지: ${COVERAGE}% (≥80% 충족)"
        else
            fail "커버리지: ${COVERAGE}% (<80% 미달)"
        fi
    else
        warn "커버리지 정보 없음"
    fi
else
    warn "PROGRESS.md 없음 - 커버리지 확인 불가"
fi

echo ""

# ─────────────────────────────────────────
# 5. 품질 검사 검증
# ─────────────────────────────────────────
echo "🔍 [5/7] 품질 검사 검증"
echo "────────────────────────"

if [[ -f "$PROGRESS_FILE" ]]; then
    # 정적 분석 결과
    if grep -qiE "(정적.*분석.*통과|lint.*pass|clang-tidy.*pass|rubocop.*pass|eslint.*pass)" "$PROGRESS_FILE"; then
        pass "정적 분석 통과 기록"
    else
        warn "정적 분석 결과 기록 없음"
    fi

    # 메모리 검사 (C++ 프로젝트)
    if grep -qiE "(valgrind|asan|memory)" "$PROGRESS_FILE"; then
        if grep -qiE "(memory.*clean|valgrind.*clean|메모리.*정상|누수.*0)" "$PROGRESS_FILE"; then
            pass "메모리 검사 통과"
        elif grep -qiE "(memory.*error|valgrind.*error|메모리.*오류|누수)" "$PROGRESS_FILE"; then
            fail "메모리 오류 기록 있음"
        fi
    fi

    # 빌드 성공
    if grep -qiE "(빌드.*성공|build.*success|빌드.*✅)" "$PROGRESS_FILE"; then
        pass "빌드 성공 기록"
    else
        warn "빌드 성공 기록 없음"
    fi
else
    warn "PROGRESS.md 없음 - 품질 검사 확인 불가"
fi

echo ""

# ─────────────────────────────────────────
# 6. 커밋 기록 검증
# ─────────────────────────────────────────
echo "💾 [6/7] 커밋 기록 검증"
echo "────────────────────────"

if [[ -f "$PROGRESS_FILE" ]]; then
    # 커밋 해시 존재 확인
    COMMIT_COUNT=$(grep -cE "(커밋|commit).*[a-f0-9]{7,}" "$PROGRESS_FILE" 2>/dev/null | tail -1 || echo "0")
    COMMIT_COUNT=$(echo "$COMMIT_COUNT" | tr -d '[:space:]')

    if [[ "$COMMIT_COUNT" -gt 0 ]]; then
        pass "커밋 기록: ${COMMIT_COUNT}개"
    else
        warn "커밋 기록 없음"
    fi

    # Phase별 커밋 확인
    if grep -qiE "phase.*커밋|phase.*commit" "$PROGRESS_FILE"; then
        pass "Phase별 커밋 기록 존재"
    fi
else
    warn "PROGRESS.md 없음 - 커밋 기록 확인 불가"
fi

# Git 로그에서 최근 커밋 확인
if command -v git &> /dev/null; then
    # feature 디렉토리 기준으로 커밋 확인
    FEATURE_NAME=$(basename "$FEATURE_DIR")
    RECENT_COMMITS=$(git log --oneline -10 2>/dev/null | grep -ci "$FEATURE_NAME" 2>/dev/null || echo "0")
    RECENT_COMMITS="${RECENT_COMMITS//[^0-9]/}"  # 숫자만 추출
    RECENT_COMMITS="${RECENT_COMMITS:-0}"  # 빈 값이면 0

    if [[ "$RECENT_COMMITS" -gt 0 ]]; then
        info "Git에서 관련 커밋 ${RECENT_COMMITS}개 발견"
    fi
fi

echo ""

# ─────────────────────────────────────────
# 7. 완료 상태 검증
# ─────────────────────────────────────────
echo "✅ [7/7] 완료 상태 검증"
echo "────────────────────────"

if [[ -f "$PROGRESS_FILE" ]]; then
    # 전체 완료 상태 확인
    if grep -qiE "(전체.*완료|모든.*phase.*완료|구현.*완료|implementation.*complete|🎉)" "$PROGRESS_FILE"; then
        pass "전체 구현 완료 상태"
    else
        warn "전체 완료 상태 미확인"
    fi

    # 최종 결과 섹션 존재
    if grep -qiE "(최종.*결과|final.*result)" "$PROGRESS_FILE"; then
        pass "최종 결과 섹션 존재"
    else
        warn "최종 결과 섹션 없음"
    fi

    # 다음 단계 안내 존재
    if grep -qiE "(다음.*단계|next.*step)" "$PROGRESS_FILE"; then
        pass "다음 단계 안내 존재"
    fi

    # Slack 알림 기록
    if grep -qiE "(slack|알림.*전송)" "$PROGRESS_FILE"; then
        pass "Slack 알림 기록 존재"
    else
        warn "Slack 알림 기록 없음"
    fi
else
    fail "PROGRESS.md 없음 - 완료 상태 확인 불가"
fi

echo ""

# ─────────────────────────────────────────
# 결과 요약
# ─────────────────────────────────────────
echo "========================================"
echo "검증 결과 요약"
echo "========================================"
echo ""
echo -e "${GREEN}✅ PASS${NC}: $PASS"
echo -e "${RED}❌ FAIL${NC}: $FAIL"
echo -e "${YELLOW}⚠️ WARN${NC}: $WARN"
echo ""

TOTAL=$((PASS + FAIL))
if [[ $TOTAL -gt 0 ]]; then
    SCORE=$((PASS * 100 / TOTAL))
    echo "점수: $SCORE/100 ($PASS/$TOTAL)"
else
    SCORE=0
    echo "점수: 측정 불가"
fi

echo ""

# 상태 판정
if [[ $FAIL -eq 0 && -f "$PROGRESS_FILE" ]]; then
    # PROGRESS.md가 있고 FAIL이 없으면 완료 여부 확인
    if grep -qiE "(전체.*완료|모든.*phase.*완료|🎉)" "$PROGRESS_FILE"; then
        echo -e "${GREEN}🎉 구현 완료! 모든 검증 통과${NC}"
        exit 0
    else
        echo -e "${YELLOW}🔄 구현 진행 중 - 아직 완료되지 않음${NC}"
        exit 0
    fi
elif [[ $FAIL -eq 0 ]]; then
    echo -e "${YELLOW}⚠️ PROGRESS.md 없음 - implement 스킬 실행 필요${NC}"
    exit 1
elif [[ $FAIL -le 2 ]]; then
    echo -e "${YELLOW}⚠️ 일부 항목 미준수 - 검토 필요${NC}"
    exit 1
else
    echo -e "${RED}❌ 다수 항목 미준수 - 문제 해결 필요${NC}"
    exit 2
fi
