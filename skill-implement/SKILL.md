---
name: implement
description: 기능 구현 실행 - PLAN.md를 기반으로 자동으로 구현을 진행합니다. 프로젝트 타입을 자동 감지하여 언어별 최적화된 빌드/테스트를 실행합니다 (Ruby/Rails, Node.js/TypeScript, C++). 모든 품질 검사를 통과한 후 자동 커밋하며, 중대한 문제 발생시 중단하고 Slack으로 보고합니다.
---

# Feature Implementation Skill

## 목적

PLAN.md를 기반으로 **자동화된 구현**을 수행합니다:
- 프로젝트 타입 자동 감지 (Ruby/Rails, Node.js/TypeScript, C++, Python)
- Phase별 자동 진행 (TDD 준수)
- 언어별 최적화된 빌드/테스트 실행
  - Ruby/Rails: 로컬 실행 (Minitest, RuboCop 등)
  - Node.js/TypeScript: 로컬 실행 (Jest/Vitest, ESLint 등)
  - C++: Docker 컨테이너 내부 실행 (Google Test, clang-tidy 등)
- 전체 품질 검사 (커버리지, 정적 분석, 보안 검사)
- 자동 커밋 (푸시는 수동)
- Slack 실시간 알림

## 사용법

```bash
/skill implement "feature-name"
```

**예제:**
```bash
/skill implement "jwt-authentication"
/skill implement "2025-01-29-http2-server"
```

## 실행 프로세스

### 0단계: 사고 도구 자동 선택

각 Phase의 복잡도와 상황에 따라 적절한 사고 도구와 에이전트를 자동으로 활성화합니다:

**Phase 복잡도 기반 자동 선택:**

**낮은 복잡도 Phase:**
- **모드**: 일반 모드
- **사고 도구**: 기본 추론
- **특징**: 빠른 구현 및 테스트
- **예**: 간단한 헬퍼 함수, 유틸리티 클래스

**중간 복잡도 Phase:**
- **모드**: Sequential Thinking 활성화
- **사고 도구**: 구조화된 문제 해결 (~5-10 steps)
- **특징**:
  - 단계별 구현 검증
  - 테스트 케이스 체계적 분석
  - 에러 패턴 탐지
- **예**: 비즈니스 로직, API 엔드포인트, 데이터 처리

**높은 복잡도 Phase:**
- **모드**: Sequential Thinking (확장)
- **사고 도구**: 심층 분석 (~15-20 steps)
- **에이전트**: 필요시 전문 에이전트 활용
  - `root-cause-analyst`: 테스트 실패 원인 분석
  - `system-architect`: 아키텍처 이슈 해결
  - `performance-engineer`: 성능 문제 최적화
- **특징**:
  - 다중 컴포넌트 통합 분석
  - 복잡한 버그 추적
  - 성능 병목 지점 식별
- **예**: 인증/인가 시스템, 분산 트랜잭션, 동시성 처리

**매우 높은 복잡도 Phase:**
- **모드**: Sequential Thinking (최대 깊이)
- **사고 도구**: 최대 깊이 분석 (~25-30 steps)
- **에이전트 조율**: 다중 전문 에이전트 병렬 활용
  - `root-cause-analyst`: 복합 오류 분석
  - `system-architect`: 전체 시스템 영향 평가
  - `performance-engineer`: 종합 성능 분석
  - `security-engineer`: 보안 취약점 검토
- **통합 도구**: Context7 (공식 문서), Playwright (E2E 테스트)
- **특징**:
  - 시스템 레벨 디버깅
  - 복잡한 메모리 이슈 해결
  - 멀티스레드 동시성 문제
  - 보안 크리티컬 구현
- **예**:
  - 레거시 통합
  - 실시간 고성능 시스템
  - 복잡한 메모리 관리
  - 보안 암호화 모듈

**상황별 자동 에이전트 활성화:**

**테스트 실패 발생 시:**
```
→ Sequential Thinking 활성화
→ root-cause-analyst 에이전트 호출
→ 실패 패턴 분석
→ 수정 제안 생성
→ 재검증
```

