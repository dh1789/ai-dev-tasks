# AI Dev Tasks - 베스트 프랙티스 스킬 셋

**다언어 지원 통합 자동화 스킬 셋**입니다. Ruby/Rails, Node.js/TypeScript, C++ 프로젝트에서 요구사항 수집부터 구현, 테스트, 품질 검사까지 전체 워크플로우를 자동화합니다.

## 🎯 주요 기능

- **2단계 워크플로우**: 계획 (`/skill plan`) → 구현 (`/skill implement`)
- **다언어 지원**: Ruby/Rails, Node.js/TypeScript, C++ (자동 감지)
- **유연한 실행 환경**: Ruby/Node.js는 로컬 실행, C++는 Docker 기반
- **TDD 준수**: Red-Green-Refactor 사이클 강제
- **포괄적 테스트**: 단위/통합/시나리오/인수 테스트
- **전체 품질 검사**: 커버리지, 정적 분석, 보안 검사, 메모리 검사 (C++)
- **Slack 실시간 알림**: 진행 상황 및 문제 알림
- **자동 커밋**: Phase 완료시 자동 커밋 (푸시는 수동)

---

## 🧠 지능형 사고 도구 자동 선택

AI가 작업 복잡도를 자동으로 분석하여 최적의 사고 도구를 선택합니다:

### 복잡도 기반 자동 활성화

| 복잡도 수준 | 사고 도구 | 특징 | 사용 예시 |
|------------|----------|------|-----------|
| **낮음** (0-10점) | 일반 모드 | 기본 추론 | UI 컴포넌트, 유틸리티 함수 |
| **중간** (11-25점) | Sequential Thinking | 5-8단계 구조화된 추론 | API 엔드포인트, 데이터 모델 |
| **높음** (26-50점) | Sequential + 에이전트 | 10-15단계 심층 분석 | 인증 시스템, 성능 최적화 |
| **매우 높음** (51+) | Sequential (최대) + 다중 에이전트 | 20-30단계 최대 깊이 분석 | 마이크로서비스 아키텍처, 레거시 현대화 |

### 복잡도 계산 공식

**계획 단계 (plan):**
```
복잡도 = 컴포넌트 수 × 2 + 외부 의존성 × 3 + 보안(0/5/10) + 성능(0/5/10) + 불명확성(0-10)
```

**구현 단계 (implement):**
```
복잡도 = 컴포넌트 수 × 2 + 외부 의존성 × 3 + 멀티스레딩(0/10) +
         메모리 관리(0-10) + 성능 요구사항(0-10) + 보안 요구사항(0-10)
```

### 상황별 에이전트 자동 활성화

구현 중 문제 발생 시 자동으로 전문 에이전트가 활성화됩니다:

- **테스트 실패** → root-cause-analyst (근본 원인 분석)
- **메모리 오류** → performance-engineer + Valgrind/ASan 분석
- **빌드 실패** → system-architect (의존성 체인 분석)
- **성능 이슈** → performance-engineer (병목 지점 프로파일링)

이 모든 과정은 **자동**으로 이루어지며, 사용자의 별도 지시가 필요 없습니다.

---

## 📁 프로젝트 구조

```
ai-dev-tasks/
├── skill-plan/              # 계획 수립 스킬
│   ├── SKILL.md            # 스킬 정의
│   └── plan-template.md    # PLAN.md 템플릿
│
├── skill-implement/         # 구현 실행 스킬
│   ├── SKILL.md            # 스킬 정의
│   └── progress-template.md # PROGRESS.md 템플릿
│
├── scripts/                 # 자동화 스크립트
│   ├── detect-project-type.sh # 프로젝트 타입 자동 감지
│   ├── slack-notify.sh      # Slack 알림
│   ├── docker-setup.sh      # Docker 관리
│   ├── check-prerequisites.sh # 사전조건 확인 (다언어)
│   ├── ruby-quality-check.sh  # Ruby/Rails 품질 검사
│   ├── node-quality-check.sh  # Node.js/TS 품질 검사
│   ├── cpp-quality-check.sh  # C++ 품질 검사
│   └── cpp-memory-check.sh   # 메모리 안전성 검사
│
├── docker/                  # Docker 설정
│   ├── docker-compose.yml   # 컨테이너 구성
│   └── .dockerignore        # 제외 파일
│
├── Dockerfile.gcc15.1_22.04 # C++ 개발 환경 이미지
└── README.md               # 이 파일
```

