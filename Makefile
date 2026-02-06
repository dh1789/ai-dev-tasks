# AI Dev Tasks - Installation Makefile
# Usage:
#   make install                                    # Install global skills
#   make install-project PROJECT_PATH=/path/to/project  # Install project resources
#   make check-global                               # Check global skills installation
#   make check-project PROJECT_PATH=/path/to/project    # Check project resources
#   make uninstall-global                           # Uninstall global skills
#   make uninstall-project PROJECT_PATH=/path/to/project # Uninstall project resources
#   make help                                       # Show this help

# Variables
AI_DEV_TASKS_DIR := $(shell pwd)
CLAUDE_SKILLS_DIR := $(HOME)/.claude/skills
CLAUDE_AGENTS_DIR := $(HOME)/.claude/agents
CLAUDE_DIR := $(HOME)/.claude
CLAUDE_SETTINGS := $(HOME)/.claude/settings.json

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m

# Phony targets
.PHONY: help install install-global install-project uninstall-global uninstall-project check-global check-project

# Default target
.DEFAULT_GOAL := help

# Help
help:
	@echo ""
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║         AI Dev Tasks - 설치 도구                            ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)사용법:$(NC)"
	@echo ""
	@echo "  $(YELLOW)make install$(NC)"
	@echo "    글로벌 스킬 및 서브에이전트 설치"
	@echo "    • 스킬: plan, implement → ~/.claude/skills/"
	@echo "    • 서브에이전트: planner, implementer, reviewer, orchestrator → ~/.claude/agents/"
	@echo "    • 공통 리소스: common/ → ~/.claude/agents/common/"
	@echo "    • 설정: settings.json → ~/.claude/settings.json"
	@echo "    • 리소스: ai-dev-tasks 전체 디렉토리 (scripts, docker 등)"
	@echo ""
	@echo "  $(YELLOW)make install-project PROJECT_PATH=/path/to/project$(NC)"
	@echo "    C++ 프로젝트에 Docker 리소스 링크 (docker/, Dockerfile)"
	@echo "    • 글로벌 설치 필수 (먼저 make install 실행)"
	@echo "    • Ruby/Node.js 프로젝트는 설치 불필요"
	@echo ""
	@echo "  $(YELLOW)make check-global$(NC)"
	@echo "    글로벌 스킬 설치 상태 확인"
	@echo ""
	@echo "  $(YELLOW)make check-project PROJECT_PATH=/path/to/project$(NC)"
	@echo "    프로젝트 리소스 설치 상태 확인"
	@echo ""
	@echo "  $(YELLOW)make uninstall-global$(NC)"
	@echo "    글로벌 스킬 및 리소스 제거"
	@echo ""
	@echo "  $(YELLOW)make uninstall-project PROJECT_PATH=/path/to/project$(NC)"
	@echo "    프로젝트 리소스 제거"
	@echo ""
	@echo "$(GREEN)예제:$(NC)"
	@echo ""
	@echo "  # 1. 글로벌 설치 (필수)"
	@echo "  make install"
	@echo ""
	@echo "  # 2. C++ 프로젝트에 Docker 리소스 링크 (C++ 프로젝트만)"
	@echo "  make install-project PROJECT_PATH=~/my-cpp-project"
	@echo ""
	@echo "  # 3. 설치 확인"
	@echo "  make check-global"
	@echo "  make check-project PROJECT_PATH=~/my-cpp-project"
	@echo ""
	@echo "  # 4. 스크립트 사용 (모든 프로젝트 타입)"
	@echo "  ~/.claude/skills/ai-dev-tasks/scripts/check-prerequisites.sh"
	@echo ""

# Install global skills
install: install-global