**메모리 오류 발생 시 (C++):**
```
→ Sequential Thinking (확장) 활성화
→ Valgrind/ASan 로그 심층 분석
→ 메모리 사용 패턴 추적
→ 누수/오버플로우 원인 식별
→ 수정 및 재검증
```

**빌드 오류 발생 시:**
```
→ Sequential Thinking 활성화
→ 컴파일 오류 분석
→ 의존성 체인 확인
→ 복구 전략 수립
→ 재빌드 검증
```

**성능 이슈 발생 시:**
```
→ Sequential Thinking 활성화
→ performance-engineer 에이전트 호출
→ 병목 지점 프로파일링
→ 최적화 전략 수립
→ 벤치마크 비교
```

**복잡도 자동 판단 기준:**

```
Phase 복잡도 점수 =
  구현 컴포넌트 수 * 2 +
  외부 의존성 수 * 3 +
  멀티스레딩 (0/10) +
  메모리 관리 복잡도 (0-10) +
  성능 요구사항 (0-10) +
  보안 요구사항 (0-10)

점수 범위:
- 0-10: 낮은 복잡도 → 일반 모드
- 11-25: 중간 복잡도 → Sequential Thinking
- 26-50: 높은 복잡도 → Sequential Thinking + 에이전트
- 51+: 매우 높은 복잡도 → Sequential Thinking + 다중 에이전트
```

### 1단계: PLAN.md 찾기 및 로드

**Feature 이름으로 찾기:**
```bash
docs/features/*/PLAN.md 검색
→ 가장 최근 날짜의 매칭 파일 사용
```

**전체 경로 제공:**
```bash
/skill implement "docs/features/2025-01-29-jwt-authentication"
```

### 2단계: PROGRESS.md 초기화

PLAN.md와 같은 디렉토리에 PROGRESS.md 생성:
```
docs/features/YYYY-MM-DD-feature-name/
├── PLAN.md (읽기 전용)
└── PROGRESS.md (실시간 업데이트)
```

### 3단계: 프로젝트 타입 감지 및 환경 확인

**프로젝트 타입 자동 감지:**
```bash
~/.claude/skills/ai-dev-tasks/scripts/detect-project-type.sh
```

**감지 결과에 따라 환경 확인:**

*Ruby/Rails 프로젝트:*
- Ruby 및 Bundler 설치 확인
- `bundle install` 실행

*Node.js/TypeScript 프로젝트:*
- Node.js 및 패키지 매니저 확인
- `npm install` (또는 `pnpm install`, `yarn install`) 실행

*C++ 프로젝트:*
- Docker 컨테이너 상태 확인: `docker ps | grep gcc15.1_22.04`
- 실행 중이 아니면: `./scripts/docker-setup.sh start`

### 4단계: Phase별 자동 실행

각 Phase에 대해 다음을 **완전 자동**으로 수행:

#### A. TDD Cycle 실행

**Phase 복잡도 판단:**
- 낮음 → TDD 선택적
- 중간/높음 → TDD 필수

**RED Phase (복잡도 중간 이상):**
```bash
# 컨테이너 내부에서
docker exec gcc15.1_22.04 bash -c "
  cd /workspace
  # 테스트 파일 생성
  # 테스트 실행 → 실패 확인
"
```

**GREEN Phase:**
```bash
# 구현 코드 작성
# 테스트 실행 → 통과 확인
```

**REFACTOR Phase:**
```bash
# 코드 개선
# 테스트 여전히 통과 확인
```

#### B. 빌드 및 테스트 (언어별)

**Ruby/Rails:**
```bash
bundle exec rails test  # 또는 bundle exec rake test
```

**Node.js/TypeScript:**
```bash
npm test  # 또는 pnpm test, yarn test
```

**C++:**
```bash
docker exec gcc15.1_22.04 bash -c "
  cd /workspace/build
  ninja clean
  ninja
  ./test/unit/*_test
"
```

**공통 요구사항:**
- **타임아웃**: 30분 (1800000ms) - 모든 언어 공통
- **절대 스킵 불가**: 모든 테스트는 반드시 완료까지 실행
- **실패시**: 최대 3회 재시도 → 실패시 중단 및 보고

#### C. 품질 검사 (언어별)

