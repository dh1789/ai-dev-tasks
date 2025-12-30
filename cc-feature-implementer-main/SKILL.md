---
name: feature-planner
description: Creates phase-based feature plans with quality gates and incremental delivery structure. Use when planning features, organizing work, breaking down tasks, creating roadmaps, or structuring development strategy. Keywords: plan, planning, phases, breakdown, strategy, roadmap, organize, structure, outline.
---

# Feature Planner

## Purpose
Generate structured, phase-based plans where:
- Each phase delivers complete, runnable functionality
- Quality gates enforce validation before proceeding
- User approves plan before any work begins
- Progress tracked via markdown checkboxes
- Each phase is 1-4 hours maximum

**Target Audience**: Plans are designed for **junior developers** who will implement the feature. Therefore:
- Requirements are explicit and unambiguous
- Technical terms are explained where necessary
- Sufficient detail provided to understand feature purpose and core logic
- Assume awareness of existing codebase context

## Planning Workflow

### Step 1: Requirements Analysis
1. **Read relevant files** to understand codebase architecture
2. **Assess Current State** - Review existing codebase:
   - Understand existing infrastructure, architectural patterns, and conventions
   - Identify existing components or features relevant to requirements
   - Find existing files, components, and utilities that can be leveraged or need modification
   - Note reusable patterns and established coding practices
3. **Identify dependencies** and integration points
4. **Assess complexity and risks**
5. **Determine appropriate scope** (small/medium/large)

### Step 2: Phase Breakdown with TDD Integration
Break feature into 3-7 phases where each phase:
- **Test-First**: Write tests BEFORE implementation
- Delivers working, testable functionality
- Takes 1-4 hours maximum
- Follows Red-Green-Refactor cycle
- Has measurable test coverage requirements
- Can be rolled back independently
- Has clear success criteria

**Phase Structure**:
- Phase Name: Clear deliverable
- Goal: What working functionality this produces
- **Test Strategy**: What test types, coverage target, test scenarios
- Tasks (ordered by TDD workflow):
  1. **RED Tasks**: Write failing tests first
  2. **GREEN Tasks**: Implement minimal code to make tests pass
  3. **REFACTOR Tasks**: Improve code quality while tests stay green
- Quality Gate: TDD compliance + validation criteria
- Dependencies: What must exist before starting
- **Coverage Target**: Specific percentage or checklist for this phase

### Step 3: Plan Document Creation
Use plan-template.md to generate: `docs/plans/PLAN_<feature-name>.md`

Include:
- Overview and objectives
- Architecture decisions with rationale
- Complete phase breakdown with checkboxes
- Quality gate checklists
- Risk assessment table
- Rollback strategy per phase
- Progress tracking section
- Notes & learnings area

### Step 4: User Approval
**CRITICAL**: 반드시 **AskUserQuestion 도구**를 사용하여 명시적 승인을 받은 후 진행합니다.

**승인 질문 예시:**
```
AskUserQuestion({
  questions: [
    {
      question: "이 계획안을 승인하시겠습니까?",
      header: "계획 승인",
      multiSelect: false,
      options: [
        {
          label: "승인 - 계획 문서 생성 (권장)",
          description: `Phase 분해: ${phases.length}개
예상 총 시간: ${totalHours}시간
주요 컴포넌트: ${components.join(', ')}
제안된 접근 방식에 문제가 없으면 진행합니다.`
        },
        {
          label: "수정 필요",
          description: "Phase 구성이나 접근 방식을 조정하고 싶습니다."
        },
        {
          label: "처음부터 다시",
          description: "요구사항 수집부터 다시 시작합니다."
        }
      ]
    }
  ]
})
```

**승인 후 동작:**
- **승인**: 즉시 PLAN 문서 생성
- **수정 필요**: 사용자 피드백을 반영하여 계획 수정
- **처음부터 다시**: 요구사항 분석부터 재시작

**중요**: 사용자가 "승인"을 선택한 후에만 계획 문서를 생성합니다.

