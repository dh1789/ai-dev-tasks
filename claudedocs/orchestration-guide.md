# 서브에이전트 오케스트레이션 가이드

**작성일**: 2026-01-20
**목적**: Planner → Implementer → Reviewer 자동 연결 실행

---

## 🎯 오케스트레이션이란?

개별 에이전트를 수동으로 호출하는 대신, **한 번의 요청으로 전체 워크플로우를 자동 실행**하는 방식입니다.

### 비교

| 방식 | 요청 횟수 | 사용자 개입 | 소요 시간 | 적합한 경우 |
|------|----------|------------|----------|------------|
| **개별 호출** | 3회 | 각 단계마다 | 느림 | 중요한 프로젝트, 세밀한 제어 필요 |
| **오케스트레이션** | 1회 | 최소 | 빠름 | 일반적인 작업, 신뢰할 수 있는 워크플로우 |

---

## 🚀 사용 방법

### 방법 1: 전체 자동 실행 (Planner → Implementer → Reviewer)

#### 기본 사용법

```
"JWT 인증 기능을 추가해줘. 계획 수립, 구현, 검토까지 완료해줘."
```

#### 상세 예시

```
"Node.js + Express 프로젝트에 JWT 인증 시스템을 추가해줘.

요구사항:
- 회원가입 (POST /api/auth/signup)
- 로그인 (POST /api/auth/login)
- JWT 토큰 발급 및 검증
- 보호된 엔드포인트 (GET /api/users/me)

Planner로 계획 수립 → Implementer로 구현 → Reviewer로 검증까지 자동으로 진행해줘."
```

#### Claude Code의 자동 실행

Claude Code는 다음과 같이 자동으로 진행합니다:

**Phase 1: Planner 실행**
```
✅ PLAN.md 생성: docs/features/2026-01-20-jwt-auth/PLAN.md
✅ 4개 Phase 정의
✅ TDD 구조, Quality Gate, 롤백 전략 포함
```

**Phase 2: Implementer 실행**
```
✅ PLAN.md 읽기
✅ Phase 1-4 순차 구현
✅ 각 Phase: TDD → 테스트 → 품질 검사 → 커밋
✅ PROGRESS.md 업데이트
```

**Phase 3: Reviewer 실행**
```
✅ 요구사항 충족도 검증
✅ 코드 품질 평가
✅ 테스트 품질 검증
✅ REVIEW_REPORT.md 생성
✅ 최종 결정: 승인/거부/조건부 승인
```

---

### 방법 2: 단계별 자동 실행 + 사용자 승인

중간에 사용자 확인이 필요한 경우:

```
"JWT 인증 기능을 추가해줘.

1단계: Planner로 계획 수립 후 나에게 보여줘
2단계: 내가 승인하면 Implementer로 구현
3단계: 구현 완료 후 Reviewer로 검증

각 단계마다 내 승인을 받고 진행해줘."
```

#### 실행 흐름

```
Claude: [Planner 실행]
        PLAN.md 생성 완료했습니다.
        4개 Phase로 구성:
        - Phase 1: 데이터 모델 (1-2h)
        - Phase 2: 컨트롤러 (2-3h)
        - Phase 3: 라우트/미들웨어 (1-2h)
        - Phase 4: 통합 검증 (1h)

        이 계획으로 진행해도 될까요?

사용자: "좋아, 진행해"

Claude: [Implementer 실행]
        Phase 1-4 구현 완료했습니다.
        - 총 23개 테스트 통과
        - 커버리지 87%
        - 4개 커밋 완료

        Reviewer로 검증을 진행할까요?

사용자: "응"

Claude: [Reviewer 실행]
        검증 완료했습니다.
        - 요구사항 충족도: 100%
        - 코드 품질: 14/15
        - 최종 결정: ✅ 조건부 승인
```

---

### 방법 3: 스킬 사용 (스킬이 설정된 경우)

#### /plan 스킬

```bash
/plan "JWT 인증 기능 추가"
```

**결과**: Planner 에이전트 실행 → PLAN.md 생성

#### /implement 스킬

```bash
/implement docs/features/2026-01-20-jwt-auth/PLAN.md
```

