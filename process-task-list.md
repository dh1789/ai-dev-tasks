# Task List Management

Guidelines for managing task lists in markdown files to track progress on completing a PRD

## Task Implementation
- **One sub-task at a time:** Do **NOT** start the next sub‑task until you ask the user for permission and they say "yes" or "y"
- **Test Execution Policy:**
  - **NEVER skip tests**: All tests must be executed completely, even if they take time
  - **Timeout setting**: Set test timeout to 30 minutes (1800000ms) to allow sufficient execution time
  - **Wait for completion**: Always wait for full test suite to complete before proceeding
  - **No shortcuts**: Do not use grep, tail, or other methods to skip test execution
- **Unit Test Implementation Requirements** (CRITICAL):
  - **Use Production Code ONLY**: Unit tests MUST import and use actual production functions/classes from `src/` or production directories
  - **NO Test-Specific Implementations**: NEVER create test-specific versions of production code inside test files
  - **Production Code Verification**: All tested functions/classes MUST actually be used in production application code
  - **Import Validation**:
    - ✅ CORRECT: `from src.payment import process_payment` → tests actual production code
    - ❌ WRONG: Define `process_payment()` inside test file → tests unused code
  - **Common Mistakes to AVOID**:
    - Implementing functions/classes inside test files that don't exist in production
    - Writing tests that pass but test code never used in actual application
    - Creating mock implementations that replace production code entirely
  - **Verification Steps**:
    1. Check all test imports point to production code paths
    2. Verify tested functions/classes exist in `src/` or production directories
    3. Confirm tested code is actually imported and used in application entry points
    4. Search codebase to ensure tested code has real usage beyond tests
- **Completion protocol:**
  1. When you finish a **sub‑task**, immediately mark it as completed by changing `[ ]` to `[x]`.
  2. If **all** subtasks underneath a parent task are now `[x]`, follow this sequence:
    - **First**: Run the full test suite (`pytest`, `npm test`, `bin/rails test`, etc.) with 30-minute timeout
    - **Only if all tests pass**: Stage changes (`git add .`)
    - **Clean up**: Remove any temporary files and temporary code before committing
    - **Commit**: Use a descriptive commit message that:
      - Uses conventional commit format (`feat:`, `fix:`, `refactor:`, etc.)
      - Summarizes what was accomplished in the parent task
      - Lists key changes and additions
      - References the task number and PRD context
      - **Formats the message as a single-line command using `-m` flags**, e.g.:

        ```
        git commit -m "feat: add payment validation logic" -m "- Validates card type and expiry" -m "- Adds unit tests for edge cases" -m "Related to T123 in PRD"
        ```
  3. Once all the subtasks are marked completed and changes have been committed, mark the **parent task** as completed.
- Stop after each sub‑task and wait for the user's go‑ahead.

## Task List Maintenance

1. **Update the task list as you work:**
   - Mark tasks and subtasks as completed (`[x]`) per the protocol above.
   - Add new tasks as they emerge.

2. **Maintain the "Relevant Files" section:**
   - List every file created or modified.
   - Give each file a one‑line description of its purpose.

## Debug Logging Requirements

**MANDATORY**: All production code must include comprehensive debug logging to facilitate troubleshooting and issue resolution.

### Logging Standards

**Logging Levels:**
- `DEBUG`: 상세한 진단 정보 (함수 파라미터, 중간 값, 개발/디버깅용)
- `INFO`: 일반적인 정보성 메시지 (정상 실행 흐름, 주요 이벤트)
- `WARN`: 잠재적 문제 경고 (deprecation, 복구 가능한 이슈)
- `ERROR`: 실제 오류 발생 (예외, 실패, 복구 필요한 상황)

**필수 로깅 위치:**

1. **함수 진입/종료** (복잡한 연산의 경우):
   ```python
   logger.debug(f"함수 시작: process_payment, transaction_id={transaction.id}, amount={transaction.amount}")
   try:
       result = payment_gateway.charge(transaction)
       logger.info(f"결제 성공: transaction_id={transaction.id}")
       return result
   except PaymentError as e:
       logger.error(f"결제 실패: transaction_id={transaction.id}, error={e}", exc_info=True)
       raise
   ```

2. **상태 변경** (중요한 상태 전환):
   ```python
   logger.info(f"주문 상태 변경: order_id={order.id}, {old_status} → {new_status}")
   ```

3. **외부 시스템 연동**:
   ```python
   logger.debug(f"API 요청: endpoint={url}, method={method}, params={params}")
   response = api_call()
   logger.debug(f"API 응답: status={response.status_code}, body={response.body[:100]}")
   ```

4. **비즈니스 로직 의사결정**:
   ```python
   if user.is_premium():
       logger.debug(f"프리미엄 할인 적용: user_id={user.id}")
   ```

5. **예외 처리** (모든 try-except 블록):
   ```python
   try:
       risky_operation()
   except Exception as e:
       logger.error(f"작업 실패: context={context}, error={e}", exc_info=True)
       raise
   ```

