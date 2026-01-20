# 서브에이전트 지식 누락 분석 보고서

**작성일**: 2026-01-19
**목적**: 기존 스킬 및 문서의 노하우가 서브에이전트에 누락된 부분 파악

---

## 📊 파일 크기 비교

| 구분 | 기존 스킬 | 서브에이전트 | 차이 |
|------|----------|-------------|------|
| **Plan** | skill-plan/SKILL.md (1,137줄) | planner.md (371줄) | **-766줄 (-67%)** |
| **Implement** | skill-implement/SKILL.md (818줄) | implementer.md (750줄) | -68줄 (-8%) |
| **Review** | (없음) | reviewer.md (716줄) | +716줄 (신규) |

**결론**: Planner에서 67%의 내용이 누락되었습니다!

---

## 🚨 심각한 누락 항목

### 1. CRITICAL REQUIREMENTS 체크리스트 (skill-plan 10-68줄)

**누락 내용**:
```markdown
## ⚠️ CRITICAL REQUIREMENTS (필수 체크리스트)

### 우선순위 정의
| 표시 | 의미 | 위반 시 |
|-----|------|--------|
| 🔴 **MUST** | 필수 - 반드시 준수 | 스킬 실패로 간주 |
| 🟡 **SHOULD** | 권장 - 강력히 권장 | 경고 후 진행 가능 |
| 🟢 **MAY** | 선택 - 상황에 따라 | 자유롭게 선택 |

### 📁 파일 위치 🔴 MUST
docs/features/YYYY-MM-DD-feature-name/
├── PRD.md
└── PLAN.md

- [ ] 🔴 날짜 형식: YYYY-MM-DD
- [ ] 🔴 기능명: kebab-case
- [ ] 🔴 ❌ tasks/ 디렉토리 사용 금지

### 📊 Phase 규격 🔴 MUST
- [ ] 🔴 Phase 개수: 3-7개 (최대 7개 초과 금지)
- [ ] 🔴 각 Phase: 1-4시간 내 완료 가능
- [ ] 🟡 독립적으로 테스트 가능

### 🔄 TDD 구조 🔴 MUST
각 Phase에 반드시 포함:
- [ ] 🔴 RED Phase: 테스트 먼저 작성 (실패 확인)
- [ ] 🔴 GREEN Phase: 최소 코드로 테스트 통과
- [ ] 🟡 REFACTOR Phase: 코드 품질 개선
```

**영향**:
- ❌ 파일 위치 규칙 없음 → 프로젝트마다 다른 위치에 PLAN.md 생성
- ❌ Phase 규격 없음 → 너무 많거나 너무 큰 Phase 생성 가능
- ❌ TDD 구조 강제 없음 → RED-GREEN-REFACTOR 사이클 누락

---

### 2. 검증 스크립트 (skill-plan 59-67줄)

**누락 내용**:
```bash
# 스킬 완료 후 반드시 실행
~/.claude/skills/plan/scripts/validate-plan.sh docs/features/YYYY-MM-DD-feature-name/

- [ ] 🔴 검증 스크립트 실행
- [ ] 🔴 FAIL 항목 0개 확인
- [ ] 🟡 WARN 항목 검토
```

**영향**:
- ❌ 계획 품질 자동 검증 불가
- ❌ 필수 섹션 누락 방지 메커니즘 없음

---

### 3. 복잡도 자동 분석 및 사고 도구 선택 (skill-plan 100-152줄)

**누락 내용**:
```javascript
복잡도 점수 =
  컴포넌트 수 * 2 +
  외부 의존성 수 * 3 +
  보안 요구사항 (0/5/10) +
  성능 제약사항 (0/5/10) +
  불명확성 (0-10)

점수 범위:
- 0-10: 낮은 복잡도 → 일반 모드
- 11-25: 중간 복잡도 → Sequential Thinking
- 26-50: 높은 복잡도 → Sequential Thinking (확장)
- 51+: 매우 높은 복잡도 → Sequential Thinking (최대)
```

**영향**:
- ❌ Sequential Thinking 자동 활성화 없음
- ❌ 복잡한 기능에 대한 체계적 분석 부족

---

### 4. AskUserQuestion을 통한 체계적 요구사항 수집 (skill-plan 183-199줄)

**누락 내용**:
```yaml
AskUserQuestion 사용:
  - 기능 요구사항 수집
  - 기술 스택 확인
  - 성능/보안 요구사항
  - 제약사항 파악

단계별 질문 구조로 체계적 수집
```

**영향**:
- ❌ 모호한 요구사항 명확화 프로세스 없음
- ❌ 사용자와의 대화형 수집 메커니즘 부재

---

### 5. TDD 원칙 (tdd.md 전체)

**누락 내용**:
```markdown
# RED → GREEN → REFACTOR 사이클
- Red: 실패하는 테스트 먼저 작성
- Green: 최소 코드로 테스트 통과
- Refactor: 코드 품질 개선

# Tidy First 원칙
- Structural Changes (구조 변경): 리팩토링
- Behavioral Changes (동작 변경): 기능 추가
- 절대 섞지 말 것!
- 구조 변경 먼저 커밋

# Production Integration Verification
- 구현된 기능이 실제로 프로덕션 코드에 통합되었는지 검증
- 호출 경로 추적
- 사용되지 않는 코드 방지
```