### Step 5: Document Generation
1. Create `docs/plans/` directory if not exists
2. Generate plan document with all checkboxes unchecked
3. Add clear instructions in header about quality gates
4. Inform user of plan location and next steps

## Debug Logging Standards

### Required Logging Implementation

All production code MUST include comprehensive debug logging to facilitate troubleshooting, monitoring, and maintenance.

**Logging Hierarchy:**
```
DEBUG   → 상세 진단 정보 (함수 파라미터, 중간값, 디버깅용)
INFO    → 일반 정보 (상태 변경, 마일스톤, 정상 흐름)
WARN    → 잠재적 문제 (deprecation, 복구 가능한 오류)
ERROR   → 실제 오류 (예외, 실패, 긴급 조치 필요)
```

**필수 로깅 지점:**

1. **복잡한 함수 경계**
   ```python
   def process_payment(transaction):
       logger.debug(f"결제 처리 시작 - transaction_id: {transaction.id}, amount: {transaction.amount}")
       try:
           result = payment_gateway.charge(transaction)
           logger.info(f"결제 성공 - transaction_id: {transaction.id}")
           return result
       except PaymentError as e:
           logger.error(f"결제 실패 - transaction_id: {transaction.id}, error: {e}", exc_info=True)
           raise
   ```

2. **상태 전환**
   ```python
   logger.info(f"주문 상태 변경 - order_id: {order.id}, from: {old_status}, to: {new_status}")
   ```

3. **외부 시스템 연동**
   ```python
   logger.debug(f"API 요청 - endpoint: {url}, method: {method}, params: {params}")
   response = api_call()
   logger.debug(f"API 응답 - status: {response.status_code}, body: {response.body[:100]}")
   ```

4. **비즈니스 로직 의사결정**
   ```python
   if user.is_premium():
       logger.debug(f"프리미엄 할인 적용 - user_id: {user.id}")
   ```

**보안 요구사항:**
- ❌ 절대 로깅 금지: 비밀번호, 토큰, API 키, 신용카드 번호, 개인정보
- ✅ 안전한 로깅: `logger.info(f"로그인 성공 - email: {email.split('@')[1]}")` (도메인만)

**성능 고려사항:**
- 적절한 로그 레벨 사용 (프로덕션에서는 DEBUG 비활성화)
- 로그 구문에서 비용 높은 연산 회피
- Lazy formatting 사용: `logger.debug("Value: %s", expensive_call())`
  - 나쁜 예: `logger.debug(f"Value: {expensive_call()}")` (항상 실행됨)

**로그 분석 용이성:**
- 구조화된 로깅 (JSON 형식 권장)
- 일관된 키 이름 사용 (user_id, transaction_id, order_id)
- 컨텍스트 충분히 포함 (ID, 파라미터, 상태)
- 검색 가능한 문자열 사용

## Quality Gate Standards

Each phase MUST validate these items before proceeding to next phase:

**Build & Compilation**:
- [ ] Project builds/compiles without errors
- [ ] No syntax errors

**Test-Driven Development (TDD)**:
- [ ] Tests written BEFORE production code
- [ ] Red-Green-Refactor cycle followed
- [ ] Unit tests: ≥80% coverage for business logic
- [ ] Integration tests: Critical user flows validated
- [ ] Test suite runs in acceptable time (<5 minutes)

**Production Code Verification** (CRITICAL):
- [ ] Tests import actual production code from `src/` or production directories
- [ ] NO test-specific function/class implementations in test files
- [ ] All tested code is actually used in production application
- [ ] Test imports verified: `from src.module import function` (not defined in tests)
- [ ] Tested functions/classes confirmed to exist in production codebase

**Testing**:
- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Test coverage maintained or improved

**Code Quality**:
- [ ] Linting passes with no errors
- [ ] Type checking passes (if applicable)
- [ ] Code formatting consistent

**Functionality**:
- [ ] Manual testing confirms feature works
- [ ] No regressions in existing functionality
- [ ] Edge cases tested

