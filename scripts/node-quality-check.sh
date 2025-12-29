#!/usr/bin/env bash
###############################################################################
# AI Dev Tasks - Node.js/TypeScript Quality Check Script
# Node.js 및 TypeScript 프로젝트 품질 검사
###############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${1:-.}"
COVERAGE_THRESHOLD="${2:-80}"
FAILED_CHECKS=0

# Output functions
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; FAILED_CHECKS=$((FAILED_CHECKS + 1)); }

print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}$1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

###############################################################################
# Detect Package Manager
###############################################################################
detect_package_manager() {
    cd "$PROJECT_ROOT"

    if [[ -f "pnpm-lock.yaml" ]]; then
        echo "pnpm"
    elif [[ -f "yarn.lock" ]]; then
        echo "yarn"
    elif [[ -f "package-lock.json" ]]; then
        echo "npm"
    else
        echo "npm"  # default
    fi
}

PKG_MANAGER=$(detect_package_manager)

# Package manager commands
case "$PKG_MANAGER" in
    pnpm)
        INSTALL_CMD="pnpm install"
        RUN_CMD="pnpm run"
        EXEC_CMD="pnpm exec"
        ;;
    yarn)
        INSTALL_CMD="yarn install"
        RUN_CMD="yarn run"
        EXEC_CMD="yarn"
        ;;
    *)
        INSTALL_CMD="npm install"
        RUN_CMD="npm run"
        EXEC_CMD="npx"
        ;;
esac

###############################################################################
# 1. 의존성 설치 확인
###############################################################################
check_dependencies() {
    print_header "1️⃣  의존성 설치 확인"

    cd "$PROJECT_ROOT"

    if [[ ! -f "package.json" ]]; then
        print_error "package.json을 찾을 수 없습니다"
        return 1
    fi

    print_info "패키지 매니저: $PKG_MANAGER"

    if [[ ! -d "node_modules" ]]; then
        print_info "의존성 설치 중..."
        if $INSTALL_CMD; then
            print_success "의존성 설치 완료"
        else
            print_error "의존성 설치 실패"
            return 1
        fi
    else
        print_success "의존성이 이미 설치되어 있습니다"
    fi
}

###############################################################################
# 2. TypeScript 타입 체크
###############################################################################
run_typecheck() {
    print_header "2️⃣  TypeScript 타입 체크"

    cd "$PROJECT_ROOT"

    if [[ ! -f "tsconfig.json" ]]; then
        print_info "TypeScript 프로젝트가 아니므로 스킵"
        return 0
    fi

    print_info "TypeScript 타입 체크 실행 중..."

    # package.json에 typecheck 스크립트가 있는지 확인
    if grep -q "\"typecheck\"" package.json 2>/dev/null; then
        if $RUN_CMD typecheck; then
            print_success "타입 체크 통과"
        else
            print_error "타입 체크 실패"
            return 1
        fi
    else
        # 직접 tsc 실행
        if $EXEC_CMD tsc --noEmit; then
            print_success "타입 체크 통과"
        else
            print_error "타입 체크 실패"
            return 1
        fi
    fi
}

###############################################################################
# 3. ESLint 검사
###############################################################################
run_eslint() {
    print_header "3️⃣  ESLint 코드 검사"

    cd "$PROJECT_ROOT"

    # ESLint 설정 파일 확인
    if [[ ! -f ".eslintrc.js" ]] && [[ ! -f ".eslintrc.json" ]] && [[ ! -f "eslint.config.js" ]] && ! grep -q "\"eslintConfig\"" package.json 2>/dev/null; then
        print_warning "ESLint 설정을 찾을 수 없습니다"
        return 0
    fi

    print_info "ESLint 실행 중..."

    # package.json에 lint 스크립트가 있는지 확인
    if grep -q "\"lint\"" package.json 2>/dev/null; then
        if $RUN_CMD lint; then
            print_success "ESLint 검사 통과"
        else
            print_error "ESLint 검사 실패"
            print_info "자동 수정: $RUN_CMD lint --fix"
            return 1
        fi
    else
        if $EXEC_CMD eslint . --ext .js,.jsx,.ts,.tsx; then
            print_success "ESLint 검사 통과"
        else
            print_error "ESLint 검사 실패"
            print_info "자동 수정: $EXEC_CMD eslint . --ext .js,.jsx,.ts,.tsx --fix"
            return 1
        fi
    fi
}

###############################################################################
# 4. Prettier 포매팅 체크
###############################################################################
run_prettier() {
    print_header "4️⃣  Prettier 포매팅 체크"

    cd "$PROJECT_ROOT"

    # Prettier 설정 파일 확인
    if [[ ! -f ".prettierrc" ]] && [[ ! -f ".prettierrc.json" ]] && [[ ! -f "prettier.config.js" ]] && ! grep -q "\"prettier\"" package.json 2>/dev/null; then
        print_warning "Prettier 설정을 찾을 수 없습니다"
        return 0
    fi

    print_info "Prettier 포매팅 체크 중..."

    # package.json에 format:check 스크립트가 있는지 확인
    if grep -q "\"format:check\"" package.json 2>/dev/null; then
        if $RUN_CMD format:check; then
            print_success "Prettier 포매팅 통과"
        else
            print_error "Prettier 포매팅 필요"
            print_info "자동 수정: $RUN_CMD format"
            return 1
        fi
    else
        if $EXEC_CMD prettier --check .; then
            print_success "Prettier 포매팅 통과"
        else
            print_error "Prettier 포매팅 필요"
            print_info "자동 수정: $EXEC_CMD prettier --write ."
            return 1
        fi
    fi
}