**영향**:
- ❌ TDD 사이클 강제 없음
- ❌ Tidy First 원칙 누락
- ❌ 프로덕션 통합 검증 없음 (실전 문제!)

---

### 6. PLAN.md 필수 섹션 (skill-plan 50-57줄)

**누락 내용**:
```markdown
### 📋 PLAN 필수 섹션
- [ ] 🔴 헤더 메타데이터: Status, 생성일, 예상 완료, 프로젝트 타입, 언어/프레임워크, 실행 환경
- [ ] 🔴 Quality Gate per Phase: 각 Phase 완료 조건
- [ ] 🔴 롤백 전략: Phase별 실패 시 복구 방법
- [ ] 🟡 진행 상황 추적: 완료율, 시간 추적 테이블
- [ ] 🟡 최종 체크리스트: 구현 완료 전 확인 사항
- [ ] 🟢 위험 요소: 예상 위험 및 완화 전략
- [ ] 🟢 참고 자료: 관련 문서 링크
```

**현재 planner.md의 PLAN.md 구조**:
```markdown
# [기능명] 구현 계획
## 📋 목표
## 🎯 핵심 요구사항
## 🏗️ 아키텍처 결정
## 📝 구현 Phase
## ✅ 품질 기준
## 📦 의존성 및 제약사항
## 🔗 참고 자료
```

**차이**:
- ❌ 헤더 메타데이터 없음 (Status, 생성일 등)
- ❌ Phase별 Quality Gate 없음
- ❌ 롤백 전략 없음
- ❌ 진행 상황 추적 테이블 없음
- ❌ 최종 체크리스트 없음

---

### 7. 프로젝트 타입별 템플릿 (skill-plan/plan-template.md)

**파일 크기**:
- skill-plan/plan-template.md: 17,342줄

**내용**:
- 프로젝트 타입별 상세 템플릿 (Node.js, Ruby/Rails, C++, Python)
- 언어별 품질 게이트 명령어
- 프레임워크별 모범 사례

**영향**:
- ❌ 언어별 특화 가이드 없음
- ❌ 품질 게이트 명령어 표준화 부재

---

### 8. 진행 상황 추적 템플릿 (skill-implement/progress-template.md)

**파일 크기**:
- skill-implement/progress-template.md: 5,467줄

**내용**:
- Phase별 진행률 추적
- 시간 소요 기록
- 블로커 관리
- 완료 체크리스트

**영향**:
- ❌ 구현 진행 상황 추적 불가
- ❌ 시간 관리 메커니즘 없음

---

## 📋 testing-standards.md 주요 내용 (✅ 확인 완료)

**파일 크기**: 424줄

### 🚨 Critical 누락 항목

#### 1. **유닛 테스트 프로덕션 코드 요구사항** (testing-standards.md 21-115줄)

**누락 내용**:
```markdown
## 유닛 테스트 프로덕션 코드 요구사항

### 핵심 원칙
**CRITICAL:** 유닛 테스트는 **실제 프로덕션 코드**를 테스트해야 하며, 테스트 전용 구현을 테스트해서는 안 됩니다.

### 필수 요구사항
1. **프로덕션 코드 임포트:**
   - 모든 유닛 테스트는 프로덕션 디렉토리(`src/`, `lib/`, `app/` 등)에서 함수/클래스를 임포트해야 함
   - 테스트만을 위한 별도 구현 금지

2. **테스트 내 구현 금지:**
   - 테스트 파일 내에서 프로덕션 함수/클래스를 정의하지 말 것

3. **프로덕션 사용 검증:**
   - 테스트된 모든 코드는 실제 프로덕션 애플리케이션에서 사용되어야 함

4. **임포트 경로 검증:**
   - 테스트 임포트는 `src/`, `lib/`, `app/` 등 프로덕션 디렉토리를 참조하는지 확인

5. **테스트 설명 필수:**
   - 목적, 시나리오, 기대 결과를 명시

### 프로덕션 코드 검증 명령어
```bash
# 테스트 파일에서 의심스러운 정의 찾기
grep -r "^class\|^def\|^function" test/ --include="*.py" --include="*.js" --include="*.ts"

# 테스트 임포트가 프로덕션을 가리키는지 확인
grep -r "from src\|import.*src\|require.*src" test/
```
```

**현재 서브에이전트 상태**:
- implementer.md: ❌ 전혀 언급 없음
- reviewer.md: ❌ 전혀 언급 없음

**영향**:
- ❌ 테스트가 실제 프로덕션 코드가 아닌 테스트 파일 내 구현을 테스트할 수 있음
- ❌ 구현된 기능이 프로덕션에 통합되지 않는 문제 재발 (실전에서 자주 발생!)
- ❌ 임포트 경로 검증 메커니즘 부재

---

#### 2. **AAA 테스트 패턴** (testing-standards.md 198-286줄)

**누락 내용**:
```markdown
## AAA 테스트 패턴 (Arrange-Act-Assert)

모든 테스트는 다음 구조를 따라야 합니다:

```
test '동작 설명':
  // Arrange: 테스트 데이터 및 의존성 설정
  input = createTestData()

  // Act: 테스트 중인 동작 실행
  result = systemUnderTest.method(input)

  // Assert: 예상 결과 확인
  assert result == expectedOutput
