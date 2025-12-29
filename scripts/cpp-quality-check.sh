#!/usr/bin/env bash

# C++ Quality Check Script (runs inside Docker container)
# Performs comprehensive quality checks on C++ code
# Usage: ./cpp-quality-check.sh [build_dir] [coverage_threshold]

set -euo pipefail

BUILD_DIR="${1:-build}"
COVERAGE_THRESHOLD="${2:-80}"
PROJECT_ROOT="$(pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

print_section() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

# 1. Build Check
print_section "1. 빌드 확인"
echo "빌드 디렉토리: $BUILD_DIR"

if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    cmake -G Ninja ..
    cd "$PROJECT_ROOT"
fi

cd "$BUILD_DIR"
if ninja; then
    print_success "빌드 성공"
else
    print_error "빌드 실패"
    cd "$PROJECT_ROOT"
    exit 1
fi
cd "$PROJECT_ROOT"

# 2. Run Tests
print_section "2. 테스트 실행"
cd "$BUILD_DIR"
if ctest --output-on-failure; then
    print_success "모든 테스트 통과"
else
    print_error "테스트 실패"
    cd "$PROJECT_ROOT"
    exit 1
fi
cd "$PROJECT_ROOT"

# 3. Code Coverage
print_section "3. 코드 커버리지 분석"
cd "$BUILD_DIR"

# Run tests with coverage
if [ -f "CMakeCache.txt" ]; then
    # Rebuild with coverage flags if not already set
    if ! grep -q "CMAKE_CXX_FLAGS.*coverage" CMakeCache.txt 2>/dev/null; then
        print_warning "커버리지 플래그 없이 빌드됨. 재빌드 필요."
        cd "$PROJECT_ROOT"
        rm -rf "$BUILD_DIR"
        mkdir -p "$BUILD_DIR"
        cd "$BUILD_DIR"
        cmake -G Ninja -DCMAKE_CXX_FLAGS="--coverage -fprofile-arcs -ftest-coverage" ..
        ninja
    fi
fi

# Generate coverage report
lcov --capture --directory . --output-file coverage.info || true
lcov --remove coverage.info '/usr/*' '*/test/*' '*/tests/*' --output-file coverage.info || true

if [ -f coverage.info ]; then
    COVERAGE=$(lcov --summary coverage.info 2>&1 | grep "lines" | awk '{print $2}' | tr -d '%' || echo "0")
    echo "커버리지: ${COVERAGE}%"

    if (( $(echo "$COVERAGE >= $COVERAGE_THRESHOLD" | bc -l) )); then
        print_success "커버리지 목표 달성 (${COVERAGE}% >= ${COVERAGE_THRESHOLD}%)"
    else
        print_warning "커버리지 목표 미달성 (${COVERAGE}% < ${COVERAGE_THRESHOLD}%)"
    fi

    # Generate HTML report
    genhtml coverage.info --output-directory coverage_html || true
    print_success "HTML 리포트 생성: $BUILD_DIR/coverage_html/index.html"
else
    print_warning "커버리지 정보 생성 실패"
fi

cd "$PROJECT_ROOT"

# 4. Static Analysis - clang-tidy
print_section "4. 정적 분석 - clang-tidy"
if command -v clang-tidy &> /dev/null; then
    # Find all C++ source files
    SOURCES=$(find src -name "*.cpp" -o -name "*.cc" -o -name "*.cxx" 2>/dev/null || true)

    if [ -n "$SOURCES" ]; then
        clang-tidy $SOURCES \
            -p="$BUILD_DIR" \
            --checks='*,-fuchsia-*,-google-*,-llvm-*,-modernize-use-trailing-return-type' \
            --warnings-as-errors='' \
            2>&1 | tee "$BUILD_DIR/clang-tidy-report.txt" || true

        if grep -q "error:" "$BUILD_DIR/clang-tidy-report.txt"; then
            print_warning "clang-tidy 경고 발견 (상세: $BUILD_DIR/clang-tidy-report.txt)"
        else
            print_success "clang-tidy 검사 통과"
        fi
    else
        print_warning "분석할 소스 파일 없음"
    fi
else
    print_warning "clang-tidy 미설치"
fi

# 5. Static Analysis - cppcheck
print_section "5. 정적 분석 - cppcheck"
if command -v cppcheck &> /dev/null; then
    cppcheck --enable=all \
        --suppress=missingInclude \
        --suppress=unmatchedSuppression \
        --std=c++23 \
        --xml \
        --xml-version=2 \
        src/ 2> "$BUILD_DIR/cppcheck-report.xml" || true

    if grep -q "error id=" "$BUILD_DIR/cppcheck-report.xml"; then
        print_warning "cppcheck 경고 발견 (상세: $BUILD_DIR/cppcheck-report.xml)"
    else
        print_success "cppcheck 검사 통과"
    fi
else
    print_warning "cppcheck 미설치"
fi

# 6. Code Formatting Check - clang-format
print_section "6. 코드 포매팅 확인 - clang-format"
if command -v clang-format &> /dev/null; then
    UNFORMATTED=$(find src -name "*.cpp" -o -name "*.h" -o -name "*.hpp" 2>/dev/null | \
        xargs clang-format --dry-run --Werror 2>&1 | grep "warning:" || true)

    if [ -n "$UNFORMATTED" ]; then
        print_warning "포매팅되지 않은 파일 발견"
        echo "$UNFORMATTED"
        echo ""
        echo "자동 수정: find src -name '*.cpp' -o -name '*.h' | xargs clang-format -i"
    else
        print_success "모든 파일이 포맷됨"
    fi
else
    print_warning "clang-format 미설치"
fi

# 7. Include-What-You-Use
print_section "7. 헤더 포함 검사 - include-what-you-use"
if command -v include-what-you-use &> /dev/null; then
    print_success "include-what-you-use 사용 가능"
    echo "수동 실행: iwyu_tool.py -p $BUILD_DIR"
else
    print_warning "include-what-you-use 미설치"
fi

# 8. Summary
print_section "품질 검사 요약"
echo ""
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    print_success "모든 품질 검사 통과!"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}경고 ${WARNINGS}개 발견${NC}"
    echo "경고를 검토하고 수정하는 것을 권장합니다."
    exit 0
else
    echo -e "${RED}오류 ${ERRORS}개, 경고 ${WARNINGS}개 발견${NC}"
    echo "오류를 수정해야 합니다."
    exit 1
fi