install-global:
	@echo ""
	@echo "$(BLUE)📦 글로벌 스킬 설치 중...$(NC)"
	@echo ""
	@mkdir -p $(CLAUDE_SKILLS_DIR)
	@if [ -L "$(CLAUDE_SKILLS_DIR)/plan" ]; then \
		echo "$(YELLOW)⚠️  plan 스킬이 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
		rm "$(CLAUDE_SKILLS_DIR)/plan"; \
	elif [ -e "$(CLAUDE_SKILLS_DIR)/plan" ]; then \
		echo "$(RED)❌ 오류: $(CLAUDE_SKILLS_DIR)/plan이 일반 파일/디렉토리로 존재합니다.$(NC)"; \
		echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv $(CLAUDE_SKILLS_DIR)/plan $(CLAUDE_SKILLS_DIR)/plan.backup$(NC)"; \
		exit 1; \
	fi
	@ln -s "$(AI_DEV_TASKS_DIR)/skill-plan" "$(CLAUDE_SKILLS_DIR)/plan"
	@echo "$(GREEN)✅ plan 스킬 설치 완료$(NC)"
	@if [ -L "$(CLAUDE_SKILLS_DIR)/implement" ]; then \
		echo "$(YELLOW)⚠️  implement 스킬이 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
		rm "$(CLAUDE_SKILLS_DIR)/implement"; \
	elif [ -e "$(CLAUDE_SKILLS_DIR)/implement" ]; then \
		echo "$(RED)❌ 오류: $(CLAUDE_SKILLS_DIR)/implement이 일반 파일/디렉토리로 존재합니다.$(NC)"; \
		echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv $(CLAUDE_SKILLS_DIR)/implement $(CLAUDE_SKILLS_DIR)/implement.backup$(NC)"; \
		exit 1; \
	fi
	@ln -s "$(AI_DEV_TASKS_DIR)/skill-implement" "$(CLAUDE_SKILLS_DIR)/implement"
	@echo "$(GREEN)✅ implement 스킬 설치 완료$(NC)"
	@if [ -L "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks" ]; then \
		echo "$(YELLOW)⚠️  ai-dev-tasks가 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
		rm "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks"; \
	elif [ -e "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks" ]; then \
		echo "$(RED)❌ 오류: $(CLAUDE_SKILLS_DIR)/ai-dev-tasks가 일반 파일/디렉토리로 존재합니다.$(NC)"; \
		echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv $(CLAUDE_SKILLS_DIR)/ai-dev-tasks $(CLAUDE_SKILLS_DIR)/ai-dev-tasks.backup$(NC)"; \
		exit 1; \
	fi
	@ln -s "$(AI_DEV_TASKS_DIR)" "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks"
	@echo "$(GREEN)✅ ai-dev-tasks 전체 리소스 설치 완료$(NC)"
	@echo ""
	@echo "$(BLUE)📋 서브에이전트 설치 중...$(NC)"
	@mkdir -p $(CLAUDE_AGENTS_DIR)
	@if [ -L "$(CLAUDE_AGENTS_DIR)/planner.md" ]; then \
		echo "$(YELLOW)⚠️  planner.md가 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
		rm "$(CLAUDE_AGENTS_DIR)/planner.md"; \
	elif [ -e "$(CLAUDE_AGENTS_DIR)/planner.md" ]; then \
		echo "$(RED)❌ 오류: $(CLAUDE_AGENTS_DIR)/planner.md가 일반 파일로 존재합니다.$(NC)"; \
		echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv $(CLAUDE_AGENTS_DIR)/planner.md $(CLAUDE_AGENTS_DIR)/planner.md.backup$(NC)"; \
		exit 1; \
	fi
	@ln -s "$(AI_DEV_TASKS_DIR)/.claude/agents/planner.md" "$(CLAUDE_AGENTS_DIR)/planner.md"
	@echo "$(GREEN)✅ planner.md 설치 완료$(NC)"
	@if [ -L "$(CLAUDE_AGENTS_DIR)/implementer.md" ]; then \
		echo "$(YELLOW)⚠️  implementer.md가 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
		rm "$(CLAUDE_AGENTS_DIR)/implementer.md"; \
	elif [ -e "$(CLAUDE_AGENTS_DIR)/implementer.md" ]; then \
		echo "$(RED)❌ 오류: $(CLAUDE_AGENTS_DIR)/implementer.md가 일반 파일로 존재합니다.$(NC)"; \
		echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv $(CLAUDE_AGENTS_DIR)/implementer.md $(CLAUDE_AGENTS_DIR)/implementer.md.backup$(NC)"; \
		exit 1; \
	fi
	@ln -s "$(AI_DEV_TASKS_DIR)/.claude/agents/implementer.md" "$(CLAUDE_AGENTS_DIR)/implementer.md"
	@echo "$(GREEN)✅ implementer.md 설치 완료$(NC)"
	@if [ -L "$(CLAUDE_AGENTS_DIR)/reviewer.md" ]; then \
		echo "$(YELLOW)⚠️  reviewer.md가 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
		rm "$(CLAUDE_AGENTS_DIR)/reviewer.md"; \
	elif [ -e "$(CLAUDE_AGENTS_DIR)/reviewer.md" ]; then \
		echo "$(RED)❌ 오류: $(CLAUDE_AGENTS_DIR)/reviewer.md가 일반 파일로 존재합니다.$(NC)"; \
		echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv $(CLAUDE_AGENTS_DIR)/reviewer.md $(CLAUDE_AGENTS_DIR)/reviewer.md.backup$(NC)"; \
		exit 1; \
	fi
	@ln -s "$(AI_DEV_TASKS_DIR)/.claude/agents/reviewer.md" "$(CLAUDE_AGENTS_DIR)/reviewer.md"
	@echo "$(GREEN)✅ reviewer.md 설치 완료$(NC)"
	@if [ -L "$(CLAUDE_AGENTS_DIR)/orchestrator.md" ]; then \
		echo "$(YELLOW)⚠️  orchestrator.md가 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
		rm "$(CLAUDE_AGENTS_DIR)/orchestrator.md"; \
	elif [ -e "$(CLAUDE_AGENTS_DIR)/orchestrator.md" ]; then \
		echo "$(RED)❌ 오류: $(CLAUDE_AGENTS_DIR)/orchestrator.md가 일반 파일로 존재합니다.$(NC)"; \
		echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv $(CLAUDE_AGENTS_DIR)/orchestrator.md $(CLAUDE_AGENTS_DIR)/orchestrator.md.backup$(NC)"; \
		exit 1; \
	fi
	@ln -s "$(AI_DEV_TASKS_DIR)/.claude/agents/orchestrator.md" "$(CLAUDE_AGENTS_DIR)/orchestrator.md"
	@echo "$(GREEN)✅ orchestrator.md 설치 완료$(NC)"
	@if [ -L "$(CLAUDE_AGENTS_DIR)/common" ]; then \
		echo "$(YELLOW)⚠️  common이 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
		rm "$(CLAUDE_AGENTS_DIR)/common"; \
	elif [ -e "$(CLAUDE_AGENTS_DIR)/common" ]; then \
		echo "$(RED)❌ 오류: $(CLAUDE_AGENTS_DIR)/common이 일반 디렉토리로 존재합니다.$(NC)"; \
		echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv $(CLAUDE_AGENTS_DIR)/common $(CLAUDE_AGENTS_DIR)/common.backup$(NC)"; \
		exit 1; \
	fi
	@ln -s "$(AI_DEV_TASKS_DIR)/.claude/agents/common" "$(CLAUDE_AGENTS_DIR)/common"
	@echo "$(GREEN)✅ common/ 디렉토리 설치 완료$(NC)"
	@echo ""
	@echo "$(BLUE)⚙️  설정 파일 설치 중...$(NC)"
	@if [ -L "$(CLAUDE_SETTINGS)" ]; then \
		echo "$(YELLOW)⚠️  settings.json이 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
		rm "$(CLAUDE_SETTINGS)"; \
	elif [ -e "$(CLAUDE_SETTINGS)" ]; then \
		echo "$(YELLOW)⚠️  settings.json이 이미 존재합니다. 백업 후 덮어씁니다.$(NC)"; \
		cp "$(CLAUDE_SETTINGS)" "$(CLAUDE_SETTINGS).backup"; \
		rm "$(CLAUDE_SETTINGS)"; \
	fi
	@ln -s "$(AI_DEV_TASKS_DIR)/settings.json" "$(CLAUDE_SETTINGS)"
	@echo "$(GREEN)✅ settings.json 설치 완료$(NC)"
	@echo ""
	@echo "$(GREEN)🎉 글로벌 스킬 및 서브에이전트 설치 완료!$(NC)"
	@echo ""
	@echo "$(BLUE)설치된 항목:$(NC)"
	@echo "  • ~/.claude/skills/plan → skill-plan/"
	@echo "  • ~/.claude/skills/implement → skill-implement/"
	@echo "  • ~/.claude/skills/ai-dev-tasks → 전체 리소스 (scripts, docker 등)"
	@echo "  • ~/.claude/agents/planner.md → .claude/agents/planner.md"
	@echo "  • ~/.claude/agents/implementer.md → .claude/agents/implementer.md"
	@echo "  • ~/.claude/agents/reviewer.md → .claude/agents/reviewer.md"
	@echo "  • ~/.claude/agents/orchestrator.md → .claude/agents/orchestrator.md"
	@echo "  • ~/.claude/agents/common/ → .claude/agents/common/"
	@echo "  • ~/.claude/settings.json → settings.json"
	@echo ""
	@echo "$(BLUE)다음 단계:$(NC)"
	@echo "  1. C++ 프로젝트에 Docker 리소스 링크: make install-project PROJECT_PATH=/path/to/project"
	@echo "  2. Claude Code에서 스킬 확인: /skill"
	@echo "  3. 서브에이전트 사용:"
	@echo "     Task(subagent_type='general-purpose',"
	@echo "          prompt='~/.claude/agents/planner.md 지침을 따라 PLAN.md를 작성하세요.')"
	@echo "  4. 스크립트 실행: ~/.claude/skills/ai-dev-tasks/scripts/check-prerequisites.sh"
	@echo ""