```

### 언어별 예시
- Python (pytest)
- JavaScript/TypeScript (Jest)
- C++ (Google Test)
- Ruby (Minitest)
```

**현재 서브에이전트 상태**:
- implementer.md: ❌ 언급 없음
- reviewer.md: ❌ 언급 없음

**영향**:
- ❌ 테스트 구조 표준 부재
- ❌ 언어별 모범 사례 가이드 없음

---

#### 3. **테스트 실행 정책 - 절대 스킵 불가** (testing-standards.md 287-325줄)

**누락 내용**:
```markdown
## 테스트 실행 정책

### 절대 스킵 불가 정책
**필수 사항:**
- ✅ 전체 테스트 스위트 실행
- ✅ **타임아웃 설정:** 30분 (1800000ms) - 모든 언어 공통
- ✅ 모든 테스트 통과 대기
- ✅ 실패 시 재시도

**절대 금지:**
- ❌ 테스트 스킵 (`--skip-tests`)
- ❌ 타임아웃 단축
- ❌ grep/tail로 일부만 확인
- ❌ 테스트 주석 처리
```

**현재 서브에이전트 상태**:
- implementer.md: ⚠️ "테스트 우회 금지" 언급만 있음 (타임아웃 30분 누락!)
- reviewer.md: ❌ 전혀 언급 없음

**영향**:
- ❌ 타임아웃 30분 (1800000ms) 명시 없음 → 기본 타임아웃으로 긴 테스트 실패 가능
- ❌ 테스트 스킵 금지 정책 약함

---

#### 4. **테스트 케이스 최소 요구사항** (testing-standards.md 129-133줄)

**누락 내용**:
```markdown
최소 **3가지 테스트 케이스** 포함:
1. **Happy Path:** 가장 일반적이고 예상되는 시나리오
2. **Boundary Conditions:** 최소값, 최대값, 빈 입력, null 값, 경계 시나리오
3. **Exception Cases:** 잘못된 입력, 오류 조건, 예외 상황
4. **Side Effects:** 테스트 독립성 보장
```

**현재 서브에이전트 상태**:
- implementer.md: ❌ 명시적 요구사항 없음
- reviewer.md: ⚠️ Happy Path, Exception, Boundary 언급만 있음 (최소 3가지 요구사항 아님)

---

#### 5. **테스트 설명 작성 방법** (testing-standards.md 135-138줄)

**누락 내용**:
```markdown
**테스트 설명 작성:**
- 목적: 무엇을 테스트하는지
- 시나리오: 어떤 상황에서
- 기대 결과: 무엇이 발생해야 하는지
```

**현재 서브에이전트 상태**:
- implementer.md: ❌ 구체적 가이드 없음
- reviewer.md: ⚠️ "테스트 설명 명확" 언급만 있음 (작성 방법 없음)

---

#### 6. **Mock/Stub 사용 가이드** (testing-standards.md 371-393줄)

**누락 내용**:
```markdown
## Mock/Stub 사용 가이드

**주의사항:**
- Mock은 외부 의존성에만 사용 (API, 데이터베이스, 외부 서비스)
- 프로덕션 비즈니스 로직을 mock으로 대체하지 않음
- 과도한 mocking은 테스트의 신뢰성 저하
```

**현재 서브에이전트 상태**:
- implementer.md: ❌ 전혀 언급 없음
- reviewer.md: ⚠️ "Mock 객체 (프로덕션 코드)" 언급만 있음 (사용 원칙 없음)

---

#### 7. **커버리지 계산 명령어** (testing-standards.md 327-359줄)

**누락 내용**:
```bash
# JavaScript/TypeScript
jest --coverage

# Python
pytest --cov=src --cov-report=html

# Ruby
bundle exec rspec --coverage

# C++
ctest
```

**현재 서브에이전트 상태**:
- implementer.md: ⚠️ 일부만 언급 (npm test, pytest)
- reviewer.md: ⚠️ "npm test -- --coverage" 언급만 있음

---

## 📋 process-task-list.md 주요 내용 (✅ 확인 완료)

**파일 크기**: 246줄

### 🚨 Critical 누락 항목

#### 8. **디버그 로깅 요구사항** (process-task-list.md 57-191줄)

**누락 내용**:
```markdown
## Debug Logging Requirements

**MANDATORY**: 모든 프로덕션 코드에 포괄적인 디버그 로깅 필수

### Logging Standards
**Logging Levels:**
- DEBUG: 상세한 진단 정보
- INFO: 일반적인 정보성 메시지
- WARN: 잠재적 문제 경고
- ERROR: 실제 오류 발생

**필수 로깅 위치:**
1. 함수 진입/종료 (복잡한 연산)
2. 상태 변경 (중요한 상태 전환)
3. 외부 시스템 연동
4. 비즈니스 로직 의사결정
5. 예외 처리 (모든 try-except)

**보안 고려사항:**
- ❌ 민감 정보 로깅 금지 (비밀번호, 토큰, API 키, 신용카드)

### Quality Gate Addition
- [ ] 모든 프로덕션 코드에 적절한 디버그 로그 추가됨
- [ ] 복잡한 함수에 진입/종료 로그 있음
- [ ] 모든 예외 처리에 ERROR 로그 있음
- [ ] 민감 정보가 로그에 포함되지 않음
```

