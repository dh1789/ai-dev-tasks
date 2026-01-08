---
name: plan
description: 기능 계획 수립 - 요구사항 수집, PRD 생성, Phase 분해를 수행합니다. 복잡도에 따라 대화형 질문을 통해 상세 요구사항을 수집하거나 즉시 플래닝합니다. 다언어 지원 (Ruby/Rails, Node.js/TypeScript, C++, Python) - 프로젝트 타입을 자동 감지하고 언어별 최적화된 계획을 수립합니다.
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
- 요구사항은 명확하고 모호하지 않음
- 필요시 기술 용어 설명 포함
- 기능 목적과 핵심 로직 이해를 위한 충분한 세부사항 제공
- 기존 코드베이스 맥락에 대한 인지 가정

## 사용법

```bash
/skill plan "기능 설명"
```

**예제:**
```bash
/skill plan "JWT 기반 사용자 인증 시스템"        # Rails, Node.js, C++ 등 자동 감지
/skill plan "HTTP/2 서버 구현"                  # C++, Node.js
/skill plan "블로그 댓글 시스템"                 # Rails
/skill plan "CLI 명령어 파서"                    # Node.js/TypeScript
```

## 실행 프로세스

### 0단계: 사고 도구 자동 선택

복잡도 분석 결과에 따라 적절한 사고 도구를 자동으로 활성화합니다:

**낮은 복잡도 (간단한 기능):**
- **모드**: 일반 모드
- **사고 도구**: 기본 추론
- **특징**: 빠른 분석 및 계획 수립
- **예**: UI 컴포넌트, 유틸리티 함수

**중간 복잡도:**
- **모드**: Sequential Thinking 활성화
- **사고 도구**: 구조화된 다단계 추론 (~5-8 steps)
- **특징**: 체계적 분석, 가설 검증
- **예**: API 엔드포인트, 데이터 모델 설계

**높은 복잡도:**
- **모드**: Sequential Thinking (확장)
- **사고 도구**: 심층 분석 (~10-15 steps)
- **특징**: 아키텍처 분석, 트레이드오프 검토, 다중 대안 평가
- **예**: 인증 시스템, 분산 시스템 컴포넌트, 성능 최적화

**매우 높은 복잡도:**
- **모드**: Sequential Thinking (최대 깊이)
- **사고 도구**: 최대 깊이 분석 (~20-30 steps)
- **통합**: Context7 (공식 문서), 다중 관점 분석
- **특징**:
  - 시스템 전체 영향 분석
  - 보안/성능/확장성 종합 검토
  - 다중 에이전트 조율 (필요시)
  - 단계별 검증 및 수정
- **예**:
  - 레거시 시스템 현대화
  - 마이크로서비스 아키텍처 설계
  - 보안 크리티컬 시스템
  - 실시간 고성능 시스템

**사고 도구 활성화 기준:**