###############################################################################
# 5. 테스트 실행 (Jest/Vitest)
###############################################################################
run_tests() {
    print_header "5️⃣  테스트 실행"

    cd "$PROJECT_ROOT"

    # package.json에 test 스크립트 확인
    if ! grep -q "\"test\"" package.json 2>/dev/null; then
        print_warning "test 스크립트를 찾을 수 없습니다"
        return 0
    fi

    print_info "모든 테스트 실행 중..."

    # 테스트 실행 (타임아웃 10분)
    if timeout 600 $RUN_CMD test 2>&1 | tee /tmp/test-output.log; then
        print_success "모든 테스트 통과"
    else
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            print_error "테스트 타임아웃 (10분 초과)"
        else
            print_error "테스트 실패"
        fi
        return 1
    fi
}

###############################################################################
# 6. 테스트 커버리지 확인
###############################################################################
check_coverage() {
    print_header "6️⃣  테스트 커버리지 확인"

    cd "$PROJECT_ROOT"

    # package.json에 test:coverage 스크립트 확인
    if ! grep -q "\"test:coverage\"" package.json 2>/dev/null && ! grep -q "\"coverage\"" package.json 2>/dev/null; then
        print_warning "커버리지 스크립트를 찾을 수 없습니다"
        return 0
    fi

    print_info "커버리지 측정 중..."

    # 커버리지 실행
    local coverage_cmd="test:coverage"
    if ! grep -q "\"test:coverage\"" package.json 2>/dev/null; then
        coverage_cmd="coverage"
    fi

    if $RUN_CMD $coverage_cmd 2>&1 | tee /tmp/coverage-output.log; then
        # 커버리지 퍼센트 추출 (Jest/Vitest)
        local coverage=$(grep -oP "All files.*?\|\s+\K[\d\.]+" /tmp/coverage-output.log | head -1 || echo "0")

        if [[ -z "$coverage" ]]; then
            # Vitest 형식 시도
            coverage=$(grep -oP "All files\s+\|\s+\K[\d\.]+" /tmp/coverage-output.log | head -1 || echo "0")
        fi

        if [[ -n "$coverage" ]] && [[ "$coverage" != "0" ]]; then
            print_info "현재 커버리지: ${coverage}%"
            print_info "목표 커버리지: ${COVERAGE_THRESHOLD}%"

            if (( $(echo "$coverage >= $COVERAGE_THRESHOLD" | bc -l) )); then
                print_success "커버리지 목표 달성 ✅"
            else
                print_error "커버리지 목표 미달 (${coverage}% < ${COVERAGE_THRESHOLD}%)"
            fi
        else
            print_warning "커버리지를 파싱할 수 없습니다"
        fi

        # 커버리지 리포트 위치
        if [[ -d "coverage" ]]; then
            print_info "커버리지 리포트: file://$PROJECT_ROOT/coverage/index.html"
        fi
    else
        print_error "커버리지 측정 실패"
        return 1
    fi
}

###############################################################################
# 7. 빌드 체크 (TypeScript 프로젝트)
###############################################################################
run_build() {
    print_header "7️⃣  빌드 체크"

    cd "$PROJECT_ROOT"

    # package.json에 build 스크립트 확인
    if ! grep -q "\"build\"" package.json 2>/dev/null; then
        print_info "빌드 스크립트가 없으므로 스킵"
        return 0
    fi

    print_info "빌드 실행 중..."

    if $RUN_CMD build; then
        print_success "빌드 성공"
    else
        print_error "빌드 실패"
        return 1
    fi
}

###############################################################################
# 8. 보안 취약점 검사 (npm audit)
###############################################################################
run_security_audit() {
    print_header "8️⃣  보안 취약점 검사"

    cd "$PROJECT_ROOT"

    print_info "의존성 보안 취약점 검사 중..."

    case "$PKG_MANAGER" in
        pnpm)
            if pnpm audit --audit-level=moderate; then
                print_success "보안 취약점 없음"
            else
                print_warning "보안 취약점 발견 (pnpm audit --fix로 수정 가능)"
            fi
            ;;
        yarn)
            if yarn audit --level moderate; then
                print_success "보안 취약점 없음"
            else
                print_warning "보안 취약점 발견"
            fi
            ;;
        *)
            if npm audit --audit-level=moderate; then
                print_success "보안 취약점 없음"
            else
                print_warning "보안 취약점 발견 (npm audit fix로 수정 가능)"
            fi
            ;;
    esac
}

###############################################################################
# Main Execution
###############################################################################
main() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║       Node.js/TypeScript Quality Check - AI Dev Tasks       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    print_info "프로젝트: $PROJECT_ROOT"
    print_info "패키지 매니저: $PKG_MANAGER"
    print_info "커버리지 목표: ${COVERAGE_THRESHOLD}%"
    echo ""

    # 체크 실행
    check_dependencies || true
    run_typecheck || true
    run_eslint || true
    run_prettier || true
    run_tests || true
    check_coverage || true
    run_build || true
    run_security_audit || true

    # 최종 결과
    echo ""
    print_header "📊 최종 결과"

    if [[ $FAILED_CHECKS -eq 0 ]]; then
        print_success "모든 품질 검사 통과! 🎉"
        echo ""
        return 0
    else
        print_error "실패한 검사: $FAILED_CHECKS 개"
        echo ""
        return 1
    fi
}

# 실행
main "$@"
