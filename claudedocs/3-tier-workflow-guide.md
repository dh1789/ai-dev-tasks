# 3단계 서브에이전트 워크플로우 가이드

## 📋 개요

이 가이드는 **Planner → Implementer → Reviewer** 3단계 서브에이전트 워크플로우의 완전한 사용 방법을 설명합니다.

### 핵심 구조
```
사용자 요청
    ↓
┌─────────────────────────────────────┐
│  Planner Agent (Fresh Context)      │
│  - 요구사항 분석                      │
│  - 아키텍처 설계                      │
│  - Phase 분해                        │
│  출력: PLAN.md                       │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│  Implementer Agent (Fresh Context)  │
│  - PLAN.md 기반 구현                 │
│  - 테스트 작성                       │
│  - 품질 검증                         │
│  출력: Code + Tests                  │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│  Reviewer Agent (Fresh Context)     │
│  - 요구사항 충족도 검증               │
│  - 코드 품질 평가                    │
│  - 보안/성능 검토                    │
│  출력: REVIEW_REPORT.md              │
│  결정: 승인/거부                      │
└─────────────────────────────────────┘
    ↓
  ✅ 승인? → 완료
  ❌ 거부? → Implementer 재작업 → Reviewer 재검토
```

---

## 🚀 빠른 시작

### 1. Planner 호출

```bash
# Claude Code에서 Task 도구 사용
```

**프롬프트**:
```
다음 기능에 대한 구체적인 구현 계획을 수립하고 PLAN.md를 작성하세요:

**기능**: [여기에 구현하고자 하는 기능 설명]

.claude/agents/planner.md의 지침을 따라:
1. 프로젝트 환경 분석
2. 요구사항 명확화
3. 아키텍처 결정
4. Phase 분해
5. PLAN.md 작성

PLAN.md는 프로젝트 루트에 생성하세요.
```

**결과**: `PLAN.md` 생성 완료

---

### 2. Implementer 호출

**프롬프트**:
```
PLAN.md를 읽고 계획된 모든 Phase를 구현하세요.

.claude/agents/implementer.md의 지침을 따라:
1. PLAN.md 읽기 및 검증
2. 프로젝트 타입 자동 감지
3. Phase별 순차 구현
4. 품질 검증 (빌드, 테스트, 린트)
5. 최종 완료 보고서 작성

모든 품질 기준을 통과할 때까지 반복적으로 디버깅하세요.
```

**결과**:
- 구현된 코드 (`src/`)
- 테스트 코드 (`test/`)
- 구현 완료 보고서

---

### 3. Reviewer 호출

**프롬프트**:
```
다음 구현을 검토하고 REVIEW_REPORT.md를 작성하세요:

**PLAN.md 위치**: PLAN.md
**구현 코드**: src/
**테스트 코드**: test/

.claude/agents/reviewer.md의 지침을 따라:
1. PLAN.md 요구사항 확인
2. 구현 코드 검토
3. 테스트 실행 및 결과 확인
4. 요구사항 충족도 계산
5. 코드 품질 평가
6. 보안/성능 검토
7. REVIEW_REPORT.md 작성
8. 승인/거부 결정

**출력**: REVIEW_REPORT.md (프로젝트 루트)
```

**결과**: `REVIEW_REPORT.md` 생성

---

### 4. 결과 확인 및 후속 조치

#### ✅ 승인된 경우
```markdown
# REVIEW_REPORT.md

## 최종 결정
✅ 승인

→ 완료! 프로덕션 배포 가능
```

#### ❌ 거부된 경우
```markdown
# REVIEW_REPORT.md

## 최종 결정
❌ 거부

## 개선 필수 사항
1. TODO 주석 제거
2. 에러 처리 추가
...

→ Implementer 재호출 (피드백 루프)
```

---

## 🔄 피드백 루프 사용법

### 재작업 프롬프트 (Implementer)

