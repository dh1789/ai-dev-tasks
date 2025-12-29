---
name: plan
description: 기능 계획 수립 - 요구사항 수집, PRD 생성, Phase 분해를 수행합니다. 복잡도에 따라 대화형 질문을 통해 상세 요구사항을 수집하거나 즉시 플래닝합니다. 다언어 지원 (Ruby/Rails, Node.js/TypeScript, C++, Python) - 프로젝트 타입을 자동 감지하고 언어별 최적화된 계획을 수립합니다.
---

# Feature Planning Skill

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

다음 영역에 대해 **10-15개의 체계적인 질문**을 합니다:

**A. 기능 요구사항 (Functional Requirements)**
1. 핵심 기능은 무엇인가요?
2. 사용자/시스템이 수행할 주요 동작은?
3. 입력/출력 데이터 형식은?
4. 필요한 알고리즘이나 로직은?
5. 기존 시스템과의 통합 지점은?

**B. 비기능 요구사항 (Non-Functional Requirements)**
1. **성능 요구사항:**
   - 예상 처리량 (TPS, QPS)?
   - 응답 시간 제약?
   - 동시 사용자/연결 수?
   - 메모리 사용 제한?

2. **보안 요구사항:**
   - 인증/인가 필요?
   - 데이터 암호화?
   - 입력 검증 수준?
   - 취약점 고려사항?

3. **안정성 요구사항:**
   - 가용성 목표 (99.9%)?
   - 장애 복구 전략?
   - 데이터 손실 허용 범위?

4. **확장성 요구사항:**
   - 수평/수직 확장 가능해야 하나?
   - 예상 데이터 증가율?

**C. 유지보수성 요구사항**
1. 코드 품질 기준 (커버리지, 복잡도)?
2. 문서화 수준?
3. 로깅/모니터링 요구사항?
4. 배포 전략?

**D. 기술 제약사항 (언어별)**

**프로젝트 타입 자동 감지:**
- `scripts/detect-project-type.sh`를 사용하여 프로젝트 언어/프레임워크 자동 식별
- Gemfile → Ruby/Rails
- package.json → Node.js/TypeScript
- CMakeLists.txt → C++
- requirements.txt → Python

**언어별 질문:**

*Ruby/Rails 프로젝트:*
1. Ruby 버전 (3.3.x)?
2. Rails 버전 (8.0.x)?
3. 데이터베이스 (SQLite, MySQL, PostgreSQL)?
4. 프론트엔드 전략 (Hotwire, Importmap, React 등)?
5. 테스트 프레임워크 (Minitest, RSpec)?
6. 배포 방식 (Kamal, Capistrano, Heroku)?

*Node.js/TypeScript 프로젝트:*
1. Node.js 버전 (18+, 20+)?
2. TypeScript 사용 여부?
3. 패키지 매니저 (npm, yarn, pnpm)?
4. 프레임워크 (Express, Next.js, NestJS)?
5. 테스트 프레임워크 (Jest, Vitest, Mocha)?
6. 빌드 도구 (tsup, esbuild, webpack)?

*C++ 프로젝트:*
1. C++ 표준 버전 (C++23 기본)?
2. 컴파일러 (GCC, Clang, MSVC)?
3. 빌드 시스템 (CMake, Meson, Make)?
4. 플랫폼 제약 (Linux, Windows, macOS)?
5. 실행 환경 (Docker 필수)?

*Python 프로젝트:*
1. Python 버전 (3.10+, 3.11+, 3.12+)?
2. 의존성 관리 (pip, Poetry, Pipenv)?
3. 프레임워크 (Django, Flask, FastAPI)?
4. 테스트 프레임워크 (pytest, unittest)?
5. 타입 체크 (mypy 사용 여부)?

#### 간단한 기능일 경우

기본 정보만 확인하고 즉시 플래닝으로 진행합니다.

### 3단계: PRD 생성

수집된 정보를 바탕으로 다음 구조의 PRD를 생성합니다:

```markdown
# PRD: [기능명]

## 개요
[기능 요약 및 목적]

## 목표
- 구체적이고 측정 가능한 목표들

## 기능 요구사항
1. [요구사항 1]
2. [요구사항 2]
...

## 비기능 요구사항

### 성능
- [성능 목표]

### 보안
- [보안 요구사항]

### 안정성
- [안정성 목표]

## 제약사항 및 비목표
- [포함하지 않을 것들]

## 사용자 시나리오
### 시나리오 1: [이름]
[상세 설명]

## 기술 스택

**자동 감지된 프로젝트 타입: [Ruby/Node.js/C++/Python]**

*Ruby/Rails 프로젝트 예시:*
- 언어: Ruby 3.3.x
- 프레임워크: Rails 8.0.x
- 데이터베이스: MySQL / SQLite (테스트)
- 테스트: Minitest
- 배포: Kamal / Heroku
- 프론트엔드: Hotwire (Turbo + Stimulus)

*Node.js/TypeScript 프로젝트 예시:*
- 언어: TypeScript 5.x
- 런타임: Node.js 20+
- 패키지 매니저: pnpm / npm / yarn
- 프레임워크: Express / Next.js
- 테스트: Jest / Vitest
- 빌드: tsup / esbuild

*C++ 프로젝트 예시:*
- 언어: C++23
- 컴파일러: GCC 15.1.0
- 빌드: CMake + Ninja
- 테스트: Google Test
- 환경: Docker (Ubuntu 22.04)

*Python 프로젝트 예시:*
- 언어: Python 3.12+
- 의존성: Poetry / pip
- 프레임워크: FastAPI / Django
- 테스트: pytest
- 타입 체크: mypy

## 성공 지표
- [측정 가능한 성공 기준]
```

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