```
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

### 1단계: 복잡도 분석

기능 설명을 분석하여 복잡도를 판단하고, 위의 기준에 따라 사고 도구를 자동 선택합니다:

**간단한 기능 (자동 플래닝):**
- 단일 컴포넌트/클래스
- 명확한 요구사항
- 최소 의존성
- 예: UI 컴포넌트, 유틸리티 함수, 간단한 알고리즘
- **→ 일반 모드 사용**

**복잡한 기능 (대화형 수집):**
- 다중 컴포넌트
- 불명확한 요구사항
- 외부 의존성
- 보안/성능 고려사항
- 예: 인증 시스템, 네트워크 프로토콜, 데이터베이스 통합
- **→ Sequential Thinking 활성화**

### 2단계: 요구사항 수집

**현재 상태 평가** - 기존 코드베이스 검토:
- 기존 인프라, 아키텍처 패턴, 코딩 규칙 이해
- 요구사항과 관련된 기존 컴포넌트 또는 기능 식별
- 활용하거나 수정이 필요한 기존 파일, 컴포넌트, 유틸리티 찾기
- 재사용 가능한 패턴과 확립된 코딩 관행 파악

#### 복잡한 기능일 경우

**AskUserQuestion 도구**를 사용하여 체계적으로 요구사항을 수집합니다:

**1단계: 기능 요구사항 수집**
```
AskUserQuestion({
  questions: [
    {
      question: "이 기능의 핵심 동작은 무엇인가요?",
      header: "핵심 기능",
      multiSelect: false,
      options: [
        { label: "데이터 처리/변환", description: "데이터를 읽고, 변환하고, 저장하는 로직" },
        { label: "사용자 인터페이스", description: "사용자와의 상호작용 UI 컴포넌트" },
        { label: "API/서비스 통합", description: "외부 시스템과의 연동" },
        { label: "비즈니스 로직", description: "핵심 업무 규칙 처리" }
      ]
    },
    {
      question: "주요 입력/출력 데이터 형식은 무엇인가요?",
      header: "데이터 형식",
      multiSelect: true,
      options: [
        { label: "JSON", description: "JSON 형식 데이터" },
        { label: "XML", description: "XML 형식 데이터" },
        { label: "Binary", description: "바이너리 데이터" },
        { label: "Plain Text", description: "일반 텍스트" }
      ]
    }
  ]
})
```

**2단계: 비기능 요구사항 수집**
```
AskUserQuestion({
  questions: [
    {
      question: "성능 요구사항은 어느 정도인가요?",
      header: "성능",
      multiSelect: false,
      options: [
        { label: "낮음", description: "일반적인 응답 속도 (<1초)" },
        { label: "중간", description: "빠른 응답 필요 (<100ms)" },
        { label: "높음", description: "실시간 처리 필요 (<10ms)" },
        { label: "매우 높음", description: "초고속 처리 (<1ms)" }
      ]
    },
    {
      question: "보안 요구사항은 무엇인가요?",
      header: "보안",
      multiSelect: true,
      options: [
        { label: "인증/인가", description: "사용자 인증 및 권한 관리" },
        { label: "데이터 암호화", description: "전송/저장 데이터 암호화" },
        { label: "입력 검증", description: "사용자 입력 유효성 검사" },
        { label: "보안 감사", description: "보안 로깅 및 모니터링" }
      ]
    },
    {
      question: "안정성 목표는 어느 정도인가요?",
      header: "안정성",
      multiSelect: false,
      options: [
        { label: "기본", description: "일반적인 오류 처리" },
        { label: "높음 (99.9%)", description: "높은 가용성 목표" },
        { label: "매우 높음 (99.99%)", description: "미션 크리티컬" },
        { label: "최고 (99.999%)", description: "무중단 서비스" }
      ]
    }
  ]
})
```

**3단계: 유지보수성 요구사항**
```
AskUserQuestion({
  questions: [
    {
      question: "테스트 커버리지 목표는 얼마인가요?",
      header: "테스트",
      multiSelect: false,
      options: [
        { label: "60% 이상", description: "기본 커버리지" },
        { label: "80% 이상 (권장)", description: "권장 커버리지" },
        { label: "90% 이상", description: "높은 커버리지" },
        { label: "95% 이상", description: "매우 높은 커버리지" }
      ]
    },
    {
      question: "로깅 및 모니터링 수준은 어떻게 할까요?",
      header: "로깅",
      multiSelect: true,
      options: [
        { label: "기본 로깅", description: "에러 및 경고 로그" },
        { label: "상세 로깅", description: "디버그 수준 로그 포함" },
        { label: "성능 모니터링", description: "실행 시간, 리소스 사용량" },
        { label: "보안 감사", description: "접근 로그, 변경 이력" }
      ]
    }
  ]
})
```

**4단계: 기술 제약사항 수집 (언어별)**

**프로젝트 타입 자동 감지:**
- `scripts/detect-project-type.sh`를 사용하여 프로젝트 언어/프레임워크 자동 식별
- Gemfile → Ruby/Rails
- package.json → Node.js/TypeScript
- CMakeLists.txt → C++
- requirements.txt → Python

**언어별 AskUserQuestion 예시:**

*Ruby/Rails 프로젝트:*
```
AskUserQuestion({
  questions: [
    {
      question: "Ruby와 Rails 버전은 무엇인가요?",
      header: "Ruby/Rails",
      multiSelect: false,
      options: [
        { label: "Ruby 3.3.x + Rails 8.0.x (권장)", description: "최신 안정 버전" },
        { label: "Ruby 3.2.x + Rails 7.x", description: "이전 안정 버전" },
        { label: "기타", description: "직접 입력" }
      ]
    },
    {
      question: "데이터베이스는 무엇을 사용하나요?",
      header: "데이터베이스",
      multiSelect: false,
      options: [
        { label: "SQLite", description: "개발 및 테스트용" },
        { label: "PostgreSQL", description: "프로덕션 권장" },
        { label: "MySQL", description: "프로덕션 대안" }
      ]
    },
    {
      question: "테스트 프레임워크는 무엇인가요?",
      header: "테스트",
      multiSelect: false,
      options: [
        { label: "Minitest", description: "Rails 기본 테스트 프레임워크" },
        { label: "RSpec", description: "BDD 스타일 테스트" }
      ]
    }
  ]
})
```

*Node.js/TypeScript 프로젝트:*
```
AskUserQuestion({
  questions: [
    {
      question: "Node.js 버전과 TypeScript 사용 여부는?",
      header: "Node.js",
      multiSelect: false,
      options: [
        { label: "Node.js 20+ with TypeScript (권장)", description: "최신 버전 + 타입 안전성" },
        { label: "Node.js 20+ JavaScript only", description: "최신 버전, TS 미사용" },
        { label: "Node.js 18+ with TypeScript", description: "LTS 버전 + TypeScript" },
        { label: "Node.js 18+ JavaScript only", description: "LTS 버전, TS 미사용" }
      ]
    },
    {
      question: "프레임워크는 무엇을 사용하나요?",
      header: "프레임워크",
      multiSelect: false,
      options: [
        { label: "Express", description: "간단한 웹 서버" },
        { label: "Next.js", description: "React 풀스택 프레임워크" },
        { label: "NestJS", description: "엔터프라이즈급 백엔드" },
        { label: "없음/기타", description: "직접 입력" }
      ]
    },
    {
      question: "테스트 프레임워크는 무엇인가요?",
      header: "테스트",
      multiSelect: false,
      options: [
        { label: "Jest", description: "가장 인기 있는 테스트 프레임워크" },
        { label: "Vitest (권장)", description: "빠른 Vite 기반 테스트" },
        { label: "Mocha + Chai", description: "유연한 테스트 환경" }
      ]
    }
  ]
})
```

*C++ 프로젝트:*
```
AskUserQuestion({
  questions: [
    {
      question: "C++ 표준 버전과 컴파일러는 무엇인가요?",
      header: "C++ 환경",
      multiSelect: false,
      options: [
        { label: "C++23 + GCC 15.1 (권장)", description: "최신 표준 + 최신 컴파일러" },
        { label: "C++20 + GCC 13+", description: "안정적인 최신 표준" },
        { label: "C++17 + GCC 11+", description: "널리 사용되는 표준" },
        { label: "기타", description: "직접 입력" }
      ]
    },
    {
      question: "빌드 시스템은 무엇을 사용하나요?",
      header: "빌드",
      multiSelect: false,
      options: [
        { label: "CMake + Ninja (권장)", description: "빠른 빌드" },
        { label: "CMake + Make", description: "전통적인 방식" },
        { label: "Meson", description: "현대적인 빌드 시스템" }
      ]
    },
    {
      question: "Docker 실행 환경이 필수인가요?",
      header: "환경",
      multiSelect: false,
      options: [
        { label: "예 (권장)", description: "일관된 빌드 환경 보장" },
        { label: "아니오", description: "로컬 환경 사용" }
      ]
    }
  ]
})
```

*Python 프로젝트:*
```
AskUserQuestion({
  questions: [
    {
      question: "Python 버전과 의존성 관리 도구는?",
      header: "Python",
      multiSelect: false,
      options: [
        { label: "Python 3.12+ with Poetry (권장)", description: "최신 버전 + 현대적 의존성 관리" },
        { label: "Python 3.11+ with Poetry", description: "안정 버전 + Poetry" },
        { label: "Python 3.10+ with pip", description: "전통적인 방식" },
        { label: "기타", description: "직접 입력" }
      ]
    },
    {
      question: "프레임워크는 무엇을 사용하나요?",
      header: "프레임워크",
      multiSelect: false,
      options: [
        { label: "FastAPI (권장)", description: "현대적인 고성능 API" },
        { label: "Django", description: "풀스택 웹 프레임워크" },
        { label: "Flask", description: "경량 웹 프레임워크" },
        { label: "없음", description: "프레임워크 미사용" }
      ]
    }
  ]
})
```

#### 간단한 기능일 경우

기본 정보만 확인하고 즉시 플래닝으로 진행합니다.

### 3단계: PRD 생성

**PRD 구조 및 작성 가이드라인은 `create-prd.md` 문서를 참조하세요.**

수집된 정보를 바탕으로 다음 항목이 포함된 PRD를 생성합니다:
- 개요 및 목표
- 기능 요구사항 및 비기능 요구사항
- 사용자 시나리오
- 기술 스택 (프로젝트 타입 자동 감지 결과 포함)
- 테스트 요구사항 (`testing-standards.md` 참조)
- 성공 지표

상세한 PRD 템플릿 및 섹션 구조는 `create-prd.md`의 "PRD Structure" 섹션 참조.

### 4단계: Architecture 설계

시스템 아키텍처와 주요 컴포넌트를 정의합니다:

```markdown
## 아키텍처 결정사항