**Ruby/Rails:**
```bash
~/.claude/skills/ai-dev-tasks/scripts/ruby-quality-check.sh
```
**검사 항목:**
- ✅ 모든 테스트 통과 (100%)
- ✅ 커버리지 ≥ 80% (SimpleCov)
- ✅ RuboCop 통과 (코드 스타일)
- ✅ Brakeman 통과 (보안)
- ✅ Bundle Audit 통과 (의존성 보안)

**Node.js/TypeScript:**
```bash
~/.claude/skills/ai-dev-tasks/scripts/node-quality-check.sh
```
**검사 항목:**
- ✅ 모든 테스트 통과 (100%)
- ✅ 커버리지 ≥ 80%
- ✅ TypeScript 타입 체크 통과
- ✅ ESLint 통과
- ✅ Prettier 포매팅 적용
- ✅ 빌드 성공 (해당시)

**C++:**
```bash
docker exec gcc15.1_22.04 bash -c "cd /workspace && ./scripts/cpp-quality-check.sh"
docker exec gcc15.1_22.04 bash -c "cd /workspace && ./scripts/cpp-memory-check.sh build all"
```
**검사 항목:**
- ✅ 빌드 성공
- ✅ 모든 테스트 통과 (100%)
- ✅ 커버리지 ≥ 80%
- ✅ clang-tidy 통과
- ✅ cppcheck 통과
- ✅ clang-format 적용
- ✅ Valgrind: 메모리 누수 0
- ✅ AddressSanitizer: 메모리 오류 0
- ✅ ThreadSanitizer: 데이터 레이스 0 (멀티스레드시)
- ✅ UndefinedBehaviorSanitizer: UB 0

#### E. 커밋 (호스트에서)

**품질 검사 통과 후:**
```bash
git add .
git commit -m "feat(phase-X): [요약]

- [변경사항 1]
- [변경사항 2]

Tests: X/X passed
Coverage: Y%
Memory: Clean (Valgrind + ASan + TSan + UBSan)

Phase X/Total completed"
```

**푸시는 하지 않음** - 사용자가 수동으로 결정

#### F. PROGRESS.md 업데이트

```markdown
## Phase X 완료 ✅

**완료 시각**: YYYY-MM-DD HH:MM:SS
**소요 시간**: X분

### 결과
- ✅ 빌드: 성공
- ✅ 테스트: 15/15 통과
- ✅ 커버리지: 88%
- ✅ 메모리: Clean
- ✅ 정적 분석: 통과

### 변경 파일
- src/auth/jwt.cpp
- include/auth/jwt.h
- test/unit/jwt_test.cpp

### 커밋
- Hash: abc1234
- Message: feat(phase-1): implement JWT token generation
```

#### G. Slack 알림

```bash
~/.claude/skills/ai-dev-tasks/scripts/slack-notify.sh "
**[프로젝트명]** Phase X 완료 ✅

**기능:** [feature-name]
**Phase:** X/Total
**테스트:** X/X 통과
**커버리지:** Y%
**커밋:** abc1234

다음 Phase 자동 진행 중...
" success
```

### 5단계: 중대한 문제 처리

**중대한 문제 정의:**
1. 테스트 실패 (3회 재시도 후에도)
2. 메모리 검사 실패
3. 빌드 실패 (복구 불가)
4. 요구사항 불만족 (구현 불가능)

**처리 방법:**
1. **즉시 중단**
2. **현재 상태 저장** (PROGRESS.md)
3. **Slack 알림 전송:**

```bash
~/.claude/skills/ai-dev-tasks/scripts/slack-notify.sh "
🚨 **[프로젝트명]** 중대한 문제 발생

**기능:** [feature-name]
**Phase:** X/Total
**문제:** [상세 설명]

**현재 상태:**
- 완료: Phase 1-X
- 실패: Phase Y
- 테스트: X/Y 실패
- 오류: [에러 메시지]

**다음 조치:**
1. 로그 확인: [파일 경로]
2. 수동 디버깅 필요
3. 대안 검토

구현 중단. 사용자 개입 필요.
" error
```

4. **사용자에게 AskUserQuestion 도구로 질문:**

