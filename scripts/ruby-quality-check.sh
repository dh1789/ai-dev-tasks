#!/usr/bin/env bash
###############################################################################
# AI Dev Tasks - Ruby/Rails Quality Check Script
# Ruby 및 Rails 프로젝트 품질 검사
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
# 1. Bundler 의존성 확인
###############################################################################
check_bundler() {
    print_header "1️⃣  Bundler 의존성 확인"

    if ! command -v bundle &> /dev/null; then
        print_error "Bundler가 설치되어 있지 않습니다"
        return 1
    fi

    if [[ ! -f "$PROJECT_ROOT/Gemfile" ]]; then
        print_error "Gemfile을 찾을 수 없습니다"
        return 1
    fi

    print_info "Bundle install 실행 중..."
    cd "$PROJECT_ROOT"

    if bundle check &> /dev/null; then
        print_success "의존성이 이미 설치되어 있습니다"
    else
        if bundle install; then
            print_success "의존성 설치 완료"
        else
            print_error "Bundle install 실패"
            return 1
        fi
    fi
}

###############################################################################
# 2. Database 준비 (Rails 프로젝트)
###############################################################################
check_database() {
    print_header "2️⃣  데이터베이스 준비"

    cd "$PROJECT_ROOT"

    # Rails 프로젝트인지 확인
    if [[ ! -f "config/database.yml" ]]; then
        print_info "Rails 프로젝트가 아니므로 DB 준비 스킵"
        return 0
    fi

    # Test DB 준비
    print_info "테스트 데이터베이스 준비 중..."

    if RAILS_ENV=test bundle exec rails db:test:prepare 2>&1 | grep -v "already exists"; then
        print_success "테스트 DB 준비 완료"
    else
        print_warning "테스트 DB 준비 중 경고 발생 (계속 진행)"
    fi
}

###############################################################################
# 3. 테스트 실행 (Minitest)
###############################################################################
run_tests() {
    print_header "3️⃣  테스트 실행 (Minitest)"

    cd "$PROJECT_ROOT"

    print_info "모든 테스트 실행 중..."

    # Rails 프로젝트
    if [[ -f "config/database.yml" ]]; then
        if bundle exec rails test; then
            print_success "모든 테스트 통과"
        else
            print_error "테스트 실패"
            return 1
        fi
    # Standalone Ruby 프로젝트
    elif [[ -f "Rakefile" ]]; then
        if bundle exec rake test; then
            print_success "모든 테스트 통과"
        else
            print_error "테스트 실패"
            return 1
        fi
    else
        print_warning "테스트 실행 방법을 찾을 수 없습니다 (Rakefile 또는 Rails 필요)"
    fi
}