```
이전 REVIEW_REPORT.md의 개선사항을 반영하여 코드를 수정하세요:

**REVIEW_REPORT**: REVIEW_REPORT.md
**현재 코드**: src/

.claude/agents/implementer.md의 지침을 따라:
1. REVIEW_REPORT.md 읽기
2. 모든 "개선 필수 사항" 반영
3. 가능한 "개선 권장 사항" 반영
4. 개선사항 체크리스트 작성
5. 품질 검증

**출력**: 개선된 코드 + 체크리스트
```

### 재검토 프롬프트 (Reviewer)

```
이전 REVIEW_REPORT.md의 개선사항이 반영되었는지 재검토하세요:

**이전 리뷰**: REVIEW_REPORT.md
**구현 코드**: src/ (업데이트됨)

.claude/agents/reviewer.md의 재검토 프로세스 따라:
1. 이전 REVIEW_REPORT.md 읽기
2. 개선사항 목록 확인
3. 각 개선사항 반영 여부 체크
4. 새로운 REVIEW_REPORT.md 작성
5. 최종 승인/거부 결정

**출력**: REVIEW_REPORT.md (v2)
```

---

## 📊 전체 워크플로우 다이어그램

### 기본 시나리오 (첫 구현 승인)

```
User: "JWT 인증 시스템 구현"
    ↓
Planner Agent
    ↓ (PLAN.md)
    ├─ 요구사항: 46개
    ├─ Phase: 5개
    └─ 품질 기준: 정의됨
    ↓
Implementer Agent
    ↓ (Code + Tests)
    ├─ 파일: 19개
    ├─ 테스트: 53/53 통과
    └─ 커버리지: 96.25%
    ↓
Reviewer Agent
    ↓ (REVIEW_REPORT.md)
    ├─ 요구사항: 46/46 (100%)
    ├─ 품질: 14/15
    └─ 결정: ✅ 승인
    ↓
✅ 완료!
```

### 피드백 루프 시나리오

```
User: "사용자 관리 시스템 구현"
    ↓
Planner Agent → PLAN.md
    ↓
Implementer Agent → Code v1.0
    ↓
Reviewer Agent → REVIEW_REPORT v1.0
    ↓ (❌ 거부)
    ├─ 요구사항: 38/42 (90%)
    ├─ 품질: 11/15
    └─ 개선사항:
        - TODO 제거
        - 테스트 추가
    ↓
Implementer Agent (재작업) → Code v1.1
    ↓ (개선사항 반영)
    ├─ TODO 제거 완료
    ├─ 테스트 추가 (커버리지 75% → 88%)
    └─ 요구사항 4개 추가 구현
    ↓
Reviewer Agent (재검토) → REVIEW_REPORT v1.1
    ↓ (✅ 승인)
    ├─ 요구사항: 42/42 (100%)
    ├─ 품질: 14/15
    └─ 개선 확인: 모두 반영됨
    ↓
✅ 완료!
```

---

## 💼 실전 예제

### 예제 1: JWT 인증 시스템 (단순 케이스)

#### 사용자 요청
```
"JWT 기반 사용자 인증 시스템을 구현해주세요.
회원가입, 로그인, 토큰 갱신 기능이 필요합니다."
```

#### Step 1: Planner
```
[Task 도구로 Planner Agent 호출]

결과: PLAN.md (727줄)
- 요구사항: 46개
- Phase: 5개
- 품질 기준: 테스트 커버리지 80%+
```

#### Step 2: Implementer
```
[Task 도구로 Implementer Agent 호출]

결과:
- 파일: 28개 (프로덕션 9 + 테스트 10 + 설정 9)
- 테스트: 53/53 통과
- 커버리지: 96.25%
```

#### Step 3: Reviewer
```
[Task 도구로 Reviewer Agent 호출]

결과: REVIEW_REPORT.md
- 요구사항 충족도: 100%
- 코드 품질: 14/15
- 최종 결정: ✅ 승인
```

#### 총 소요
- 에이전트 호출: 3회
- 피드백 루프: 0회
- 결과: 완벽 구현 ✅

---

### 예제 2: 사용자 관리 시스템 (피드백 루프 케이스)

