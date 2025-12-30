# 테스트 표준 및 요구사항 (Testing Standards and Requirements)

## 목적

모든 프로젝트에서 일관된 테스트 전략과 품질 기준을 제공합니다. 이 문서는 PRD 작성, 태스크 생성, 구현 단계에서 공통으로 참조됩니다.

## TDD (Test-Driven Development) 원칙

### 핵심 철학

이 프로젝트는 **Kent Beck의 TDD 및 Tidy First 원칙**을 따릅니다.

**상세 내용은 `tdd.md` 문서를 참조하세요.**

주요 원칙:
- Red → Green → Refactor 사이클 준수
- 가장 간단한 실패하는 테스트부터 작성
- 테스트를 통과시키기 위한 최소한의 코드만 구현
- 구조적 변경과 동작적 변경 분리 (Tidy First)

## 유닛 테스트 프로덕션 코드 요구사항

### 핵심 원칙

**CRITICAL:** 유닛 테스트는 **실제 프로덕션 코드**를 테스트해야 하며, 테스트 전용 구현을 테스트해서는 안 됩니다.

### 필수 요구사항

1. **프로덕션 코드 임포트:**
   - 모든 유닛 테스트는 프로덕션 디렉토리(`src/`, `lib/`, `app/` 등)에서 함수/클래스를 임포트해야 함
   - 테스트만을 위한 별도 구현 금지

2. **테스트 내 구현 금지:**
   - 테스트 파일 내에서 프로덕션 함수/클래스를 정의하지 말 것
   - 테스트는 이미 존재하는 프로덕션 코드를 검증하는 역할만 수행

3. **프로덕션 사용 검증:**
   - 테스트된 모든 코드는 실제 프로덕션 애플리케이션에서 사용되어야 함
   - 진입점(`main.py`, `app.js` 등)에서 호출되거나 참조되는 코드만 테스트

4. **임포트 경로 검증:**
   - 테스트 임포트는 테스트 유틸리티가 아닌 프로덕션 모듈을 가리켜야 함
   - 임포트 경로가 `src/`, `lib/`, `app/` 등 프로덕션 디렉토리를 참조하는지 확인

5. **테스트 설명 필수:**
   - 모든 테스트는 무엇을 테스트하는지 간략한 설명을 포함해야 함
   - 목적, 시나리오, 기대 결과를 명시

### 올바른 예 vs 잘못된 예

✅ **올바름 - 실제 프로덕션 코드 테스트:**
```python
# test/unit/payment/test_processor.py
from src.payment.processor import ProcessPayment  # 프로덕션에서 임포트

def test_payment_processing_with_valid_amount():
    """
    유효한 금액으로 결제 처리 시 성공 결과를 반환해야 함

    시나리오: 100원 결제 요청
    기대 결과: success=True, amount=100
    """
    # Arrange
    processor = ProcessPayment()  # 실제 프로덕션 클래스 사용
    amount = 100

    # Act
    result = processor.charge(amount=amount)

    # Assert
    assert result.success == True
    assert result.amount == amount
```

❌ **잘못됨 - 테스트 전용 구현:**
```python
# test/unit/payment/test_processor.py
# 테스트 파일에 프로덕션 코드 정의 - 절대 금지!
class ProcessPayment:
    def charge(self, amount):
        return {"success": True}

def test_payment_processing():  # 설명 없음
    processor = ProcessPayment()  # 프로덕션에 존재하지 않는 코드 테스트
    result = processor.charge(amount=100)
    assert result["success"] == True
```

### 테스트 커밋 전 검증 단계

1. ✅ 모든 `import` 문이 프로덕션 코드 경로를 가리키는지 확인
2. ✅ 테스트된 함수/클래스 정의가 프로덕션 코드베이스에 있는지 검색
3. ✅ 테스트된 코드가 애플리케이션 진입점에서 임포트되는지 확인
4. ✅ 테스트 파일에 함수/클래스 정의가 없는지 확인 (fixture/helper 제외)

### 프로덕션 코드 검증 명령어