| 결정사항 | 근거 | 트레이드오프 |
|---------|------|-------------|
| [결정 1] | [이유] | [장단점] |
| [결정 2] | [이유] | [장단점] |

## 주요 컴포넌트

### 컴포넌트 1: [이름]
- 책임: [역할]
- 인터페이스: [API]
- 의존성: [다른 컴포넌트]

## 데이터 모델
[필요시 클래스 다이어그램 또는 구조 설명]
```

### 5단계: Phase 분해

기능을 **3-7개의 Phase**로 분해합니다. 각 Phase는:
- **1-4시간** 내 완료 가능
- **독립적으로 테스트 가능**
- **점진적 가치 제공**
- **TDD Red-Green-Refactor 사이클 적용**

#### Phase 크기 가이드라인

**작은 범위 (Small Scope)** - 2-3개 Phase, 총 3-6시간:
- 단일 컴포넌트 또는 간단한 기능
- 최소한의 의존성
- 명확한 요구사항
- 예: 다크 모드 토글 추가, 새 폼 컴포넌트 생성

**중간 범위 (Medium Scope)** - 4-5개 Phase, 총 8-15시간:
- 여러 컴포넌트 또는 중간 복잡도 기능
- 일부 통합 복잡성
- 데이터베이스 변경 또는 API 작업
- 예: 사용자 인증 시스템, 검색 기능

**큰 범위 (Large Scope)** - 6-7개 Phase, 총 15-25시간:
- 여러 영역에 걸친 복잡한 기능
- 상당한 아키텍처 영향
- 다중 통합
- 예: AI 기반 검색(임베딩 포함), 실시간 협업 기능

#### Phase 구조 예시:

```markdown
## Phase 1: [Foundation - 기반 구조]
**목표**: 핵심 데이터 구조 및 인터페이스 정의
**예상 시간**: 2시간
**복잡도**: 낮음 → TDD 선택적