---

## 🚀 빠른 시작

> **참고**: 두 가지 설정 방식이 있습니다:
> - **계정 전체 설정** (권장): 모든 프로젝트에서 사용 → [SETUP_GLOBAL.md](SETUP_GLOBAL.md) 참조
> - **프로젝트별 설정**: 특정 프로젝트만 사용 → [SETUP.md](SETUP.md) 참조

### 계정 전체 설정 (권장)

#### 방법 1: Makefile 사용 (가장 간편)

```bash
# 1. ai-dev-tasks 클론
cd ~
git clone https://github.com/YOUR_USERNAME/ai-dev-tasks.git
cd ai-dev-tasks

# 2. 글로벌 설치 (필수)
make install

# 설치되는 항목:
# - ~/.claude/skills/plan → skill-plan/
# - ~/.claude/skills/implement → skill-implement/
# - ~/.claude/skills/ai-dev-tasks → 전체 디렉토리 (scripts, docker 등)

# 3. C++ 프로젝트만 추가 설정 (Ruby/Node.js는 생략)
make install-project PROJECT_PATH=~/your-cpp-project

# 4. 설치 확인
make check-global
```

**Ruby/Rails 및 Node.js/TypeScript 프로젝트:**
- 프로젝트별 설치 불필요!
- 스크립트는 `~/.claude/skills/ai-dev-tasks/scripts/`에서 직접 실행

**C++ 프로젝트:**
- `make install-project`로 docker/ 및 Dockerfile.gcc15.1_22.04 링크 생성
- 프로젝트 루트에서 docker-compose 실행 가능

#### 방법 2: 수동 설정

```bash
# 1. ai-dev-tasks 클론
cd ~
git clone https://github.com/YOUR_USERNAME/ai-dev-tasks.git

# 2. 글로벌 스킬 디렉토리 생성
mkdir -p ~/.claude/skills

# 3. 스킬 및 리소스 링크
ln -s ~/ai-dev-tasks/skill-plan ~/.claude/skills/plan
ln -s ~/ai-dev-tasks/skill-implement ~/.claude/skills/implement
ln -s ~/ai-dev-tasks ~/.claude/skills/ai-dev-tasks

# 4. C++ 프로젝트만: Docker 리소스 링크
cd ~/your-cpp-project
ln -s ~/.claude/skills/ai-dev-tasks/docker ./docker
ln -s ~/.claude/skills/ai-dev-tasks/Dockerfile.gcc15.1_22.04 ./Dockerfile.gcc15.1_22.04
```

**완료!** 이제 모든 프로젝트에서 `/skill plan`, `/skill implement`를 사용할 수 있습니다.

**Makefile 명령어:**
- `make help` - 사용 가능한 명령어 확인
- `make install` - 글로벌 스킬 및 리소스 설치
- `make install-project PROJECT_PATH=/path` - C++ 프로젝트에 Docker 리소스 링크
- `make check-global` - 글로벌 설치 상태 확인
- `make check-project PROJECT_PATH=/path` - 프로젝트 리소스 확인
- `make uninstall-global` - 글로벌 스킬 및 리소스 제거

---

### 1. 프로젝트 타입 감지

시스템이 자동으로 프로젝트 타입을 감지합니다:

```bash
./scripts/detect-project-type.sh
```

