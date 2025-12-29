# AI Dev Tasks 프로젝트별 환경 설정 가이드

이 가이드는 AI Dev Tasks 스킬 셋을 여러분의 프로젝트에서 사용하기 위한 환경 설정 방법을 설명합니다.

---

## 📋 목차

1. [기본 개념](#기본-개념)
2. [설정 방법](#설정-방법)
3. [프로젝트별 설정](#프로젝트별-설정)
4. [검증 및 테스트](#검증-및-테스트)
5. [문제 해결](#문제-해결)

---

## 🎯 기본 개념

### Claude Code 스킬 시스템

Claude Code는 프로젝트별로 **`.claude/skills/`** 디렉토리에서 커스텀 스킬을 로드합니다.

**구조:**
```
your-project/
├── .claude/
│   └── skills/
│       ├── plan/           # /skill plan 명령어
│       │   ├── SKILL.md
│       │   └── plan-template.md
│       └── implement/      # /skill implement 명령어
│           ├── SKILL.md
│           └── progress-template.md
├── scripts/                # 품질 검사 스크립트들
└── [프로젝트 파일들]
```

### 스킬 작동 원리

1. `/skill plan` 실행 시 → `.claude/skills/plan/SKILL.md` 로드
2. `/skill implement` 실행 시 → `.claude/skills/implement/SKILL.md` 로드
3. 스킬은 `scripts/` 디렉토리의 스크립트들을 호출

---

## 🚀 설정 방법

### 방법 1: 심볼릭 링크 사용 (권장)

ai-dev-tasks를 한 곳에 두고 여러 프로젝트에서 공유하는 방식입니다.

#### 1-1. ai-dev-tasks 클론

```bash
# 홈 디렉토리에 클론 (또는 원하는 위치)
cd ~
git clone https://github.com/YOUR_USERNAME/ai-dev-tasks.git
```

#### 1-2. 각 프로젝트에서 심볼릭 링크 생성

**Ruby/Rails 프로젝트 예제:**

```bash
cd ~/your-ruby-project

# .claude/skills 디렉토리 생성
mkdir -p .claude/skills

# 스킬 링크
ln -s ~/ai-dev-tasks/skill-plan .claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement .claude/skills/implement

# 스크립트 링크
ln -s ~/ai-dev-tasks/scripts ./scripts

# .gitignore에 추가 (선택사항)
echo ".claude/skills/plan" >> .gitignore
echo ".claude/skills/implement" >> .gitignore
echo "scripts" >> .gitignore
```

**Node.js/TypeScript 프로젝트 예제:**

```bash
cd ~/your-nodejs-project

# .claude/skills 디렉토리 생성
mkdir -p .claude/skills

# 스킬 링크
ln -s ~/ai-dev-tasks/skill-plan .claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement .claude/skills/implement

# 스크립트 링크
ln -s ~/ai-dev-tasks/scripts ./scripts
```

**C++ 프로젝트 예제:**

```bash
cd ~/your-cpp-project

# .claude/skills 디렉토리 생성
mkdir -p .claude/skills

# 스킬 링크
ln -s ~/ai-dev-tasks/skill-plan .claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement .claude/skills/implement

# 스크립트 및 Docker 설정 링크
ln -s ~/ai-dev-tasks/scripts ./scripts
ln -s ~/ai-dev-tasks/docker ./docker
ln -s ~/ai-dev-tasks/Dockerfile.gcc15.1_22.04 ./Dockerfile.gcc15.1_22.04
```

#### 1-3. 장점

- ✅ ai-dev-tasks를 한 곳에서 관리
- ✅ 업데이트 시 모든 프로젝트에 자동 반영
- ✅ 디스크 공간 절약
- ✅ 일관된 품질 표준 유지

#### 1-4. 단점

- ⚠️ 심볼릭 링크가 깨지면 작동 안 함
- ⚠️ Windows에서는 관리자 권한 필요

---

### 방법 2: 파일 복사 사용

각 프로젝트에 독립적으로 복사하는 방식입니다.

#### 2-1. ai-dev-tasks 클론

```bash
cd ~
git clone https://github.com/YOUR_USERNAME/ai-dev-tasks.git
```

#### 2-2. 각 프로젝트에 복사

```bash
cd ~/your-project

# .claude/skills 디렉토리 생성
mkdir -p .claude/skills

# 스킬 복사
cp -r ~/ai-dev-tasks/skill-plan .claude/skills/plan
cp -r ~/ai-dev-tasks/skill-implement .claude/skills/implement

# 스크립트 복사
cp -r ~/ai-dev-tasks/scripts ./scripts

# C++ 프로젝트는 추가로
cp -r ~/ai-dev-tasks/docker ./docker
cp ~/ai-dev-tasks/Dockerfile.gcc15.1_22.04 ./Dockerfile.gcc15.1_22.04
```

#### 2-3. 장점

- ✅ 독립적으로 커스터마이징 가능
- ✅ 심볼릭 링크 문제 없음
- ✅ Windows에서도 동일하게 작동

#### 2-4. 단점

- ⚠️ 업데이트 시 모든 프로젝트에 수동 복사 필요
- ⚠️ 디스크 공간 더 많이 사용
- ⚠️ 프로젝트마다 다른 버전 사용 가능 (일관성 문제)

---

### 방법 3: Git Submodule 사용 (고급)

ai-dev-tasks를 서브모듈로 추가하는 방식입니다.

#### 3-1. 서브모듈 추가

```bash
cd ~/your-project

# 서브모듈 추가
git submodule add https://github.com/YOUR_USERNAME/ai-dev-tasks.git .ai-dev-tasks

# 심볼릭 링크 생성
mkdir -p .claude/skills
ln -s ../../.ai-dev-tasks/skill-plan .claude/skills/plan
ln -s ../../.ai-dev-tasks/skill-implement .claude/skills/implement
ln -s .ai-dev-tasks/scripts ./scripts

# C++ 프로젝트는 추가로
ln -s .ai-dev-tasks/docker ./docker
ln -s .ai-dev-tasks/Dockerfile.gcc15.1_22.04 ./Dockerfile.gcc15.1_22.04
```

#### 3-2. 서브모듈 업데이트

```bash
# 최신 버전으로 업데이트
git submodule update --remote .ai-dev-tasks

# 커밋
git add .ai-dev-tasks
git commit -m "chore: update ai-dev-tasks submodule"
```

#### 3-3. 팀원이 클론할 때

```bash
# 서브모듈 포함 클론
git clone --recurse-submodules https://github.com/YOUR/project.git

# 또는 기존 클론에 서브모듈 초기화
git submodule init
git submodule update
```

#### 3-4. 장점

- ✅ Git으로 버전 관리
- ✅ 팀 전체가 동일한 버전 사용
- ✅ 업데이트 추적 가능

#### 3-4. 단점

- ⚠️ Git 서브모듈 이해 필요
- ⚠️ 클론 시 `--recurse-submodules` 옵션 필요
- ⚠️ 초기 설정 복잡

---

## 🔧 프로젝트별 설정

### Ruby/Rails 프로젝트

```bash
cd ~/your-rails-project

# 방법 1: 심볼릭 링크 (권장)
mkdir -p .claude/skills
ln -s ~/ai-dev-tasks/skill-plan .claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement .claude/skills/implement
ln -s ~/ai-dev-tasks/scripts ./scripts

# 실행 권한 확인
chmod +x scripts/*.sh

# 사전조건 확인
./scripts/check-prerequisites.sh

# 출력 예시:
# ✅ Ruby 설치됨 (버전: 3.3.6)
# ✅ Bundler 설치됨 (버전: 2.5.23)
# ✅ Rails 설치됨 (버전: 8.0.2)
```

### Node.js/TypeScript 프로젝트

```bash
cd ~/your-nodejs-project

# 방법 1: 심볼릭 링크 (권장)
mkdir -p .claude/skills
ln -s ~/ai-dev-tasks/skill-plan .claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement .claude/skills/implement
ln -s ~/ai-dev-tasks/scripts ./scripts

# 실행 권한 확인
chmod +x scripts/*.sh

# 사전조건 확인
./scripts/check-prerequisites.sh

# 출력 예시:
# ✅ Node.js 설치됨 (버전: v20.11.0)
# ✅ pnpm 설치됨 (버전: 8.15.0)
```

### C++ 프로젝트

```bash
cd ~/your-cpp-project

# 방법 1: 심볼릭 링크 (권장)
mkdir -p .claude/skills
ln -s ~/ai-dev-tasks/skill-plan .claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement .claude/skills/implement
ln -s ~/ai-dev-tasks/scripts ./scripts
ln -s ~/ai-dev-tasks/docker ./docker
ln -s ~/ai-dev-tasks/Dockerfile.gcc15.1_22.04 ./Dockerfile.gcc15.1_22.04

# 실행 권한 확인
chmod +x scripts/*.sh

# 사전조건 확인
./scripts/check-prerequisites.sh

# Docker 컨테이너 빌드 및 시작
./scripts/docker-setup.sh build
./scripts/docker-setup.sh start

# 출력 예시:
# ✅ Docker 설치됨 (버전: 24.0.7)
# ✅ Docker 데몬 실행 중
# ✅ Docker Compose 설치됨
```

---

## ✅ 검증 및 테스트

### 1. 스킬 로드 확인

Claude Code를 프로젝트 디렉토리에서 실행:

```bash
cd ~/your-project
claude
```

Claude Code에서 다음 명령어 실행:

```
/skill
```

**기대 출력:**
```
Available skills:
- plan: AI Dev Tasks - 계획 수립 스킬
- implement: AI Dev Tasks - 구현 실행 스킬
```

### 2. 프로젝트 타입 감지 테스트

```bash
./scripts/detect-project-type.sh
```

**기대 출력 (Ruby 프로젝트):**
```
주 언어: ruby
신뢰도: 100
발견 항목: Gemfile, Rails, Minitest
```

**기대 출력 (Node.js 프로젝트):**
```
주 언어: nodejs
신뢰도: 80
발견 항목: package.json, TypeScript
```

**기대 출력 (C++ 프로젝트):**
```
주 언어: cpp
신뢰도: 70
발견 항목: CMakeLists.txt, src/, include/
```

### 3. 품질 검사 스크립트 테스트

**Ruby 프로젝트:**
```bash
./scripts/ruby-quality-check.sh . 80
```

**Node.js 프로젝트:**
```bash
./scripts/node-quality-check.sh . 80
```

**C++ 프로젝트:**
```bash
# Docker 컨테이너 내부에서
docker exec -it gcc15.1_22.04 bash
cd /workspace
./scripts/cpp-quality-check.sh build 80
```

### 4. 실제 기능 개발 테스트

Claude Code에서:

```
/skill plan "간단한 헬퍼 함수"
```

**기대 동작:**
- 프로젝트 타입 자동 감지
- 언어에 맞는 질문 진행
- `docs/features/YYYY-MM-DD-feature-name/PLAN.md` 생성

---

## 🛠️ 문제 해결

### 문제 1: 스킬이 로드되지 않음

**증상:**
```
/skill
→ No skills available
```

**해결:**

```bash
# 1. .claude/skills 디렉토리 확인
ls -la .claude/skills/

# 기대 출력:
# plan -> /Users/YOUR_USER/ai-dev-tasks/skill-plan
# implement -> /Users/YOUR_USER/ai-dev-tasks/skill-implement

# 2. 심볼릭 링크가 올바른지 확인
readlink .claude/skills/plan
readlink .claude/skills/implement

# 3. SKILL.md 파일 존재 확인
cat .claude/skills/plan/SKILL.md
cat .claude/skills/implement/SKILL.md

# 4. 재생성 (심볼릭 링크 깨진 경우)
rm -rf .claude/skills
mkdir -p .claude/skills
ln -s ~/ai-dev-tasks/skill-plan .claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement .claude/skills/implement
```

### 문제 2: 스크립트 실행 권한 오류

**증상:**
```bash
./scripts/check-prerequisites.sh
→ Permission denied
```

**해결:**

```bash
# 실행 권한 부여
chmod +x scripts/*.sh

# 또는 개별 파일
chmod +x scripts/detect-project-type.sh
chmod +x scripts/check-prerequisites.sh
chmod +x scripts/ruby-quality-check.sh
chmod +x scripts/node-quality-check.sh
chmod +x scripts/cpp-quality-check.sh
chmod +x scripts/cpp-memory-check.sh
chmod +x scripts/docker-setup.sh
chmod +x scripts/slack-notify.sh
```

### 문제 3: 프로젝트 타입 감지 실패

**증상:**
```bash
./scripts/detect-project-type.sh
→ 주 언어: unknown
```

**해결:**

```bash
# 1. 프로젝트 루트에서 실행하는지 확인
pwd

# 2. 언어별 마커 파일 확인
# Ruby/Rails
ls -la Gemfile

# Node.js/TypeScript
ls -la package.json

# C++
ls -la CMakeLists.txt

# 3. 디버그 모드로 실행
bash -x ./scripts/detect-project-type.sh
```

### 문제 4: Slack 알림 전송 실패

**증상:**
```bash
./scripts/slack-notify.sh "테스트" info
→ Slack webhook URL이 설정되지 않았습니다
```

**해결:**

```bash
# 1. 환경 변수 설정
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# 2. .zshrc 또는 .bashrc에 추가 (영구 설정)
echo 'export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"' >> ~/.zshrc
source ~/.zshrc

# 3. 테스트
./scripts/slack-notify.sh "환경 설정 완료" success
```

### 문제 5: Docker 컨테이너 시작 실패 (C++ 프로젝트)

**증상:**
```bash
./scripts/docker-setup.sh start
→ Error: Cannot connect to Docker daemon
```

**해결:**

```bash
# 1. Docker Desktop 실행 확인
docker info

# 2. Docker Desktop 재시작
# macOS: Docker Desktop 앱 재시작
# Linux: sudo systemctl restart docker

# 3. 다시 시도
./scripts/docker-setup.sh stop
./scripts/docker-setup.sh start

# 4. 로그 확인
docker logs gcc15.1_22.04
```

---

## 📝 체크리스트

설정이 완료되었는지 확인하세요:

### 모든 프로젝트 공통

- [ ] `.claude/skills/plan` 디렉토리 또는 심볼릭 링크 존재
- [ ] `.claude/skills/implement` 디렉토리 또는 심볼릭 링크 존재
- [ ] `scripts/` 디렉토리 존재
- [ ] 모든 스크립트 실행 권한 있음 (`chmod +x scripts/*.sh`)
- [ ] `/skill` 명령어로 스킬 로드 확인
- [ ] `./scripts/detect-project-type.sh` 올바른 타입 감지
- [ ] `./scripts/check-prerequisites.sh` 모든 도구 확인됨

### Ruby/Rails 프로젝트 추가

- [ ] Ruby 설치됨 (3.3.x+)
- [ ] Bundler 설치됨
- [ ] `./scripts/ruby-quality-check.sh` 실행 가능

### Node.js/TypeScript 프로젝트 추가

- [ ] Node.js 설치됨 (18+ or 20+)
- [ ] npm/yarn/pnpm 설치됨
- [ ] `./scripts/node-quality-check.sh` 실행 가능

### C++ 프로젝트 추가

- [ ] Docker Desktop 설치 및 실행 중
- [ ] `docker/` 디렉토리 존재
- [ ] `Dockerfile.gcc15.1_22.04` 파일 존재
- [ ] `./scripts/docker-setup.sh build` 성공
- [ ] `./scripts/docker-setup.sh start` 성공
- [ ] `docker exec -it gcc15.1_22.04 zsh` 접속 가능

---

## 🎯 다음 단계

환경 설정이 완료되었다면:

1. **간단한 기능으로 테스트**
   ```
   /skill plan "헬퍼 유틸리티 함수"
   /skill implement "helper-utility"
   ```

2. **실제 프로젝트에 적용**
   - 프로젝트의 실제 요구사항으로 시작
   - 계획 수립부터 구현까지 전체 워크플로우 실행

3. **팀과 공유**
   - Git 서브모듈 또는 문서로 팀원과 공유
   - 일관된 품질 표준 적용

---

## 📞 지원

문제가 발생하면:

1. **GitHub Issues**: https://github.com/YOUR_USERNAME/ai-dev-tasks/issues
2. **문서**: 각 스킬의 SKILL.md 참조
3. **Slack**: Webhook 설정 시 알림 수신

---

**버전**: 2.0.0
**최종 업데이트**: 2025-12-29
**지원 언어**: Ruby/Rails, Node.js/TypeScript, C++