#### 사용자 요청
```
"사용자 프로필 관리 시스템을 만들어주세요.
CRUD 기능과 이미지 업로드가 필요합니다."
```

#### Step 1: Planner
```
결과: PLAN.md
- 요구사항: 35개
- Phase: 4개
```

#### Step 2: Implementer (v1.0)
```
결과: Code v1.0
- 파일: 12개
- 테스트: 28/32 실패 (일부 기능 미구현)
- 커버리지: 68%
```

#### Step 3: Reviewer (v1.0)
```
결과: REVIEW_REPORT.md v1.0
- 요구사항 충족도: 85% (30/35)
- 코드 품질: 10/15
- 최종 결정: ❌ 거부

개선사항:
1. 이미지 업로드 기능 미구현
2. 삭제 기능 TODO 남아있음
3. 테스트 부족 (32개 중 4개 실패)
4. 커버리지 부족 (68% < 80%)
```

#### Step 4: Implementer (v1.1 - 재작업)
```
개선:
- 이미지 업로드 구현 완료
- 삭제 기능 완전 구현 (TODO 제거)
- 테스트 추가 (모든 테스트 통과)
- 커버리지: 68% → 87%

결과: Code v1.1
- 파일: 15개 (3개 추가)
- 테스트: 38/38 통과
- 커버리지: 87%
```

#### Step 5: Reviewer (v1.1 - 재검토)
```
결과: REVIEW_REPORT.md v1.1
- 요구사항 충족도: 100% (35/35)
- 코드 품질: 13/15
- v1.0 대비 개선도:
  - 요구사항: 85% → 100%
  - 품질: 10/15 → 13/15
  - 커버리지: 68% → 87%
- 최종 결정: ✅ 승인
```

#### 총 소요
- 에이전트 호출: 5회
- 피드백 루프: 1회
- 결과: 피드백 반영 후 승인 ✅

---

## 📁 파일 구조

### 프로젝트 파일
```
project/
├── PLAN.md                  ← Planner 출력
├── REVIEW_REPORT.md         ← Reviewer 출력
├── src/                     ← Implementer 출력
│   ├── controllers/
│   ├── services/
│   ├── models/
│   └── ...
├── test/                    ← Implementer 출력
│   ├── unit/
│   ├── integration/
│   └── e2e/
└── ...
```

### 에이전트 사양
```
.claude/agents/
├── planner.md          ← Planner 사양
├── implementer.md      ← Implementer 사양
└── reviewer.md         ← Reviewer 사양
```

### 가이드 문서
```
claudedocs/
├── 3-tier-workflow-guide.md       ← 이 가이드
├── feedback-loop-workflow.md      ← 피드백 루프 상세
├── subagent-migration-plan.md     ← 프로젝트 개요
└── test-results/                  ← 테스트 결과
    └── final-report.md
```

---

## ⚙️ 설정 및 커스터마이징

### Planner 커스터마이징

**PLAN.md 템플릿 수정**:
- `.claude/agents/planner.md` 파일의 템플릿 섹션 편집
- 프로젝트 타입별 Phase 분해 전략 조정

### Implementer 커스터마이징

**언어별 빌드/테스트 명령어**:
- `.claude/agents/implementer.md`의 "프로젝트 타입 자동 감지" 섹션 수정
- 새로운 언어/프레임워크 추가 가능

### Reviewer 커스터마이징

**품질 기준 조정**:
```markdown
# reviewer.md

## 승인 기준
- 요구사항 충족도: ≥ 95%  (조정 가능)
- 코드 품질: ≥ 12/15      (조정 가능)
- 테스트 커버리지: ≥ 80%   (조정 가능)
```

### 피드백 루프 설정

**최대 반복 횟수**:
```yaml
# 기본값: 3회
feedback_loop_config:
  max_iterations: 3
  escalate_on_max: true
```

---

## 🔧 문제 해결 (Troubleshooting)

### 문제 1: PLAN.md가 너무 간략함

**증상**: Implementer가 세부사항을 몰라 구현 실패