**Tasks:**
1. **🔴 RED**: 핵심 클래스 인터페이스 테스트 작성
2. **🟢 GREEN**: 클래스 구현
3. **🔵 REFACTOR**: 인터페이스 정리

**테스트 전략:**
- 단위 테스트: 각 클래스 메서드
- 커버리지 목표: 80%
- 테스트 케이스:
  - ✅ Happy Path: 정상 동작
  - 🔶 Boundary: 경계값 (empty, max, min)
  - ❌ Exception: 오류 처리

## Phase 2: [Core Logic - 핵심 로직]
**목표**: 비즈니스 로직 구현
**예상 시간**: 3시간
**복잡도**: 높음 → TDD 필수

**Tasks:**
1. **🔴 RED**: 비즈니스 로직 테스트 작성 (모든 경로)
2. **🟢 GREEN**: 로직 구현 (최소 코드)
3. **🔵 REFACTOR**: 중복 제거, 가독성 개선

**테스트 전략:**
- 단위 테스트: 로직 함수들
- 통합 테스트: 컴포넌트 간 상호작용
- 커버리지 목표: 90%
- 테스트 케이스:
  - ✅ Happy Path: 정상 흐름
  - 🔶 Boundary: 경계 조건
  - ❌ Exception: 예외 상황
  - 🔀 Edge Cases: 특수 케이스

## Phase 3: [Integration - 통합]
**목표**: 외부 시스템/컴포넌트 통합
**예상 시간**: 2.5시간
**복잡도**: 중간 → TDD 적용

**Tasks:**
1. **🔴 RED**: 통합 테스트 작성
2. **🟢 GREEN**: 통합 코드 구현
3. **🔵 REFACTOR**: 에러 핸들링 개선

**테스트 전략:**
- 통합 테스트: 실제 통합 검증
- 시나리오 테스트: 실제 사용 흐름
- Mock/Stub: 외부 의존성

## Phase 4: [Acceptance - 인수 테스트]
**목표**: 실제 사용 시나리오 검증
**예상 시간**: 1.5시간

**Tasks:**
1. 인수 테스트 시나리오 작성
2. End-to-End 테스트 구현
3. 성능 벤치마크 (Google Benchmark)

