# AI Dev Tasks 계정 전체 환경 설정 가이드

이 가이드는 AI Dev Tasks 스킬 셋을 **계정 전체**에서 사용할 수 있도록 설정하는 방법을 설명합니다.

---

## 🎯 개요

**글로벌 설정**을 하면 모든 프로젝트에서 `/skill plan`, `/skill implement` 명령어를 사용할 수 있습니다.

**설정 위치:**
- 글로벌: `~/.claude/skills/` (모든 프로젝트)
- 프로젝트별: `<project>/.claude/skills/` (특정 프로젝트만)

---

## 🚀 빠른 설정 (권장)

### 1. ai-dev-tasks 클론

```bash
# 홈 디렉토리에 클론
cd ~
git clone https://github.com/YOUR_USERNAME/ai-dev-tasks.git

# 또는 이미 클론한 경우 최신 버전으로 업데이트
cd ~/ai-dev-tasks
git pull origin main
```

### 2. 글로벌 스킬 디렉토리 생성

```bash
# ~/.claude/skills 디렉토리 생성
mkdir -p ~/.claude/skills
```

### 3. 심볼릭 링크 생성

```bash
# 스킬 링크
ln -s ~/ai-dev-tasks/skill-plan ~/.claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement ~/.claude/skills/implement

# 링크 확인
ls -la ~/.claude/skills/
```

**기대 출력:**
```
total 0
drwxr-xr-x  4 user  staff  128 Dec 29 10:00 .
drwxr-xr-x  3 user  staff   96 Dec 29 10:00 ..
lrwxr-xr-x  1 user  staff   45 Dec 29 10:00 implement -> /Users/user/ai-dev-tasks/skill-implement
lrwxr-xr-x  1 user  staff   42 Dec 29 10:00 plan -> /Users/user/ai-dev-tasks/skill-plan
```

### 4. 완료! 🎉

이제 **모든 프로젝트**에서 `/skill plan`, `/skill implement` 명령어를 사용할 수 있습니다.

---

## 📦 프로젝트별 scripts 설정

각 프로젝트에서 품질 검사를 실행하려면 `scripts/` 디렉토리가 필요합니다.

### ⚠️ 중요: scripts 디렉토리 충돌 해결

**프로젝트에 이미 scripts/ 디렉토리가 존재하는 경우** (예: C++ 프로젝트), 전체 디렉토리를 링크하면 기존 스크립트가 손실될 수 있습니다.

**해결 방법**: `scripts/ai-dev-tasks/` 서브디렉토리 사용

```bash
# 기존 scripts 유지하면서 ai-dev-tasks 추가
cd ~/your-project
ln -s ~/ai-dev-tasks/scripts ./scripts/ai-dev-tasks
chmod +x scripts/ai-dev-tasks/*.sh

# 이제 다음과 같이 사용:
./scripts/ai-dev-tasks/check-prerequisites.sh
./scripts/ai-dev-tasks/detect-project-type.sh
```

**장점:**
- ✅ 기존 프로젝트 스크립트 유지
- ✅ ai-dev-tasks 스크립트와 공존
- ✅ 명확한 구분과 관리

### 방법 1: 자동 설정 스크립트 (권장)

프로젝트 타입을 자동으로 감지하고 적절하게 설정합니다.

```bash
# 현재 디렉토리에 설정
cd ~/your-project
~/ai-dev-tasks/setup-project.sh

# 또는 프로젝트 경로 지정
~/ai-dev-tasks/setup-project.sh ~/your-project
```

**자동 처리 사항:**
- 프로젝트 타입 감지 (Ruby/Node.js/C++)
- scripts 충돌 자동 해결 (서브디렉토리 방식 사용)
- C++ 프로젝트는 docker, Dockerfile도 자동 링크
- 실행 권한 자동 부여
- .gitignore 업데이트 제안

### 방법 2: 수동 심볼릭 링크

**프로젝트에 scripts가 없는 경우:**