**해결**:
1. Planner 프롬프트에 "매우 상세하게" 추가
2. AskUserQuestion으로 요구사항 명확화 요청
3. `.claude/agents/planner.md`의 템플릿 강화

---

### 문제 2: Implementer가 PLAN.md를 무시함

**증상**: 요구사항과 다른 구현

**해결**:
1. Implementer 프롬프트에 "PLAN.md 정확히 따를 것" 강조
2. Reviewer가 요구사항 충족도 엄격히 검증
3. 피드백 루프로 수정

---

### 문제 3: Reviewer가 너무 엄격함

**증상**: 사소한 문제로 계속 거부

**해결**:
1. Reviewer 기준 완화 (예: 요구사항 90% → 85%)
2. "조건부 승인" 활용
3. 최대 반복 횟수 후 수동 승인

---

### 문제 4: 피드백 루프가 무한 반복

**증상**: 최대 횟수에 계속 도달

**해결**:
1. PLAN.md 품질 문제 → Planner 재호출
2. 근본적 기술 제약 → 요구사항 조정
3. 수동 개입 → 현재 상태로 승인 결정

---

## 📈 성능 지표

### 테스트 결과 (JWT 인증 시스템)

| 지표 | 2단계 (Planner→Implementer) | 3단계 (+Reviewer) |
|------|---------------------------|-------------------|
| 요구사항 충족도 | 100% | 100% |
| 코드 품질 | 측정 안 됨 | 14/15 (93%) |
| 독립 검증 | ❌ 없음 | ✅ 있음 |
| 개선 피드백 | ❌ 없음 | ✅ 3개 제안 |
| 프로덕션 준비도 | 불명확 | ✅ 명확 (승인) |

### 피드백 루프 효과

```
초기 구현 → 1차 개선 → 2차 개선

요구사항:  75% → 90% → 98%
코드 품질:  8/15 → 11/15 → 14/15
커버리지:  60% → 80% → 92%
```

---

## 🎯 Best Practices

### 1. 명확한 요구사항으로 시작
- Planner에게 충분한 컨텍스트 제공
- 모호한 요청은 AskUserQuestion으로 명확화

### 2. Reviewer 피드백 존중
- 거부 결정에는 타당한 이유가 있음
- 개선사항을 성실히 반영

### 3. 피드백 루프는 품질 향상의 기회
- 실패가 아닌 개선 과정
- 점진적 품질 향상

### 4. 적절한 타협점 찾기
- 완벽주의 지양 (80% 규칙)
- 조건부 승인 활용

---

## 📚 추가 참고 자료

### 에이전트 사양 상세
- [Planner Agent 사양](../.claude/agents/planner.md)
- [Implementer Agent 사양](../.claude/agents/implementer.md)
- [Reviewer Agent 사양](../.claude/agents/reviewer.md)

### 워크플로우 상세
- [피드백 루프 워크플로우](./feedback-loop-workflow.md)
- [서브에이전트 마이그레이션 계획](./subagent-migration-plan.md)

### 테스트 결과
- [최종 테스트 보고서](./test-results/final-report.md)
- [요구사항 체크리스트](./test-results/requirements-checklist.md)

---

## ✅ 체크리스트

### 시작 전 확인
- [ ] `.claude/agents/` 에 3개 에이전트 사양 파일 존재
- [ ] 프로젝트 루트 경로 확인
- [ ] Git 저장소 초기화 (권장)

### 각 단계 완료 확인
- [ ] Planner: PLAN.md 생성됨
- [ ] Implementer: src/ 및 test/ 생성됨
- [ ] Reviewer: REVIEW_REPORT.md 생성됨

### 최종 확인
- [ ] 모든 요구사항 구현됨 (REVIEW_REPORT 확인)
- [ ] 코드 품질 기준 충족
- [ ] Reviewer 승인 획득

---

**버전**: 1.0.0
**작성일**: 2026-01-19
**다음 단계**: 이 가이드대로 실제 프로젝트에 적용해보세요!