**테스트 전략:**
- 인수 테스트: 사용자 관점 검증
- 성능 테스트: 응답 시간, 처리량
- 부하 테스트: 동시 요청 처리
```

### 5-A단계: 테스트 명세 가이드라인

**TDD 철학 및 원칙은 `tdd.md`와 `testing-standards.md`를 참조하세요.**

#### TDD (Test-First Development) 워크플로우

**각 기능 컴포넌트에 대해**:

1. **테스트 케이스 명세** (코드 작성 전)
   - 어떤 입력을 테스트할 것인가?
   - 예상 출력은 무엇인가?
   - 처리해야 할 경계 케이스는?
   - 테스트해야 할 오류 조건은?

2. **테스트 작성** (Red Phase)
   - 실패할 테스트 작성
   - 올바른 이유로 실패하는지 확인
   - 테스트 실행하여 실패 확인
   - TDD 준수 추적을 위해 실패하는 테스트 커밋

3. **코드 구현** (Green Phase)
   - 테스트를 통과시키는 최소 코드 작성
   - 자주 테스트 실행 (2-5분마다)
   - 모든 테스트가 통과하면 중지
   - 테스트 이상의 추가 기능 없음

4. **리팩토링** (Blue Phase)
   - 테스트를 통과 상태로 유지하면서 코드 품질 개선
   - 중복 로직 추출
   - 네이밍 및 구조 개선
   - 각 리팩토링 단계 후 테스트 실행
   - 리팩토링 완료 시 커밋

#### 유닛 테스트 프로덕션 코드 요구사항

**유닛 테스트는 반드시 실제 프로덕션 코드를 테스트해야 합니다.**

상세한 요구사항 및 가이드라인은 `testing-standards.md`의 "유닛 테스트 프로덕션 코드 요구사항" 섹션을 참조하세요.

핵심 원칙:
- 프로덕션 디렉토리(`src/`, `lib/`, `app/`)에서 코드 임포트
- 테스트 파일 내 프로덕션 코드 정의 금지
- 모든 테스트는 실제 사용되는 코드만 검증
- 테스트 설명 필수 (목적, 시나리오, 기대 결과)

#### 테스트 유형

**단위 테스트 (Unit Tests)**:
- **대상**: 개별 함수, 메서드, 클래스
- **의존성**: 없음 또는 mocked/stubbed
- **속도**: 빠름 (<100ms per test)
- **격리**: 외부 시스템으로부터 완전 격리
- **커버리지**: 비즈니스 로직의 ≥80%

**통합 테스트 (Integration Tests)**:
- **대상**: 컴포넌트/모듈 간 상호작용
- **의존성**: 실제 의존성 또는 Mock 사용 가능
- **속도**: 중간 (<1s per test)
- **격리**: 컴포넌트 경계 테스트
- **커버리지**: 중요한 통합 지점

**엔드투엔드 테스트 (E2E Tests)**:
- **대상**: 완전한 사용자 워크플로우
- **의존성**: 실제 또는 실제에 가까운 환경
- **속도**: 느림 (초에서 분 단위)
- **격리**: 전체 시스템 통합
- **커버리지**: 중요한 사용자 여정

#### 테스트 커버리지 계산

**커버리지 임계값** (프로젝트에 맞게 조정):
- **비즈니스 로직**: ≥90% (중요 코드 경로)
- **데이터 접근 계층**: ≥80% (repositories, DAOs)
- **API/컨트롤러 계층**: ≥70% (endpoints)
- **UI/프레젠테이션**: 커버리지보다 통합 테스트 선호

**생태계별 커버리지 명령어**:
```bash
# JavaScript/TypeScript
jest --coverage
nyc report --reporter=html

# Python
pytest --cov=src --cov-report=html
coverage report

# Java
mvn jacoco:report
gradle jacocoTestReport

# Go
go test -cover ./...
go tool cover -html=coverage.out

# .NET
dotnet test /p:CollectCoverage=true /p:CoverageReporter=html
reportgenerator -reports:coverage.xml -targetdir:coverage

# Ruby
bundle exec rspec --coverage
open coverage/index.html

# PHP
phpunit --coverage-html coverage
```

#### 일반적인 테스트 패턴

**테스트 설명 작성 요구사항**:
모든 테스트는 **간략한 설명**을 포함해야 합니다:
- **목적**: 무엇을 테스트하는지
- **시나리오**: 어떤 상황에서
- **기대 결과**: 무엇이 발생해야 하는지

**언어별 테스트 설명 예시**:

*Python (pytest):*
```python
def test_calculate_total_with_valid_items():
    """
    유효한 아이템들로 총액을 계산할 때
    모든 아이템의 가격 합계를 정확히 반환해야 함
    """
    # Arrange
    items = [Item(price=100), Item(price=200)]
    calculator = PriceCalculator()

    # Act
    total = calculator.calculate_total(items)

    # Assert
    assert total == 300
