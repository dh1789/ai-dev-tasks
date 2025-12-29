#!/usr/bin/env bash
###############################################################################
# AI Dev Tasks - Project Type Detection Script
# 프로젝트 타입 자동 감지 (Ruby, Node.js, C++, etc.)
###############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Project root (기본값: 현재 디렉토리)
PROJECT_ROOT="${1:-.}"

# Output functions
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

###############################################################################
# Detection Functions
###############################################################################

detect_ruby() {
    local confidence=0
    local details=""

    if [[ -f "$PROJECT_ROOT/Gemfile" ]]; then
        confidence=$((confidence + 40))
        details+="Gemfile, "

        # Rails 감지
        if grep -q "rails" "$PROJECT_ROOT/Gemfile" 2>/dev/null; then
            confidence=$((confidence + 30))
            details+="Rails, "
        fi
    fi

    if [[ -f "$PROJECT_ROOT/Rakefile" ]]; then
        confidence=$((confidence + 20))
        details+="Rakefile, "
    fi

    if [[ -d "$PROJECT_ROOT/app" ]] && [[ -d "$PROJECT_ROOT/config" ]]; then
        confidence=$((confidence + 20))
        details+="Rails structure, "
    fi

    if [[ -f "$PROJECT_ROOT/.ruby-version" ]]; then
        confidence=$((confidence + 10))
        local version=$(cat "$PROJECT_ROOT/.ruby-version")
        details+="Ruby $version, "
    fi

    # Remove trailing comma
    details="${details%, }"

    if [[ $confidence -gt 0 ]]; then
        echo "ruby|$confidence|$details"
    fi
}