**현재 서브에이전트 상태**:
- planner.md: ❌ 전혀 없음
- implementer.md: ❌ 전혀 없음
- reviewer.md: ❌ 전혀 없음

**영향**:
- ❌ 디버그 로깅 표준 부재 → 문제 발생 시 원인 파악 어려움
- ❌ 보안 고려사항 없음 → 민감 정보 로깅 위험
- ❌ 품질 게이트 없음 → 로깅 누락 방지 불가

---

#### 9. **Slack 알림 요구사항** (process-task-list.md 192-234줄)

**누락 내용**:
```markdown
## Slack Notification Requirements

**MANDATORY**: 다음 상황에서 Slack 웹훅 알림 필수

1. 태스크 완료 시:
   - 프로젝트명, 태스크 번호, 완료 내용
   - 테스트 결과, 커밋 해시

2. 태스크 실패 또는 타협 필요 시:
   - 실패 원인 설명
   - 대안 제시
   - 사용자 피드백 대기

3. 더 나은 접근법 제안 시:
   - 대안 추천 이유
   - 명확한 근거와 이점
   - 사용자 승인 대기

### Slack Webhook Configuration
- Webhook Script: ./scripts/slack-notify.sh
- Character Limit: 1000자 최대
- Message Language: **모든 메시지 한글 작성**
```

**현재 서브에이전트 상태**:
- planner.md: ❌ 전혀 없음
- implementer.md: ❌ 전혀 없음
- reviewer.md: ❌ 전혀 없음

**영향**:
- ❌ 진행 상황 알림 메커니즘 부재
- ❌ 실패 보고 프로토콜 없음
- ❌ 사용자 피드백 루프 없음

---

#### 10. **커밋 프로토콜** (process-task-list.md 28-44줄)

**누락 내용**:
```markdown
## Completion Protocol
1. 서브태스크 완료 시 즉시 [x] 표시
2. 모든 서브태스크 완료 시:
   - **First**: 전체 테스트 실행 (30분 타임아웃)
   - **Only if all tests pass**: git add .
   - **Clean up**: 임시 파일 및 임시 코드 삭제
   - **Commit**: Conventional commit 형식 사용
     - feat:, fix:, refactor: 등
     - 태스크 번호 및 PRD 참조
     - 단일 라인 명령어 (-m 플래그)
```

**현재 서브에이전트 상태**:
- implementer.md: ⚠️ "Bash 'git add . && git commit'" 언급만 있음 (프로토콜 없음)
- reviewer.md: ❌ 커밋 권한 없음

**영향**:
- ❌ Conventional commit 형식 강제 없음
- ❌ 임시 파일 정리 단계 누락
- ❌ 테스트 통과 확인 후 커밋 프로토콜 약함

---

## 📋 create-prd.md 주요 내용 (✅ 확인 완료)

**파일 크기**: 68줄

### 🟡 Important 누락 항목

#### 11. **PRD 작성 프로세스** (create-prd.md 8-12줄)

**누락 내용**:
```markdown
## Process
1. Receive Initial Prompt
2. **Ask Clarifying Questions** (MUST) - **Use AskUserQuestion tool**
3. Generate PRD
4. Save PRD: [n]-prd-[feature-name].md in /tasks directory
```

**현재 서브에이전트 상태**:
- planner.md: ⚠️ AskUserQuestion 언급 있음 (프로세스 명확하지 않음)

**영향**:
- ⚠️ 명확화 질문 단계 프로세스 부재
- ⚠️ 파일명 규칙 없음 ([n]-prd-[feature-name].md)

---

## 📋 generate-tasks.md 주요 내용 (✅ 확인 완료)

**파일 크기**: 84줄

### 🟡 Important 누락 항목

#### 12. **2단계 태스크 생성 프로세스** (generate-tasks.md 14-26줄)

**누락 내용**:
```markdown
## Process
Phase 1: Generate Parent Tasks
  - Create high-level tasks (약 5개)
  - Present to user
  - Wait for confirmation ("Go")

Phase 2: Generate Sub-Tasks
  - **Reload PRD file** (컨텍스트 유지)
  - Break down into actionable sub-tasks
  - **For each implementation task, generate testing sub-tasks**:
    - Unit Testing Sub-Tasks (3 cases)
    - System Testing Sub-Tasks (2 scenarios)
```

**현재 서브에이전트 상태**:
- planner.md: ❌ 2단계 프로세스 없음 (즉시 전체 계획 생성)

**영향**:
- ❌ 사용자 확인 후 상세화 프로세스 없음
- ❌ PRD 재로드 단계 없음
- ❌ 자동 테스트 태스크 생성 메커니즘 없음

---

## 📋 language-policy.md 주요 내용 (✅ 확인 완료)

**파일 크기**: 191줄

### 🚨 Critical 누락 항목

#### 13. **언어 사용 정책** (language-policy.md 전체) ⭐ **실전 필수**

