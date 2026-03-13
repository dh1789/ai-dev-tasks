---
name: plan
description: 기능 계획 수립 - 요구사항 수집, PRD 생성, Phase 분해를 수행합니다. 새 기능 개발, 구현 계획, 개발 로드맵, Phase 분해, 요구사항 분석이 필요할 때 반드시 이 스킬을 사용하세요. 사용자가 '계획', '플래닝', '설계', 'PRD', '구현 전략', '기능 개발', 'feature plan', '개발 계획' 등을 언급하면 자동으로 활성화됩니다. 다언어 지원 (Ruby/Rails, Node.js/TypeScript, C++, Python) - 프로젝트 타입을 자동 감지하고 언어별 최적화된 계획을 수립합니다.
argument-hint: "[기능 설명]"
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# Feature Planning Skill

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

### 📁 파일 위치 🔴 MUST
```
docs/features/YYYY-MM-DD-feature-name/
├── PRD.md
└── PLAN.md
```
- [ ] 🔴 날짜 형식: `YYYY-MM-DD` (예: 2026-01-08)
- [ ] 🔴 기능명: kebab-case (예: `ubuntu-offline-upgrade`)
- [ ] 🔴 ❌ `tasks/` 디렉토리 사용 금지

### 📊 Phase 규격 🔴 MUST
- [ ] 🔴 Phase 개수: **3-7개** (최대 7개 초과 금지)
- [ ] 🔴 각 Phase: 1-4시간 내 완료 가능
- [ ] 🟡 독립적으로 테스트 가능

### 🔄 TDD 구조 🔴 MUST
각 Phase에 반드시 포함:
- [ ] 🔴 **RED Phase**: 테스트 먼저 작성 (실패 확인)
- [ ] 🔴 **GREEN Phase**: 최소 코드로 테스트 통과
- [ ] 🟡 **REFACTOR Phase**: 코드 품질 개선

### 📝 PRD 필수 섹션
- [ ] 🔴 사용자 시나리오 (최소 2개)
- [ ] 🔴 성공 지표 (측정 가능한 KPI)
- [ ] 🟡 기술 스택 명시
- [ ] 🟡 제약사항 및 가정

### 📋 PLAN 필수 섹션
- [ ] 🔴 **헤더 메타데이터**: Status, 생성일, 예상 완료, 프로젝트 타입, 언어/프레임워크, 실행 환경
- [ ] 🔴 **Quality Gate per Phase**: 각 Phase 완료 조건
- [ ] 🔴 **롤백 전략**: Phase별 실패 시 복구 방법
- [ ] 🟡 **진행 상황 추적**: 완료율, 시간 추적 테이블
- [ ] 🟡 **최종 체크리스트**: 구현 완료 전 확인 사항
- [ ] 🟢 **위험 요소**: 예상 위험 및 완화 전략
- [ ] 🟢 **참고 자료**: 관련 문서 링크

### ✅ 검증 🔴 MUST
```bash
# 스킬 완료 후 반드시 실행
~/.claude/skills/plan/scripts/validate-plan.sh docs/features/YYYY-MM-DD-feature-name/
```
- [ ] 🔴 검증 스크립트 실행
- [ ] 🔴 FAIL 항목 0개 확인
- [ ] 🟡 WARN 항목 검토

---

## 목적

기능 개발을 위한 체계적인 계획을 수립합니다:
- 요구사항 수집 및 명확화
- PRD (Product Requirements Document) 생성
- Phase-based 구현 계획 수립
- 테스트 전략 정의

**대상 독자**: 계획은 기능을 구현할 **주니어 개발자**를 위해 작성됩니다. 따라서:
- 요구사항은 명확하고 모호하지 않아야 함
- 기능 목적과 핵심 로직 이해를 위한 충분한 세부사항 제공
- 기존 코드베이스 맥락에 대한 인지 가정

## 사용법

```bash
/plan "기능 설명"
```