```
AskUserQuestion({
  questions: [
    {
      question: `Phase ${phaseNumber} 실패 - 다음 조치는 어떻게 할까요?`,
      header: "Phase 실패",
      multiSelect: false,
      options: [
        {
          label: "디버깅 후 재시도 (권장)",
          description: `문제: ${errorDescription}
로그: ${logPath}
자동 수정 시도 후 재시도합니다.`
        },
        {
          label: "대안 접근 방식 적용",
          description: `현재 접근 방식을 변경하여 재시도합니다.
예상 추가 시간: 1-2시간`
        },
        {
          label: "요구사항 수정",
          description: `현재 Phase의 요구사항을 조정합니다.
PLAN.md 업데이트 필요`
        },
        {
          label: "Phase 스킵 (비권장)",
          description: `⚠️ 이 Phase를 건너뛰고 다음 Phase로 진행합니다.
품질 저하 가능성 있음`
        }
      ]
    }
  ]
})
```

### 6단계: 전체 완료

**모든 Phase 완료시:**

```bash
~/.claude/skills/ai-dev-tasks/scripts/slack-notify.sh "
🎉 **[프로젝트명]** 기능 구현 완료!

**기능:** [feature-name]
**총 Phase:** X개
**총 시간:** Y시간 Z분
**커밋 수:** N개

**최종 결과:**
- ✅ 테스트: X/X 통과 (100%)
- ✅ 커버리지: Y%
- ✅ 메모리: Clean
- ✅ 정적 분석: 통과
- ✅ 품질 게이트: 모두 통과

**다음 단계:**
1. PROGRESS.md 검토
2. 코드 리뷰
3. git push (수동)
4. PR 생성
" success
```

## 자동화 모드 세부사항

**자동 실행 (중단 없음):**
- 빌드
- 테스트 (10분 타임아웃)
- 품질 검사
- 메모리 검사
- 커밋
- Slack 알림
- 다음 Phase 진행

**중단 조건 (사용자 개입 필요):**
- 테스트 실패 (3회 재시도 후)
- 메모리 오류
- 품질 게이트 실패
- 빌드 오류 (복구 불가)

## 테스트 절대 스킵 불가 정책

**절대 금지:**
- ❌ 테스트 스킵 (`--skip-tests`)
- ❌ 타임아웃 단축
- ❌ grep/tail로 일부만 확인
- ❌ 테스트 주석 처리

**필수 사항:**
- ✅ 전체 테스트 스위트 실행
- ✅ **타임아웃 설정**: 30분 (1800000ms) - 모든 언어 공통
- ✅ 모든 테스트 통과 대기
- ✅ 실패시 재시도

## 언어별 실행 패턴

**Ruby/Rails 프로젝트 (로컬 실행):**
```bash
# 의존성 설치
bundle install

# 테스트 실행
bundle exec rails test  # 또는 bundle exec rake test

# 품질 검사
~/.claude/skills/ai-dev-tasks/scripts/ruby-quality-check.sh
```

**Node.js/TypeScript 프로젝트 (로컬 실행):**
```bash
# 의존성 설치 (패키지 매니저 자동 감지)
npm install  # 또는 pnpm install, yarn install

# 테스트 실행
npm test

# 품질 검사
~/.claude/skills/ai-dev-tasks/scripts/node-quality-check.sh
```

**C++ 프로젝트 (Docker 컨테이너):**
```bash
# 빌드
docker exec gcc15.1_22.04 bash -c "cd /workspace/build && ninja"

# 테스트 (Google Test 실행)
docker exec gcc15.1_22.04 bash -c "cd /workspace/build && ./test/unit/*_test"

# 품질 검사
docker exec gcc15.1_22.04 bash -c "cd /workspace && ./scripts/cpp-quality-check.sh"

# 메모리 검사
docker exec gcc15.1_22.04 bash -c "cd /workspace && ./scripts/cpp-memory-check.sh build all"
```

**호스트에서 공통 작업 (모든 언어):**
- git 작업 (add, commit)
- 파일 편집
- Slack 알림
- PROGRESS.md 업데이트

## PROGRESS.md 실시간 업데이트

**각 단계마다 업데이트:**