**누락 내용**:
```markdown
## 기본 원칙
**IMPORTANT:** 모든 문서 콘텐츠는 **한글(Korean)**로 작성

### 언어 사용 규칙
**반드시 한글 작성:**
- PRD: 모든 섹션, 사용자 스토리, 요구사항
- 태스크 리스트: 제목, 설명, Notes
- 일반 문서: 가이드라인, 프로세스, 정책
- 사용자 커뮤니케이션: 진행 상황, Slack 알림

**영어 유지 항목:**
- 프로그래밍 키워드, 파일 경로, 코드 식별자
- 프레임워크/라이브러리 이름
- API endpoint, 기술 약어 (API, HTTP, REST)
```

**현재 서브에이전트 상태**:
- planner.md: ❌ 전혀 없음
- implementer.md: ❌ 전혀 없음
- reviewer.md: ❌ 전혀 없음

**영향**:
- ❌ 한글 작성 원칙 부재
- ❌ 기술 용어 처리 가이드 없음
- ❌ 사용자 커뮤니케이션 언어 정책 없음

---

## 🎯 통합 필요 우선순위

### 🔴 Critical (즉시 통합 필수)
1. **CRITICAL REQUIREMENTS 체크리스트** → planner.md, implementer.md
2. **TDD 원칙 (RED-GREEN-REFACTOR)** → implementer.md
3. **유닛 테스트 프로덕션 코드 요구사항** → implementer.md, reviewer.md ⭐ **신규 발견**
4. **테스트 실행 정책 - 타임아웃 30분 (1800000ms)** → implementer.md ⭐ **신규 발견**
5. **파일 위치 규칙 (docs/features/)** → planner.md
6. **Phase 규격 (3-7개, 1-4시간)** → planner.md
7. **검증 스크립트 참조** → planner.md
8. **Production Integration Verification** → implementer.md
9. **PLAN.md 필수 섹션** → planner.md
10. **디버그 로깅 요구사항** → implementer.md, reviewer.md ⭐ **신규 발견** (process-task-list.md)
11. **Slack 알림 요구사항** → implementer.md ⭐ **신규 발견** (process-task-list.md)
12. **커밋 프로토콜** → implementer.md ⭐ **신규 발견** (process-task-list.md)
13. **언어 사용 정책** → 모든 agents ⭐ **신규 발견** (language-policy.md) - **모든 문서의 기본 원칙**

### 🟡 Important (조속히 통합 권장)
14. **AAA 테스트 패턴** → implementer.md, reviewer.md ⭐ **신규 발견**
15. **테스트 케이스 최소 요구사항 (3가지)** → implementer.md, reviewer.md ⭐ **신규 발견**
16. **테스트 설명 작성 방법** → implementer.md, reviewer.md ⭐ **신규 발견**
17. **복잡도 자동 분석** → planner.md
18. **AskUserQuestion 체계적 수집** → planner.md
19. **Tidy First 원칙** → implementer.md
20. **진행 상황 추적 템플릿** → implementer.md
21. **PRD 작성 프로세스** → planner.md ⭐ **신규 발견** (create-prd.md)
22. **2단계 태스크 생성 프로세스** → planner.md ⭐ **신규 발견** (generate-tasks.md)

### 🟢 Nice to Have (점진적 통합)
23. **Mock/Stub 사용 가이드** → implementer.md, reviewer.md
24. **커버리지 계산 명령어** → implementer.md, reviewer.md
25. **프로젝트 타입별 템플릿** → planner.md

---

## 🎁 서브에이전트만의 강점 (유지 필수!)

### 새로운 아키텍처 (skill-*에 없음)
1. **3-Tier 워크플로우**: Planner → Implementer → Reviewer
   - 명확한 역할 분리
   - 단계별 책임 분담

2. **Reviewer Agent** (716줄) - 완전히 새로운 개념!
   - 독립적 코드 리뷰
   - 승인/거부/조건부 승인 권한
   - REVIEW_REPORT.md 생성
   - 요구사항 충족도 계산 (%)
   - 코드 품질 점수 시스템 (15점 만점)
     - 아키텍처: 5점
     - 가독성/유지보수성: 5점
     - 완전성: 5점
   - 최종 결정 기준:
     - ✅ 승인: 요구사항 ≥95%, 품질 ≥12/15
     - ❌ 거부: 요구사항 <90%, Critical 문제
     - ⚠️ 조건부: 사소한 개선 필요

3. **피드백 루프 메커니즘**
   - 거부 시: Implementer 재작업 → Reviewer 재검토
   - 최대 3회 반복
   - 구조화된 개선사항 전달

4. **파일 기반 통신**
   - PLAN.md: Planner → Implementer
   - REVIEW_REPORT.md: Reviewer → (User/Implementer)
   - Fresh context isolation per agent

### 현대적 구조
- 단일 에이전트 (skill-*) vs 3-tier (agents)
- 순차적 실행 vs 역할 분담
- 품질 체크 부재 vs Reviewer 독립 검증

---

## 💡 통합 전략 제안

### ❌ 옵션 A: 전면 개편 (철회)
```bash
# 기존 스킬을 기반으로 서브에이전트 재작성
```

