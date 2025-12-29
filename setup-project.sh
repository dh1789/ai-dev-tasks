#!/usr/bin/env bash
###############################################################################
# AI Dev Tasks - 프로젝트 자동 설정 스크립트
# 프로젝트별로 scripts 디렉토리 및 필요한 파일들을 심볼릭 링크로 연결
###############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         AI Dev Tasks - 프로젝트 자동 설정 스크립트          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# 프로젝트 디렉토리로 이동
cd "$PROJECT_DIR"
PROJECT_DIR="$(pwd)"

print_info "프로젝트 디렉토리: $PROJECT_DIR"
echo ""

###############################################################################
# 1. 프로젝트 타입 감지
###############################################################################
print_info "🔍 프로젝트 타입 감지 중..."

if [[ -f "Gemfile" ]]; then
    print_success "Ruby/Rails 프로젝트 감지"
    PROJECT_TYPE="ruby"
elif [[ -f "package.json" ]]; then
    print_success "Node.js/TypeScript 프로젝트 감지"
    PROJECT_TYPE="nodejs"
elif [[ -f "CMakeLists.txt" ]]; then
    print_success "C++ 프로젝트 감지"
    PROJECT_TYPE="cpp"
else
    print_warning "프로젝트 타입을 감지할 수 없습니다"
    print_info "수동으로 scripts 링크를 생성합니다"
    PROJECT_TYPE="unknown"
fi

echo ""

###############################################################################
# 2. scripts/ai-dev-tasks 디렉토리 링크
###############################################################################
print_info "📁 scripts/ai-dev-tasks 디렉토리 설정 중..."

# scripts 디렉토리가 존재하지 않으면 생성
if [[ ! -e "scripts" ]]; then
    mkdir -p scripts
    print_info "scripts 디렉토리 생성 완료"
fi

# scripts가 심볼릭 링크인 경우 (기존 방식)
if [[ -L "scripts" ]]; then
    LINK_TARGET=$(readlink scripts)
    if [[ "$LINK_TARGET" == "$SCRIPT_DIR/scripts" ]]; then
        print_warning "기존 방식으로 설정되어 있습니다 (전체 scripts 링크)"
        print_info "서브디렉토리 방식(scripts/ai-dev-tasks/)으로 마이그레이션하시겠습니까? (y/N)"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            rm scripts
            mkdir -p scripts
            ln -s "$SCRIPT_DIR/scripts" ./scripts/ai-dev-tasks
            print_success "서브디렉토리 방식으로 마이그레이션 완료"
        else
            print_info "기존 설정 유지 (변경 없음)"
        fi
    else
        print_warning "scripts가 다른 위치를 가리킴: $LINK_TARGET"
        print_info "scripts/ai-dev-tasks 서브디렉토리를 생성하시겠습니까? (y/N)"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            rm scripts
            mkdir -p scripts
            ln -s "$SCRIPT_DIR/scripts" ./scripts/ai-dev-tasks
            print_success "scripts/ai-dev-tasks 링크 생성 완료"
        fi
    fi
elif [[ -d "scripts" ]]; then
    # scripts가 일반 디렉토리인 경우 (C++ 프로젝트 등)
    if [[ -e "scripts/ai-dev-tasks" ]]; then
        if [[ -L "scripts/ai-dev-tasks" ]]; then
            LINK_TARGET=$(readlink scripts/ai-dev-tasks)
            if [[ "$LINK_TARGET" == "$SCRIPT_DIR/scripts" ]]; then
                print_success "scripts/ai-dev-tasks 이미 올바르게 링크됨"
            else
                print_warning "scripts/ai-dev-tasks가 다른 위치를 가리킴: $LINK_TARGET"
                print_info "재생성하시겠습니까? (y/N)"
                read -r answer
                if [[ "$answer" =~ ^[Yy]$ ]]; then
                    rm scripts/ai-dev-tasks
                    ln -s "$SCRIPT_DIR/scripts" ./scripts/ai-dev-tasks
                    print_success "scripts/ai-dev-tasks 링크 재생성 완료"
                fi
            fi
        else
            print_error "scripts/ai-dev-tasks가 이미 일반 디렉토리로 존재합니다"
            print_info "백업 후 링크로 변경하시겠습니까? (y/N)"
            read -r answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                mv scripts/ai-dev-tasks scripts/ai-dev-tasks.backup
                ln -s "$SCRIPT_DIR/scripts" ./scripts/ai-dev-tasks
                print_success "scripts/ai-dev-tasks 백업 및 링크 생성 완료"
                print_info "백업 위치: $PROJECT_DIR/scripts/ai-dev-tasks.backup"
            fi
        fi
    else
        # scripts/ai-dev-tasks가 존재하지 않음 - 서브디렉토리 생성
        ln -s "$SCRIPT_DIR/scripts" ./scripts/ai-dev-tasks
        print_success "scripts/ai-dev-tasks 링크 생성 완료 (기존 scripts 유지)"
    fi