```bash
# Ruby/Rails 프로젝트
cd ~/your-ruby-project
ln -s ~/ai-dev-tasks/scripts ./scripts
chmod +x scripts/*.sh

# Node.js/TypeScript 프로젝트
cd ~/your-nodejs-project
ln -s ~/ai-dev-tasks/scripts ./scripts
chmod +x scripts/*.sh
```

**프로젝트에 scripts가 이미 있는 경우 (C++ 등):**

```bash
# C++ 프로젝트 - 서브디렉토리 방식
cd ~/your-cpp-project
ln -s ~/ai-dev-tasks/scripts ./scripts/ai-dev-tasks
ln -s ~/ai-dev-tasks/docker ./docker
ln -s ~/ai-dev-tasks/Dockerfile.gcc15.1_22.04 ./Dockerfile.gcc15.1_22.04
chmod +x scripts/ai-dev-tasks/*.sh
```

---

## ✅ 검증

### 1. 글로벌 스킬 확인

**아무 프로젝트에서나** Claude Code 실행:

```bash
cd ~/any-project
claude
```

Claude Code에서:

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
# Ruby 프로젝트에서
cd ~/your-ruby-project
./scripts/detect-project-type.sh
# 출력: 주 언어: ruby

# Node.js 프로젝트에서
cd ~/your-nodejs-project
./scripts/detect-project-type.sh
# 출력: 주 언어: nodejs

# C++ 프로젝트에서
cd ~/your-cpp-project
./scripts/detect-project-type.sh
# 출력: 주 언어: cpp
```

### 3. 실제 사용 테스트

Claude Code에서:

```
/skill plan "간단한 헬퍼 함수"
```

**기대 동작:**
- 프로젝트 타입 자동 감지
- 언어에 맞는 질문 진행
- `docs/features/YYYY-MM-DD-feature-name/PLAN.md` 생성

---

## 📁 최종 디렉토리 구조

### 글로벌 설정

```
~/.claude/
└── skills/
    ├── plan -> /Users/user/ai-dev-tasks/skill-plan
    └── implement -> /Users/user/ai-dev-tasks/skill-implement

~/ai-dev-tasks/
├── skill-plan/
├── skill-implement/
├── scripts/
├── docker/
├── Dockerfile.gcc15.1_22.04
└── setup-project.sh
```

### Ruby/Rails 프로젝트

```
~/your-ruby-project/
├── app/
├── config/
├── Gemfile
├── Gemfile.lock
└── scripts -> /Users/user/ai-dev-tasks/scripts  # 심볼릭 링크
```

### Node.js/TypeScript 프로젝트

```
~/your-nodejs-project/
├── src/
├── package.json
├── tsconfig.json
└── scripts -> /Users/user/ai-dev-tasks/scripts  # 심볼릭 링크
```

### C++ 프로젝트 (scripts 충돌 해결 - 서브디렉토리 방식)

```
~/your-cpp-project/
├── src/
├── include/
├── CMakeLists.txt
├── scripts/                                      # 기존 프로젝트 스크립트 (유지)
│   ├── build.sh                                  # 기존 스크립트
│   ├── test.sh                                   # 기존 스크립트
│   └── ai-dev-tasks -> /Users/user/ai-dev-tasks/scripts  # 심볼릭 링크
├── docker -> /Users/user/ai-dev-tasks/docker    # 심볼릭 링크
└── Dockerfile.gcc15.1_22.04 -> /Users/user/ai-dev-tasks/Dockerfile.gcc15.1_22.04
```

---

## 🔄 업데이트

ai-dev-tasks가 업데이트되면 모든 프로젝트에 자동 반영됩니다.

```bash
# ai-dev-tasks 업데이트
cd ~/ai-dev-tasks
git pull origin main

# 끝! 모든 프로젝트에 자동 반영됨
```

---

## 🛠️ 문제 해결

### 문제 1: 스킬이 로드되지 않음

```bash
# 1. 글로벌 스킬 디렉토리 확인
ls -la ~/.claude/skills/

# 2. 심볼릭 링크 확인
readlink ~/.claude/skills/plan
readlink ~/.claude/skills/implement