**피해야 할 일반적인 안티패턴**:
- ❌ `src/`에서 임포트하는 대신 테스트 파일에 전체 클래스 구현
- ❌ 통과하지만 프로덕션에서 실행되지 않는 코드 테스트 작성
- ❌ 프로덕션 코드를 완전히 대체하는 mock 구현 생성 (의존성에만 stub 사용)
- ❌ 테스트 헬퍼 파일에만 정의된 유틸리티 함수 테스트

**프로덕션 코드 검증 명령어**:
```bash
# 의심스러운 class/function 정의가 있는 테스트 파일 찾기
grep -r "^class\|^def\|^function" test/ --include="*.py" --include="*.js" --include="*.ts"

# 테스트 파일의 임포트가 프로덕션을 가리키는지 확인
grep -r "from src\|import.*src\|require.*src" test/

# 테스트된 코드가 프로덕션에 존재하는지 확인
grep -r "class ProcessPayment\|def process_payment" src/ lib/ app/
```

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
2. **테스트 시나리오**: 특정 테스트 케이스 목록
3. **예상 실패**: 초기에 테스트가 표시해야 할 오류는?
4. **커버리지 목표**: 이 phase의 퍼센트
5. **Mock할 의존성**: Mock/stub이 필요한 것은?
6. **테스트 데이터**: 필요한 fixture/factory는?

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

**CRITICAL**: PLAN.md 생성 전 반드시 사용자의 명시적 승인을 받아야 합니다.

**질문해야 할 내용:**
- "이 Phase 분해가 프로젝트에 적합한가요?"
- "제안된 접근 방식에 대한 우려사항이 있나요?"
- "PLAN 문서를 생성해도 될까요?"

**추가 제공 정보:**
- Phase 개수: X개
- 예상 총 시간: Y시간
- 주요 컴포넌트: [리스트]
- 주요 기술 스택 및 의존성

**중요**: 사용자가 승인을 확인한 후에만 PLAN.md 파일을 생성합니다.

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

**필수**: 다음 상황에서 Slack webhook 알림을 보내야 합니다:

### 알림을 보내야 하는 경우

1. **계획 완료**:
   - 프로젝트 이름/경로, Phase 개수, 예상 시간 포함
   - 상태: `success`
   - 예: "계획 수립 완료 ✅ - jwt-authentication, 5개 Phase, 예상 12시간"

2. **계획 실패 또는 타협 필요**:
   - 실패 이유를 명확히 설명
   - 대안 제시 (스킵, 단순화, 범위 축소)
   - 사용자 피드백 대기 후 진행
   - 상태: `error`
   - 예: "계획 수립 실패 ⚠️ - 요구사항 불명확. 추가 정보 필요"

3. **더 나은 접근 방식 제안**:
   - 대안 접근 방식을 권장하는 이유 설명
   - 명확한 근거와 이점 제공
   - 방향 변경 전 사용자 승인 대기
   - 상태: `info`
   - 예: "더 나은 방법 제안 💡 - Phase를 3개에서 5개로 분리하여 위험 감소"

### Webhook 설정

- **Webhook URL**: `https://hooks.slack.com/services/YOUR_WORKSPACE/YOUR_CHANNEL/YOUR_TOKEN`
- **환경 변수**: `~/.zshrc` 또는 `~/.bashrc`에 `SLACK_WEBHOOK_URL` 설정:
  ```bash
  export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR_WORKSPACE/YOUR_CHANNEL/YOUR_TOKEN"
  ```
- **문자 제한**: 최대 1000자 - 메시지는 자동으로 잘립니다
- **메시지 언어**: 모든 Slack 메시지는 **한글**로 작성해야 합니다
- **스크립트 위치**: `./scripts/slack-notify.sh`

### slack-notify.sh 스크립트 사용

**사용법**:
```bash
./scripts/slack-notify.sh "메시지 내용" [status]
```

**상태 옵션**:
- `success` - 작업 성공 (초록색, ✅)
- `error` - 작업 실패 또는 오류 발생 (빨간색, ❌)
- `warning` - 경고 또는 주의 필요 (주황색, ⚠️)
- `info` - 일반 정보 (파란색, ℹ️) [기본값]

**예제**:
```bash
# 계획 완료
./scripts/slack-notify.sh "계획 수립 완료 - jwt-authentication, 5개 Phase, 예상 12시간" "success"

# 계획 실패
./scripts/slack-notify.sh "계획 수립 실패 - 요구사항 불명확. 추가 정보 필요" "error"

# 더 나은 접근 방식 제안
./scripts/slack-notify.sh "더 나은 방법 제안 - Phase 분리로 위험 감소" "info"
```

## 지원 파일

- `plan-template.md`: PLAN.md 생성 템플릿 (언어별)
- `../scripts/detect-project-type.sh`: 프로젝트 타입 자동 감지
- `../scripts/slack-notify.sh`: Slack 알림 (계획 완료시)
- `../scripts/ruby-quality-check.sh`: Ruby/Rails 품질 검사
- `../scripts/node-quality-check.sh`: Node.js/TypeScript 품질 검사
- `../scripts/cpp-quality-check.sh`: C++ 품질 검사 (Docker)
- `../scripts/cpp-memory-check.sh`: C++ 메모리 검사 (Docker)