**감지 기준:**
- **Ruby/Rails**: `Gemfile` 존재 여부
- **Node.js/TypeScript**: `package.json` 존재 여부
- **C++**: `CMakeLists.txt` 존재 여부

### 2. 사전조건 확인

프로젝트 타입에 따라 필요한 도구를 확인합니다:

```bash
./scripts/check-prerequisites.sh
```

**언어별 필수 요구사항:**

#### Ruby/Rails 프로젝트
- Ruby 3.3.x 이상
- Bundler
- Git

#### Node.js/TypeScript 프로젝트
- Node.js 18+ 또는 20+
- npm/yarn/pnpm
- Git

#### C++ 프로젝트
- Docker Desktop 실행 중
- Git

**공통 선택사항:**
- Slack Webhook URL (알림용)

### 3. 환경 변수 설정 (선택)

```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

### 4. 환경 준비 (C++ 프로젝트만 해당)

```bash
# 이미지 빌드 (최초 1회, 시간 소요)
./scripts/docker-setup.sh build

# 컨테이너 시작
./scripts/docker-setup.sh start

# 상태 확인
./scripts/docker-setup.sh status
```

**참고:** Ruby/Rails 및 Node.js/TypeScript 프로젝트는 로컬에서 직접 실행되므로 Docker 설정이 불필요합니다.

### 5. 기능 개발 시작

모든 언어에서 동일한 워크플로우를 사용합니다:

```bash
# 1단계: 계획 수립
/skill plan "JWT 기반 사용자 인증"

# 2단계: 구현 실행
/skill implement "jwt-authentication"
```

---

## 📖 사용 가이드

### Skill 1: plan (계획 수립)

**목적**: 기능 요구사항을 수집하고 상세 계획을 수립합니다.

**사용법**:
```bash
/skill plan "기능 설명"
```

**동작**:
1. 복잡도 자동 분석
2. 복잡하면 → 10-15개 질문으로 상세 요구사항 수집
3. 간단하면 → 즉시 플래닝
4. PRD + Architecture + Phase 분해
5. `docs/features/YYYY-MM-DD-feature-name/PLAN.md` 생성

**출력**:
```
docs/features/
└── 2025-01-29-jwt-authentication/
    └── PLAN.md  (계획서)
```

### Skill 2: implement (구현 실행)

**목적**: PLAN.md를 기반으로 자동으로 구현합니다.

**사용법**:
```bash
/skill implement "feature-name"
```

**동작**:
1. PLAN.md 로드
2. Docker 컨테이너 확인
3. Phase별 자동 실행:
   - TDD 사이클 (RED → GREEN → REFACTOR)
   - 빌드 및 테스트 (컨테이너 내부)
   - 품질 검사 (clang-tidy, cppcheck, clang-format)
   - 메모리 검사 (Valgrind, ASan, TSan, UBSan)
   - 자동 커밋 (호스트)
   - Slack 알림
4. PROGRESS.md 실시간 업데이트
5. 중대한 문제 발생시 중단 및 보고

**출력**:
```
docs/features/
└── 2025-01-29-jwt-authentication/
    ├── PLAN.md       (읽기 전용)
    └── PROGRESS.md   (실시간 업데이트)
```

---

## 🌐 지원 언어 및 품질 도구

### Ruby/Rails
**실행 환경:** 로컬 (호스트)
**테스트 프레임워크:** Minitest, RSpec
**품질 도구:**
- RuboCop (린트 및 스타일)
- Brakeman (보안 검사)
- Bundle Audit (의존성 보안)
- SimpleCov (커버리지)

### Node.js/TypeScript
**실행 환경:** 로컬 (호스트)
**테스트 프레임워크:** Jest, Vitest
**품질 도구:**
- TypeScript Compiler (타입 체크)
- ESLint (린트)
- Prettier (포매팅)
- npm/yarn/pnpm audit (보안 검사)
- Jest/Vitest (커버리지)

### C++
**실행 환경:** Docker (Ubuntu 22.04 + GCC 15.1.0)
**테스트 프레임워크:** Google Test
**품질 도구:**
- clang-tidy, cppcheck (정적 분석)
- clang-format (포매팅)
- Valgrind (메모리 누수)
- ASan, TSan, UBSan (메모리 오류)
- lcov (커버리지)

---

## 🧪 테스트 전략

### 테스트 피라미드 (모든 언어 공통)

```
        /\
       /  \  인수 테스트 (E2E)
      /    \ - 실제 사용 시나리오
     /------\
    /        \ 시나리오 테스트
   /          \ - 여러 컴포넌트 통합
  /------------\
 /              \ 통합 테스트
