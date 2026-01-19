# 피드백 루프 워크플로우 (Feedback Loop Workflow)

## 📋 개요

Reviewer → Implementer 피드백 루프는 구현 품질을 점진적으로 향상시키는 자동화된 반복 프로세스입니다.

### 핵심 개념
- **Reviewer**가 문제를 발견하면 **거부** + 구체적 개선사항 제시
- **Implementer**가 개선사항을 반영하여 코드 수정
- **Reviewer**가 재검토하여 개선 여부 확인
- **승인**될 때까지 또는 **최대 횟수**까지 반복

### 실제 개발 프로세스와의 유사성
```
실제 개발:
Pull Request → Code Review → Changes Requested
  → Developer Fix → Re-review → Approved

서브에이전트:
Implementer → Reviewer → Rejected + Feedback
  → Implementer Fix → Reviewer Re-review → Approved
```

---

## 🔄 워크플로우 시나리오

### 시나리오 1: 첫 구현 즉시 승인 (이상적)

```
User Request
    ↓
Planner → PLAN.md
    ↓
Implementer → Code v1.0
    ↓
Reviewer → REVIEW_REPORT v1.0
    ↓
✅ APPROVED
    ↓
Done
```

**조건**:
- 요구사항 충족도 ≥ 95%
- 코드 품질 ≥ 12/15
- 보안/성능 문제 없음

**결과**:
- 1회 구현, 1회 리뷰로 완료
- 가장 효율적

---

### 시나리오 2: 1회 피드백 루프 (일반적)

```
User Request
    ↓
Planner → PLAN.md
    ↓
Implementer → Code v1.0
    ↓
Reviewer → REVIEW_REPORT v1.0
    ↓
❌ REJECTED
  개선사항:
  - TODO 주석 제거
  - 에러 처리 추가
  - 테스트 커버리지 향상
    ↓
Implementer (재작업) → Code v1.1
  - TODO 제거 완료
  - 에러 처리 추가
  - 테스트 추가 (커버리지 85% → 92%)
    ↓
Reviewer (재검토) → REVIEW_REPORT v1.1
  - 이전 개선사항 반영 확인
  - 새로운 평가
    ↓
✅ APPROVED
    ↓
Done
```

**조건**:
- 초기 구현에 사소한 문제
- 1회 수정으로 해결 가능

**결과**:
- 2회 구현, 2회 리뷰로 완료
- 일반적인 케이스

---

### 시나리오 3: 다중 피드백 루프 (복잡한 경우)

```
User Request
    ↓
Planner → PLAN.md
    ↓
Implementer → Code v1.0
    ↓
Reviewer → REVIEW_REPORT v1.0
    ↓
❌ REJECTED (충족도 75%, 품질 8/15)
  개선사항:
  - 핵심 기능 3개 미구현
  - 아키텍처 재설계 필요
    ↓
Implementer (재작업) → Code v1.1
  - 핵심 기능 추가
  - 일부 아키텍처 개선
    ↓
Reviewer (재검토) → REVIEW_REPORT v1.1
    ↓
⚠️ CONDITIONALLY APPROVED (충족도 90%, 품질 11/15)
  조건:
  - 나머지 아키텍처 개선 필요
  - 테스트 커버리지 향상
    ↓
Implementer (재작업) → Code v1.2
  - 아키텍처 완전 개선
  - 테스트 추가
    ↓
Reviewer (재검토) → REVIEW_REPORT v1.2
    ↓
✅ APPROVED (충족도 98%, 품질 14/15)
    ↓
Done
```

**조건**:
- 초기 구현이 기준 미달
- 여러 번 수정 필요

**결과**:
- 3회 구현, 3회 리뷰로 완료
- 복잡한 케이스

---

### 시나리오 4: 최대 횟수 도달 (예외)

```
User Request
    ↓
Planner → PLAN.md
    ↓
Implementer → Code v1.0
    ↓
Reviewer → REVIEW_REPORT v1.0
    ↓
❌ REJECTED
    ↓
Implementer → Code v1.1
    ↓
Reviewer → REVIEW_REPORT v1.1
    ↓
❌ REJECTED
    ↓
Implementer → Code v1.2
    ↓
Reviewer → REVIEW_REPORT v1.2
    ↓
❌ REJECTED
    ↓
🛑 MAX_ITERATIONS_REACHED (기본: 3회)
    ↓
⚠️ ESCALATE TO USER
  - 문제 요약
  - 시도한 개선사항
  - 사용자 의사결정 요청:
    * 현재 상태로 승인?
    * PLAN.md 수정?
    * 포기?
```