detect_nodejs() {
    local confidence=0
    local details=""

    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        confidence=$((confidence + 50))
        details+="package.json, "

        # TypeScript 감지
        if [[ -f "$PROJECT_ROOT/tsconfig.json" ]]; then
            confidence=$((confidence + 30))
            details+="TypeScript, "
        fi

        # 프레임워크 감지
        if grep -q "\"next\"" "$PROJECT_ROOT/package.json" 2>/dev/null; then
            details+="Next.js, "
        elif grep -q "\"express\"" "$PROJECT_ROOT/package.json" 2>/dev/null; then
            details+="Express, "
        fi

        # 패키지 매니저
        if [[ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]]; then
            details+="pnpm, "
        elif [[ -f "$PROJECT_ROOT/yarn.lock" ]]; then
            details+="yarn, "
        elif [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then
            details+="npm, "
        fi
    fi

    if [[ -d "$PROJECT_ROOT/node_modules" ]]; then
        confidence=$((confidence + 10))
    fi

    # Remove trailing comma
    details="${details%, }"

    if [[ $confidence -gt 0 ]]; then
        echo "nodejs|$confidence|$details"
    fi
}

detect_cpp() {
    local confidence=0
    local details=""

    if [[ -f "$PROJECT_ROOT/CMakeLists.txt" ]]; then
        confidence=$((confidence + 50))
        details+="CMake, "
    fi

    if [[ -f "$PROJECT_ROOT/Makefile" ]]; then
        confidence=$((confidence + 30))
        details+="Makefile, "
    fi

    if [[ -f "$PROJECT_ROOT/meson.build" ]]; then
        confidence=$((confidence + 40))
        details+="Meson, "
    fi

    # C++ 소스 파일 확인
    if find "$PROJECT_ROOT" -maxdepth 3 -name "*.cpp" -o -name "*.cc" -o -name "*.cxx" | grep -q .; then
        confidence=$((confidence + 20))
        details+="C++ sources, "
    fi

    # 헤더 파일 확인
    if find "$PROJECT_ROOT" -maxdepth 3 -name "*.h" -o -name "*.hpp" -o -name "*.hxx" | grep -q .; then
        confidence=$((confidence + 10))
        details+="C++ headers, "
    fi

    # Remove trailing comma
    details="${details%, }"

    if [[ $confidence -gt 0 ]]; then
        echo "cpp|$confidence|$details"
    fi
}

detect_python() {
    local confidence=0
    local details=""

    if [[ -f "$PROJECT_ROOT/requirements.txt" ]]; then
        confidence=$((confidence + 40))
        details+="requirements.txt, "
    fi

    if [[ -f "$PROJECT_ROOT/setup.py" ]] || [[ -f "$PROJECT_ROOT/pyproject.toml" ]]; then
        confidence=$((confidence + 40))
        details+="Python package, "
    fi

    if [[ -f "$PROJECT_ROOT/Pipfile" ]]; then
        confidence=$((confidence + 30))
        details+="Pipenv, "
    fi

    if [[ -f "$PROJECT_ROOT/poetry.lock" ]]; then
        confidence=$((confidence + 30))
        details+="Poetry, "
    fi

    # Python 소스 파일 확인
    if find "$PROJECT_ROOT" -maxdepth 3 -name "*.py" | grep -q .; then
        confidence=$((confidence + 20))
        details+="Python sources, "
    fi

    # Remove trailing comma
    details="${details%, }"

    if [[ $confidence -gt 0 ]]; then
        echo "python|$confidence|$details"
    fi
}

###############################################################################
# Main Detection Logic
###############################################################################

main() {
    print_info "프로젝트 타입 감지 중: $PROJECT_ROOT"
    echo ""

    # 모든 감지 함수 실행
    local ruby_result=$(detect_ruby)
    local nodejs_result=$(detect_nodejs)
    local cpp_result=$(detect_cpp)
    local python_result=$(detect_python)

    # 결과 수집
    declare -A results
    local max_confidence=0
    local primary_type=""

    # Ruby 결과 처리
    if [[ -n "$ruby_result" ]]; then
        IFS='|' read -r type confidence details <<< "$ruby_result"
        results["$type"]="$confidence|$details"
        if [[ $confidence -gt $max_confidence ]]; then
            max_confidence=$confidence
            primary_type="$type"
        fi
    fi

    # Node.js 결과 처리
    if [[ -n "$nodejs_result" ]]; then
        IFS='|' read -r type confidence details <<< "$nodejs_result"
        results["$type"]="$confidence|$details"
        if [[ $confidence -gt $max_confidence ]]; then
            max_confidence=$confidence
            primary_type="$type"
        fi
    fi

    # C++ 결과 처리
    if [[ -n "$cpp_result" ]]; then
        IFS='|' read -r type confidence details <<< "$cpp_result"
        results["$type"]="$confidence|$details"
        if [[ $confidence -gt $max_confidence ]]; then
            max_confidence=$confidence
            primary_type="$type"
        fi
    fi

    # Python 결과 처리
    if [[ -n "$python_result" ]]; then
        IFS='|' read -r type confidence details <<< "$python_result"
        results["$type"]="$confidence|$details"
        if [[ $confidence -gt $max_confidence ]]; then
            max_confidence=$confidence
            primary_type="$type"
        fi
    fi

    # 결과 출력
    if [[ ${#results[@]} -eq 0 ]]; then
        print_warning "프로젝트 타입을 감지할 수 없습니다"
        exit 1
    fi

    echo "📊 감지된 언어/프레임워크:"
    echo ""

    for type in "${!results[@]}"; do
        IFS='|' read -r confidence details <<< "${results[$type]}"

        if [[ "$type" == "$primary_type" ]]; then
            print_success "🎯 $type (신뢰도: ${confidence}%) - PRIMARY"
        else
            print_info "   $type (신뢰도: ${confidence}%)"
        fi
        echo "      └─ $details"
    done

    echo ""
    print_success "주 언어: $primary_type"

    # 환경 변수로 내보내기 (다른 스크립트에서 사용 가능)
    echo ""
    echo "# Export for other scripts:"
    echo "export PROJECT_TYPE=\"$primary_type\""
    echo "export PROJECT_CONFIDENCE=\"$max_confidence\""

    # JSON 형식으로도 출력 (선택사항)
    if [[ "${2:-}" == "--json" ]]; then
        echo ""
        echo "{"
        echo "  \"primary\": \"$primary_type\","
        echo "  \"confidence\": $max_confidence,"
        echo "  \"detected\": {"
        for type in "${!results[@]}"; do
            IFS='|' read -r confidence details <<< "${results[$type]}"
            echo "    \"$type\": {\"confidence\": $confidence, \"details\": \"$details\"},"
        done | sed '$ s/,$//'
        echo "  }"
        echo "}"
    fi
}

# 실행
main "$@"