/                \ - 컴포넌트 간 상호작용
/------------------\
/                    \ 단위 테스트
/______________________\ - 개별 함수/클래스
```

### 모든 테스트에 포함

- ✅ **Happy Path**: 정상 동작
- 🔶 **Boundary Cases**: 경계값 (0, max, min, empty)
- ❌ **Exception Cases**: 예외 처리
- 🔀 **Edge Cases**: 특수 상황

### 품질 목표 (모든 언어 공통)

| 항목 | 목표 |
|-----|------|
| 단위 테스트 커버리지 | ≥ 80% |
| 모든 테스트 통과 | 100% |
| 테스트 타임아웃 | 10분 (600초) |
| 테스트 스킵 | **절대 금지** |

### 언어별 추가 품질 목표

#### Ruby/Rails
- RuboCop 위반 0개
- Brakeman 보안 이슈 0개
- Bundle Audit 취약점 0개

#### Node.js/TypeScript
- TypeScript 타입 오류 0개
- ESLint 경고 0개
- Prettier 포매팅 100%
- npm audit 중대한 취약점 0개

#### C++
- 메모리 누수 0개
- clang-tidy 경고 0개
- cppcheck 경고 0개
- clang-format 적용 100%

---

## 🐳 Docker 환경 (C++ 프로젝트 전용)

**참고:** Docker는 **C++ 프로젝트에만** 필요합니다. Ruby/Rails 및 Node.js/TypeScript 프로젝트는 로컬에서 직접 실행됩니다.

### 컨테이너 사양

- **Base**: Ubuntu 22.04
- **Compiler**: GCC 15.1.0
- **Build System**: CMake 4.0 + Ninja
- **Test Framework**: Google Test 1.14.0
- **Libraries**: fmt, TBB, asio, liburing
- **Quality Tools**:
  - clang-tidy, clang-format, cppcheck
  - Valgrind, ASan, TSan, UBSan
  - lcov, gcov, ccache
  - Google Benchmark

### 컨테이너 관리

```bash
# 시작
./scripts/docker-setup.sh start

# 중지
./scripts/docker-setup.sh stop

# 재시작
./scripts/docker-setup.sh restart

# 상태 확인
./scripts/docker-setup.sh status

# 컨테이너 접속
docker exec -it gcc15.1_22.04 zsh
```

### 볼륨 마운트

```yaml
volumes:
  - ./:/workspace          # 프로젝트 디렉토리
  - ccache-data:/workspace/.ccache  # 빌드 캐시 (영구)
```

**작업 방식:**
- **호스트**: 파일 편집, git 작업, Slack 알림
- **컨테이너**: 빌드, 테스트, 품질 검사

---

## 🔧 품질 검사 스크립트

### ruby-quality-check.sh (Ruby/Rails 프로젝트)

**목적**: Ruby/Rails 프로젝트 전체 품질 검사

```bash
# 로컬에서 실행
./scripts/ruby-quality-check.sh [project_root] [coverage_threshold]