**결과**: Implementer 에이전트 실행 → Phase별 구현

#### /review 스킬

```bash
/review docs/features/2026-01-20-jwt-auth/PLAN.md
```

**결과**: Reviewer 에이전트 실행 → REVIEW_REPORT.md 생성

#### 전체 워크플로우 스킬 (있는 경우)

```bash
/workflow "JWT 인증 기능" --full-cycle

# 또는
/sc:workflow "JWT 인증 기능 계획 → 구현 → 검토"
```

**결과**: Planner → Implementer → Reviewer 자동 실행

---

### 방법 4: Task 에이전트 사용

복잡한 오케스트레이션이 필요한 경우:

```
"Task 에이전트를 사용해서 다음 작업을 수행해줘:

1. Planner로 JWT 인증 기능 계획 수립
2. 계획 검증 (Phase 개수, TDD 구조 확인)
3. Implementer로 구현
4. 각 Phase 완료 시 PROGRESS.md 확인
5. Reviewer로 최종 검증
6. 검증 결과가 '승인'이면 배포 준비, '거부'면 문제점 보고"
```

**Task 에이전트의 장점**:
- 복잡한 조건 분기 가능
- 에러 처리 및 재시도
- 병렬 실행 (여러 기능 동시 개발)

---

## 🎯 오케스트레이션 패턴

### 패턴 1: 완전 자동 (Full Auto)

**적합한 경우**:
- 간단하고 표준적인 기능
- 요구사항이 명확함
- 이전에 비슷한 작업 성공 경험

**사용법**:
```
"사용자 프로필 수정 기능을 추가해줘. 계획, 구현, 검토까지 자동으로 완료해줘."
```

**리스크**: 중간에 개입 불가, PLAN.md가 잘못되어도 바로 구현 진행

---

### 패턴 2: 승인 게이트 (Approval Gates)

**적합한 경우**:
- 중요한 프로젝트
- 요구사항 조정 필요 가능성
- 아키텍처 결정이 중요

**사용법**:
```
"결제 시스템을 추가해줘.
각 단계(계획, 구현, 검토)마다 내 승인을 받고 진행해줘."
```

**장점**: 각 단계 확인 가능, 문제 조기 발견

---

### 패턴 3: 하이브리드 (Hybrid)

**적합한 경우**:
- 계획만 확인하고 싶음
- 구현과 검토는 자동화

**사용법**:
```
"OAuth 2.0 인증을 추가해줘.

1단계: Planner로 계획 수립 → 나에게 보여주고 승인 받기
2단계: 승인 후 Implementer → Reviewer 자동 실행"
```

**장점**: 계획만 확인하면 되므로 빠르고 안전

---

### 패턴 4: 병렬 실행 (Parallel)

**적합한 경우**:
- 여러 독립적인 기능 동시 개발
- 팀 작업 시뮬레이션

**사용법**:
```
"다음 3가지 기능을 병렬로 개발해줘:
1. JWT 인증 시스템
2. 사용자 프로필 관리
3. 이메일 알림 기능

각각 Planner → Implementer → Reviewer 워크플로우 실행"
```

**주의**: 파일 충돌 가능성, Git 브랜치 관리 필요

---

## 🎛️ 오케스트레이션 옵션

### 옵션 1: 진행 상황 보고

```
"JWT 인증 기능을 추가해줘.
각 Phase 완료 시마다 간단히 보고해줘."
```

**결과**:
```
✅ Planner 완료: PLAN.md 생성 (4개 Phase)
🔄 Implementer 시작...
  ✅ Phase 1 완료: User 모델 (테스트 5/5)
  ✅ Phase 2 완료: 컨트롤러 (테스트 8/8)
  ✅ Phase 3 완료: 라우트 (테스트 10/10)
  ✅ Phase 4 완료: 통합 검증 (총 23/23)
✅ Implementer 완료: 커버리지 87%
🔄 Reviewer 시작...
✅ Reviewer 완료: 조건부 승인 (품질 14/15)
```

---

### 옵션 2: 실패 시 중단

