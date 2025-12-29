#!/usr/bin/env bash

# Prerequisites Checker for AI Dev Tasks
# Checks if all required tools and configurations are in place
# Usage: ./check-prerequisites.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

print_header() {
    echo ""
    echo "================================================"
    echo "  AI Dev Tasks - 사전조건 확인"
    echo "================================================"
    echo ""
}

check_pass() {
    echo -e "${GREEN}✅ $1${NC}"
}

check_fail() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

print_header

# 0. Detect Project Type
echo "🔍 프로젝트 타입 감지 중..."
if [ -f "$PROJECT_ROOT/scripts/detect-project-type.sh" ] && [ -x "$PROJECT_ROOT/scripts/detect-project-type.sh" ]; then
    PROJECT_TYPE=$("$PROJECT_ROOT/scripts/detect-project-type.sh" 2>/dev/null | grep "주 언어:" | awk '{print $3}')
    if [ -n "$PROJECT_TYPE" ]; then
        check_pass "프로젝트 타입: $PROJECT_TYPE"
    else
        check_warn "프로젝트 타입 자동 감지 실패 - 모든 도구 확인 진행"
        PROJECT_TYPE="unknown"
    fi
else
    check_warn "detect-project-type.sh 없음 - 모든 도구 확인 진행"
    PROJECT_TYPE="unknown"
fi

# 1. Check Language-Specific Tools
echo ""
echo "🛠️  언어별 도구 확인 중..."

# Ruby/Rails Tools
if [ "$PROJECT_TYPE" = "ruby" ] || [ "$PROJECT_TYPE" = "unknown" ]; then
    if [ -f "$PROJECT_ROOT/Gemfile" ]; then
        echo ""
        echo "💎 Ruby/Rails 도구:"

        if command -v ruby &> /dev/null; then
            RUBY_VERSION=$(ruby --version | awk '{print $2}')
            check_pass "Ruby 설치됨 (버전: $RUBY_VERSION)"
        else
            check_fail "Ruby가 설치되어 있지 않습니다."
        fi

        if command -v bundle &> /dev/null; then
            BUNDLE_VERSION=$(bundle --version | awk '{print $3}')
            check_pass "Bundler 설치됨 (버전: $BUNDLE_VERSION)"
        else
            check_fail "Bundler가 설치되어 있지 않습니다."
            echo "   설치: gem install bundler"
        fi

        if command -v rails &> /dev/null; then
            RAILS_VERSION=$(rails --version | awk '{print $2}')
            check_pass "Rails 설치됨 (버전: $RAILS_VERSION)"
        else
            check_warn "Rails가 전역으로 설치되어 있지 않습니다 (선택사항)"
        fi
    fi
fi

# Node.js/TypeScript Tools
if [ "$PROJECT_TYPE" = "nodejs" ] || [ "$PROJECT_TYPE" = "unknown" ]; then
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        echo ""
        echo "📦 Node.js/TypeScript 도구:"

        if command -v node &> /dev/null; then
            NODE_VERSION=$(node --version)
            check_pass "Node.js 설치됨 (버전: $NODE_VERSION)"
        else
            check_fail "Node.js가 설치되어 있지 않습니다."
            echo "   설치: https://nodejs.org/"
        fi

        # Check package manager
        if command -v pnpm &> /dev/null && [ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]; then
            PNPM_VERSION=$(pnpm --version)
            check_pass "pnpm 설치됨 (버전: $PNPM_VERSION)"
        elif command -v yarn &> /dev/null && [ -f "$PROJECT_ROOT/yarn.lock" ]; then
            YARN_VERSION=$(yarn --version)
            check_pass "yarn 설치됨 (버전: $YARN_VERSION)"
        elif command -v npm &> /dev/null; then
            NPM_VERSION=$(npm --version)
            check_pass "npm 설치됨 (버전: $NPM_VERSION)"
        else
            check_fail "패키지 매니저 (npm/yarn/pnpm)가 설치되어 있지 않습니다."
        fi
    fi
fi

# 2. Check Docker (for C++ projects or all if unknown)
echo "🐳 Docker 확인 중..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
    check_pass "Docker 설치됨 (버전: $DOCKER_VERSION)"

    if docker info &> /dev/null; then
        check_pass "Docker 데몬 실행 중"
    else
        check_fail "Docker 데몬이 실행 중이 아닙니다. Docker Desktop을 시작하세요."
    fi
else
    check_fail "Docker가 설치되어 있지 않습니다."
    echo "   설치: https://www.docker.com/get-started"
fi