```bash
# 테스트 파일에서 의심스러운 정의 찾기
grep -r "^class\|^def\|^function" test/ --include="*.py" --include="*.js" --include="*.ts"

# 테스트 임포트가 프로덕션을 가리키는지 확인
grep -r "from src\|import.*src\|require.*src" test/

# 테스트된 코드가 프로덕션에 존재하는지 확인
grep -r "class ProcessPayment\|def process_payment" src/ lib/ app/
```

### 일반적인 안티패턴 회피

- ❌ `src/`에서 임포트하는 대신 테스트 파일에 전체 클래스 구현
- ❌ 통과하지만 프로덕션에서 실행되지 않는 코드 테스트 작성
- ❌ 프로덕션 코드를 완전히 대체하는 mock 구현 생성 (의존성에만 stub 사용)
- ❌ 테스트 헬퍼 파일에만 정의된 유틸리티 함수 테스트

## 테스트 유형 및 커버리지

### 단위 테스트 (Unit Tests)

**대상:** 개별 함수, 메서드, 클래스

**필수 요구사항:**
- 프로그래밍 언어의 **네이티브 테스트 프레임워크** 사용
  - JavaScript/TypeScript: Jest 또는 Vitest
  - Python: pytest 또는 unittest
  - Java: JUnit
  - Ruby: RSpec 또는 Minitest
  - C++: Google Test
- 최소 **3가지 테스트 케이스** 포함:
  1. **Happy Path:** 가장 일반적이고 예상되는 시나리오
  2. **Boundary Conditions:** 최소값, 최대값, 빈 입력, null 값, 경계 시나리오
  3. **Exception Cases:** 잘못된 입력, 오류 조건, 예외 상황
  4. **Side Effects:** 테스트 독립성 보장, 전역 상태나 외부 시스템에 영향 없음

**테스트 설명 작성:**
- 목적: 무엇을 테스트하는지
- 시나리오: 어떤 상황에서
- 기대 결과: 무엇이 발생해야 하는지

**커버리지 목표:**
- 비즈니스 로직: ≥ 90%
- 데이터 접근 계층: ≥ 80%
- API/컨트롤러 계층: ≥ 70%

**속도:** 빠름 (테스트당 < 100ms)

**격리:** 외부 시스템으로부터 완전 격리

### 시스템 테스트 (System/Integration Tests)

**대상:** PRD의 사용자 스토리 기반 완전한 워크플로우

**필수 요구사항:**
- **최소 2개의 realistic user scenarios** 테스트
- **실제 데이터 사용 필수** - 하드코딩된 값이나 더미 데이터 사용 금지
- 사용자 워크플로우를 시작부터 끝까지 검증
- 모든 컴포넌트의 통합 및 기능의 end-to-end 검증

**커버리지 대상:** 중요한 통합 지점

**속도:** 중간 (테스트당 < 1초)

**격리:** 컴포넌트 경계 테스트

### 엔드투엔드 테스트 (E2E Tests)

**대상:** 완전한 사용자 워크플로우

**요구사항:**
- 실제 또는 실제에 가까운 환경 사용
- 중요한 사용자 여정 검증

**커버리지 대상:** 중요한 사용자 여정

**속도:** 느림 (초에서 분 단위)

**격리:** 전체 시스템 통합

## 테스트 피라미드

```
        /\
       /  \  E2E 테스트
      /    \ - 실제 사용 시나리오
     /------\
    /        \ 시나리오/통합 테스트
   /          \ - 여러 컴포넌트 통합
  /------------\
 /              \ 단위 테스트
/________________\ - 개별 함수/클래스
```

**원칙:**
- 단위 테스트가 가장 많아야 함 (80%)
- 통합 테스트는 중간 (15%)
- E2E 테스트는 가장 적게 (5%)

## AAA 테스트 패턴

### Arrange-Act-Assert

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

**Python (pytest):**
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

**JavaScript/TypeScript (Jest):**
```typescript
describe('PriceCalculator', () => {
  test('유효한 아이템들로 총액 계산 시 모든 가격의 합계를 반환한다', () => {
    // Arrange
    const items = [{ price: 100 }, { price: 200 }];
    const calculator = new PriceCalculator();

    // Act
    const total = calculator.calculateTotal(items);

    // Assert
    expect(total).toBe(300);
  });
});
```