fi

echo ""

###############################################################################
# 3. C++ 프로젝트 추가 설정
###############################################################################
if [[ "$PROJECT_TYPE" == "cpp" ]]; then
    print_info "🐳 C++ 프로젝트 추가 설정 중..."

    # docker 디렉토리
    if [[ -e "docker" ]]; then
        if [[ -L "docker" ]]; then
            print_success "docker 디렉토리 이미 링크됨"
        else
            print_warning "docker가 이미 일반 디렉토리로 존재합니다"
        fi
    else
        ln -s "$SCRIPT_DIR/docker" ./docker
        print_success "docker 디렉토리 링크 생성 완료"
    fi

    # Dockerfile
    if [[ -e "Dockerfile.gcc15.1_22.04" ]]; then
        if [[ -L "Dockerfile.gcc15.1_22.04" ]]; then
            print_success "Dockerfile 이미 링크됨"
        else
            print_warning "Dockerfile.gcc15.1_22.04가 이미 파일로 존재합니다"
        fi
    else
        ln -s "$SCRIPT_DIR/Dockerfile.gcc15.1_22.04" ./Dockerfile.gcc15.1_22.04
        print_success "Dockerfile 링크 생성 완료"
    fi

    echo ""
fi

###############################################################################
# 4. 실행 권한 부여
###############################################################################
print_info "🔑 스크립트 실행 권한 부여 중..."