**문제점**:
- ❌ 서브에이전트의 3-tier 구조 손실
- ❌ Reviewer Agent의 독립적 검증 기능 손실
- ❌ 피드백 루프 메커니즘 손실
- ❌ 요구사항 충족도 계산 시스템 손실
- ❌ 코드 품질 점수 시스템 손실

**→ 좋은 것들을 버리는 방법이므로 철회!**

### ⚠️ 옵션 B: 점진적 통합 (부분 해결)
```bash
# 우선순위 높은 항목만 먼저 통합
1. CRITICAL REQUIREMENTS → planner.md 추가
2. TDD 원칙 → implementer.md 추가
3. 테스트 프로덕션 코드 요구사항 → implementer.md 추가
4. 디버그 로깅 → implementer.md 추가
5. Slack 알림 → implementer.md 추가
```

**장점**:
- ✅ 빠른 개선 (1-2시간)
- ✅ 핵심 문제 해결
- ✅ 서브에이전트 구조 유지

**단점**:
- ❌ 일부 노하우 여전히 누락
- ❌ 체계적이지 않음

### ❌ 옵션 C: 참조 방식 (비현실적)
```bash
# 서브에이전트가 기존 문서를 참조하도록 수정
```

**문제점**:
- ❌ 서브에이전트는 Fresh context로 실행 → 외부 파일 접근 불가
- ❌ 매번 여러 파일 읽기 필요 → 컨텍스트 낭비
- ❌ 실행 효율성 저하

**→ 서브에이전트 아키텍처와 맞지 않아 철회!**

### ✅ 옵션 D: 하이브리드 통합 (추천 ⭐⭐⭐)

**핵심 원칙**: 서브에이전트의 좋은 구조는 유지하고, 실전 노하우만 추가

```bash
# 각 agent에 누락된 실전 노하우 섹션 추가

📁 planner.md (현재 371줄 → 약 600줄)
├─ 🆕 CRITICAL REQUIREMENTS 체크리스트 추가
├─ 🆕 파일 위치 규칙 (docs/features/) 추가
├─ 🆕 Phase 규격 (3-7개, 1-4시간) 추가
├─ 🆕 검증 스크립트 참조 추가
├─ 🆕 복잡도 자동 분석 추가
├─ 🆕 AskUserQuestion 체계적 수집 추가
├─ 🆕 언어 사용 정책 추가
└─ ✅ 기존 3-tier 구조 유지

📁 implementer.md (현재 750줄 → 약 1,100줄)
├─ 🆕 TDD 원칙 (RED-GREEN-REFACTOR) 추가
├─ 🆕 Tidy First 원칙 추가
├─ 🆕 Production Integration Verification 추가
├─ 🆕 유닛 테스트 프로덕션 코드 요구사항 추가 ⭐
├─ 🆕 테스트 타임아웃 30분 (1800000ms) 추가 ⭐
├─ 🆕 AAA 테스트 패턴 추가
├─ 🆕 테스트 케이스 최소 요구사항 추가
├─ 🆕 디버그 로깅 요구사항 추가 ⭐
├─ 🆕 Slack 알림 요구사항 추가 ⭐
├─ 🆕 커밋 프로토콜 추가
└─ ✅ 기존 구현 프로세스 유지

📁 reviewer.md (현재 716줄 → 약 900줄)
├─ 🆕 유닛 테스트 프로덕션 코드 검증 추가 ⭐
├─ 🆕 테스트 타임아웃 30분 확인 추가
├─ 🆕 AAA 패턴 준수 확인 추가
├─ 🆕 디버그 로깅 검증 추가
├─ 🆕 Mock/Stub 사용 검증 추가
└─ ✅ 기존 승인/거부 시스템 유지
```

**통합 방법**:
1. 각 agent 파일을 열어서 적절한 섹션에 노하우 추가
2. 기존 구조/프로세스는 절대 삭제하지 않음
3. 새로운 내용은 기존 내용과 조화롭게 통합
4. 중복은 최소화하되, 중요한 내용은 반복 허용

**장점**:
- ✅ 서브에이전트의 3-tier 구조 완전 보존
- ✅ Reviewer의 독립적 검증 기능 유지
- ✅ 피드백 루프 메커니즘 유지
- ✅ 실전 노하우 100% 통합
- ✅ 실전 문제 재발 방지
- ✅ 체계적이고 완전한 해결책

**단점**:
- ⚠️ 작업량 중간 (3-4시간 예상)
- ⚠️ 파일 크기 증가 (하지만 agent별 분리로 관리 가능)

**작업 순서**:
1. **Phase 1**: Critical 항목 통합 (2시간)
   - 유닛 테스트 프로덕션 코드 요구사항
   - 디버그 로깅 요구사항
   - 테스트 타임아웃 30분
   - Slack 알림 요구사항
   - TDD 원칙

2. **Phase 2**: Important 항목 통합 (1-2시간)
   - AAA 패턴, 테스트 케이스 요구사항
   - 복잡도 분석, AskUserQuestion
   - 커밋 프로토콜, 언어 정책

3. **Phase 3**: Nice to Have 통합 (필요 시)
   - Mock/Stub 가이드
   - 프로젝트 타입별 템플릿

---

## 🚀 권장 조치