```
"JWT 인증 기능을 추가해줘.
만약 테스트 실패나 품질 검사 실패 시 즉시 중단하고 보고해줘."
```

**예시 (Phase 2에서 실패)**:
```
✅ Phase 1 완료
🔄 Phase 2 진행 중...
❌ Phase 2 실패: 테스트 3회 재시도 후 실패

**실패 상세**:
- 위치: src/controllers/authController.ts:45
- 원인: 중복 이메일 체크 로직 오류
- 시도한 해결: 에러 핸들링 추가, 로깅 강화, 테스트 재작성

🚨 작업 중단. 사용자 개입 필요.
```

---

### 옵션 3: 품질 기준 조정

```
"JWT 인증 기능을 추가해줘.
테스트 커버리지 목표를 90%로 설정하고,
Reviewer 승인 기준을 '코드 품질 13/15 이상'으로 설정해줘."
```

**효과**:
- Implementer가 더 많은 테스트 작성
- Reviewer가 더 엄격하게 검증

---

## 📊 실전 예제: 전체 자동 실행

### 예제 1: 간단한 CRUD API

**사용자 요청**:
```
"사용자 관리 CRUD API를 추가해줘.
계획, 구현, 검토까지 자동으로 완료해줘.

요구사항:
- POST /api/users (생성)
- GET /api/users/:id (조회)
- PUT /api/users/:id (수정)
- DELETE /api/users/:id (삭제)
- 테스트 커버리지 80% 이상"
```

**Claude Code 실행**:

```
🔄 Planner 시작...
✅ Planner 완료: docs/features/2026-01-20-user-crud/PLAN.md
   - 3개 Phase (모델, 컨트롤러/라우트, 통합 테스트)
   - 예상 소요: 4-6시간

🔄 Implementer 시작...
  📝 Phase 0: 프로젝트 타입 감지 (Node.js/TypeScript)

  🔴 Phase 1: User 모델
    - RED: 테스트 작성 (5개)
    - GREEN: 모델 구현
    - REFACTOR: 로깅 추가
    ✅ 완료: 테스트 5/5, 커버리지 92%
    📦 커밋: feat: Phase 1 - User 모델 구현

  🔴 Phase 2: 컨트롤러 및 라우트
    - RED: 테스트 작성 (12개)
    - GREEN: CRUD 로직 구현
    - REFACTOR: 에러 핸들링 개선
    ✅ 완료: 테스트 12/12, 커버리지 88%
    📦 커밋: feat: Phase 2 - CRUD 컨트롤러 및 라우트

  🔴 Phase 3: 통합 테스트
    - E2E 시나리오 테스트 (6개)
    ✅ 완료: 전체 테스트 23/23, 커버리지 87%
    📦 커밋: feat: Phase 3 - 통합 테스트 및 최종 검증

✅ Implementer 완료
   - 총 23개 테스트 통과
   - 커버리지: 87%
   - 4개 커밋 생성
   - PROGRESS.md 업데이트 완료

🔄 Reviewer 시작...
  📋 요구사항 충족도 검증...
    ✅ POST /api/users (생성)
    ✅ GET /api/users/:id (조회)
    ✅ PUT /api/users/:id (수정)
    ✅ DELETE /api/users/:id (삭제)
    ✅ 테스트 커버리지 ≥ 80% (87%)

    **충족도**: 100% (5/5)

  🏗️ 코드 품질 평가...
    - 아키텍처: 5/5 ✅
    - 가독성: 5/5 ✅
    - 완전성: 5/5 ✅
    **총점**: 15/15

  🧪 테스트 품질 검증...
    - 커버리지: 87% ✅
    - 테스트 품질: 5/5 ✅

  🔒 보안 검토: ✅ 문제 없음
  ⚡ 성능 검토: ✅ 문제 없음
  📝 PROGRESS.md 검증: ✅ 완벽
  🔍 언어별 품질 검증: ✅ ESLint 0 errors, TypeScript 0 errors

✅ Reviewer 완료: docs/features/2026-01-20-user-crud/REVIEW_REPORT.md

## 최종 결과: ✅ 승인

**요약**:
- 요구사항 충족도: 100%
- 코드 품질: 15/15 (완벽)
- 테스트 커버리지: 87%
- 보안/성능: 문제 없음

**생성된 파일**:
- src/models/User.ts
- src/controllers/userController.ts
- src/routes/users.ts
- tests/user.test.ts
- docs/features/2026-01-20-user-crud/PLAN.md
- docs/features/2026-01-20-user-crud/PROGRESS.md
- docs/features/2026-01-20-user-crud/REVIEW_REPORT.md

**다음 단계**:
- 프로덕션 배포 가능
- API 문서화 권장
```