# 예제
./scripts/ruby-quality-check.sh . 80
```

**검사 항목:**
1. Bundle 의존성 설치
2. 데이터베이스 준비 (Rails)
3. 모든 테스트 실행 (Minitest/RSpec)
4. 커버리지 측정 (SimpleCov, ≥ 80%)
5. RuboCop 코드 스타일 검사
6. Brakeman 보안 검사
7. Bundle Audit 의존성 보안 검사

### node-quality-check.sh (Node.js/TypeScript 프로젝트)

**목적**: Node.js/TypeScript 프로젝트 전체 품질 검사

```bash
# 로컬에서 실행
./scripts/node-quality-check.sh [project_root] [coverage_threshold]

# 예제
./scripts/node-quality-check.sh . 80
```

**검사 항목:**
1. 의존성 설치 (npm/yarn/pnpm 자동 감지)
2. TypeScript 타입 체크
3. ESLint 코드 검사
4. Prettier 포매팅 체크
5. 모든 테스트 실행 (타임아웃 10분)
6. 커버리지 측정 (≥ 80%)
7. 빌드 성공 여부
8. npm/yarn/pnpm audit 보안 검사

### cpp-quality-check.sh (C++ 프로젝트)

**목적**: C++ 프로젝트 전체 품질 검사

```bash
# 컨테이너 내부에서
./scripts/cpp-quality-check.sh [build_dir] [coverage_threshold]

# 예제
./scripts/cpp-quality-check.sh build 80
```

**검사 항목:**
1. 빌드 성공 여부
2. 모든 테스트 통과 (100%)
3. 코드 커버리지 (≥ 80%)
4. clang-tidy 정적 분석
5. cppcheck 정적 분석
6. clang-format 포매팅

### cpp-memory-check.sh (C++ 프로젝트)

**목적**: C++ 메모리 안전성 검사

```bash
# 컨테이너 내부에서
./scripts/cpp-memory-check.sh [build_dir] [tool]

# 전체 검사
./scripts/cpp-memory-check.sh build all

# 개별 도구
./scripts/cpp-memory-check.sh build valgrind
./scripts/cpp-memory-check.sh build asan
./scripts/cpp-memory-check.sh build tsan
./scripts/cpp-memory-check.sh build ubsan
```

**검사 항목:**
- **Valgrind**: 메모리 누수, 잘못된 접근
- **AddressSanitizer**: 버퍼 오버플로우, use-after-free
- **ThreadSanitizer**: 데이터 레이스 (멀티스레드)
- **UBSan**: 정의되지 않은 동작

---

## 📬 Slack 알림

### 설정

```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

### 사용

```bash
./scripts/slack-notify.sh "메시지" [status]

# 예제
./scripts/slack-notify.sh "Phase 1 완료 ✅" success
./scripts/slack-notify.sh "빌드 실패" error
./scripts/slack-notify.sh "테스트 시작" info
```

### 자동 알림 시점

- ✅ Phase 완료
- ❌ 중대한 문제 발생
- 🎉 전체 구현 완료

**메시지 형식** (한글):
```
**[프로젝트명]** Phase 1 완료 ✅

**기능:** jwt-authentication
**테스트:** 15/15 통과
**커버리지:** 88%
**커밋:** abc1234
```

---

## 🎓 TDD (Test-Driven Development)

### Red-Green-Refactor Cycle

```
🔴 RED Phase
├─ 테스트 먼저 작성
├─ 테스트 실행 → 실패 확인
└─ 커밋: "test: add failing test for X"

🟢 GREEN Phase
├─ 최소 코드로 테스트 통과
├─ 테스트 실행 → 성공 확인
└─ 커밋: "feat: implement X"

🔵 REFACTOR Phase
├─ 코드 품질 개선
├─ 테스트 여전히 통과 확인
└─ 커밋: "refactor: improve X"
```

### TDD 적용 기준

- **낮은 복잡도**: TDD 선택적
- **중간 복잡도**: TDD 적용 권장
- **높은 복잡도**: TDD 필수

---

## ⚙️ Git 워크플로우

### 자동 커밋