```

*JavaScript/TypeScript (Jest):*
```typescript
describe('PriceCalculator', () => {
  test('유효한 아이템들로 총액을 계산할 때 모든 가격의 합계를 반환한다', () => {
    // Arrange: 테스트 데이터 설정
    const items = [{ price: 100 }, { price: 200 }];
    const calculator = new PriceCalculator();

    // Act: 동작 실행
    const total = calculator.calculateTotal(items);

    // Assert: 결과 검증
    expect(total).toBe(300);
  });
});
```

*C++ (Google Test):*
```cpp
// 유효한 아이템들로 총액 계산 시 모든 가격의 합계를 반환해야 함
TEST(PriceCalculatorTest, CalculateTotalWithValidItems) {
    // Arrange: 테스트 데이터 준비
    std::vector<Item> items = {Item(100), Item(200)};
    PriceCalculator calculator;

    // Act: 동작 실행
    int total = calculator.calculateTotal(items);

    // Assert: 결과 검증
    EXPECT_EQ(total, 300);
}
```

*Ruby (Minitest):*
```ruby
class PriceCalculatorTest < Minitest::Test
  # 유효한 아이템들로 총액을 계산할 때 모든 가격의 합계를 반환해야 함
  def test_calculate_total_with_valid_items
    # Arrange: 테스트 데이터 설정
    items = [Item.new(price: 100), Item.new(price: 200)]
    calculator = PriceCalculator.new

    # Act: 동작 실행
    total = calculator.calculate_total(items)

    # Assert: 결과 검증
    assert_equal 300, total
  end
end
```

**Arrange-Act-Assert (AAA) 패턴**:
```
test 'description of behavior':
  // Arrange: 테스트 데이터 및 의존성 설정
  input = createTestData()

  // Act: 테스트 중인 동작 실행
  result = systemUnderTest.method(input)

  // Assert: 예상 결과 확인
  assert result == expectedOutput
```

**Given-When-Then (BDD 스타일)**:
```
test 'feature should behave in specific way':
  // Given: 초기 컨텍스트/상태
  given userIsLoggedIn()

  // When: 액션 발생
  when userClicksButton()

  // Then: 관찰 가능한 결과
  then shouldSeeConfirmation()
```

**의존성 Mocking/Stubbing**:
```
test 'component should call dependency':
  // mock/stub 생성
  mockService = createMock(ExternalService)
  component = new Component(mockService)

  // mock 동작 구성
  when(mockService.method()).thenReturn(expectedData)

  // 실행 및 검증
  component.execute()
  verify(mockService.method()).calledOnce()
```

#### 플랜에 테스트 문서화

**각 phase에서 명시**:
1. **테스트 파일 위치**: 테스트가 작성될 정확한 경로
2. **테스트 시나리오**: 특정 테스트 케이스 목록 (각 테스트에 대한 간략한 설명 포함)
3. **예상 실패**: 초기에 테스트가 표시해야 할 오류는?
4. **커버리지 목표**: 이 phase의 퍼센트
5. **Mock할 의존성**: Mock/stub이 필요한 것은?
6. **테스트 데이터**: 필요한 fixture/factory는?

**테스트 시나리오 문서화 예시**:
```markdown
### Phase 2: Core Logic - 테스트 시나리오

**파일**: `test/unit/payment/processor_test.cpp`

**테스트 케이스**:
1. `test_process_payment_with_valid_card`
   - 설명: 유효한 카드로 결제 처리 시 성공 응답 반환
   - 입력: 유효한 카드 정보 (번호, 만료일, CVV)
   - 기대: `PaymentResult.success == true`

2. `test_process_payment_with_expired_card`
   - 설명: 만료된 카드로 결제 시도 시 실패 응답 반환
   - 입력: 만료일이 지난 카드 정보
   - 기대: `PaymentResult.success == false`, 에러 메시지 포함

3. `test_process_payment_with_insufficient_funds`
   - 설명: 잔액 부족 시 거래 거부
   - 입력: 잔액보다 큰 금액
   - 기대: `PaymentResult.errorCode == INSUFFICIENT_FUNDS`

4. `test_process_payment_with_invalid_cvv`
   - 설명: 잘못된 CVV로 보안 검증 실패
   - 입력: CVV 불일치하는 카드 정보
   - 기대: `PaymentResult.errorCode == INVALID_CVV`
```

### 6단계: 테스트 전략 정의

모든 Phase에 대해 **포괄적인 테스트 전략**을 정의합니다:

```markdown
## 전체 테스트 전략

### 테스트 피라미드

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

### 테스트 유형별 상세

**1. 단위 테스트 (Unit Tests)**

*프레임워크 (언어별 자동 선택):*
- Ruby/Rails: Minitest 또는 RSpec
- Node.js/TypeScript: Jest 또는 Vitest
- C++: Google Test
- Python: pytest 또는 unittest

*공통 요구사항:*
- 커버리지 목표: 80-90%
- 각 함수/메서드별:
  - ✅ Happy Path (정상 경로)
  - 🔶 Boundary Cases (경계값: 0, max, min, empty, null)
  - ❌ Exception Cases (예외 처리)
  - 🔀 Edge Cases (특수 상황)

**2. 통합 테스트 (Integration Tests)**
- 컴포넌트 간 상호작용 검증
- 실제 의존성 또는 Mock 사용
- API 계약 검증

**3. 시나리오 테스트 (Scenario Tests)**
- 복잡한 사용자 흐름 검증
- 여러 컴포넌트가 함께 동작
- 실제 사용 패턴 시뮬레이션

