#!/usr/bin/env bash

# Docker Setup Script for AI Dev Tasks
# Sets up and starts the C++ development Docker container
# Usage: ./docker-setup.sh [build|start|stop|restart|status]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${NC}ℹ️  $1${NC}"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker가 설치되어 있지 않습니다."
        print_info "https://www.docker.com/get-started 에서 Docker를 설치하세요."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker 데몬이 실행 중이 아닙니다."
        print_info "Docker Desktop을 시작하세요."
        exit 1
    fi

    print_success "Docker 확인 완료"
}

# Check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose가 설치되어 있지 않습니다."
        exit 1
    fi

    print_success "Docker Compose 확인 완료"
}

# Check environment variables
check_env() {
    if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
        print_warning "SLACK_WEBHOOK_URL 환경 변수가 설정되어 있지 않습니다."
        print_info "Slack 알림을 사용하려면 다음을 실행하세요:"
        print_info "export SLACK_WEBHOOK_URL='your-webhook-url'"
    else
        print_success "환경 변수 확인 완료"
    fi
}

# Build Docker image
build_image() {
    print_info "Docker 이미지 빌드 중..."
    cd "$PROJECT_ROOT"

    if docker compose version &> /dev/null; then
        docker compose -f "$COMPOSE_FILE" build
    else
        docker-compose -f "$COMPOSE_FILE" build
    fi

    print_success "Docker 이미지 빌드 완료"
}

# Start container
start_container() {
    print_info "Docker 컨테이너 시작 중..."
    cd "$PROJECT_ROOT"

    if docker compose version &> /dev/null; then
        docker compose -f "$COMPOSE_FILE" up -d
    else
        docker-compose -f "$COMPOSE_FILE" up -d
    fi

    print_success "Docker 컨테이너 시작 완료"
    print_info "컨테이너에 접속하려면: docker exec -it cpp-dev-env zsh"
}

# Stop container
stop_container() {
    print_info "Docker 컨테이너 중지 중..."
    cd "$PROJECT_ROOT"

    if docker compose version &> /dev/null; then
        docker compose -f "$COMPOSE_FILE" down
    else
        docker-compose -f "$COMPOSE_FILE" down
    fi

    print_success "Docker 컨테이너 중지 완료"
}

# Restart container
restart_container() {
    stop_container
    start_container
}

# Check container status
check_status() {
    print_info "Docker 컨테이너 상태 확인 중..."

    if docker ps | grep -q cpp-dev-env; then
        print_success "컨테이너가 실행 중입니다."
        docker ps | grep cpp-dev-env
    else
        print_warning "컨테이너가 실행 중이 아닙니다."
        if docker ps -a | grep -q cpp-dev-env; then
            print_info "중지된 컨테이너가 존재합니다. 'start'를 실행하세요."
        else
            print_info "컨테이너가 존재하지 않습니다. 'build'를 먼저 실행하세요."
        fi
    fi
}

# Show usage
usage() {
    echo "사용법: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build    - Docker 이미지 빌드"
    echo "  start    - Docker 컨테이너 시작"
    echo "  stop     - Docker 컨테이너 중지"
    echo "  restart  - Docker 컨테이너 재시작"
    echo "  status   - Docker 컨테이너 상태 확인"
    echo ""
    echo "예제:"
    echo "  $0 build    # 이미지 빌드"
    echo "  $0 start    # 컨테이너 시작"
}

# Main
main() {
    COMMAND="${1:-status}"

    case "$COMMAND" in
        build)
            check_docker
            check_docker_compose
            build_image
            ;;
        start)
            check_docker
            check_docker_compose
            check_env
            start_container
            ;;
        stop)
            check_docker
            check_docker_compose
            stop_container
            ;;
        restart)
            check_docker
            check_docker_compose
            restart_container
            ;;
        status)
            check_docker
            check_status
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            print_error "알 수 없는 명령: $COMMAND"
            usage
            exit 1
            ;;
    esac
}

main "$@"