# Install project resources
install-project:
	@if [ -z "$(PROJECT_PATH)" ]; then \
		echo "$(RED)❌ 오류: PROJECT_PATH가 필요합니다.$(NC)"; \
		echo "$(YELLOW)사용법: make install-project PROJECT_PATH=/path/to/project$(NC)"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT_PATH)" ]; then \
		echo "$(RED)❌ 오류: 디렉토리가 존재하지 않습니다: $(PROJECT_PATH)$(NC)"; \
		exit 1; \
	fi
	@if [ ! -L "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks" ]; then \
		echo "$(RED)❌ 오류: 먼저 글로벌 스킬을 설치하세요.$(NC)"; \
		echo "$(YELLOW)실행: make install$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(BLUE)📦 프로젝트 리소스 설치 중: $(PROJECT_PATH)$(NC)"
	@echo ""
	@cd "$(PROJECT_PATH)" && \
	PROJECT_TYPE="" && \
	if [ -f "CMakeLists.txt" ]; then \
		PROJECT_TYPE="cpp"; \
		echo "$(GREEN)✅ C++ 프로젝트 감지$(NC)"; \
	elif [ -f "Gemfile" ]; then \
		PROJECT_TYPE="ruby"; \
		echo "$(GREEN)✅ Ruby/Rails 프로젝트 감지$(NC)"; \
	elif [ -f "package.json" ]; then \
		PROJECT_TYPE="nodejs"; \
		echo "$(GREEN)✅ Node.js/TypeScript 프로젝트 감지$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  프로젝트 타입을 감지할 수 없습니다.$(NC)"; \
	fi && \
	echo "" && \
	if [ "$$PROJECT_TYPE" = "cpp" ]; then \
		echo "$(BLUE)🐳 C++ 프로젝트 Docker 리소스 설치...$(NC)" && \
		if [ -L "docker" ]; then \
			echo "$(YELLOW)⚠️  docker가 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
			rm "docker"; \
		elif [ -e "docker" ]; then \
			echo "$(RED)❌ 오류: docker가 일반 디렉토리로 존재합니다.$(NC)"; \
			echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv docker docker.backup$(NC)"; \
			exit 1; \
		fi && \
		ln -s "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks/docker" "docker" && \
		echo "$(GREEN)✅ docker 링크 생성 완료 → ~/.claude/skills/ai-dev-tasks/docker$(NC)" && \
		if [ -L "Dockerfile.gcc15.1_22.04" ]; then \
			echo "$(YELLOW)⚠️  Dockerfile.gcc15.1_22.04가 이미 링크로 존재합니다. 덮어씁니다.$(NC)"; \
			rm "Dockerfile.gcc15.1_22.04"; \
		elif [ -e "Dockerfile.gcc15.1_22.04" ]; then \
			echo "$(RED)❌ 오류: Dockerfile.gcc15.1_22.04가 일반 파일로 존재합니다.$(NC)"; \
			echo "$(YELLOW)   수동으로 백업 후 제거하세요: mv Dockerfile.gcc15.1_22.04 Dockerfile.gcc15.1_22.04.backup$(NC)"; \
			exit 1; \
		fi && \
		ln -s "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks/Dockerfile.gcc15.1_22.04" "Dockerfile.gcc15.1_22.04" && \
		echo "$(GREEN)✅ Dockerfile.gcc15.1_22.04 링크 생성 완료 → ~/.claude/skills/ai-dev-tasks/Dockerfile.gcc15.1_22.04$(NC)" && \
		echo "" && \
		echo "$(GREEN)🎉 C++ 프로젝트 리소스 설치 완료!$(NC)" && \
		echo "" && \
		echo "$(BLUE)다음 단계:$(NC)" && \
		echo "  1. Docker 빌드: ~/.claude/skills/ai-dev-tasks/scripts/docker-setup.sh build" && \
		echo "  2. Docker 시작: ~/.claude/skills/ai-dev-tasks/scripts/docker-setup.sh start" && \
		echo "  3. 사전조건 확인: ~/.claude/skills/ai-dev-tasks/scripts/check-prerequisites.sh" && \
		echo "  4. Claude Code에서 /skill plan 실행"; \
	else \
		echo "$(YELLOW)ℹ️  C++ 프로젝트가 아닙니다. 프로젝트별 설치가 필요하지 않습니다.$(NC)" && \
		echo "" && \
		echo "$(BLUE)스크립트 사용:$(NC)" && \
		echo "  ~/.claude/skills/ai-dev-tasks/scripts/ 에서 필요한 스크립트를 직접 실행하세요."; \
	fi && \
	echo ""