**Security & Performance**:
- [ ] No new security vulnerabilities
- [ ] No performance degradation
- [ ] Resource usage acceptable

**Documentation**:
- [ ] Code comments updated
- [ ] Documentation reflects changes

## Task Implementation Protocol

**CRITICAL**: When implementing tasks from generated plans:

### Completion Protocol
When you finish a **sub-task**:
1. Immediately mark it as completed by changing `[ ]` to `[x]`
2. If **all** subtasks underneath a parent task are now `[x]`, follow this sequence:
   - **First**: Run the full test suite (`pytest`, `npm test`, `bin/rails test`, etc.) with 30-minute timeout (1800000ms)
   - **Wait for completion**: Always wait for full test suite to complete before proceeding
   - **No shortcuts**: Do not use grep, tail, or other methods to skip test execution
   - **Only if all tests pass**: Stage changes (`git add .`)
   - **Clean up**: Remove any temporary files and temporary code before committing
   - **Commit**: Use a descriptive commit message with conventional commit format:
     - Format: `type: description` (e.g., `feat:`, `fix:`, `refactor:`)
     - Summarize what was accomplished in the parent task
     - List key changes and additions
     - Reference the task number and context
     - Use `-m` flags for multi-line messages:
       ```bash
       git commit -m "feat: add payment validation logic" -m "- Validates card type and expiry" -m "- Adds unit tests for edge cases" -m "Related to Task 1.0"
       ```
3. Once all subtasks are marked completed and changes have been committed, mark the **parent task** as completed

## Progress Tracking Protocol

Add this to plan document header:

```markdown
**CRITICAL INSTRUCTIONS**: After completing each phase:
1. ✅ Check off completed task checkboxes
2. 🧪 Run all quality gate validation commands
3. ⚠️ Verify ALL quality gate items pass
4. 📅 Update "Last Updated" date
5. 📝 Document learnings in Notes section
6. ➡️ Only then proceed to next phase

⛔ DO NOT skip quality gates or proceed with failing checks
```

## Slack Notification Protocol

**MANDATORY**: Send Slack webhook notifications in the following situations:

### When to Send Notifications

1. **Task Completed**:
   - Include project name/path, task number, and summary of accomplishments
   - Mention test results and commit hash
   - Status: `success`
   - Example: "Task 3.2 완료 ✅ - 결제 검증 로직 구현 완료, 테스트 15개 통과, 커밋: abc123f"

2. **Task Failed or Requires Compromise**:
   - Explain the failure reason clearly
   - Propose alternatives (skip, hardcode, simplify, or reduce scope)
   - Wait for user feedback before proceeding
   - Status: `error`
   - Example: "Task 2.1 실패 ⚠️ - API 연동 실패 (timeout). 대안: 1) Mock 데이터 사용 2) 타임아웃 증가 3) 스킵"

3. **Suggesting Better Approach**:
   - Explain why the alternative approach is recommended
   - Provide clear reasoning and benefits
   - Wait for user approval before changing course
   - Status: `info`
   - Example: "더 나은 방법 제안 💡 - 현재: 동기 처리, 제안: 비동기 처리 (성능 3배 향상 예상)"

### Webhook Configuration

- **Webhook URL**: `https://hooks.slack.com/services/YOUR_WORKSPACE/YOUR_CHANNEL/YOUR_TOKEN`
- **Environment Variable**: Set `SLACK_WEBHOOK_URL` in `~/.zshrc` or `~/.bashrc`:
  ```bash
  export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR_WORKSPACE/YOUR_CHANNEL/YOUR_TOKEN"
  ```
- **Character Limit**: 1000 characters maximum - message will be automatically truncated
- **Message Language**: ALL Slack messages MUST be written in Korean (한글)
- **Script Location**: `./scripts/slack-notify.sh`

### Using slack-notify.sh Script

**Usage**:
```bash
./scripts/slack-notify.sh "메시지 내용" [status]
```