**C++ (Google Test):**
```cpp
// 유효한 아이템들로 총액 계산 시 모든 가격의 합계를 반환해야 함
TEST(PriceCalculatorTest, CalculateTotalWithValidItems) {
    // Arrange
    std::vector<Item> items = {Item(100), Item(200)};
    PriceCalculator calculator;

    // Act
    int total = calculator.calculateTotal(items);

    // Assert
    EXPECT_EQ(total, 300);
}
```

**Ruby (Minitest):**
```ruby
class PriceCalculatorTest < Minitest::Test
  # 유효한 아이템들로 총액을 계산할 때 모든 가격의 합계를 반환해야 함
  def test_calculate_total_with_valid_items
    # Arrange
    items = [Item.new(price: 100), Item.new(price: 200)]
    calculator = PriceCalculator.new

    # Act
    total = calculator.calculate_total(items)

    # Assert
    assert_equal 300, total
  end
end
```

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

### 테스트 실행 명령어

```bash
# JavaScript/TypeScript
jest --coverage
# 특정 테스트 파일만: npx jest path/to/test/file

# Python
pytest --cov=src --cov-report=html
coverage report

# Ruby
bundle exec rails test
bundle exec rspec

# Java
mvn test
gradle test

# C++
# Google Test 실행 (Docker 컨테이너 내)
docker exec gcc15.1_22.04 bash -c "cd /workspace/build && ./test/unit/*_test"
```

## 커버리지 계산 및 임계값

### 생태계별 커버리지 명령어

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

### 커버리지 임계값

프로젝트에 맞게 조정 가능:

| 계층 | 최소 커버리지 | 권장 사유 |
|------|--------------|-----------|
| 비즈니스 로직 | ≥90% | 중요 코드 경로 보호 |
| 데이터 접근 계층 | ≥80% | Repositories, DAOs 안정성 |
| API/컨트롤러 계층 | ≥70% | Endpoints 기본 검증 |
| UI/프레젠테이션 | 커버리지보다 통합 테스트 선호 | |

## Mock/Stub 사용 가이드

### Mock/Stub 사용 원칙

```
test 'component should call dependency':
  // Mock/stub 생성
  mockService = createMock(ExternalService)
  component = new Component(mockService)

  // Mock 동작 구성
  when(mockService.method()).thenReturn(expectedData)

  // 실행 및 검증
  component.execute()
  verify(mockService.method()).calledOnce()
```

**주의사항:**
- Mock은 외부 의존성에만 사용 (API, 데이터베이스, 외부 서비스)
- 프로덕션 비즈니스 로직을 mock으로 대체하지 않음
- 과도한 mocking은 테스트의 신뢰성 저하

## 품질 게이트

### 커밋 전 테스트 검증

- [ ] 모든 프로덕션 코드에 대응하는 유닛 테스트 작성됨
- [ ] 최소 3가지 테스트 케이스 (Happy Path, Boundary, Exception) 포함
- [ ] 모든 테스트 설명이 명확하게 작성됨
- [ ] 테스트가 프로덕션 코드를 임포트하는지 확인
- [ ] 테스트 파일에 프로덕션 코드 정의가 없는지 확인
- [ ] 모든 테스트가 통과함 (100%)
- [ ] 커버리지 목표 달성
- [ ] 테스트 실행 시간이 허용 범위 내

## 참조 문서

- **`tdd.md`:** Kent Beck의 TDD 및 Tidy First 원칙 상세
- **`process-task-list.md`:** 태스크 실행 시 테스트 요구사항
- **`create-prd.md`:** PRD에 포함할 테스트 요구사항
- **`generate-tasks.md`:** 태스크 생성 시 테스트 고려사항
- **`skill-plan/SKILL.md`:** 계획 수립 시 테스트 전략
- **`skill-implement/SKILL.md`:** 구현 시 테스트 실행

## 적용 범위

이 표준은 다음 활동에 적용됩니다:

1. **PRD 작성:** Testing Requirements 섹션 작성 시
2. **태스크 생성:** 테스트 서브태스크 정의 시
3. **구현:** 코드 작성 및 테스트 구현 시
4. **품질 검증:** 커밋 전 품질 게이트 통과 확인 시