### ✅ 옵션 D: 하이브리드 통합 실행 (추천)

#### Phase 1: Critical 항목 통합 (최우선)
```bash
# 실전 문제 해결책 통합 (2시간)

1. implementer.md 통합:
   - 유닛 테스트 프로덕션 코드 요구사항 (testing-standards.md 21-115줄)
   - 테스트 타임아웃 30분 (testing-standards.md 287-325줄)
   - 디버그 로깅 요구사항 (process-task-list.md 57-191줄)
   - Slack 알림 요구사항 (process-task-list.md 192-234줄)
   - TDD 원칙 (tdd.md 전체)
   - 커밋 프로토콜 (process-task-list.md 28-44줄)
   - 언어 사용 정책 (language-policy.md 전체) ⭐

2. planner.md 통합:
   - CRITICAL REQUIREMENTS 체크리스트 (skill-plan/SKILL.md 10-68줄)
   - 파일 위치 규칙 (skill-plan/SKILL.md)
   - Phase 규격 (skill-plan/SKILL.md)
   - 검증 스크립트 참조 (skill-plan/SKILL.md)
   - 언어 사용 정책 (language-policy.md 전체) ⭐

3. reviewer.md 통합:
   - 유닛 테스트 프로덕션 코드 검증
   - 테스트 타임아웃 확인
   - 디버그 로깅 검증
   - 언어 사용 정책 확인 (PLAN.md, REVIEW_REPORT.md 한글 작성) ⭐
```

#### Phase 2: Important 항목 통합 (1-2시간)
```bash
4. implementer.md 추가:
   - AAA 테스트 패턴 (testing-standards.md 198-286줄)
   - 테스트 케이스 최소 요구사항 (testing-standards.md 129-133줄)
   - Tidy First 원칙 (tdd.md)

5. planner.md 추가:
   - 복잡도 자동 분석 (skill-plan/SKILL.md 100-152줄)
   - AskUserQuestion 체계적 수집 (skill-plan/SKILL.md 183-199줄)
   - PRD 작성 프로세스 (create-prd.md)
   - 2단계 태스크 생성 프로세스 (generate-tasks.md)

6. reviewer.md 추가:
   - AAA 패턴 준수 확인
   - Mock/Stub 사용 검증
```

#### 검증
```bash
7. 통합 완료 후 테스트:
   - 전체 워크플로우 실행 (Planner → Implementer → Reviewer)
   - CRITICAL REQUIREMENTS 체크리스트 준수 확인
   - 실전 문제 재발 여부 확인

8. 품질 검증:
   - 3-tier 구조 정상 작동 확인
   - Reviewer 승인/거부 메커니즘 작동 확인
   - 피드백 루프 정상 작동 확인
```

---

## 📝 결론

**사용자의 우려가 100% 정확했습니다.**

