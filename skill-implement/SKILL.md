---
name: implement
description: PLAN.md 기반 자동 구현 실행 스킬. Phase별 TDD 사이클(RED→GREEN→REFACTOR)을 자동으로 수행하고, 프로젝트 타입을 자동 감지하여 언어별 최적화된 빌드/테스트를 실행합니다. 사용자가 '구현', '실행', '코딩 시작', 'implement', '빌드', '개발 진행', 'Phase 실행', 'TDD', '자동 구현' 등을 언급하면 반드시 이 스킬을 사용하세요. 다언어 지원 (Ruby/Rails, Node.js/TypeScript, C++, Python, Bash/Shell, Ansible).
argument-hint: "[feature-name]"
---

# Feature Implementation Skill

---

## ⚠️ CRITICAL REQUIREMENTS (필수 체크리스트)

**⛔ 스킬 실행 전/후 반드시 확인. 컨텍스트 압축 후에도 이 섹션을 다시 읽을 것.**

### 우선순위 정의
| 표시 | 의미 | 위반 시 |
|-----|------|--------|
| 🔴 **MUST** | 필수 - 반드시 준수 | 스킬 실패로 간주 |
| 🟡 **SHOULD** | 권장 - 강력히 권장 | 경고 후 진행 가능 |
| 🟢 **MAY** | 선택 - 상황에 따라 | 자유롭게 선택 |

---

### 📁 PLAN.md 로드 🔴 MUST
- [ ] 🔴 PLAN.md 파일 존재 확인
- [ ] 🔴 `docs/features/YYYY-MM-DD-feature-name/PLAN.md` 경로
- [ ] 🔴 PLAN.md의 Phase 구조 파싱

### 📊 Phase 실행 규칙 🔴 MUST
- [ ] 🔴 **순차 실행**: Phase 1부터 순서대로 진행
- [ ] 🔴 **품질 게이트 통과 후 다음 Phase**: 현재 Phase 완료 전 다음 Phase 시작 금지
- [ ] 🔴 **TDD 사이클 준수**: 🔴RED → 🟢GREEN → 🔵REFACTOR

### 🧪 테스트 정책 🔴 MUST
- [ ] 🔴 **테스트 스킵 절대 금지**: `--skip-tests` 사용 불가
- [ ] 🔴 **전체 테스트 실행**: 부분 실행 금지
- [ ] 🔴 **타임아웃**: 30분 (1800000ms)
- [ ] 🔴 **100% 통과 필수**: 실패 테스트 있으면 진행 불가
- [ ] 🟡 **재시도**: 실패 시 최대 3회 재시도

### 🔍 품질 검사 🔴 MUST

**언어별 필수 검사:**

| 언어 | 🔴 MUST | 🟡 SHOULD |
|-----|---------|----------|
| **Ruby/Rails** | 테스트 통과, RuboCop | Brakeman, Bundle Audit |
| **Node.js/TS** | 테스트 통과, ESLint, 타입체크 | Prettier, 빌드 |
| **C++** | 빌드, 테스트, Valgrind, ASan | clang-tidy, cppcheck |
| **Bash/Shell** | shellcheck, bats 테스트 | shfmt |
| **Ansible** | ansible-lint, molecule test | - |

- [ ] 🔴 커버리지 ≥ 80%
- [ ] 🔴 메모리 오류 0 (C++)
- [ ] 🟡 정적 분석 경고 0

### 📝 PROGRESS.md 관리 🔴 MUST
- [ ] 🔴 PLAN.md와 같은 디렉토리에 생성
- [ ] 🔴 각 Phase 완료 시 업데이트
- [ ] 🔴 실패 시 현재 상태 기록
- [ ] 🟡 소요 시간 기록

### 💾 커밋 규칙 🔴 MUST
- [ ] 🔴 **품질 게이트 통과 후에만 커밋**
- [ ] 🔴 **Phase별 커밋**: 각 Phase 완료 시 개별 커밋
- [ ] 🔴 **푸시 금지**: git push는 사용자가 수동으로
- [ ] 🟡 커밋 메시지에 Phase 번호, 테스트 결과, 커버리지 포함

### 🚨 중단 조건 🔴 MUST
다음 상황에서 **즉시 중단** 및 사용자 개입 요청:
- [ ] 🔴 테스트 실패 (3회 재시도 후)
- [ ] 🔴 메모리 오류 (Valgrind/ASan)
- [ ] 🔴 빌드 실패 (복구 불가)
- [ ] 🔴 품질 게이트 실패

### 📢 알림 🟡 SHOULD
- [ ] 🟡 Phase 완료 시 Slack 알림
- [ ] 🔴 중단 시 Slack 알림 (error)
- [ ] 🟡 전체 완료 시 Slack 알림 (success)

### ✅ 완료 검증 🔴 MUST
- [ ] 🔴 모든 Phase 완료
- [ ] 🔴 모든 테스트 통과 (100%)
- [ ] 🔴 커버리지 목표 달성
- [ ] 🔴 PROGRESS.md 최종 업데이트

### 🔍 검증 스크립트 🟡 SHOULD
```bash
~/.claude/skills/implement/scripts/validate-implement.sh docs/features/YYYY-MM-DD-feature-name/
```

---

## 목적