# Uninstall global skills
uninstall-global:
	@echo ""
	@echo "$(BLUE)🗑️  글로벌 스킬 제거 중...$(NC)"
	@echo ""
	@if [ -L "$(CLAUDE_SKILLS_DIR)/plan" ]; then \
		rm "$(CLAUDE_SKILLS_DIR)/plan" && \
		echo "$(GREEN)✅ plan 스킬 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  plan 스킬이 링크로 존재하지 않습니다.$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_SKILLS_DIR)/implement" ]; then \
		rm "$(CLAUDE_SKILLS_DIR)/implement" && \
		echo "$(GREEN)✅ implement 스킬 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  implement 스킬이 링크로 존재하지 않습니다.$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks" ]; then \
		rm "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks" && \
		echo "$(GREEN)✅ ai-dev-tasks 리소스 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  ai-dev-tasks가 링크로 존재하지 않습니다.$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_AGENTS_DIR)/planner.md" ]; then \
		rm "$(CLAUDE_AGENTS_DIR)/planner.md" && \
		echo "$(GREEN)✅ planner.md 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  planner.md가 링크로 존재하지 않습니다.$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_AGENTS_DIR)/implementer.md" ]; then \
		rm "$(CLAUDE_AGENTS_DIR)/implementer.md" && \
		echo "$(GREEN)✅ implementer.md 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  implementer.md가 링크로 존재하지 않습니다.$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_AGENTS_DIR)/reviewer.md" ]; then \
		rm "$(CLAUDE_AGENTS_DIR)/reviewer.md" && \
		echo "$(GREEN)✅ reviewer.md 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  reviewer.md가 링크로 존재하지 않습니다.$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_AGENTS_DIR)/orchestrator.md" ]; then \
		rm "$(CLAUDE_AGENTS_DIR)/orchestrator.md" && \
		echo "$(GREEN)✅ orchestrator.md 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  orchestrator.md가 링크로 존재하지 않습니다.$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_AGENTS_DIR)/common" ]; then \
		rm "$(CLAUDE_AGENTS_DIR)/common" && \
		echo "$(GREEN)✅ common/ 디렉토리 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  common이 링크로 존재하지 않습니다.$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_SETTINGS)" ]; then \
		rm "$(CLAUDE_SETTINGS)" && \
		echo "$(GREEN)✅ settings.json 제거 완료$(NC)"; \
		if [ -e "$(CLAUDE_SETTINGS).backup" ]; then \
			mv "$(CLAUDE_SETTINGS).backup" "$(CLAUDE_SETTINGS)" && \
			echo "$(GREEN)   → 백업에서 원래 settings.json 복원됨$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)⚠️  settings.json이 링크로 존재하지 않습니다.$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)✅ 글로벌 스킬 및 서브에이전트 제거 완료$(NC)"
	@echo ""

