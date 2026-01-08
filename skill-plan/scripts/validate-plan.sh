#!/bin/bash
# validate-plan.sh - Plan Skill 결과물 검증 스크립트
# 사용법: ./validate-plan.sh <feature-directory>
# 예: ./validate-plan.sh docs/features/2026-01-08-ubuntu-offline-upgrade/

set -uo pipefail
# set -e 제거: grep 등의 명령이 실패해도 스크립트 계속 실행

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
echo "Plan Skill 검증 시작"
echo "대상: $FEATURE_DIR"
echo "========================================"
echo ""

# ─────────────────────────────────────────
# 1. 파일 위치 검증
# ─────────────────────────────────────────
echo "📁 [1/6] 파일 위치 검증"
echo "────────────────────────"

# 디렉토리 존재 확인
if [[ -d "$FEATURE_DIR" ]]; then
    pass "디렉토리 존재: $FEATURE_DIR"
else
    fail "디렉토리 없음: $FEATURE_DIR"
    echo "검증 중단 - 디렉토리가 없습니다."
    exit 1
fi

# 디렉토리 경로 패턴 확인
if [[ "$FEATURE_DIR" =~ docs/features/[0-9]{4}-[0-9]{2}-[0-9]{2}- ]]; then
    pass "디렉토리 경로 패턴 준수 (docs/features/YYYY-MM-DD-*)"
else
    fail "디렉토리 경로 패턴 미준수 (expected: docs/features/YYYY-MM-DD-feature-name/)"
fi

# tasks/ 디렉토리 사용 여부
if [[ "$FEATURE_DIR" =~ ^tasks/ ]]; then
    fail "tasks/ 디렉토리 사용 금지 (docs/features/ 사용해야 함)"
fi

# PRD.md 존재 확인
PRD_FILE="$FEATURE_DIR/PRD.md"
if [[ -f "$PRD_FILE" ]]; then
    pass "PRD.md 존재"
else
    fail "PRD.md 없음"
fi

# PLAN.md 존재 확인
PLAN_FILE="$FEATURE_DIR/PLAN.md"
if [[ -f "$PLAN_FILE" ]]; then
    pass "PLAN.md 존재"
else
    fail "PLAN.md 없음"
    echo "검증 중단 - PLAN.md가 없습니다."
    exit 1
fi

echo ""

# ─────────────────────────────────────────
# 2. Phase 규격 검증
# ─────────────────────────────────────────
echo "📊 [2/6] Phase 규격 검증"
echo "────────────────────────"

# Phase 개수 확인 (### Phase N: 패턴)
PHASE_COUNT=$(grep -cE "^###\s+Phase\s+[0-9]+:" "$PLAN_FILE" 2>/dev/null || echo "0")

if [[ "$PHASE_COUNT" -ge 3 && "$PHASE_COUNT" -le 7 ]]; then
    pass "Phase 개수: $PHASE_COUNT (3-7개 범위 내)"
elif [[ "$PHASE_COUNT" -lt 3 ]]; then
    fail "Phase 개수 부족: $PHASE_COUNT (최소 3개 필요)"
elif [[ "$PHASE_COUNT" -gt 7 ]]; then
    fail "Phase 개수 초과: $PHASE_COUNT (최대 7개)"
fi

echo ""

# ─────────────────────────────────────────
# 3. TDD 구조 검증
# ─────────────────────────────────────────
echo "🔄 [3/6] TDD 구조 검증"
echo "────────────────────────"

# RED 단계 확인
RED_COUNT=$(grep -cE "🔴\s*(RED|테스트)" "$PLAN_FILE" 2>/dev/null || echo "0")
if [[ "$RED_COUNT" -ge 1 ]]; then
    pass "🔴 RED 단계 존재 ($RED_COUNT개)"
else
    fail "🔴 RED 단계 없음 (테스트 먼저 작성 단계 필요)"
fi

# GREEN 단계 확인
GREEN_COUNT=$(grep -cE "🟢\s*(GREEN|구현|통과)" "$PLAN_FILE" 2>/dev/null || echo "0")
if [[ "$GREEN_COUNT" -ge 1 ]]; then
    pass "🟢 GREEN 단계 존재 ($GREEN_COUNT개)"
else
    fail "🟢 GREEN 단계 없음 (구현 단계 필요)"
fi