# 기존 방식 (전체 scripts 링크)인 경우
if [[ -L "scripts" ]] && [[ ! -e "scripts/ai-dev-tasks" ]]; then
    chmod +x scripts/*.sh 2>/dev/null || true
# 서브디렉토리 방식인 경우
elif [[ -e "scripts/ai-dev-tasks" ]]; then
    chmod +x scripts/ai-dev-tasks/*.sh 2>/dev/null || true
fi

print_success "스크립트 실행 권한 부여 완료"

echo ""

###############################################################################
# 5. .gitignore 업데이트 (선택사항)
###############################################################################
if [[ -f ".gitignore" ]]; then
    print_info "📝 .gitignore 업데이트 확인 중..."

    NEEDS_UPDATE=false

    # 기존 방식(전체 scripts 링크) 또는 서브디렉토리 방식 확인
    if [[ -L "scripts" ]] && [[ ! -e "scripts/ai-dev-tasks" ]]; then
        # 기존 방식: scripts 전체를 무시
        if ! grep -q "^scripts$" .gitignore 2>/dev/null; then
            NEEDS_UPDATE=true
        fi
    elif [[ -e "scripts/ai-dev-tasks" ]]; then
        # 서브디렉토리 방식: scripts/ai-dev-tasks만 무시
        if ! grep -q "^scripts/ai-dev-tasks$" .gitignore 2>/dev/null; then
            NEEDS_UPDATE=true
        fi
    fi

    if [[ "$PROJECT_TYPE" == "cpp" ]]; then
        if ! grep -q "^docker$" .gitignore 2>/dev/null; then
            NEEDS_UPDATE=true
        fi
        if ! grep -q "^Dockerfile.gcc15.1_22.04$" .gitignore 2>/dev/null; then
            NEEDS_UPDATE=true
        fi
    fi

    if [[ "$NEEDS_UPDATE" == true ]]; then
        print_warning ".gitignore에 심볼릭 링크 추가를 권장합니다"
        print_info ".gitignore를 업데이트하시겠습니까? (y/N)"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            echo "" >> .gitignore
            echo "# AI Dev Tasks 심볼릭 링크" >> .gitignore

            # 기존 방식 또는 서브디렉토리 방식에 따라 다르게 추가
            if [[ -L "scripts" ]] && [[ ! -e "scripts/ai-dev-tasks" ]]; then
                echo "scripts" >> .gitignore
            elif [[ -e "scripts/ai-dev-tasks" ]]; then
                echo "scripts/ai-dev-tasks" >> .gitignore
            fi

            if [[ "$PROJECT_TYPE" == "cpp" ]]; then
                echo "docker" >> .gitignore
                echo "Dockerfile.gcc15.1_22.04" >> .gitignore
            fi

            print_success ".gitignore 업데이트 완료"
        fi
    else
        print_success ".gitignore 이미 최신 상태"
    fi

    echo ""
fi

###############################################################################
# 6. 사전조건 확인
###############################################################################
print_info "📋 사전조건 확인 중..."
echo ""

# 기존 방식 또는 서브디렉토리 방식에 따라 스크립트 경로 결정
if [[ -L "scripts" ]] && [[ ! -e "scripts/ai-dev-tasks" ]]; then
    PREREQ_SCRIPT="scripts/check-prerequisites.sh"
elif [[ -e "scripts/ai-dev-tasks" ]]; then
    PREREQ_SCRIPT="scripts/ai-dev-tasks/check-prerequisites.sh"
else
    print_error "scripts 디렉토리 설정을 찾을 수 없습니다"
    exit 1
fi

if [[ -x "$PREREQ_SCRIPT" ]]; then
    ./"$PREREQ_SCRIPT"
else
    print_error "$PREREQ_SCRIPT가 실행 가능하지 않습니다"
    exit 1
fi

echo ""

###############################################################################
# 7. 완료 메시지
###############################################################################
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  🎉 설정 완료!                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

print_success "AI Dev Tasks가 프로젝트에 성공적으로 설정되었습니다"
echo ""

print_info "다음 명령어로 시작하세요:"
echo ""
echo "  📝 계획 수립:"
echo "     /skill plan \"기능 설명\""
echo ""
echo "  🚀 구현 실행:"
echo "     /skill implement \"feature-name\""
echo ""

# 스크립트 경로 결정 (기존 방식 vs 서브디렉토리 방식)
if [[ -L "scripts" ]] && [[ ! -e "scripts/ai-dev-tasks" ]]; then
    SCRIPTS_PATH="./scripts"
elif [[ -e "scripts/ai-dev-tasks" ]]; then
    SCRIPTS_PATH="./scripts/ai-dev-tasks"
else
    SCRIPTS_PATH="./scripts"
fi

if [[ "$PROJECT_TYPE" == "cpp" ]]; then
    print_info "C++ 프로젝트 추가 단계:"
    echo ""
    echo "  🐳 Docker 컨테이너 빌드:"
    echo "     ${SCRIPTS_PATH}/docker-setup.sh build"
    echo ""
    echo "  🐳 Docker 컨테이너 시작:"
    echo "     ${SCRIPTS_PATH}/docker-setup.sh start"
    echo ""
fi

print_info "프로젝트 타입 감지:"
echo "     ${SCRIPTS_PATH}/detect-project-type.sh"
echo ""

print_info "품질 검사 실행:"
case "$PROJECT_TYPE" in
    ruby)
        echo "     ${SCRIPTS_PATH}/ruby-quality-check.sh . 80"
        ;;
    nodejs)
        echo "     ${SCRIPTS_PATH}/node-quality-check.sh . 80"
        ;;
    cpp)
        if [[ "$SCRIPTS_PATH" == "./scripts" ]]; then
            echo "     docker exec cpp-dev-env ./scripts/cpp-quality-check.sh build 80"
        else
            echo "     docker exec cpp-dev-env ./scripts/ai-dev-tasks/cpp-quality-check.sh build 80"
        fi
        ;;
    *)
        echo "     ${SCRIPTS_PATH}/check-prerequisites.sh"
        ;;
esac

echo ""