**예제:**
```bash
/plan "JWT 기반 사용자 인증 시스템"        # Rails, Node.js, C++ 등 자동 감지
/plan "HTTP/2 서버 구현"                  # C++, Node.js
/plan "블로그 댓글 시스템"                 # Rails
/plan "CLI 명령어 파서"                    # Node.js/TypeScript
```

## 실행 프로세스

### 0단계: 복잡도 분석 및 사고 도구 선택

기능 설명을 분석하여 복잡도를 판단하고 적절한 사고 깊이를 자동 선택합니다:

| 복잡도 | 예시 | 사고 모드 |
|--------|------|-----------|
| 낮음 (0-10점) | UI 컴포넌트, 유틸리티 함수 | 일반 추론 |
| 중간 (11-25점) | API 엔드포인트, 데이터 모델 | Sequential Thinking (~5-8 steps) |
| 높음 (26-50점) | 인증 시스템, 분산 시스템 | Sequential Thinking 확장 (~10-15 steps) |
| 매우 높음 (51+점) | 레거시 현대화, 실시간 시스템 | Sequential Thinking 최대 + Context7 |

복잡도 점수 = 컴포넌트 수×2 + 외부 의존성×3 + 보안(0/5/10) + 성능(0/5/10) + 불명확성(0-10)

### 1단계: 요구사항 수집

**현재 상태 평가** — 기존 코드베이스를 먼저 검토:
- 기존 인프라, 아키텍처 패턴, 코딩 규칙 이해
- 재사용 가능한 컴포넌트와 패턴 파악

**간단한 기능**: 기본 정보만 확인하고 즉시 플래닝으로 진행.

**복잡한 기능**: AskUserQuestion 도구를 사용하여 4단계로 체계적 수집:
1. 기능 요구사항 (핵심 동작, 데이터 형식)
2. 비기능 요구사항 (성능, 보안, 안정성)
3. 유지보수성 요구사항 (커버리지, 로깅)
4. 기술 제약사항 (언어별 — 자동 감지 결과 기반)

**상세 AskUserQuestion 예시**: [references/requirements-collection.md](references/requirements-collection.md) 참조

**프로젝트 타입 자동 감지**: `scripts/detect-project-type.sh` 실행
- Gemfile → Ruby/Rails | package.json → Node.js/TypeScript
- CMakeLists.txt → C++ | requirements.txt/pyproject.toml → Python

### 2단계: PRD 생성

수집된 정보를 바탕으로 PRD를 생성합니다:
- 개요 및 목표
- 기능 요구사항 및 비기능 요구사항
- 사용자 시나리오
- 기술 스택 (프로젝트 타입 자동 감지 결과 포함)
- 테스트 요구사항
- 성공 지표

### 3단계: Architecture 설계

시스템 아키텍처와 주요 컴포넌트를 정의합니다:

```markdown
## 아키텍처 결정사항
| 결정사항 | 근거 | 트레이드오프 |
|---------|------|-------------|
| [결정 1] | [이유] | [장단점] |

## 주요 컴포넌트
### 컴포넌트 1: [이름]
- 책임: [역할]
- 인터페이스: [API]
- 의존성: [다른 컴포넌트]
```

### 4단계: Phase 분해

기능을 **3-7개의 Phase**로 분해합니다. 각 Phase는:
- **1-4시간** 내 완료 가능
- **독립적으로 테스트 가능**
- **점진적 가치 제공**
- **TDD Red-Green-Refactor 사이클 적용**

#### Phase 크기 가이드라인

| 범위 | Phase 수 | 총 시간 | 예시 |
|------|----------|---------|------|
| Small | 2-3개 | 3-6시간 | 다크 모드 토글, 새 폼 컴포넌트 |
| Medium | 4-5개 | 8-15시간 | 사용자 인증, 검색 기능 |
| Large | 6-7개 | 15-25시간 | AI 검색(임베딩), 실시간 협업 |