```markdown
# 구현 진행 상황: [Feature Name]

**시작**: 2025-01-29 14:30:00
**현재 Phase**: 2/5
**상태**: 🔄 진행 중

## Phase 1: Foundation ✅
- 시작: 14:30
- 완료: 15:15
- 소요: 45분
- 커밋: abc1234

## Phase 2: Core Logic 🔄
- 시작: 15:16
- 현재 작업: RED Phase - 테스트 작성 중
- 진행률: 30%

## Phase 3: Integration ⏳
...
```

## 에러 복구 전략

**테스트 실패:**
1. 에러 로그 분석
2. 자동 수정 시도 (간단한 경우)
3. 재빌드 및 재테스트
4. 3회 실패 → 중단 및 보고

**메모리 오류:**
1. Valgrind 로그 확인
2. AddressSanitizer 상세 분석
3. 자동 수정 불가 → 중단 및 보고

**빌드 오류:**
1. 컴파일 에러 분석
2. 의존성 확인
3. CMake 재구성 시도
4. 복구 불가 → 중단 및 보고

## 성능 최적화

**ccache 활용:**
```bash
# 자동으로 활성화됨 (Dockerfile에서 설정)
# 재빌드 시간 대폭 단축
```

**병렬 빌드:**
```bash
ninja -j$(nproc)
# 모든 CPU 코어 활용
```

## 디버그 로깅 표준

**디버그 로깅 요구사항은 `process-task-list.md`의 "Debug Logging Requirements" 섹션을 참조하세요.**

주요 내용:
- 로깅 레벨 (DEBUG, INFO, WARN, ERROR)
- 필수 로깅 지점 (함수 경계, 상태 전환, 외부 시스템 연동 등)
- 보안 요구사항 (민감 정보 로깅 금지)
- 디버깅 프로토콜

## 유닛 테스트 프로덕션 코드 요구사항

**핵심 원칙**: 유닛 테스트는 실제 프로덕션 코드를 테스트해야 하며, 테스트 전용 구현을 테스트해서는 안 됩니다.

**요구사항**:
1. **프로덕션 코드 임포트**: 모든 유닛 테스트는 프로덕션 디렉토리(`src/`, `lib/`, `app/` 등)에서 함수/클래스를 임포트해야 함
2. **테스트 내 구현 금지**: 테스트 파일 내에서 프로덕션 함수/클래스를 정의하지 말 것
3. **프로덕션 사용 검증**: 테스트된 모든 코드는 실제 프로덕션 애플리케이션에서 사용되어야 함
4. **임포트 경로 검증**: 테스트 임포트는 테스트 유틸리티가 아닌 프로덕션 모듈을 가리켜야 함

**올바른 예 vs 잘못된 예**:

✅ **올바름 - 실제 프로덕션 코드 테스트**:
```python
# test/unit/payment/test_processor.py
from src.payment.processor import ProcessPayment  # 프로덕션에서 임포트

def test_payment_processing():
    processor = ProcessPayment()  # 실제 프로덕션 클래스 사용
    result = processor.charge(amount=100)
    assert result.success == True
```

❌ **잘못됨 - 테스트 전용 구현**:
```python
# test/unit/payment/test_processor.py
# 테스트 파일에 프로덕션 코드 정의 - 절대 금지
class ProcessPayment:
    def charge(self, amount):
        return {"success": True}

def test_payment_processing():
    processor = ProcessPayment()  # 프로덕션에 존재하지 않는 코드 테스트
    result = processor.charge(amount=100)
    assert result["success"] == True
```

**테스트 커밋 전 검증 단계**:
1. ✅ 모든 `import` 문이 프로덕션 코드 경로를 가리키는지 확인
2. ✅ 테스트된 함수/클래스 정의가 프로덕션 코드베이스에 있는지 검색
3. ✅ 테스트된 코드가 애플리케이션 진입점(`main.py`, `app.js` 등)에서 임포트되는지 확인
4. ✅ 테스트 파일에 함수/클래스 정의가 없는지 확인 (테스트 fixture/helper 제외)