서브에이전트(.claude/agents/*.md)는 기존 스킬(skill-*)과 문서(*.md)의 **실전 노하우를 전혀 반영하지 않고** 만들어졌습니다. 특히:

### 누락된 핵심 내용 요약

#### Planner (67% 누락, 766줄)
- ❌ CRITICAL REQUIREMENTS 체크리스트
- ❌ 파일 위치 규칙 (docs/features/)
- ❌ Phase 규격 (3-7개, 1-4시간)
- ❌ 검증 스크립트 참조
- ❌ 복잡도 자동 분석
- ❌ AskUserQuestion 체계적 수집
- ❌ PLAN.md 필수 섹션

#### Implementer (8% 누락, 68줄)
- ❌ TDD 원칙 (RED-GREEN-REFACTOR)
- ❌ Tidy First 원칙
- ❌ Production Integration Verification
- ❌ **타임아웃 30분 (1800000ms)** ⭐ 치명적!

#### Implementer + Reviewer (testing-standards.md 누락)
- ❌ **유닛 테스트 프로덕션 코드 요구사항** ⭐ 가장 심각!
  - 프로덕션 코드 임포트 검증
  - 테스트 내 구현 금지
  - 임포트 경로 검증 명령어
- ❌ AAA 테스트 패턴 (Arrange-Act-Assert)
- ❌ 테스트 케이스 최소 요구사항 (3가지)
- ❌ 테스트 설명 작성 방법
- ❌ Mock/Stub 사용 가이드

#### Implementer + Reviewer (process-task-list.md, language-policy.md 누락)
- ❌ **디버그 로깅 요구사항** (135줄) ⭐ 매우 심각!
  - 로깅 레벨 (DEBUG/INFO/WARN/ERROR)
  - 필수 로깅 위치 5가지
  - 민감 정보 로깅 금지
  - 품질 게이트 체크리스트
- ❌ **Slack 알림 요구사항** (43줄)
  - 태스크 완료/실패/제안 시 알림
  - 웹훅 스크립트 및 설정
  - **한글 메시지 필수** ⭐ (language-policy.md 연계)
- ❌ **커밋 프로토콜**
  - Conventional commit 형식
  - 임시 파일 정리 단계
  - 테스트 통과 후 커밋
- ❌ **언어 사용 정책** ⭐ 매우 중요!
  - 모든 출력 메시지 한글 작성
  - Slack 알림 한글 필수
  - 사용자 커뮤니케이션 한글

#### Planner (skill-plan, create-prd.md, generate-tasks.md, language-policy.md 누락)
- ❌ **CRITICAL REQUIREMENTS 체크리스트**
- ❌ **파일 위치 규칙** (docs/features/)
- ❌ **Phase 규격** (3-7개, 1-4시간)
- ❌ **복잡도 자동 분석**
- ❌ **PRD 작성 프로세스**
  - AskUserQuestion 도구 활용
  - 파일명 규칙
- ❌ **2단계 태스크 생성 프로세스**
  - Phase 1: 상위 태스크 → 확인
  - Phase 2: 하위 태스크 상세화
  - 자동 테스트 태스크 생성
- ❌ **언어 사용 정책** ⭐ 매우 중요!
  - 한글 작성 원칙 (PRD, PLAN.md 모두 한글)
  - 기술 용어 처리 가이드

### 실전 문제 재발 위험

다음 누락 항목들은 **실전에서 자주 발생했던 문제**를 해결하기 위해 작성된 핵심 규칙들입니다:

#### 1. 유닛 테스트 프로덕션 코드 요구사항 (testing-standards.md)
- **문제**: 테스트 통과 → 프로덕션 코드 작동 안 함
- **원인**: 테스트 파일 내 정의된 코드를 테스트 (프로덕션 아님)
- **해결**: 프로덕션 코드 임포트 검증 + 임포트 경로 검증
- **위험**: ⚠️ 완전히 누락 → 동일 문제 재발 가능성 매우 높음

#### 2. 디버그 로깅 요구사항 (process-task-list.md)
- **문제**: 이슈 발생 시 원인 파악 불가
- **원인**: 로깅 부재 또는 불충분
- **해결**: 필수 로깅 위치 5가지 + 로깅 레벨 + 민감 정보 금지
- **위험**: ⚠️ 완전히 누락 → 문제 발생 시 디버깅 어려움

#### 3. Slack 알림 요구사항 (process-task-list.md)
- **문제**: 태스크 진행 상황 추적 불가
- **원인**: 알림 메커니즘 부재
- **해결**: 완료/실패/제안 시 자동 알림
- **위험**: ⚠️ 완전히 누락 → 사용자 피드백 루프 없음

#### 4. 테스트 타임아웃 30분 (testing-standards.md, process-task-list.md)
- **문제**: 긴 테스트가 중간에 실패
- **원인**: 기본 타임아웃 (2분) 사용
- **해결**: 명시적으로 1800000ms (30분) 설정
- **위험**: ⚠️ 누락 → C++, 통합 테스트 등 긴 테스트 실패 가능

#### 5. 언어 사용 정책 (language-policy.md)
- **문제**: 문서마다 언어 사용이 일관되지 않음 (영어/한글 혼재)
- **원인**: 명확한 언어 정책 부재
- **해결**: 모든 문서 한글 작성 원칙 + 기술 용어 영어 유지
- **위험**: ⚠️ 완전히 누락 → PRD, PLAN.md, Slack 메시지 등 언어 불일치

이 규칙들이 서브에이전트에 **완전히 또는 부분적으로 누락**되어 있어 동일한 문제가 재발할 위험이 매우 높습니다.

### 즉시 조치 필요

**✅ 옵션 D: 하이브리드 통합 (강력 추천)**

**핵심 전략**:
- 🎁 서브에이전트의 좋은 구조는 **절대 손실 없이** 100% 유지
- 🔥 실전 노하우만 **추가로** 통합

**통합 대상**:
1. **implementer.md** (750줄 → 1,100줄):
   - testing-standards.md (유닛 테스트 프로덕션 코드, 타임아웃 30분, AAA 패턴)
   - process-task-list.md (디버그 로깅, Slack 알림, 커밋 프로토콜)
   - tdd.md (TDD 원칙, Tidy First)

2. **planner.md** (371줄 → 600줄):
   - skill-plan/SKILL.md (CRITICAL REQUIREMENTS, 파일 위치, Phase 규격, 복잡도 분석)
   - create-prd.md, generate-tasks.md (프로세스)
   - language-policy.md (언어 정책)

3. **reviewer.md** (716줄 → 900줄):
   - 프로덕션 코드 검증
   - 타임아웃 확인
   - 디버그 로깅 검증

**최우선 통합 항목 (실전 문제 해결책):**
1. **유닛 테스트 프로덕션 코드 요구사항** ⭐⭐⭐
2. **디버그 로깅 요구사항** ⭐⭐⭐
3. **테스트 타임아웃 30분** ⭐⭐⭐
4. **Slack 알림 요구사항** ⭐⭐⭐
5. **TDD 원칙** ⭐⭐⭐
6. **언어 사용 정책** ⭐⭐⭐ (모든 문서의 기본 원칙)

**보존 항목 (절대 삭제 금지)**:
- 3-Tier 워크플로우 (Planner → Implementer → Reviewer)
- Reviewer의 승인/거부 권한
- 요구사항 충족도 계산 시스템
- 코드 품질 점수 시스템 (15점 만점)
- 피드백 루프 메커니즘
- PLAN.md, REVIEW_REPORT.md 파일 기반 통신