###############################################################################
# 4. 코드 커버리지 확인 (SimpleCov)
###############################################################################
check_coverage() {
    print_header "4️⃣  코드 커버리지 확인"

    cd "$PROJECT_ROOT"

    # SimpleCov 결과 파일 확인
    local coverage_file="coverage/.resultset.json"
    local coverage_html="coverage/index.html"

    if [[ ! -f "$coverage_file" ]]; then
        print_warning "SimpleCov 결과를 찾을 수 없습니다"
        print_info "Gemfile에 'gem \"simplecov\"'를 추가하고 test_helper.rb에서 활성화하세요"
        return 0
    fi

    # 커버리지 퍼센트 추출
    if command -v ruby &> /dev/null; then
        local coverage=$(ruby -rjson -e "
            data = JSON.parse(File.read('$coverage_file'))
            result = data.values.first
            covered = result['coverage'].values.flatten.compact.select { |x| x > 0 }.size
            total = result['coverage'].values.flatten.compact.size
            puts ((covered.to_f / total * 100).round(2)) if total > 0
        " 2>/dev/null || echo "0")

        print_info "현재 커버리지: ${coverage}%"
        print_info "목표 커버리지: ${COVERAGE_THRESHOLD}%"

        if (( $(echo "$coverage >= $COVERAGE_THRESHOLD" | bc -l) )); then
            print_success "커버리지 목표 달성 ✅"
        else
            print_error "커버리지 목표 미달 (${coverage}% < ${COVERAGE_THRESHOLD}%)"
        fi

        if [[ -f "$coverage_html" ]]; then
            print_info "커버리지 리포트: file://$PROJECT_ROOT/$coverage_html"
        fi
    else
        print_warning "Ruby가 없어서 커버리지를 계산할 수 없습니다"
    fi
}

###############################################################################
# 5. RuboCop 정적 분석
###############################################################################
run_rubocop() {
    print_header "5️⃣  RuboCop 정적 분석"

    cd "$PROJECT_ROOT"

    if ! bundle exec rubocop --version &> /dev/null; then
        print_warning "RuboCop이 설치되어 있지 않습니다"
        print_info "Gemfile에 'gem \"rubocop\"'를 추가하세요"
        return 0
    fi

    print_info "RuboCop 실행 중..."

    if bundle exec rubocop; then
        print_success "RuboCop 검사 통과 (위반 사항 없음)"
    else
        print_error "RuboCop 검사 실패 (코드 스타일 위반)"
        print_info "자동 수정: bundle exec rubocop -A"
    fi
}

###############################################################################
# 6. Brakeman 보안 검사 (Rails 전용)
###############################################################################
run_brakeman() {
    print_header "6️⃣  Brakeman 보안 검사"

    cd "$PROJECT_ROOT"

    # Rails 프로젝트인지 확인
    if [[ ! -f "config/database.yml" ]]; then
        print_info "Rails 프로젝트가 아니므로 Brakeman 스킵"
        return 0
    fi

    if ! bundle exec brakeman --version &> /dev/null; then
        print_warning "Brakeman이 설치되어 있지 않습니다"
        print_info "Gemfile에 'gem \"brakeman\"'를 추가하세요"
        return 0
    fi

    print_info "Brakeman 보안 검사 실행 중..."

    if bundle exec brakeman --no-pager --quiet; then
        print_success "보안 취약점 없음"
    else
        print_error "보안 취약점 발견"
        print_info "상세 리포트: bundle exec brakeman"
    fi
}

###############################################################################
# 7. Rails Best Practices (선택사항)
###############################################################################
run_rails_best_practices() {
    print_header "7️⃣  Rails Best Practices"

    cd "$PROJECT_ROOT"

    # Rails 프로젝트인지 확인
    if [[ ! -f "config/database.yml" ]]; then
        print_info "Rails 프로젝트가 아니므로 스킵"
        return 0
    fi

    if ! command -v rails_best_practices &> /dev/null; then
        print_info "rails_best_practices가 설치되어 있지 않습니다 (선택사항)"
        return 0
    fi

    print_info "Rails Best Practices 검사 중..."

    if rails_best_practices .; then
        print_success "Rails 베스트 프랙티스 준수"
    else
        print_warning "베스트 프랙티스 위반 발견 (경고)"
    fi
}

###############################################################################
# 8. Bundle Audit (보안 취약점)
###############################################################################
run_bundle_audit() {
    print_header "8️⃣  Bundle Audit (의존성 보안 검사)"

    cd "$PROJECT_ROOT"

    if ! bundle exec bundle-audit --version &> /dev/null; then
        print_warning "bundle-audit이 설치되어 있지 않습니다"
        print_info "Gemfile에 'gem \"bundler-audit\"'를 추가하세요"
        return 0
    fi

    print_info "의존성 보안 취약점 검사 중..."

    # 데이터베이스 업데이트
    bundle exec bundle-audit update

    if bundle exec bundle-audit check; then
        print_success "의존성에 알려진 취약점 없음"
    else
        print_error "의존성에 보안 취약점 발견"
        print_info "업데이트: bundle update [gem-name]"
    fi
}

###############################################################################
# Main Execution
###############################################################################
main() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         Ruby/Rails Quality Check - AI Dev Tasks           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    print_info "프로젝트: $PROJECT_ROOT"
    print_info "커버리지 목표: ${COVERAGE_THRESHOLD}%"
    echo ""

    # 체크 실행
    check_bundler || true
    check_database || true
    run_tests || true
    check_coverage || true
    run_rubocop || true
    run_brakeman || true
    run_rails_best_practices || true
    run_bundle_audit || true

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