PLAN.md를 기반으로 **자동화된 구현**을 수행합니다:
- 프로젝트 타입 자동 감지 (Ruby/Rails, Node.js/TypeScript, C++, Python, Bash/Shell, Ansible)
- Phase별 자동 진행 (TDD 준수)
- 언어별 최적화된 빌드/테스트 실행
- 전체 품질 검사 후 자동 커밋 (푸시는 수동)
- Slack 실시간 알림

## 사용법

```bash
/implement "feature-name"
/implement "2025-01-29-jwt-authentication"
```

## 실행 프로세스

### 0단계: Sequential Thinking 활성화

모든 Phase 실행에 **항상 Sequential Thinking을 사용**합니다. 상황별 에이전트는 필요시 자동 활성화: 테스트 실패 → root-cause-analyst, 메모리 오류 → Valgrind 심층분석, 빌드 오류 → 의존성 체인 확인, 성능 이슈 → performance-engineer

### 1단계: PLAN.md 찾기 및 로드

```bash
# Feature 이름으로 검색
docs/features/*/PLAN.md → 가장 최근 날짜의 매칭 파일 사용

# 또는 전체 경로 제공
/implement "docs/features/2025-01-29-jwt-authentication"
```

### 2단계: PROGRESS.md 초기화

PLAN.md와 같은 디렉토리에 `progress-template.md` 기반으로 PROGRESS.md 생성.

### 3단계: 프로젝트 타입 감지 및 환경 확인

```bash
~/.claude/skills/ai-dev-tasks/scripts/detect-project-type.sh
```

감지 결과에 따라 환경 확인 및 의존성 설치. 언어별 상세: [references/language-patterns.md](references/language-patterns.md) 참조.

### 4단계: Phase별 자동 실행

각 Phase에 대해 다음을 **완전 자동**으로 수행:

#### A. TDD Cycle 실행
- 복잡도 낮음 → TDD 선택적
- 복잡도 중간 이상 → TDD 필수 (🔴RED → 🟢GREEN → 🔵REFACTOR)

#### B. 빌드 및 테스트
언어별 빌드/테스트 명령어: [references/language-patterns.md](references/language-patterns.md) 참조.

#### C. 품질 검사
언어별 품질 검사 스크립트: [references/language-patterns.md](references/language-patterns.md) 참조.

#### D. 커밋 (호스트에서)
품질 검사 통과 후 Phase별 개별 커밋. 커밋 형식: [references/language-patterns.md](references/language-patterns.md) 참조.

#### E. PROGRESS.md 업데이트
Phase 완료 시각, 소요 시간, 테스트 결과, 커버리지, 변경 파일, 커밋 해시 기록.

#### F. Slack 알림
```bash
~/.claude/skills/ai-dev-tasks/scripts/slack-notify.sh "[메시지]" success|error
```

### 5단계: 중대한 문제 처리

**중대한 문제 정의**: 테스트 실패(3회 재시도 후), 메모리 검사 실패, 빌드 실패(복구 불가), 요구사항 불만족

**처리 순서:**
1. 즉시 중단
2. 현재 상태 저장 (PROGRESS.md)
3. Slack 알림 전송 (error)
4. AskUserQuestion으로 사용자에게 질문:
   - 디버깅 후 재시도 (권장)
   - 대안 접근 방식 적용
   - 요구사항 수정 (PLAN.md 업데이트 필요)
   - Phase 스킵 (비권장, 품질 저하 가능)

### 6단계: 전체 완료

모든 Phase 완료 시 Slack으로 최종 결과 알림 (Phase 수, 총 시간, 테스트 결과, 커버리지). 다음 단계 안내: PROGRESS.md 검토 → 코드 리뷰 → git push (수동) → PR 생성.

## 에러 복구

테스트/빌드/메모리 오류 발생 시: 로그 분석 → 자동 수정 시도 → 재빌드/재테스트 → 3회 실패 시 중단 및 보고. 디버그 로깅은 `process-task-list.md`의 "Debug Logging Requirements" 참조. 유닛 테스트는 반드시 프로덕션 코드(`src/`, `lib/`, `app/`)를 임포트하여 검증 (테스트 파일 내 프로덕션 코드 정의 금지).

## 자동화 모드

**자동 실행**: 빌드 → 테스트 → 품질 검사 → 메모리 검사 → 커밋 → Slack 알림 → 다음 Phase 진행
**중단 조건**: 테스트 실패(3회 후), 메모리 오류, 품질 게이트 실패, 빌드 오류(복구 불가)

## 지원 파일

- `progress-template.md`: PROGRESS.md 생성 템플릿
- `references/language-patterns.md`: 언어별 빌드/테스트/품질검사 상세
- `references/examples.md`: 실행 흐름 예제
- `scripts/validate-implement.sh`: 구현 검증 스크립트
- `~/.claude/skills/ai-dev-tasks/scripts/detect-project-type.sh`: 프로젝트 타입 감지
- `~/.claude/skills/ai-dev-tasks/scripts/slack-notify.sh`: Slack 알림

**상세 사용 예제**: [references/examples.md](references/examples.md) 참조

## 주의사항

1. 구현 시작 전 `detect-project-type.sh`로 프로젝트 타입 자동 식별
2. C++은 Docker 컨테이너 필수, Ruby/Node.js는 로컬 실행
3. 테스트 절대 스킵 불가, 30분 타임아웃 엄수
4. 중대한 문제 외에는 자동 진행
5. git push는 사용자가 직접
6. Slack 알림: 모든 중요 이벤트 알림 (한글)