**Status Options**:
- `success` - Task completed successfully (green, ✅)
- `error` - Task failed or error occurred (red, ❌)
- `warning` - Warning or requires attention (orange, ⚠️)
- `info` - General information (blue, ℹ️) [default]

**Examples**:
```bash
# Task completion
./scripts/slack-notify.sh "Task 2.3 완료 - 사용자 인증 API 구현 완료, 테스트: 23개 통과, 커밋: a1b2c3d" "success"

# Task failure
./scripts/slack-notify.sh "Task 2.1 실패 - API 연동 실패 (timeout). 대안 제시 필요" "error"

# Better approach suggestion
./scripts/slack-notify.sh "더 나은 방법 제안 - 비동기 처리로 성능 3배 향상 가능" "info"
```

**Automatic Information Included**:
- Project path (automatically detected from `pwd`)
- Timestamp (automatically added)
- Status indicator with color coding
- Emoji based on status type

## Phase Sizing Guidelines

**Small Scope** (2-3 phases, 3-6 hours total):
- Single component or simple feature
- Minimal dependencies
- Clear requirements
- Example: Add dark mode toggle, create new form component

**Medium Scope** (4-5 phases, 8-15 hours total):
- Multiple components or moderate feature
- Some integration complexity
- Database changes or API work
- Example: User authentication system, search functionality

**Large Scope** (6-7 phases, 15-25 hours total):
- Complex feature spanning multiple areas
- Significant architectural impact
- Multiple integrations
- Example: AI-powered search with embeddings, real-time collaboration

## Risk Assessment

Identify and document:
- **Technical Risks**: API changes, performance issues, data migration
- **Dependency Risks**: External library updates, third-party service availability
- **Timeline Risks**: Complexity unknowns, blocking dependencies
- **Quality Risks**: Test coverage gaps, regression potential

For each risk, specify:
- Probability: Low/Medium/High
- Impact: Low/Medium/High
- Mitigation Strategy: Specific action steps

## Rollback Strategy

For each phase, document how to revert changes if issues arise.
Consider:
- What code changes need to be undone
- Database migrations to reverse (if applicable)
- Configuration changes to restore
- Dependencies to remove

## Test Specification Guidelines

### Test-First Development Workflow

**For Each Feature Component**:
1. **Specify Test Cases** (before writing ANY code)
   - What inputs will be tested?
   - What outputs are expected?
   - What edge cases must be handled?
   - What error conditions should be tested?

2. **Write Tests** (Red Phase)
   - Write tests that WILL fail
   - Verify tests fail for the right reason
   - Run tests to confirm failure
   - Commit failing tests to track TDD compliance

3. **Implement Code** (Green Phase)
   - Write minimal code to make tests pass
   - Run tests frequently (every 2-5 minutes)
   - Stop when all tests pass
   - No additional functionality beyond tests

4. **Refactor** (Blue Phase)
   - Improve code quality while tests remain green
   - Extract duplicated logic
   - Improve naming and structure
   - Run tests after each refactoring step
   - Commit when refactoring complete

### Unit Test Production Code Requirements

**CRITICAL PRINCIPLE**: Unit tests MUST test actual production code, not test-specific implementations.

**Requirements**:
1. **Import Production Code**: All unit tests must import functions/classes from production directories (`src/`, `lib/`, `app/`, etc.)
2. **No Test-Local Implementations**: NEVER define production functions/classes inside test files
3. **Production Usage Verification**: All tested code must be actually used in the production application
4. **Import Path Validation**: Test imports must point to production modules, not test utilities

**Correct vs Incorrect Examples**:

✅ **CORRECT - Testing Actual Production Code**:
```python
# test/unit/payment/test_processor.py
from src.payment.processor import ProcessPayment  # Import from production

def test_payment_processing():
    processor = ProcessPayment()  # Use actual production class
    result = processor.charge(amount=100)
    assert result.success == True
```