**조건**:
- 근본적인 문제 (요구사항 불명확, 기술적 제약 등)
- Implementer 혼자 해결 불가

**결과**:
- 사용자 개입 필요
- 프로세스 재시작 또는 종료

---

## 📊 피드백 루프 상세 설계

### 데이터 전달 메커니즘

#### Reviewer → Implementer

**REVIEW_REPORT.md 구조**:
```markdown
# Code Review Report v1.1

## 최종 결정
❌ REJECTED

## 개선 필수 사항 (Required Changes)

### 1. TODO 주석 제거
- 파일: `src/services/auth-service.ts:45`
- 내용: `// TODO: Implement password strength validation`
- 조치: 비밀번호 강도 검증 로직 완전 구현
- 우선순위: 🔴 높음

### 2. 에러 처리 추가
- 파일: `src/controllers/auth-controller.ts:78`
- 내용: try-catch 누락
- 조치: 모든 async 함수에 에러 처리 추가
- 우선순위: 🔴 높음

## 개선 권장 사항 (Suggested Changes)

### 1. 테스트 커버리지 향상
- 현재: 85%
- 목표: 90%
- 파일: `test/unit/auth-service.test.ts`
- 조치: Edge case 테스트 추가
- 우선순위: 🟡 중간

## 다음 단계
1. 필수 개선사항 모두 반영
2. Implementer Agent 재호출
3. 재검토 요청
```

#### Implementer의 개선사항 반영

**Implementer Agent 입력**:
```
이전 REVIEW_REPORT.md를 읽고 모든 개선사항을 반영하세요:

**REVIEW_REPORT**: REVIEW_REPORT.md
**현재 코드**: src/
**작업**:
1. REVIEW_REPORT.md 읽기
2. "개선 필수 사항" 모두 반영
3. "개선 권장 사항" 가능한 만큼 반영
4. 각 개선사항별 체크리스트 작성
5. 코드 수정 완료
```

**Implementer 출력 예시**:
```markdown
# 개선사항 반영 체크리스트

## 필수 개선사항
- [x] TODO 주석 제거
  - 파일: src/services/auth-service.ts:45
  - 변경: 비밀번호 강도 검증 로직 완전 구현
  - 테스트: test/unit/auth-service.test.ts:78-92 추가

- [x] 에러 처리 추가
  - 파일: src/controllers/auth-controller.ts:78
  - 변경: try-catch 블록 추가
  - 테스트: test/unit/auth-controller.test.ts:45-60 추가

## 권장 개선사항
- [x] 테스트 커버리지 향상
  - 이전: 85%
  - 현재: 92%
  - 추가 테스트: 7개

## 테스트 결과
- 빌드: ✅ 성공
- 테스트: ✅ 60/60 통과
- 커버리지: ✅ 92%
```

#### Reviewer의 재검토

**Reviewer Agent 입력**:
```
이전 REVIEW_REPORT.md의 개선사항이 반영되었는지 재검토하세요:

**이전 리뷰**: REVIEW_REPORT.md (v1.0)
**현재 코드**: src/ (업데이트됨)

**작업**:
1. 이전 REVIEW_REPORT.md 읽기
2. 각 개선사항 반영 여부 체크
3. 새로운 문제 없는지 확인
4. REVIEW_REPORT.md (v1.1) 작성
5. 승인/거부 결정
```

**Reviewer 출력**:
```markdown
# Code Review Report v1.1

**이전 버전**: v1.0 (2026-01-19)
**재검토 일자**: 2026-01-19

## 이전 개선사항 반영 확인

### 필수 개선사항
- [x] TODO 주석 제거 → ✅ 완전 반영
- [x] 에러 처리 추가 → ✅ 완전 반영

### 권장 개선사항
- [x] 테스트 커버리지 → ✅ 목표 초과 (92%)

## v1.0 대비 개선도
- 요구사항 충족도: 90% → 98%
- 코드 품질: 11/15 → 14/15
- 테스트 커버리지: 85% → 92%

## 최종 결정
✅ **승인**