**일반적인 안티패턴 회피**:
- ❌ `src/`에서 임포트하는 대신 테스트 파일에 전체 클래스 구현
- ❌ 통과하지만 프로덕션에서 실행되지 않는 코드 테스트 작성
- ❌ 프로덕션 코드를 완전히 대체하는 mock 구현 생성 (의존성에만 stub 사용)
- ❌ 테스트 헬퍼 파일에만 정의된 유틸리티 함수 테스트

## 지원 파일

- `progress-template.md`: PROGRESS.md 생성 템플릿
- `~/.claude/skills/ai-dev-tasks/scripts/detect-project-type.sh`: 프로젝트 타입 자동 감지
- `~/.claude/skills/ai-dev-tasks/scripts/ruby-quality-check.sh`: Ruby/Rails 품질 검사
- `~/.claude/skills/ai-dev-tasks/scripts/node-quality-check.sh`: Node.js/TypeScript 품질 검사
- `~/.claude/skills/ai-dev-tasks/scripts/cpp-quality-check.sh`: C++ 품질 검사
- `~/.claude/skills/ai-dev-tasks/scripts/cpp-memory-check.sh`: C++ 메모리 검사
- `~/.claude/skills/ai-dev-tasks/scripts/slack-notify.sh`: Slack 알림

## 사용 예제

### 예제 1: 정상 완료

```
사용자: /skill implement "jwt-authentication"

AI: PLAN.md 로드 중...
    ✅ docs/features/2025-01-29-jwt-authentication/PLAN.md

    총 5개 Phase 발견
    예상 시간: 12시간

    Docker 컨테이너 확인 중...
    ✅ gcc15.1_22.04 실행 중

    PROGRESS.md 초기화 완료

    Phase 1/5 시작: Foundation

    🔴 RED Phase...
    [테스트 작성 중...]
    ✅ 테스트 실패 확인 (예상대로)

    🟢 GREEN Phase...
    [구현 중...]
    ✅ 테스트 통과

    🔵 REFACTOR Phase...
    [리팩토링 중...]
    ✅ 테스트 여전히 통과

    품질 검사 중...
    ✅ 빌드: 성공
    ✅ 테스트: 12/12 통과
    ✅ 커버리지: 85%
    ✅ clang-tidy: 통과
    ✅ Valgrind: Clean

    커밋 중...
    ✅ Commit: abc1234

    Slack 알림 전송...
    ✅ Phase 1 완료 알림 전송됨

    Phase 2/5 시작: Core Logic
    ...

    [5개 Phase 모두 완료]

    🎉 전체 구현 완료!

    최종 결과:
    - 5 Phases 완료
    - 52 테스트 통과
    - 커버리지: 87%
    - 5개 커밋

    다음 단계:
    1. PROGRESS.md 검토
    2. git push (수동)
```

### 예제 2: 중대한 문제 발생

```
사용자: /skill implement "complex-feature"

AI: ...

    Phase 3/7: Integration

    테스트 실행 중...
    ❌ 테스트 실패: 5/15

    재시도 1/3...
    ❌ 여전히 실패: 5/15

    재시도 2/3...
    ❌ 여전히 실패: 5/15

    재시도 3/3...
    ❌ 여전히 실패: 5/15

    🚨 중대한 문제 발생!

    Slack 알림 전송 중...
    ✅ 알림 전송 완료

    현재 상태 저장 중...
    ✅ PROGRESS.md 업데이트 완료

    [AskUserQuestion 도구로 사용자에게 질문]

사용자: "디버깅 후 재시도" 선택

AI: 로그 분석 중...
    [디버깅 수행]
    ...
```

## 주의사항

1. **프로젝트 타입 자동 감지**: 구현 시작 전 `scripts/detect-project-type.sh`로 프로젝트 타입 자동 식별
2. **언어별 실행 환경**:
   - Ruby/Rails, Node.js/TypeScript: 로컬 실행
   - C++: Docker 컨테이너 필수
3. **테스트 필수**: 절대 스킵 불가, 10분 타임아웃 엄수
4. **자동 진행**: 중대한 문제 외에는 자동 진행
5. **수동 푸시**: git push는 사용자가 직접
6. **Slack 알림**: 모든 중요 이벤트 알림 (한글)
