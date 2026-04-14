# 테스트 가이드라인

TDD 철학, 테스트 명세, 테스트 전략을 위한 종합 가이드.

## 목차
- [TDD 워크플로우](#tdd-워크플로우)
- [유닛 테스트 요구사항](#유닛-테스트-요구사항)
- [테스트 유형](#테스트-유형)
- [테스트 커버리지](#테스트-커버리지)
- [테스트 패턴](#테스트-패턴)
- [언어별 테스트 예시](#언어별-테스트-예시)
- [테스트 전략](#테스트-전략)
- [품질 게이트](#품질-게이트)

---

## TDD 워크플로우

각 기능 컴포넌트에 대해:

### 1. 테스트 케이스 명세 (코드 작성 전)
- 어떤 입력을 테스트할 것인가?
- 예상 출력은 무엇인가?
- 처리해야 할 경계 케이스는?
- 테스트해야 할 오류 조건은?

### 2. 테스트 작성 (🔴 Red Phase)
- 실패할 테스트 작성
- 올바른 이유로 실패하는지 확인
- 테스트 실행하여 실패 확인
- TDD 준수 추적을 위해 실패하는 테스트 커밋

### 3. 코드 구현 (🟢 Green Phase)
- 테스트를 통과시키는 최소 코드 작성
- 자주 테스트 실행 (2-5분마다)
- 모든 테스트가 통과하면 중지
- 테스트 이상의 추가 기능 없음

### 4. 리팩토링 (🔵 Refactor Phase)
- 테스트를 통과 상태로 유지하면서 코드 품질 개선
- 중복 로직 추출
- 네이밍 및 구조 개선
- 각 리팩토링 단계 후 테스트 실행
- 리팩토링 완료 시 커밋

---

## 유닛 테스트 요구사항

유닛 테스트는 반드시 실제 프로덕션 코드를 테스트해야 합니다.

핵심 원칙:
- 프로덕션 디렉토리(`src/`, `lib/`, `app/`)에서 코드 임포트
- 테스트 파일 내 프로덕션 코드 정의 금지
- 모든 테스트는 실제 사용되는 코드만 검증
- 테스트 설명 필수 (목적, 시나리오, 기대 결과)

---

## 테스트 유형

### 단위 테스트 (Unit Tests)
- **대상**: 개별 함수, 메서드, 클래스
- **의존성**: 없음 또는 mocked/stubbed
- **속도**: 빠름 (<100ms per test)
- **격리**: 외부 시스템으로부터 완전 격리
- **커버리지**: 비즈니스 로직의 ≥80%

### 통합 테스트 (Integration Tests)
- **대상**: 컴포넌트/모듈 간 상호작용
- **의존성**: 실제 의존성 또는 Mock 사용 가능
- **속도**: 중간 (<1s per test)
- **격리**: 컴포넌트 경계 테스트
- **커버리지**: 중요한 통합 지점

### 엔드투엔드 테스트 (E2E Tests)
- **대상**: 완전한 사용자 워크플로우
- **의존성**: 실제 또는 실제에 가까운 환경
- **속도**: 느림 (초에서 분 단위)
- **격리**: 전체 시스템 통합
- **커버리지**: 중요한 사용자 여정

---

## 테스트 커버리지

### 임계값 (프로젝트에 맞게 조정)
- **비즈니스 로직**: ≥90% (중요 코드 경로)
- **데이터 접근 계층**: ≥80% (repositories, DAOs)
- **API/컨트롤러 계층**: ≥70% (endpoints)
- **UI/프레젠테이션**: 커버리지보다 통합 테스트 선호

### 언어별 커버리지 명령어
```bash
# JavaScript/TypeScript
jest --coverage

# Python
pytest --cov=src --cov-report=html

# Ruby
bundle exec rspec --coverage

# C++
# gcov/lcov 기반
```

---

## 테스트 패턴

### Arrange-Act-Assert (AAA) 패턴
```
test 'description of behavior':
  // Arrange: 테스트 데이터 및 의존성 설정
  input = createTestData()

  // Act: 테스트 중인 동작 실행
  result = systemUnderTest.method(input)

  // Assert: 예상 결과 확인
  assert result == expectedOutput
```

### Given-When-Then (BDD 스타일)
```
test 'feature should behave in specific way':
  // Given: 초기 컨텍스트/상태
  given userIsLoggedIn()

  // When: 액션 발생
  when userClicksButton()

  // Then: 관찰 가능한 결과
  then shouldSeeConfirmation()
```

### 의존성 Mocking/Stubbing
```
test 'component should call dependency':
  mockService = createMock(ExternalService)
  component = new Component(mockService)

  when(mockService.method()).thenReturn(expectedData)

  component.execute()
  verify(mockService.method()).calledOnce()
```

---

## 언어별 테스트 예시

### Python (pytest)
```python
def test_calculate_total_with_valid_items():
    """
    유효한 아이템들로 총액을 계산할 때
    모든 아이템의 가격 합계를 정확히 반환해야 함
    """
    items = [Item(price=100), Item(price=200)]
    calculator = PriceCalculator()

    total = calculator.calculate_total(items)

    assert total == 300
```

### JavaScript/TypeScript (Jest)
```typescript
describe('PriceCalculator', () => {
  test('유효한 아이템들로 총액을 계산할 때 모든 가격의 합계를 반환한다', () => {
    const items = [{ price: 100 }, { price: 200 }];
    const calculator = new PriceCalculator();

    const total = calculator.calculateTotal(items);

    expect(total).toBe(300);
  });
});
```

### C++ (Google Test)
```cpp
// 유효한 아이템들로 총액 계산 시 모든 가격의 합계를 반환해야 함
TEST(PriceCalculatorTest, CalculateTotalWithValidItems) {
    std::vector<Item> items = {Item(100), Item(200)};
    PriceCalculator calculator;

    int total = calculator.calculateTotal(items);

    EXPECT_EQ(total, 300);
}
```

### Ruby (Minitest)
```ruby
class PriceCalculatorTest < Minitest::Test
  # 유효한 아이템들로 총액을 계산할 때 모든 가격의 합계를 반환해야 함
  def test_calculate_total_with_valid_items
    items = [Item.new(price: 100), Item.new(price: 200)]
    calculator = PriceCalculator.new

    total = calculator.calculate_total(items)

    assert_equal 300, total
  end
end
```

---

## 테스트 전략

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

### 테스트 프레임워크 (언어별 필수 지정) 🔴 MUST

PLAN 단계에서 프레임워크는 **협상 불가능한 고정값**으로 결정한다. "프로젝트에 테스트 인프라 없음"으로 오판하여 단위 테스트를 생략하는 것을 방지.

| 언어 | 필수 프레임워크 | 비고 |
|------|----------------|------|
| **C / C++** | 🔴 **Google Test (gtest)** | 다른 선택지 불가. 기존 `tests/` 디렉토리 구조 준수 |
| **Python** | pytest | unittest는 legacy 대응 시에만 |
| **Node.js / TypeScript** | Jest (또는 Vitest — 프로젝트 기존 설정 우선) | Mocha는 legacy 대응 시에만 |
| **Ruby / Rails** | Minitest (Rails 기본) 또는 RSpec (프로젝트 선택) | |
| **Go** | 표준 `testing` + `testify` | |
| **Rust** | `cargo test` + `#[cfg(test)]` | |
| **Java** | JUnit 5 | |
| **Kotlin** | JUnit 5 + MockK | |
| **Swift** | XCTest | |

**결정 순서**:
1. 프로젝트 타입 자동 감지
2. 위 표에서 해당 언어의 필수 프레임워크 선택
3. 기존에 다른 프레임워크가 이미 설정되어 있으면 **기존 우선 존중** (단, C/C++는 예외 — gtest 고정)
4. 기존 테스트 디렉토리(`tests/`, `test/`, `spec/`) 구조 조사 → PLAN.md에 반영

### 🚫 테스트 전략 금지 패턴 🔴 MUST

아래 패턴은 **테스트 전략으로 인정하지 않는다**:

- ❌ "프로젝트에 단위 테스트 프레임워크가 없으므로 빌드 성공 + CLI 수동 테스트로 검증" — 대부분의 프로젝트에는 이미 인프라가 있다. 확인 없이 가정 금지
- ❌ RED Phase 태스크를 "빌드 실패 확인", "상수 번호 충돌 확인", "헤더 include 에러 확인" 수준으로 왜소화 — 이는 컴파일러 체크이지 단위 테스트가 아님
- ❌ 순수 함수(유효성 검증, 파싱, 변환 유틸)에 대한 단위 테스트 생략 — 테스트 비용 가장 낮고 회귀 안전망 효과 가장 큼
- ❌ 수동 CLI 테스트 / 엔드투엔드 테스트만으로 전체 테스트 전략 완결 처리 — 회귀 방지 자동화 없음
- ❌ `private` 메서드라서 테스트 불가 → 리팩터(friend, public static 추출)로 접근성 확보해야 함. 테스트 생략 이유로 삼지 말 것

### ✅ 테스트 전략 필수 포함 항목

PLAN.md의 "테스트 전략" 섹션에는 다음이 모두 포함되어야 한다:

1. **프레임워크 명시**: 위 표에서 선택한 프레임워크와 버전
2. **테스트 파일 경로 규칙**: 프로덕션 소스 대응 위치 (예: `sources/utils/foo.cpp` → `tests/utils/test_foo.cpp`)
3. **각 Phase별 추가할 테스트 파일**과 **테스트 케이스 수** (최소 수치)
4. **순수 함수 목록**: 단위 테스트 대상 명시 (누락 방지)
5. **경계값/예외 케이스**: Happy Path / Boundary / Exception / Edge 각각 몇 개
6. **실행 커맨드**: 테스트 실행 / 특정 테스트 필터 / CI 출력 형식

### 각 함수/메서드별 테스트 케이스
- ✅ Happy Path (정상 경로)
- 🔶 Boundary Cases (경계값: 0, max, min, empty, null)
- ❌ Exception Cases (예외 처리)
- 🔀 Edge Cases (특수 상황)

### 플랜에 테스트 문서화

각 Phase에서 명시:
1. **테스트 파일 위치**: 테스트가 작성될 정확한 경로
2. **테스트 시나리오**: 특정 테스트 케이스 목록 (각 테스트에 대한 간략한 설명 포함)
3. **예상 실패**: 초기에 테스트가 표시해야 할 오류는?
4. **커버리지 목표**: 이 Phase의 퍼센트
5. **Mock할 의존성**: Mock/stub이 필요한 것은?
6. **테스트 데이터**: 필요한 fixture/factory는?

---

## 품질 게이트

### 각 Phase 완료 기준
- ✅ 모든 테스트 통과 (100%)
- ✅ 커버리지 목표 달성 (80%+)
- ✅ 메모리 검사 통과 (Valgrind/ASan) — C++
- ✅ 정적 분석 통과 (clang-tidy, cppcheck) — C++
- ✅ 코드 포매팅 준수

### QA 도구 (언어별)
- **Ruby/Rails**: `scripts/ruby-quality-check.sh` — 테스트, RuboCop, Brakeman, Bundle Audit
- **Node.js/TypeScript**: `scripts/node-quality-check.sh` — TypeScript, ESLint, Prettier, 테스트
- **C++**: `scripts/cpp-quality-check.sh` — clang-tidy, cppcheck, Valgrind, ASan/TSan/UBSan