#### Phase 구조

```markdown
## Phase N: [이름]
**목표**: [달성할 것]
**예상 시간**: N시간

**Tasks:**
1. 🔴 RED: 테스트 작성 (실패 확인)
2. 🟢 GREEN: 최소 코드로 테스트 통과
3. 🔵 REFACTOR: 코드 품질 개선

**테스트 전략:**
- 커버리지 목표: N%
- 테스트 케이스: ✅ Happy Path | 🔶 Boundary | ❌ Exception | 🔀 Edge
```

### 5단계: 테스트 전략 정의

모든 Phase에 대해 포괄적인 테스트 전략을 정의합니다.

**상세 테스트 가이드라인**: [references/testing-guidelines.md](references/testing-guidelines.md) 참조

핵심 요소:
- TDD 워크플로우 (Red → Green → Refactor)
- 테스트 피라미드 (단위 → 통합 → 시나리오 → 인수)
- 커버리지 목표: 비즈니스 로직 ≥90%, 데이터 계층 ≥80%, API ≥70%
- 품질 게이트: 100% 테스트 통과, 80%+ 커버리지, 정적 분석 통과

### 6단계: 파일 저장

```
docs/features/YYYY-MM-DD-feature-name/PLAN.md
```
- 날짜: 오늘 날짜 (YYYY-MM-DD)
- 기능명: kebab-case
- 예: `docs/features/2025-01-29-jwt-authentication/PLAN.md`

**PLAN.md 템플릿**: [plan-template.md](plan-template.md) 참조

## 언어별 실행 환경

| 언어 | 실행 위치 | 테스트 실행 | 품질 검사 |
|------|-----------|-------------|-----------|
| Ruby/Rails | 로컬 | `bundle exec rails test` | `scripts/ruby-quality-check.sh` |
| Node.js/TS | 로컬 | `npm test` / `pnpm test` | `scripts/node-quality-check.sh` |
| C++ | Docker (gcc15.1_22.04) | `docker exec` 내부 | `scripts/cpp-quality-check.sh` |
| Python | 로컬 | `pytest` | 언어별 스크립트 |

**C++ 특이사항**: 빌드/테스트는 Docker 내부, 파일 편집은 호스트, Git은 호스트에서 수행.

## 사용자 승인

PLAN.md 생성 전 반드시 AskUserQuestion 도구로 사용자의 명시적 승인을 받아야 합니다.
승인 옵션: "승인 — PLAN.md 생성" / "수정 필요" / "다시 계획"
승인 후에만 PLAN.md 파일을 생성합니다.

## 다음 단계

PLAN.md 생성 후 사용자에게 안내:
```
✅ 계획 수립 완료!
📄 파일 위치: docs/features/YYYY-MM-DD-feature-name/PLAN.md
다음 단계: /implement "feature-name"
```

**실행 흐름 예제**: [references/examples.md](references/examples.md) 참조

## 주의사항

1. 계획 수립 전 `scripts/detect-project-type.sh`로 프로젝트 타입 식별
2. Phase는 최대 7개 — 과도한 계획 금지
3. 모호한 요구사항은 반드시 질문
4. 실제 구현 가능한 계획만 수립
5. 사용자 피드백에 따라 계획 조정 가능
6. 각 언어에 맞는 도구와 테스트 전략 사용

## 지원 파일

- `plan-template.md`: PLAN.md 생성 템플릿
- `references/requirements-collection.md`: AskUserQuestion 상세 예시
- `references/testing-guidelines.md`: TDD, 테스트 패턴, 품질 게이트
- `references/examples.md`: 실행 흐름 예제
- `scripts/validate-plan.sh`: 계획 검증 스크립트
- `~/.claude/skills/ai-dev-tasks/scripts/detect-project-type.sh`: 프로젝트 타입 감지
- `~/.claude/skills/ai-dev-tasks/scripts/slack-notify.sh`: Slack 알림