**개발자 친화적 로깅 원칙:**
- ✅ 관련 컨텍스트 포함 (ID, 파라미터, 상태값)
- ✅ 구조화된 로깅 사용 (JSON 형식 권장)
- ✅ 검색 가능하고 실행 가능한 정보 제공
- ✅ 타임스탬프 자동 포함 (로깅 프레임워크)
- ❌ 민감 정보 로깅 금지 (비밀번호, 토큰, API 키, 신용카드, 개인정보)

**보안 고려사항:**
```python
# ❌ 절대 로깅하면 안되는 것
logger.debug(f"User login: password={password}")  # 비밀번호
logger.info(f"API key: {api_key}")  # API 키
logger.debug(f"Credit card: {card_number}")  # 신용카드

# ✅ 올바른 로깅
logger.info(f"User login: email={email.split('@')[1]}")  # 도메인만
logger.debug(f"API call authenticated: key_id={key_id[:8]}...")  # 일부만
logger.info(f"Payment processed: card_last4={card_number[-4:]}")  # 마지막 4자리만
```

### Debugging Protocol

**이슈 발생 시 디버깅 절차:**

1. **로그 우선 검토**:
   - 먼저 로그 파일을 확인
   - 타임스탬프로 이슈 발생 시점 특정
   - ERROR 레벨 로그부터 역추적

2. **컨텍스트 분석**:
   - 관련 ID 추출 (user_id, transaction_id 등)
   - 해당 ID로 전체 로그 필터링
   - 실행 흐름 재구성

3. **원인 파악**:
   - 로그의 DEBUG 레벨까지 확인
   - 의사결정 지점 확인
   - 예상치 못한 분기 식별

4. **재현 및 수정**:
   - 로그 기반으로 재현 시나리오 작성
   - 필요시 추가 로그 삽입
   - 수정 후 로그로 검증

**로그 분석 도구 활용:**
```bash
# 특정 에러 검색
grep "ERROR" logs/application.log

# 특정 ID 추적
grep "transaction_id=12345" logs/application.log

# 시간대별 필터링
grep "2025-12-29 14:" logs/application.log

# 실시간 모니터링
tail -f logs/application.log | grep "ERROR\|WARN"
```

### Quality Gate Addition

**커밋 전 로깅 검증:**
- [ ] 모든 프로덕션 코드에 적절한 디버그 로그 추가됨
- [ ] 로그 레벨이 적절하게 사용됨 (DEBUG/INFO/WARN/ERROR)
- [ ] 복잡한 함수에 진입/종료 로그 있음
- [ ] 모든 예외 처리에 ERROR 로그 있음
- [ ] 민감 정보가 로그에 포함되지 않음
- [ ] 로그가 개발자 친화적이고 실행 가능함
- [ ] 로그에 충분한 컨텍스트 포함됨

**로그 검증 명령어:**
```bash
# 새로 추가된 코드의 로그 확인
grep -r "logger\.\|log\." src/[your-new-files]

# 민감 정보 패턴 체크
grep -ri "password\|token\|secret\|api_key" src/ | grep "logger\|log"

# 로그 레벨 사용 확인
grep -r "logger\." src/ | grep -E "debug|info|warn|error"
```

## Slack Notification Requirements

**MANDATORY**: Send Slack webhook notifications in the following situations:

1. **When a task is completed:**
   - Include project name/path, task number, and summary of what was accomplished
   - Mention test results and commit hash

2. **When a task fails or requires compromise:**
   - Explain the failure reason clearly
   - Propose alternatives (skip, hardcode, simplify, or reduce scope)
   - Wait for user feedback before proceeding

3. **When suggesting a better approach:**
   - Explain why the alternative approach is recommended
   - Provide clear reasoning and benefits
   - Wait for user approval before changing course

### Slack Webhook Configuration

- **Webhook Script:** `./scripts/slack-notify.sh`
- **Environment Variable:** `SLACK_WEBHOOK_URL` (configured in `~/.zshrc` or `~/.bashrc`)
- **Character Limit:** 1000 characters maximum - summarize appropriately
- **Message Language:** ALL Slack messages MUST be written in Korean (한글)
- **Message Format:** Always include:
  - Project name or path identifier
  - Current task number and description
  - Status or action required
  - Relevant details (commit hash, test results, error summary, etc.)

### Example Slack Message Format

```bash
./scripts/slack-notify.sh "**[FIRE]** Task 5.0 완료 ✅

**작업:** 증자/감자 현황 API 구현
**경로:** /Users/idongho/proj/fire
**테스트:** 84개 통과, 149 assertions
**커밋:** 12699a1

모든 서브태스크 완료. 다음 지시 대기 중입니다." "success"
```

## AI Instructions

When working with task lists, the AI must:

1. Regularly update the task list file after finishing any significant work.
2. Follow the completion protocol:
   - Mark each finished **sub‑task** `[x]`.
   - Mark the **parent task** `[x]` once **all** its subtasks are `[x]`.
3. Add newly discovered tasks.
4. Keep "Relevant Files" accurate and up to date.
5. Before starting work, check which sub‑task is next.
6. After implementing a sub‑task, update the file and then pause for user approval.
7. **ALWAYS send Slack notifications** as specified in the Slack Notification Requirements section above.