**Phase 완료시 자동:**
```bash
git add .
git commit -m "feat(phase-X): [요약]

- [변경사항 1]
- [변경사항 2]

Tests: X/X passed
Coverage: Y%
Memory: Clean

Phase X/Total completed"
```

### 수동 푸시

**전체 완료 후 사용자가 직접:**
```bash
git push origin feature-branch
```

### 브랜치 전략

```bash
# Feature 브랜치 생성
git checkout -b feature/jwt-authentication

# 구현 진행 (자동 커밋)
/skill implement "jwt-authentication"

# 검토 후 푸시
git push origin feature/jwt-authentication

# PR 생성
gh pr create --title "feat: JWT authentication" --body "..."
```

---

## 🚨 문제 해결

### Docker 컨테이너가 시작되지 않음

```bash
# Docker Desktop 실행 확인
docker info

# 컨테이너 로그 확인
docker logs gcc15.1_22.04

# 강제 재시작
./scripts/docker-setup.sh stop
./scripts/docker-setup.sh start
```

### 테스트 실패

```bash
# 컨테이너 내부에서 수동 테스트
docker exec -it gcc15.1_22.04 bash
cd /workspace/build
ctest --output-on-failure --verbose
```

### 메모리 검사 실패

```bash
# Valgrind 상세 로그
docker exec gcc15.1_22.04 bash -c "
  cd /workspace/build
  valgrind --leak-check=full --show-leak-kinds=all ./test_binary
"
```

### 빌드 실패

```bash
# 클린 빌드
docker exec gcc15.1_22.04 bash -c "
  cd /workspace
  rm -rf build
  mkdir build
  cd build
  cmake -G Ninja ..
  ninja
"
```

---

## 📚 예제 시나리오

### 예제 1: Ruby/Rails - 사용자 인증 기능

```bash
# 프로젝트 타입 자동 감지
# → Gemfile 발견 → Ruby/Rails 프로젝트

# 1. 계획 수립
/skill plan "Devise를 이용한 사용자 인증"

AI: Ruby/Rails 프로젝트 감지
    복잡도: 중간 - 상세 요구사항 수집

    Q1. 인증 방식은?
        a) 이메일/비밀번호
        b) 소셜 로그인 (OAuth)
    ...

    4개 Phase, 예상 8시간
    PLAN.md 생성 완료

# 2. 구현 (로컬 실행)
/skill implement "devise-authentication"

AI: Phase 1/4 시작...
    ✅ bundle install
    ✅ Minitest 실행 (15/15 통과)
    ✅ RuboCop 통과
    ✅ Brakeman 보안 검사 통과
    ✅ 커버리지 85%
    ✅ 커밋 완료
    ...
    🎉 전체 완료!
```

### 예제 2: Node.js/TypeScript - REST API

```bash
# 프로젝트 타입 자동 감지
# → package.json + tsconfig.json 발견 → TypeScript 프로젝트

# 1. 계획 수립
/skill plan "Express REST API with TypeScript"

AI: TypeScript 프로젝트 감지
    복잡도: 중간 - 자동 플래닝

    5개 Phase, 예상 10시간
    PLAN.md 생성 완료

# 2. 구현 (로컬 실행)
/skill implement "express-rest-api"

AI: Phase 1/5 시작...
    ✅ pnpm install
    ✅ TypeScript 타입 체크 통과
    ✅ ESLint 통과
    ✅ Jest 테스트 (25/25 통과)
    ✅ 커버리지 88%
    ✅ 빌드 성공
    ✅ 커밋 완료
    ...
    🎉 전체 완료!
```

### 예제 3: C++ - 고성능 네트워크 라이브러리