**소요 시간**: 약 5-10분 (자동 실행)

---

### 예제 2: 승인 게이트 방식

**사용자 요청**:
```
"결제 시스템을 추가해줘.

요구사항:
- Stripe 결제 통합
- 결제 이력 저장
- 환불 처리

각 단계마다 내 승인을 받고 진행해줘."
```

**실행 흐름**:

**Phase 1: Planner**
```
Claude: Planner를 실행하여 PLAN.md를 작성했습니다.

## 계획 요약
- Phase 1: Stripe SDK 통합 및 테스트 (2h)
- Phase 2: 결제 모델 및 컨트롤러 (3h)
- Phase 3: 결제 이력 저장 (2h)
- Phase 4: 환불 로직 (2h)
- Phase 5: 통합 테스트 및 보안 검증 (2h)

총 예상 소요: 11시간

**주요 아키텍처 결정**:
- Stripe Webhook 사용 (결제 상태 동기화)
- 이벤트 기반 아키텍처 (결제 → 이메일 알림)
- Idempotency Key 사용 (중복 결제 방지)

이 계획으로 진행할까요? 수정이 필요한 부분이 있으면 알려주세요.

사용자: "Phase 4를 Phase 2 다음으로 옮겨줘. 환불 로직을 먼저 구현하고 싶어."

Claude: 계획을 수정했습니다.

## 수정된 계획
- Phase 1: Stripe SDK 통합 및 테스트 (2h)
- Phase 2: 결제 모델 및 컨트롤러 (3h)
- Phase 3: 환불 로직 (2h) ← 이동됨
- Phase 4: 결제 이력 저장 (2h)
- Phase 5: 통합 테스트 및 보안 검증 (2h)

PLAN.md를 업데이트했습니다. 이제 Implementer로 구현을 시작할까요?

사용자: "좋아, 진행해"
```

**Phase 2: Implementer**
```
Claude: [Implementer 실행]

Phase 1-5 구현을 완료했습니다.

**구현 결과**:
- 총 테스트: 34/34 통과
- 커버리지: 91%
- 커밋: 5개
- Stripe Webhook 테스트: 성공
- 환불 시뮬레이션: 성공

**생성된 파일**:
- src/services/stripe.ts
- src/models/Payment.ts
- src/controllers/paymentController.ts
- src/webhooks/stripeWebhook.ts
- tests/payment.test.ts

Reviewer로 검증을 진행할까요?

사용자: "응"
```

**Phase 3: Reviewer**
```
Claude: [Reviewer 실행]

검증을 완료했습니다.

## 검증 결과

**요구사항 충족도**: 100% (3/3)
- ✅ Stripe 결제 통합
- ✅ 결제 이력 저장
- ✅ 환불 처리

**코드 품질**: 14/15
- 아키텍처: 5/5 ✅
- 가독성: 4/5 ⚠️ (Webhook 핸들러 복잡도 높음)
- 완전성: 5/5 ✅

**보안 검토**: ✅ 통과
- Stripe Secret Key 환경변수 관리
- Webhook Signature 검증
- Idempotency Key 구현

**성능 검토**: ✅ 통과
- 비동기 처리 적절
- N+1 쿼리 없음

## 최종 결정: ✅ 조건부 승인

**조건**:
- 🟡 Webhook 핸들러 리팩토링 권장 (복잡도 감소)

**다음 단계**:
1. (선택) Webhook 핸들러 리팩토링
2. Stripe 테스트 모드에서 실제 결제 시뮬레이션
3. 프로덕션 배포 전 Stripe Webhook URL 설정
```

---

## 🛠️ 고급 오케스트레이션