## 다음 단계
프로덕션 배포 가능
```

---

## 🎛️ 설정 및 제어

### 최대 반복 횟수 설정

```yaml
feedback_loop_config:
  max_iterations: 3        # 기본값
  escalate_on_max: true    # 최대 도달 시 사용자 에스컬레이션
  auto_approve_threshold: 0.95  # 이 이상이면 자동 승인 고려
```

### 종료 조건

**자동 종료 (성공)**:
- ✅ Reviewer가 승인 결정
- ⚠️ Reviewer가 조건부 승인 + 사용자가 수락

**자동 종료 (실패)**:
- 🛑 최대 반복 횟수 도달
- 🛑 Implementer가 개선 불가 보고
- 🛑 Critical 에러 발생

**수동 종료**:
- 사용자가 현재 상태로 강제 승인
- 사용자가 프로세스 중단 요청

### 에스컬레이션 프로세스

최대 횟수 도달 시:

```markdown
# 🛑 피드백 루프 최대 횟수 도달

## 요약
- 반복 횟수: 3회
- 최종 상태: 거부 (요구사항 충족도 82%, 품질 9/15)

## 시도한 개선사항
### v1.0 → v1.1
- TODO 주석 제거
- 에러 처리 추가

### v1.1 → v1.2
- 아키텍처 일부 개선
- 테스트 추가

### v1.2 (현재)
- 여전히 기준 미달
- 근본적 문제: 요구사항 불명확 (인증 방식)

## 사용자 의사결정 필요

### 옵션 1: 현재 상태로 승인 ⚠️
- 장점: 빠른 진행
- 단점: 품질 기준 미달, 기술 부채

### 옵션 2: PLAN.md 수정 후 재시작 ✅ 권장
- 조치: 인증 방식 명확히 정의 (JWT? OAuth? 세션?)
- 예상: 새로운 계획으로 성공 가능성 높음

### 옵션 3: 포기 ❌
- 해당 기능 구현 중단

**어떤 옵션을 선택하시겠습니까?**
```

---

## 🚀 실제 사용 예시

### 기본 워크플로우 (3단계: Planner → Implementer → Reviewer)

#### Step 1: Planner 호출
```bash
# Planner Agent로 PLAN.md 생성
Task: Planner Agent
Input: "JWT 인증 시스템 구현"
Output: PLAN.md
```

#### Step 2: Implementer 호출
```bash
# Implementer Agent로 구현
Task: Implementer Agent
Input: PLAN.md
Output: Code v1.0
```

#### Step 3: Reviewer 호출 (최초)
```bash
# Reviewer Agent로 검토
Task: Reviewer Agent
Input: PLAN.md + Code v1.0
Output: REVIEW_REPORT.md v1.0

결과: ❌ REJECTED
개선사항:
- TODO 주석 제거
- 테스트 커버리지 향상
```

#### Step 4: Implementer 재호출 (피드백 반영)
```bash
# Implementer Agent로 개선
Task: Implementer Agent (재작업)
Input: REVIEW_REPORT.md v1.0
Output: Code v1.1
```

#### Step 5: Reviewer 재호출 (재검토)
```bash
# Reviewer Agent로 재검토
Task: Reviewer Agent (재검토)
Input: REVIEW_REPORT.md v1.0 + Code v1.1
Output: REVIEW_REPORT.md v1.1

결과: ✅ APPROVED
```

### 자동화 스크립트 예시

```bash
#!/bin/bash
# scripts/run-feedback-loop.sh

MAX_ITERATIONS=3
ITERATION=1

echo "🚀 피드백 루프 시작"

# Step 1: 최초 구현 검토
echo "📝 Step 1: 최초 구현 검토"
claude_task reviewer "PLAN.md" "src/" > REVIEW_REPORT.md

# 승인 여부 확인
DECISION=$(grep "최종 결정" REVIEW_REPORT.md | grep "승인")

# 피드백 루프
while [ -z "$DECISION" ] && [ $ITERATION -lt $MAX_ITERATIONS ]; do
  ITERATION=$((ITERATION + 1))
  echo "🔄 Iteration $ITERATION: 개선사항 반영 중..."

  # Implementer 재작업
  claude_task implementer --feedback "REVIEW_REPORT.md" "src/"

  # Reviewer 재검토
  claude_task reviewer --re-review "REVIEW_REPORT.md" "src/" > REVIEW_REPORT.md

  # 승인 여부 재확인
  DECISION=$(grep "최종 결정" REVIEW_REPORT.md | grep "승인")