# Uninstall project resources
uninstall-project:
	@if [ -z "$(PROJECT_PATH)" ]; then \
		echo "$(RED)❌ 오류: PROJECT_PATH가 필요합니다.$(NC)"; \
		echo "$(YELLOW)사용법: make uninstall-project PROJECT_PATH=/path/to/project$(NC)"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT_PATH)" ]; then \
		echo "$(RED)❌ 오류: 디렉토리가 존재하지 않습니다: $(PROJECT_PATH)$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(BLUE)🗑️  프로젝트 리소스 제거 중: $(PROJECT_PATH)$(NC)"
	@echo ""
	@cd "$(PROJECT_PATH)" && \
	if [ -L "docker" ]; then \
		rm "docker" && \
		echo "$(GREEN)✅ docker 링크 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  docker 링크가 존재하지 않습니다.$(NC)"; \
	fi && \
	if [ -L "Dockerfile.gcc15.1_22.04" ]; then \
		rm "Dockerfile.gcc15.1_22.04" && \
		echo "$(GREEN)✅ Dockerfile.gcc15.1_22.04 링크 제거 완료$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Dockerfile.gcc15.1_22.04 링크가 존재하지 않습니다.$(NC)"; \
	fi && \
	echo "" && \
	echo "$(GREEN)✅ 프로젝트 리소스 제거 완료$(NC)" && \
	echo ""