```bash
# 프로젝트 타입 자동 감지
# → CMakeLists.txt 발견 → C++ 프로젝트

# 1. Docker 컨테이너 시작
./scripts/docker-setup.sh start

# 2. 계획 수립
/skill plan "asio 기반 비동기 TCP 서버"

AI: C++ 프로젝트 감지
    복잡도: 높음 - 상세 요구사항 수집

    Q1. 동시 접속 처리 방식은?
        a) Thread Pool
        b) Event Loop (asio)
    ...

    6개 Phase, 예상 18시간
    PLAN.md 생성 완료

# 3. 구현 (Docker 컨테이너 내)
/skill implement "async-tcp-server"

AI: Phase 1/6 시작...
    ✅ Docker 컨테이너에서 빌드
    ✅ Google Test 실행 (50/50 통과)
    ✅ clang-tidy 통과
    ✅ cppcheck 통과
    ✅ Valgrind 메모리 체크 통과
    ✅ 커버리지 82%
    ✅ 호스트에서 커밋 완료
    ...
    🎉 전체 완료!
```

---

## 🤝 기여 가이드

이 스킬 셋을 개선하려면:

1. 이슈 생성
2. Feature 브랜치 생성
3. 변경사항 커밋
4. PR 제출

---

## 📄 라이선스

MIT License

---

## 🙋 FAQ

**Q: 어떤 언어를 지원하나요?**
A: Ruby/Rails, Node.js/TypeScript, C++ 프로젝트를 지원합니다. 프로젝트 타입은 자동으로 감지됩니다.

**Q: Docker가 필요한가요?**
A: **C++ 프로젝트만** Docker가 필수입니다. Ruby/Rails 및 Node.js/TypeScript 프로젝트는 로컬에서 직접 실행되므로 Docker가 불필요합니다.

**Q: 프로젝트 타입을 어떻게 감지하나요?**
A: 파일 마커를 사용합니다:
- Ruby/Rails: `Gemfile` 존재
- Node.js/TypeScript: `package.json` 존재
- C++: `CMakeLists.txt` 존재

**Q: Slack 알림이 필수인가요?**
A: 선택사항입니다. SLACK_WEBHOOK_URL을 설정하지 않으면 콘솔 출력만 됩니다.

**Q: 테스트를 스킵할 수 있나요?**
A: **절대 불가능합니다.** 모든 언어에 테스트 절대 스킵 불가 정책이 적용됩니다.

**Q: 테스트 타임아웃은 얼마나 되나요?**
A: 모든 언어에서 10분 (600초 / 600000ms) 타임아웃이 적용됩니다.

**Q: 커버리지 목표는 얼마나 되나요?**
A: 모든 언어에서 최소 80% 커버리지를 목표로 합니다.

**Q: 다른 C++ 표준 버전을 사용할 수 있나요?**
A: Dockerfile에서 CMAKE_CXX_STANDARD를 수정하면 됩니다.

**Q: 다른 빌드 시스템 (Make)을 사용할 수 있나요?**
A: 가능하지만 스크립트 수정이 필요합니다. CMake + Ninja를 권장합니다.

**Q: Ruby 버전은 어떻게 관리하나요?**
A: rbenv, rvm, asdf 등 버전 관리 도구를 사용하거나, 시스템 Ruby를 사용할 수 있습니다.

**Q: Node.js 패키지 매니저는 어떤 것을 사용하나요?**
A: npm, yarn, pnpm 모두 지원하며 프로젝트의 락 파일을 기준으로 자동으로 감지합니다.

---

## 📞 지원

- **문서**: 각 스킬의 SKILL.md 참조
- **이슈**: GitHub Issues
- **Slack**: [Webhook 설정시 알림 수신]

---

**버전**: 2.0.0
**최종 업데이트**: 2025-12-29
**지원 언어**: Ruby/Rails, Node.js/TypeScript, C++ (자동 감지)
**개발 환경**:
- Ruby/Rails: 로컬 (Ruby 3.3.x + Rails 8.0.x)
- Node.js/TypeScript: 로컬 (Node.js 18+/20+ + TypeScript 5.x)
- C++: Docker (Ubuntu 22.04 + GCC 15.1.0 + C++23)