# REFACTOR 단계 확인
REFACTOR_COUNT=$(grep -cE "🔵\s*(REFACTOR|리팩토링|리팩터)" "$PLAN_FILE" 2>/dev/null || echo "0")
if [[ "$REFACTOR_COUNT" -ge 1 ]]; then
    pass "🔵 REFACTOR 단계 존재 ($REFACTOR_COUNT개)"
else
    warn "🔵 REFACTOR 단계 없음 (권장: 코드 품질 개선 단계)"
fi

echo ""

# ─────────────────────────────────────────
# 4. PRD 필수 섹션 검증
# ─────────────────────────────────────────
echo "📝 [4/6] PRD 필수 섹션 검증"
echo "────────────────────────"

if [[ -f "$PRD_FILE" ]]; then
    # 사용자 시나리오 섹션
    if grep -qiE "(사용자\s*시나리오|user\s*scenario|use\s*case)" "$PRD_FILE"; then
        pass "사용자 시나리오 섹션 존재"
    else
        fail "사용자 시나리오 섹션 없음"
    fi

    # 성공 지표 섹션
    if grep -qiE "(성공\s*지표|success\s*metric|KPI|측정)" "$PRD_FILE"; then
        pass "성공 지표 섹션 존재"
    else
        fail "성공 지표 섹션 없음"
    fi
else
    fail "PRD.md 파일 없음 - PRD 섹션 검증 불가"
fi

echo ""

# ─────────────────────────────────────────
# 5. PLAN 필수 섹션 검증
# ─────────────────────────────────────────
echo "📋 [5/6] PLAN 필수 섹션 검증"
echo "────────────────────────"

# 헤더 메타데이터
if grep -qE "^\*\*Status\*\*:" "$PLAN_FILE"; then
    pass "헤더 메타데이터: Status"
else
    fail "헤더 메타데이터 누락: Status"
fi

if grep -qE "(\*\*생성일\*\*|Created|Date):" "$PLAN_FILE"; then
    pass "헤더 메타데이터: 생성일"
else
    warn "헤더 메타데이터 누락: 생성일"
fi

if grep -qiE "(프로젝트\s*타입|project\s*type)" "$PLAN_FILE"; then
    pass "헤더 메타데이터: 프로젝트 타입"
else
    warn "헤더 메타데이터 누락: 프로젝트 타입"
fi

# Quality Gate
if grep -qiE "(quality\s*gate|품질\s*게이트)" "$PLAN_FILE"; then
    pass "Quality Gate 섹션 존재"
else
    fail "Quality Gate 섹션 없음"
fi

# 롤백 전략
if grep -qiE "(롤백|rollback)" "$PLAN_FILE"; then
    pass "롤백 전략 섹션 존재"
else
    fail "롤백 전략 섹션 없음"
fi

# 진행 상황
if grep -qiE "(진행\s*상황|progress|완료율)" "$PLAN_FILE"; then
    pass "진행 상황 추적 섹션 존재"
else
    warn "진행 상황 추적 섹션 없음"
fi

# 최종 체크리스트
if grep -qiE "(최종\s*체크리스트|final\s*checklist)" "$PLAN_FILE"; then
    pass "최종 체크리스트 섹션 존재"
else
    warn "최종 체크리스트 섹션 없음"
fi

echo ""

# ─────────────────────────────────────────
# 6. 추가 품질 검사
# ─────────────────────────────────────────
echo "🔍 [6/6] 추가 품질 검사"
echo "────────────────────────"

# 테스트 전략 섹션
if grep -qiE "(테스트\s*전략|test\s*strategy)" "$PLAN_FILE"; then
    pass "테스트 전략 섹션 존재"
else
    warn "테스트 전략 섹션 없음"
fi

# 의존성 섹션
if grep -qiE "(의존성|dependency|dependencies)" "$PLAN_FILE"; then
    pass "의존성 섹션 존재"
else
    warn "의존성 섹션 없음"
fi

# 아키텍처 결정사항
if grep -qiE "(아키텍처|architecture)" "$PLAN_FILE"; then
    pass "아키텍처 섹션 존재"
else
    warn "아키텍처 섹션 없음"
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

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}🎉 모든 필수 검증 통과!${NC}"
    exit 0
elif [[ $FAIL -le 2 ]]; then
    echo -e "${YELLOW}⚠️ 일부 필수 항목 미준수 - 수정 필요${NC}"
    exit 1
else
    echo -e "${RED}❌ 다수 필수 항목 미준수 - 재작성 권장${NC}"
    exit 2
fi