# Check global skills installation
check-global:
	@echo ""
	@echo "$(BLUE)🔍 글로벌 스킬 설치 확인 중...$(NC)"
	@echo ""
	@if [ -L "$(CLAUDE_SKILLS_DIR)/plan" ]; then \
		PLAN_TARGET=$$(readlink "$(CLAUDE_SKILLS_DIR)/plan"); \
		if [ "$$PLAN_TARGET" = "$(AI_DEV_TASKS_DIR)/skill-plan" ]; then \
			echo "$(GREEN)✅ plan 스킬: 올바르게 설치됨$(NC)"; \
			echo "   → $(CLAUDE_SKILLS_DIR)/plan → $$PLAN_TARGET"; \
		else \
			echo "$(YELLOW)⚠️  plan 스킬: 다른 경로를 가리킴$(NC)"; \
			echo "   → $(CLAUDE_SKILLS_DIR)/plan → $$PLAN_TARGET"; \
		fi; \
	else \
		echo "$(RED)❌ plan 스킬: 설치되지 않음$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_SKILLS_DIR)/implement" ]; then \
		IMPLEMENT_TARGET=$$(readlink "$(CLAUDE_SKILLS_DIR)/implement"); \
		if [ "$$IMPLEMENT_TARGET" = "$(AI_DEV_TASKS_DIR)/skill-implement" ]; then \
			echo "$(GREEN)✅ implement 스킬: 올바르게 설치됨$(NC)"; \
			echo "   → $(CLAUDE_SKILLS_DIR)/implement → $$IMPLEMENT_TARGET"; \
		else \
			echo "$(YELLOW)⚠️  implement 스킬: 다른 경로를 가리킴$(NC)"; \
			echo "   → $(CLAUDE_SKILLS_DIR)/implement → $$IMPLEMENT_TARGET"; \
		fi; \
	else \
		echo "$(RED)❌ implement 스킬: 설치되지 않음$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks" ]; then \
		AI_DEV_TASKS_TARGET=$$(readlink "$(CLAUDE_SKILLS_DIR)/ai-dev-tasks"); \
		if [ "$$AI_DEV_TASKS_TARGET" = "$(AI_DEV_TASKS_DIR)" ]; then \
			echo "$(GREEN)✅ ai-dev-tasks 리소스: 올바르게 설치됨$(NC)"; \
			echo "   → $(CLAUDE_SKILLS_DIR)/ai-dev-tasks → $$AI_DEV_TASKS_TARGET"; \
		else \
			echo "$(YELLOW)⚠️  ai-dev-tasks 리소스: 다른 경로를 가리킴$(NC)"; \
			echo "   → $(CLAUDE_SKILLS_DIR)/ai-dev-tasks → $$AI_DEV_TASKS_TARGET"; \
		fi; \
	else \
		echo "$(RED)❌ ai-dev-tasks 리소스: 설치되지 않음$(NC)"; \
	fi
	@echo ""
	@echo "$(BLUE)서브에이전트 확인:$(NC)"
	@if [ -L "$(CLAUDE_AGENTS_DIR)/planner.md" ]; then \
		PLANNER_TARGET=$$(readlink "$(CLAUDE_AGENTS_DIR)/planner.md"); \
		if [ "$$PLANNER_TARGET" = "$(AI_DEV_TASKS_DIR)/.claude/agents/planner.md" ]; then \
			echo "$(GREEN)✅ planner.md: 올바르게 설치됨$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/planner.md → $$PLANNER_TARGET"; \
		else \
			echo "$(YELLOW)⚠️  planner.md: 다른 경로를 가리킴$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/planner.md → $$PLANNER_TARGET"; \
		fi; \
	else \
		echo "$(RED)❌ planner.md: 설치되지 않음$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_AGENTS_DIR)/implementer.md" ]; then \
		IMPLEMENTER_TARGET=$$(readlink "$(CLAUDE_AGENTS_DIR)/implementer.md"); \
		if [ "$$IMPLEMENTER_TARGET" = "$(AI_DEV_TASKS_DIR)/.claude/agents/implementer.md" ]; then \
			echo "$(GREEN)✅ implementer.md: 올바르게 설치됨$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/implementer.md → $$IMPLEMENTER_TARGET"; \
		else \
			echo "$(YELLOW)⚠️  implementer.md: 다른 경로를 가리킴$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/implementer.md → $$IMPLEMENTER_TARGET"; \
		fi; \
	else \
		echo "$(RED)❌ implementer.md: 설치되지 않음$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_AGENTS_DIR)/reviewer.md" ]; then \
		REVIEWER_TARGET=$$(readlink "$(CLAUDE_AGENTS_DIR)/reviewer.md"); \
		if [ "$$REVIEWER_TARGET" = "$(AI_DEV_TASKS_DIR)/.claude/agents/reviewer.md" ]; then \
			echo "$(GREEN)✅ reviewer.md: 올바르게 설치됨$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/reviewer.md → $$REVIEWER_TARGET"; \
		else \
			echo "$(YELLOW)⚠️  reviewer.md: 다른 경로를 가리킴$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/reviewer.md → $$REVIEWER_TARGET"; \
		fi; \
	else \
		echo "$(RED)❌ reviewer.md: 설치되지 않음$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_AGENTS_DIR)/orchestrator.md" ]; then \
		ORCHESTRATOR_TARGET=$$(readlink "$(CLAUDE_AGENTS_DIR)/orchestrator.md"); \
		if [ "$$ORCHESTRATOR_TARGET" = "$(AI_DEV_TASKS_DIR)/.claude/agents/orchestrator.md" ]; then \
			echo "$(GREEN)✅ orchestrator.md: 올바르게 설치됨$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/orchestrator.md → $$ORCHESTRATOR_TARGET"; \
		else \
			echo "$(YELLOW)⚠️  orchestrator.md: 다른 경로를 가리킴$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/orchestrator.md → $$ORCHESTRATOR_TARGET"; \
		fi; \
	else \
		echo "$(RED)❌ orchestrator.md: 설치되지 않음$(NC)"; \
	fi
	@if [ -L "$(CLAUDE_AGENTS_DIR)/common" ]; then \
		COMMON_TARGET=$$(readlink "$(CLAUDE_AGENTS_DIR)/common"); \
		if [ "$$COMMON_TARGET" = "$(AI_DEV_TASKS_DIR)/.claude/agents/common" ]; then \
			echo "$(GREEN)✅ common/: 올바르게 설치됨$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/common → $$COMMON_TARGET"; \
		else \
			echo "$(YELLOW)⚠️  common/: 다른 경로를 가리킴$(NC)"; \
			echo "   → $(CLAUDE_AGENTS_DIR)/common → $$COMMON_TARGET"; \
		fi; \
	else \
		echo "$(RED)❌ common/: 설치되지 않음$(NC)"; \
	fi
	@echo ""
	@echo "$(BLUE)설정 파일 확인:$(NC)"
	@if [ -L "$(CLAUDE_SETTINGS)" ]; then \
		SETTINGS_TARGET=$$(readlink "$(CLAUDE_SETTINGS)"); \
		if [ "$$SETTINGS_TARGET" = "$(AI_DEV_TASKS_DIR)/settings.json" ]; then \
			echo "$(GREEN)✅ settings.json: 올바르게 설치됨$(NC)"; \
			echo "   → $(CLAUDE_SETTINGS) → $$SETTINGS_TARGET"; \
		else \
			echo "$(YELLOW)⚠️  settings.json: 다른 경로를 가리킴$(NC)"; \
			echo "   → $(CLAUDE_SETTINGS) → $$SETTINGS_TARGET"; \
		fi; \
	else \
		echo "$(RED)❌ settings.json: 설치되지 않음$(NC)"; \
	fi
	@echo ""