**4. 인수 테스트 (Acceptance Tests)**
- 비즈니스 요구사항 충족 검증
- End-to-End 흐름
- 성능 및 안정성 검증

### 품질 게이트

**각 Phase 완료 기준:**
- ✅ 모든 테스트 통과 (100%)
- ✅ 커버리지 목표 달성 (80%+)
- ✅ 메모리 검사 통과 (Valgrind/ASan)
- ✅ 정적 분석 통과 (clang-tidy, cppcheck)
- ✅ 코드 포매팅 준수 (clang-format)

### Quality Assurance 도구 (언어별)

**Ruby/Rails:**
- `scripts/ruby-quality-check.sh` - 전체 품질 검사
  - Bundle install, 테스트, 커버리지
  - RuboCop, Brakeman (보안), Bundle Audit

**Node.js/TypeScript:**
- `scripts/node-quality-check.sh` - 전체 품질 검사
  - 의존성 설치, TypeScript 타입 체크
  - ESLint, Prettier, 테스트, 커버리지

**C++:**
- `scripts/cpp-quality-check.sh` - 전체 품질 검사 (Docker 내부)
- `scripts/cpp-memory-check.sh all` - 메모리 안전성 검사 (Docker 내부)
  - clang-tidy, cppcheck, Valgrind, ASan, TSan, UBSan
```

### 7단계: 파일 저장

생성된 계획을 다음 위치에 저장합니다:

```
docs/features/YYYY-MM-DD-feature-name/PLAN.md
```

**파일명 규칙:**
- 날짜: 오늘 날짜 (YYYY-MM-DD)
- 기능명: kebab-case (소문자, 하이픈 구분)
- 예: `docs/features/2025-01-29-jwt-authentication/PLAN.md`

## PLAN.md 템플릿 구조

skill-plan/plan-template.md 참조

## 언어별 실행 환경

**프로젝트 타입 자동 감지:**
- `scripts/detect-project-type.sh`를 실행하여 프로젝트 언어/프레임워크 자동 식별
- 감지 결과에 따라 적절한 실행 환경 및 도구 선택

**Ruby/Rails 프로젝트:**
- **실행 위치**: 로컬 (호스트)
- **필수 도구**: Ruby, Bundler
- **테스트 실행**: `bundle exec rails test` 또는 `bundle exec rake test`
- **품질 검사**: `scripts/ruby-quality-check.sh`

**Node.js/TypeScript 프로젝트:**
- **실행 위치**: 로컬 (호스트)
- **필수 도구**: Node.js, npm/yarn/pnpm
- **테스트 실행**: `npm test` 또는 `pnpm test`
- **품질 검사**: `scripts/node-quality-check.sh`

**C++ 프로젝트:**
- **실행 위치**: Docker 컨테이너 (필수)
- **컨테이너**: gcc15.1_22.04 (Ubuntu 22.04 + GCC 15.1.0)
- **빌드/테스트**: 모두 gcc15.1_22.04 인스턴스 내부에서 컴파일 및 디버깅 (`docker exec gcc15.1_22.04 bash -c "..."`)
- **파일 편집**: 호스트에서 가능 (볼륨 마운트)
- **Git 작업**: 호스트에서 수행
- **품질 검사**: `scripts/cpp-quality-check.sh` (gcc15.1_22.04 인스턴스 내부)

**Python 프로젝트:**
- **실행 위치**: 로컬 (호스트)
- **필수 도구**: Python, pip/Poetry
- **테스트 실행**: `pytest` 또는 `python -m unittest`
- **품질 검사**: 언어별 스크립트 (추후 추가)

## 사용자 승인

**CRITICAL**: PLAN.md 생성 전 반드시 **AskUserQuestion 도구**를 사용하여 사용자의 명시적 승인을 받아야 합니다.

**승인 질문 예시:**
```
AskUserQuestion({
  questions: [
    {
      question: "이 계획안이 프로젝트에 적합한가요?",
      header: "계획 승인",
      multiSelect: false,
      options: [
        {
          label: "승인 - PLAN.md 생성 (권장)",
          description: `Phase: ${phaseCount}개, 예상 시간: ${estimatedHours}시간
주요 컴포넌트: ${mainComponents.join(', ')}
기술 스택: ${techStack.join(', ')}`
        },
        {
          label: "수정 필요",
          description: "Phase 구성이나 접근 방식 조정 필요"
        },
        {
          label: "다시 계획",
          description: "요구사항부터 다시 수집"
        }
      ]
    }
  ]
})
```

**승인 후 처리:**
- **승인**: PLAN.md 파일 생성 및 Slack 알림
- **수정 필요**: 사용자 피드백을 받아 계획 수정
- **다시 계획**: 요구사항 수집부터 재시작

**중요**: 사용자가 "승인"을 선택한 후에만 PLAN.md 파일을 생성합니다.

## 다음 단계

PLAN.md 생성 후 사용자에게 안내:

```
✅ 계획 수립 완료!