❌ **WRONG - Test-Specific Implementation**:
```python
# test/unit/payment/test_processor.py
# Defining production code in test file - NEVER DO THIS
class ProcessPayment:
    def charge(self, amount):
        return {"success": True}

def test_payment_processing():
    processor = ProcessPayment()  # Testing code that doesn't exist in production
    result = processor.charge(amount=100)
    assert result["success"] == True
```

**Verification Steps Before Committing Tests**:
1. ✅ Check all `import` statements point to production code paths
2. ✅ Search production codebase for tested function/class definitions
3. ✅ Confirm tested code is imported in application entry points (`main.py`, `app.js`, etc.)
4. ✅ Verify no function/class definitions exist in test files (except test fixtures/helpers)

**Common Anti-Patterns to AVOID**:
- ❌ Implementing entire classes in test files instead of importing from `src/`
- ❌ Writing tests that pass but code never runs in production
- ❌ Creating mock implementations that completely replace production code (use stubs for dependencies only)
- ❌ Testing utility functions defined only in test helper files

**Production Code Verification Commands**:
```bash
# Find test files with suspicious class/function definitions
grep -r "^class\|^def\|^function" test/ --include="*.py" --include="*.js" --include="*.ts"

# Verify imports in test files point to production
grep -r "from src\|import.*src\|require.*src" test/

# Check if tested code exists in production
grep -r "class ProcessPayment\|def process_payment" src/ lib/ app/
```

### Test Types

**Unit Tests**:
- **Target**: Individual functions, methods, classes
- **Dependencies**: None or mocked/stubbed
- **Speed**: Fast (<100ms per test)
- **Isolation**: Complete isolation from external systems
- **Coverage**: ≥80% of business logic

**Integration Tests**:
- **Target**: Interaction between components/modules
- **Dependencies**: May use real dependencies
- **Speed**: Moderate (<1s per test)
- **Isolation**: Tests component boundaries
- **Coverage**: Critical integration points

**End-to-End (E2E) Tests**:
- **Target**: Complete user workflows
- **Dependencies**: Real or near-real environment
- **Speed**: Slow (seconds to minutes)
- **Isolation**: Full system integration
- **Coverage**: Critical user journeys

### Test Coverage Calculation

**Coverage Thresholds** (adjust for your project):
- **Business Logic**: ≥90% (critical code paths)
- **Data Access Layer**: ≥80% (repositories, DAOs)
- **API/Controller Layer**: ≥70% (endpoints)
- **UI/Presentation**: Integration tests preferred over coverage

**Coverage Commands by Ecosystem**:
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

### Common Test Patterns

**Arrange-Act-Assert (AAA) Pattern**:
```
test 'description of behavior':
  // Arrange: Set up test data and dependencies
  input = createTestData()

  // Act: Execute the behavior being tested
  result = systemUnderTest.method(input)

  // Assert: Verify expected outcome
  assert result == expectedOutput
```

**Given-When-Then (BDD Style)**:
```
test 'feature should behave in specific way':
  // Given: Initial context/state
  given userIsLoggedIn()

  // When: Action occurs
  when userClicksButton()

  // Then: Observable outcome
  then shouldSeeConfirmation()
```

**Mocking/Stubbing Dependencies**:
```
test 'component should call dependency':
  // Create mock/stub
  mockService = createMock(ExternalService)
  component = new Component(mockService)

  // Configure mock behavior
  when(mockService.method()).thenReturn(expectedData)

  // Execute and verify
  component.execute()
  verify(mockService.method()).calledOnce()
```

### Test Documentation in Plan

**In each phase, specify**:
1. **Test File Location**: Exact path where tests will be written
2. **Test Scenarios**: List of specific test cases
3. **Expected Failures**: What error should tests show initially?
4. **Coverage Target**: Percentage for this phase
5. **Dependencies to Mock**: What needs mocking/stubbing?
6. **Test Data**: What fixtures/factories are needed?

## Supporting Files Reference
- [plan-template.md](plan-template.md) - Complete plan document template