# Check project resources installation
check-project:
	@if [ -z "$(PROJECT_PATH)" ]; then \
		echo "$(RED)❌ 오류: PROJECT_PATH가 필요합니다.$(NC)"; \
		echo "$(YELLOW)사용법: make check-project PROJECT_PATH=/path/to/project$(NC)"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT_PATH)" ]; then \
		echo "$(RED)❌ 오류: 디렉토리가 존재하지 않습니다: $(PROJECT_PATH)$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(BLUE)🔍 프로젝트 리소스 설치 확인 중: $(PROJECT_PATH)$(NC)"
	@echo ""
	@cd "$(PROJECT_PATH)" && \
	PROJECT_TYPE="" && \
	if [ -f "CMakeLists.txt" ]; then \
		PROJECT_TYPE="cpp"; \
		echo "$(BLUE)프로젝트 타입: C++$(NC)"; \
		if [ -L "docker" ]; then \
			DOCKER_TARGET=$$(readlink "docker"); \
			echo "$(GREEN)✅ docker: 링크로 설치됨$(NC)"; \
			echo "   → docker → $$DOCKER_TARGET"; \
		else \
			echo "$(RED)❌ docker: 설치되지 않음$(NC)"; \
		fi; \
		if [ -L "Dockerfile.gcc15.1_22.04" ]; then \
			DOCKERFILE_TARGET=$$(readlink "Dockerfile.gcc15.1_22.04"); \
			echo "$(GREEN)✅ Dockerfile.gcc15.1_22.04: 링크로 설치됨$(NC)"; \
			echo "   → Dockerfile.gcc15.1_22.04 → $$DOCKERFILE_TARGET"; \
		else \
			echo "$(RED)❌ Dockerfile.gcc15.1_22.04: 설치되지 않음$(NC)"; \
		fi; \
	elif [ -f "Gemfile" ]; then \
		PROJECT_TYPE="ruby"; \
		echo "$(BLUE)프로젝트 타입: Ruby/Rails$(NC)"; \
		echo "$(YELLOW)ℹ️  프로젝트별 설치 불필요. ~/.claude/skills/ai-dev-tasks/scripts/ 에서 스크립트 사용 가능.$(NC)"; \
	elif [ -f "package.json" ]; then \
		PROJECT_TYPE="nodejs"; \
		echo "$(BLUE)프로젝트 타입: Node.js/TypeScript$(NC)"; \
		echo "$(YELLOW)ℹ️  프로젝트별 설치 불필요. ~/.claude/skills/ai-dev-tasks/scripts/ 에서 스크립트 사용 가능.$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  프로젝트 타입을 감지할 수 없습니다.$(NC)"; \
	fi && \
	echo ""