📄 파일 위치: docs/features/YYYY-MM-DD-feature-name/PLAN.md

다음 단계:
1. PLAN.md 검토
2. 필요시 수정
3. 구현 시작: /skill implement "feature-name"
```

## 예제 실행 흐름

### 예제 1: 간단한 기능

```
사용자: /skill plan "로깅 유틸리티 클래스"

AI: 기능 분석 중...
    복잡도: 낮음 - 자동 플래닝 진행

    계획:
    - Phase 1: Logger 클래스 구현
    - Phase 2: 파일 출력 기능
    - Phase 3: 로그 레벨 필터링

    예상 시간: 3시간

    PLAN.md를 생성하시겠습니까? (y/n)

사용자: y

AI: ✅ docs/features/2025-01-29-logging-utility/PLAN.md 생성 완료
```

### 예제 2: 복잡한 기능

```
사용자: /skill plan "OAuth2 인증 시스템"

AI: 기능 분석 중...
    복잡도: 높음 - 상세 요구사항 수집 필요

    OAuth2 인증 시스템에 대해 질문드리겠습니다.

Q1. 지원할 OAuth2 Grant Type은 무엇인가요?
  a) Authorization Code
  b) Implicit
  c) Resource Owner Password
  d) Client Credentials
  e) 여러 개 (직접 입력)

답변: ___

[10-15개 질문 진행]

AI: 모든 정보를 수집했습니다.

    계획:
    - Phase 1: OAuth2 토큰 생성/검증
    - Phase 2: Authorization Code Flow
    - Phase 3: Token Refresh 메커니즘
    - Phase 4: 보안 검증 (취약점 테스트)
    - Phase 5: 성능 최적화
    - Phase 6: 인수 테스트

    예상 시간: 18시간

    PLAN.md를 생성하시겠습니까? (y/n)

사용자: y

AI: ✅ docs/features/2025-01-29-oauth2-authentication/PLAN.md 생성 완료
```

## 주의사항

1. **프로젝트 타입 자동 감지**: 계획 수립 전 `scripts/detect-project-type.sh`로 프로젝트 타입 식별
2. **과도한 계획 금지**: Phase는 최대 7개
3. **명확성 우선**: 모호한 요구사항은 반드시 질문
4. **실용성**: 실제 구현 가능한 계획만 수립
5. **유연성**: 사용자 피드백에 따라 계획 조정 가능
6. **언어별 최적화**: 각 언어에 맞는 도구와 테스트 전략 사용
7. **환경 인식**: C++는 Docker 필수, 나머지 언어는 로컬 실행

## 디버그 로깅 표준

**디버그 로깅 요구사항은 `process-task-list.md`의 "Debug Logging Requirements" 섹션을 참조하세요.**

주요 내용:
- 로깅 레벨 (DEBUG, INFO, WARN, ERROR)
- 필수 로깅 지점 (함수 경계, 상태 전환, 외부 시스템 연동 등)
- 보안 요구사항 (민감 정보 로깅 금지)
- 디버깅 프로토콜

## Slack 알림 프로토콜

**Slack 알림 요구사항은 `process-task-list.md`의 "Slack Notification Requirements" 섹션을 참조하세요.**

주요 내용:
- 알림을 보내야 하는 상황 (완료, 실패, 대안 제안)
- Webhook 설정 및 환경 변수
- slack-notify.sh 스크립트 사용법
- 메시지 언어 (한글) 요구사항
- 상태 옵션 (success, error, warning, info)

## 지원 파일

- `plan-template.md`: PLAN.md 생성 템플릿 (언어별)
- `~/.claude/skills/ai-dev-tasks/scripts/detect-project-type.sh`: 프로젝트 타입 자동 감지
- `~/.claude/skills/ai-dev-tasks/scripts/slack-notify.sh`: Slack 알림 (계획 완료시)
- `~/.claude/skills/ai-dev-tasks/scripts/ruby-quality-check.sh`: Ruby/Rails 품질 검사
- `~/.claude/skills/ai-dev-tasks/scripts/node-quality-check.sh`: Node.js/TypeScript 품질 검사
- `~/.claude/skills/ai-dev-tasks/scripts/cpp-quality-check.sh`: C++ 품질 검사 (Docker)
- `~/.claude/skills/ai-dev-tasks/scripts/cpp-memory-check.sh`: C++ 메모리 검사 (Docker)
