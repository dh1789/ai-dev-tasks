# 요구사항 수집 가이드

복잡한 기능의 경우 **AskUserQuestion 도구**를 사용하여 체계적으로 요구사항을 수집합니다.

## 수집 단계

### 1단계: 기능 요구사항

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

### 2단계: 비기능 요구사항

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

### 3단계: 유지보수성 요구사항

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

### 4단계: 기술 제약사항 (언어별)

프로젝트 타입은 `scripts/detect-project-type.sh`로 자동 감지됩니다.

#### Ruby/Rails 프로젝트

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

#### Node.js/TypeScript 프로젝트

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

#### C++ 프로젝트

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

#### Python 프로젝트

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