# 3. SKILL.md 파일 확인
cat ~/.claude/skills/plan/SKILL.md

# 4. 재생성
rm -rf ~/.claude/skills
mkdir -p ~/.claude/skills
ln -s ~/ai-dev-tasks/skill-plan ~/.claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement ~/.claude/skills/implement
```

### 문제 2: scripts 디렉토리 없음

```bash
# 현재 프로젝트에서
ln -s ~/ai-dev-tasks/scripts ./scripts
chmod +x scripts/*.sh

# 또는 자동 설정 스크립트 사용
~/ai-dev-tasks/setup-project.sh
```

### 문제 3: 심볼릭 링크가 깨짐

ai-dev-tasks 위치를 변경한 경우:

```bash
# 1. 기존 링크 제거
rm ~/.claude/skills/plan
rm ~/.claude/skills/implement

# 2. 새 위치로 재생성
ln -s /new/path/to/ai-dev-tasks/skill-plan ~/.claude/skills/plan
ln -s /new/path/to/ai-dev-tasks/skill-implement ~/.claude/skills/implement

# 3. 각 프로젝트의 scripts 링크도 재생성
cd ~/your-project
rm scripts
ln -s /new/path/to/ai-dev-tasks/scripts ./scripts
```

---

## 💡 추가 팁

### 1. Slack 알림 글로벌 설정

`~/.zshrc` 또는 `~/.bashrc`에 추가:

```bash
# Slack Webhook URL
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

적용:

```bash
source ~/.zshrc
# 또는
source ~/.bashrc
```

### 2. 별칭(Alias) 설정

자주 사용하는 명령어를 별칭으로 설정:

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
alias ai-setup='~/ai-dev-tasks/setup-project.sh'
alias ai-check='./scripts/check-prerequisites.sh'
alias ai-detect='./scripts/detect-project-type.sh'
```

사용:

```bash
cd ~/new-project
ai-setup          # 프로젝트 설정
ai-detect         # 타입 감지
ai-check          # 사전조건 확인
```

### 3. 프로젝트 템플릿 만들기

자주 시작하는 프로젝트 타입별로 템플릿을 만들어두면 편합니다:

```bash
# Ruby/Rails 템플릿
~/templates/rails-template/
├── Gemfile
├── config.ru
└── scripts -> ~/ai-dev-tasks/scripts

# Node.js/TypeScript 템플릿
~/templates/nodejs-template/
├── package.json
├── tsconfig.json
└── scripts -> ~/ai-dev-tasks/scripts

# 새 프로젝트 시작
cp -r ~/templates/rails-template ~/new-rails-project
cd ~/new-rails-project
bundle install
```

---

## 📋 체크리스트

- [ ] `~/ai-dev-tasks` 클론 완료
- [ ] `~/.claude/skills/plan` 심볼릭 링크 생성
- [ ] `~/.claude/skills/implement` 심볼릭 링크 생성
- [ ] Claude Code에서 `/skill` 명령어로 스킬 로드 확인
- [ ] 각 프로젝트에 `scripts/` 링크 생성
- [ ] C++ 프로젝트는 `docker/`, `Dockerfile` 링크 추가
- [ ] `./scripts/check-prerequisites.sh` 실행 성공
- [ ] (선택) `SLACK_WEBHOOK_URL` 환경 변수 설정
- [ ] (선택) 별칭 설정
- [ ] (선택) 자동 설정 스크립트 실행 권한 부여

---

## 🎯 다음 단계

1. **프로젝트 설정**
   ```bash
   cd ~/your-project
   ~/ai-dev-tasks/setup-project.sh
   ```

2. **첫 기능 개발**
   ```
   /skill plan "헬퍼 유틸리티 함수"
   /skill implement "helper-utility"
   ```

3. **팀과 공유**
   - 이 설정 가이드 공유
   - 일관된 품질 표준 적용

---

**버전**: 2.0.0
**최종 업데이트**: 2025-12-29
**지원 언어**: Ruby/Rails, Node.js/TypeScript, C++