### 조건부 분기

```
"사용자 인증 기능을 추가해줘.

조건:
- Reviewer 검증 결과가 '승인'이면 → 자동으로 배포 브랜치에 머지
- Reviewer 검증 결과가 '거부'면 → 문제점 상세 보고 + 수정 방법 제안
- Reviewer 검증 결과가 '조건부 승인'이면 → 개선 사항 알려주고 내 판단 요청"
```

---

### 병렬 실행

```
"다음 3가지 기능을 동시에 개발해줘:

1. 사용자 프로필 관리 (User Profile)
2. 알림 시스템 (Notification)
3. 검색 기능 (Search)

각각 독립적인 Git 브랜치에서 작업하고,
모두 완료되면 통합 테스트 실행해줘."
```

---

### 에러 복구

```
"JWT 인증 기능을 추가해줘.

에러 처리:
- Implementer에서 테스트 실패 시 → 최대 3회 재시도
- 3회 재시도 후에도 실패 시 → 실패한 Phase까지만 커밋하고 보고
- Reviewer에서 '거부' 시 → Implementer 재실행하여 수정
- 최종 승인까지 최대 3번 반복"
```

---

## ⚠️ 주의사항

### 1. PLAN.md 자동 승인 리스크

**문제**:
완전 자동 실행 시 PLAN.md를 확인하지 않고 바로 구현 진행

**해결**:
- 중요한 프로젝트는 승인 게이트 사용
- 첫 Phase만 수동 확인 후 나머지 자동화
- PLAN.md 자동 검증 스크립트 활용

---

### 2. Git 충돌

**문제**:
병렬 실행 시 파일 충돌 가능

**해결**:
- 독립적인 브랜치 사용
- 파일 의존성 분석 후 병렬 실행 여부 결정
- 순차 실행 우선 고려

---

### 3. 중단 조건 발생 시

**문제**:
테스트 실패, 빌드 실패 등으로 중단

**해결**:
- 자동 재시도 설정 (최대 3회)
- Slack 알림으로 즉시 통보
- 중단된 지점부터 재개 기능

---

## 📋 체크리스트

### 오케스트레이션 시작 전

- [ ] 요구사항이 명확한가?
- [ ] 프로젝트 타입이 지원되는가? (Node.js/Ruby/C++/Python)
- [ ] 테스트 환경이 준비되었는가?
- [ ] Git 저장소가 정상 상태인가?

### 오케스트레이션 중

- [ ] Planner가 합리적인 계획을 수립했는가?
- [ ] 각 Phase가 독립적으로 테스트 가능한가?
- [ ] 중단 조건 발생 시 적절히 처리되는가?
- [ ] PROGRESS.md가 실시간으로 업데이트되는가?

### 오케스트레이션 완료 후

- [ ] Reviewer 검증 결과가 승인인가?
- [ ] 모든 테스트가 통과했는가?
- [ ] REVIEW_REPORT.md를 확인했는가?
- [ ] Git 커밋 이력이 정상인가?

---

## 🎯 권장 사용 패턴

### 일반적인 기능 개발
```
완전 자동 실행 (Full Auto)
→ 빠르고 편리함
```

### 중요한 프로젝트
```
승인 게이트 (Approval Gates)
→ 각 단계 확인 가능
```

### 처음 사용하는 경우
```
하이브리드 (Hybrid)
→ PLAN.md만 확인 후 나머지 자동화
```

### 여러 기능 동시 개발
```
병렬 실행 (Parallel)
→ 독립적인 브랜치에서 동시 작업
```

---

## 🚀 빠른 시작

```
# 가장 간단한 방법
"[기능명]을 추가해줘. 계획, 구현, 검토까지 자동으로 완료해줘."

# 승인 게이트 포함
"[기능명]을 추가해줘. 각 단계마다 내 승인을 받고 진행해줘."

# 스킬 사용 (있는 경우)
/workflow "[기능명]" --full-cycle

# Task 에이전트 사용
"Task 에이전트로 [기능명]을 계획, 구현, 검토까지 완료해줘."
```

---

**마지막 업데이트**: 2026-01-20
**버전**: 1.0