done

# 결과 확인
if [ -n "$DECISION" ]; then
  echo "✅ 승인됨! ($ITERATION 회 반복)"
else
  echo "🛑 최대 반복 횟수 도달. 사용자 의사결정 필요."
fi
```

---

## 📈 피드백 루프의 효과

### 품질 개선 예시

```
Iteration 0 (초기 구현):
- 요구사항 충족도: 75%
- 코드 품질: 8/15
- 테스트 커버리지: 60%

Iteration 1 (1차 개선):
- 요구사항 충족도: 90%
- 코드 품질: 11/15
- 테스트 커버리지: 80%

Iteration 2 (2차 개선):
- 요구사항 충족도: 98%
- 코드 품질: 14/15
- 테스트 커버리지: 92%

✅ 승인
```

### 점진적 품질 향상

| 지표 | 초기 | 1차 개선 | 2차 개선 | 목표 |
|------|------|----------|----------|------|
| 요구사항 | 75% | 90% | 98% | 95% ✅ |
| 코드 품질 | 8/15 | 11/15 | 14/15 | 12/15 ✅ |
| 테스트 커버리지 | 60% | 80% | 92% | 80% ✅ |

---

## 💡 Best Practices

### 1. 명확한 피드백 제공

**❌ 나쁜 예시**:
```
코드 품질이 좋지 않습니다. 개선이 필요합니다.
```

**✅ 좋은 예시**:
```
### 개선 필수: 에러 처리 누락
- 파일: src/controllers/auth-controller.ts:78
- 문제: async 함수에 try-catch 없음
- 조치: 다음 패턴으로 수정
  ```typescript
  async register(req, res) {
    try {
      // 기존 코드
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
  ```
- 예상 공수: 15분
```

### 2. 우선순위 명확히

```markdown
## 개선사항 우선순위

### 🔴 높음 (필수)
1. TODO 주석 제거
2. 보안 문제 수정

### 🟡 중간 (권장)
1. 테스트 커버리지 향상
2. 주석 추가

### 🟢 낮음 (선택)
1. 성능 최적화
2. 리팩토링
```

### 3. 진행 상황 추적

```markdown
## 개선 이력

### v1.0 → v1.1
- ✅ TODO 제거
- ✅ 에러 처리 추가
- ⏳ 테스트 커버리지 (진행 중: 85% → 90%)

### v1.1 → v1.2
- ✅ 테스트 커버리지 완료 (92%)
- ✅ 주석 추가
```

### 4. 건설적 피드백

**원칙**:
- 문제만 지적하지 말고 해결책 제시
- 긍정적인 부분도 언급
- 학습 기회 제공

**예시**:
```markdown
## 잘된 부분 👍
- 아키텍처 설계가 SOLID 원칙을 잘 따름
- 테스트가 체계적으로 구성됨

## 개선 필요 부분 🔧
- 에러 처리 패턴이 일관되지 않음
- 해결: 공통 에러 핸들러 미들웨어 생성 권장
```

---

## 🎯 성공 기준

### 피드백 루프의 성공

1. **효율성**
   - 평균 반복 횟수 ≤ 2회
   - 최대 횟수 도달 비율 < 10%

2. **품질 향상**
   - 각 반복마다 측정 가능한 개선
   - 최종 승인 시 모든 기준 충족

3. **명확성**
   - Implementer가 피드백을 이해하고 반영 가능
   - 재작업 방향이 명확

4. **건설성**
   - 비판이 아닌 개선 지향
   - 학습 기회 제공

---

## 📚 참고 자료

### 관련 문서
- `.claude/agents/planner.md` - Planner Agent 사양
- `.claude/agents/implementer.md` - Implementer Agent 사양
- `.claude/agents/reviewer.md` - Reviewer Agent 사양
- `claudedocs/subagent-migration-plan.md` - 프로젝트 개요

### 실제 테스트 결과
- `claudedocs/test-results/final-report.md` - 서브에이전트 테스트 결과

---

**버전**: 1.0.0
**작성일**: 2026-01-19
**업데이트**: 피드백 루프 워크플로우 초기 정의