# 2. Check Docker Compose
echo ""
echo "📦 Docker Compose 확인 중..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | awk '{print $4}' | tr -d ',')
    check_pass "Docker Compose 설치됨 (버전: $COMPOSE_VERSION)"
elif docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version --short)
    check_pass "Docker Compose (plugin) 설치됨 (버전: $COMPOSE_VERSION)"
else
    check_fail "Docker Compose가 설치되어 있지 않습니다."
fi

# 3. Check Environment Variables
echo ""
echo "🔐 환경 변수 확인 중..."
if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
    check_pass "SLACK_WEBHOOK_URL 설정됨"
else
    check_warn "SLACK_WEBHOOK_URL이 설정되어 있지 않습니다."
    echo "   설정 방법: export SLACK_WEBHOOK_URL='your-webhook-url'"
fi

# 4. Check Project Structure
echo ""
echo "📁 프로젝트 구조 확인 중..."

if [ -f "$PROJECT_ROOT/Dockerfile.gcc15.1_22.04" ]; then
    check_pass "Dockerfile 존재"
else
    check_fail "Dockerfile.gcc15.1_22.04가 존재하지 않습니다."
fi

if [ -f "$PROJECT_ROOT/docker/docker-compose.yml" ]; then
    check_pass "docker-compose.yml 존재"
else
    check_fail "docker/docker-compose.yml이 존재하지 않습니다."
fi

if [ -d "$PROJECT_ROOT/skill-plan" ]; then
    check_pass "skill-plan 디렉토리 존재"
else
    check_warn "skill-plan 디렉토리가 존재하지 않습니다."
fi

if [ -d "$PROJECT_ROOT/skill-implement" ]; then
    check_pass "skill-implement 디렉토리 존재"
else
    check_warn "skill-implement 디렉토리가 존재하지 않습니다."
fi

if [ -d "$PROJECT_ROOT/scripts" ]; then
    check_pass "scripts 디렉토리 존재"
else
    check_fail "scripts 디렉토리가 존재하지 않습니다."
fi

# 5. Check Scripts
echo ""
echo "📜 스크립트 확인 중..."

if [ -f "$PROJECT_ROOT/scripts/slack-notify.sh" ]; then
    if [ -x "$PROJECT_ROOT/scripts/slack-notify.sh" ]; then
        check_pass "slack-notify.sh (실행 가능)"
    else
        check_warn "slack-notify.sh가 실행 가능하지 않습니다."
        echo "   수정: chmod +x $PROJECT_ROOT/scripts/slack-notify.sh"
    fi
else
    check_fail "slack-notify.sh가 존재하지 않습니다."
fi

if [ -f "$PROJECT_ROOT/scripts/docker-setup.sh" ]; then
    if [ -x "$PROJECT_ROOT/scripts/docker-setup.sh" ]; then
        check_pass "docker-setup.sh (실행 가능)"
    else
        check_warn "docker-setup.sh가 실행 가능하지 않습니다."
        echo "   수정: chmod +x $PROJECT_ROOT/scripts/docker-setup.sh"
    fi
else
    check_fail "docker-setup.sh가 존재하지 않습니다."
fi

# 6. Check Git
echo ""
echo "📚 Git 확인 중..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    check_pass "Git 설치됨 (버전: $GIT_VERSION)"

    if [ -d "$PROJECT_ROOT/.git" ]; then
        check_pass "Git 저장소 초기화됨"

        BRANCH=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
        check_pass "현재 브랜치: $BRANCH"
    else
        check_warn "Git 저장소가 초기화되어 있지 않습니다."
        echo "   초기화: git init"
    fi
else
    check_fail "Git이 설치되어 있지 않습니다."
fi

# 7. Summary
echo ""
echo "================================================"
echo "  요약"
echo "================================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ 모든 사전조건이 충족되었습니다!${NC}"
    echo ""
    echo "다음 단계:"
    echo "  1. Docker 컨테이너 빌드: ./scripts/docker-setup.sh build"
    echo "  2. Docker 컨테이너 시작: ./scripts/docker-setup.sh start"
    echo "  3. 컨테이너 접속: docker exec -it cpp-dev-env zsh"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  경고 ${WARNINGS}개 발견${NC}"
    echo ""
    echo "선택사항이므로 진행할 수 있지만, 경고를 해결하는 것을 권장합니다."
    exit 0
else
    echo -e "${RED}❌ 오류 ${ERRORS}개, 경고 ${WARNINGS}개 발견${NC}"
    echo ""
    echo "오류를 해결한 후 다시 시도하세요."
    exit 1
fi
