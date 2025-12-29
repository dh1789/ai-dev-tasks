#!/usr/bin/env bash

# C++ Memory Safety Check Script (runs inside Docker container)
# Performs comprehensive memory safety checks using various tools
# Usage: ./cpp-memory-check.sh [build_dir] [tool]
#   tool: valgrind | asan | tsan | ubsan | all (default: valgrind)

set -euo pipefail

BUILD_DIR="${1:-build}"
TOOL="${2:-valgrind}"
PROJECT_ROOT="$(pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

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
}

# Find test binaries
find_test_binaries() {
    find "$BUILD_DIR" -type f -executable -name "*test*" -o -name "*_test" 2>/dev/null || true
}

# Run Valgrind
run_valgrind() {
    print_section "Valgrind 메모리 검사"

    if ! command -v valgrind &> /dev/null; then
        print_error "Valgrind 미설치"
        return 1
    fi

    TEST_BINARIES=$(find_test_binaries)

    if [ -z "$TEST_BINARIES" ]; then
        print_warning "테스트 바이너리 없음"
        return 0
    fi

    for binary in $TEST_BINARIES; do
        echo "검사 중: $binary"
        valgrind \
            --leak-check=full \
            --show-leak-kinds=all \
            --track-origins=yes \
            --verbose \
            --log-file="$BUILD_DIR/valgrind-$(basename "$binary").log" \
            "$binary" || true

        # Check results
        if grep -q "ERROR SUMMARY: 0 errors" "$BUILD_DIR/valgrind-$(basename "$binary").log"; then
            print_success "$(basename "$binary"): 메모리 오류 없음"
        else
            print_error "$(basename "$binary"): 메모리 오류 발견"
            echo "   상세: $BUILD_DIR/valgrind-$(basename "$binary").log"
        fi
    done
}

# Run AddressSanitizer
run_asan() {
    print_section "AddressSanitizer (ASan)"

    print_warning "ASan 사용을 위해 재빌드 필요"

    ASAN_BUILD_DIR="${BUILD_DIR}-asan"
    rm -rf "$ASAN_BUILD_DIR"
    mkdir -p "$ASAN_BUILD_DIR"
    cd "$ASAN_BUILD_DIR"

    echo "ASan 플래그로 빌드 중..."
    cmake -G Ninja \
        -DCMAKE_CXX_FLAGS="-fsanitize=address -fno-omit-frame-pointer -g" \
        -DCMAKE_C_FLAGS="-fsanitize=address -fno-omit-frame-pointer -g" \
        .. || {
        print_error "ASan 빌드 실패"
        cd "$PROJECT_ROOT"
        return 1
    }

    ninja || {
        print_error "ASan 빌드 실패"
        cd "$PROJECT_ROOT"
        return 1
    }

    print_success "ASan 빌드 완료"

    # Run tests
    export ASAN_OPTIONS=check_initialization_order=1:detect_stack_use_after_return=1:print_stats=1

    if ctest --output-on-failure; then
        print_success "ASan: 메모리 오류 없음"
    else
        print_error "ASan: 메모리 오류 발견"
    fi

    cd "$PROJECT_ROOT"
}

# Run ThreadSanitizer
run_tsan() {
    print_section "ThreadSanitizer (TSan)"

    print_warning "TSan 사용을 위해 재빌드 필요"

    TSAN_BUILD_DIR="${BUILD_DIR}-tsan"
    rm -rf "$TSAN_BUILD_DIR"
    mkdir -p "$TSAN_BUILD_DIR"
    cd "$TSAN_BUILD_DIR"

    echo "TSan 플래그로 빌드 중..."
    cmake -G Ninja \
        -DCMAKE_CXX_FLAGS="-fsanitize=thread -g" \
        -DCMAKE_C_FLAGS="-fsanitize=thread -g" \
        .. || {
        print_error "TSan 빌드 실패"
        cd "$PROJECT_ROOT"
        return 1
    }

    ninja || {
        print_error "TSan 빌드 실패"
        cd "$PROJECT_ROOT"
        return 1
    }

    print_success "TSan 빌드 완료"

    # Run tests
    export TSAN_OPTIONS=second_deadlock_stack=1

    if ctest --output-on-failure; then
        print_success "TSan: 데이터 레이스 없음"
    else
        print_error "TSan: 데이터 레이스 발견"
    fi

    cd "$PROJECT_ROOT"
}

# Run UndefinedBehaviorSanitizer
run_ubsan() {
    print_section "UndefinedBehaviorSanitizer (UBSan)"

    print_warning "UBSan 사용을 위해 재빌드 필요"

    UBSAN_BUILD_DIR="${BUILD_DIR}-ubsan"
    rm -rf "$UBSAN_BUILD_DIR"
    mkdir -p "$UBSAN_BUILD_DIR"
    cd "$UBSAN_BUILD_DIR"

    echo "UBSan 플래그로 빌드 중..."
    cmake -G Ninja \
        -DCMAKE_CXX_FLAGS="-fsanitize=undefined -fno-omit-frame-pointer -g" \
        -DCMAKE_C_FLAGS="-fsanitize=undefined -fno-omit-frame-pointer -g" \
        .. || {
        print_error "UBSan 빌드 실패"
        cd "$PROJECT_ROOT"
        return 1
    }

    ninja || {
        print_error "UBSan 빌드 실패"
        cd "$PROJECT_ROOT"
        return 1
    }

    print_success "UBSan 빌드 완료"

    # Run tests
    export UBSAN_OPTIONS=print_stacktrace=1

    if ctest --output-on-failure; then
        print_success "UBSan: 정의되지 않은 동작 없음"
    else
        print_error "UBSan: 정의되지 않은 동작 발견"
    fi

    cd "$PROJECT_ROOT"
}

# Main
main() {
    case "$TOOL" in
        valgrind)
            run_valgrind
            ;;
        asan)
            run_asan
            ;;
        tsan)
            run_tsan
            ;;
        ubsan)
            run_ubsan
            ;;
        all)
            run_valgrind
            run_asan
            run_tsan
            run_ubsan
            ;;
        *)
            echo "알 수 없는 도구: $TOOL"
            echo "사용 가능한 도구: valgrind, asan, tsan, ubsan, all"
            exit 1
            ;;
    esac

    # Summary
    print_section "메모리 검사 요약"
    if [ $ERRORS -eq 0 ]; then
        print_success "모든 메모리 검사 통과!"
        exit 0
    else
        print_error "$ERRORS개의 메모리 오류 발견"
        exit 1
    fi
}

main
