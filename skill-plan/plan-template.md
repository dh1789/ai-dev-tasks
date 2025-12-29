# Implementation Plan: [Feature Name]

**Status**: 🔄 계획 수립 완료
**생성일**: YYYY-MM-DD
**예상 완료**: YYYY-MM-DD
**프로젝트 타입**: [자동 감지됨: Ruby/Node.js/C++/Python]
**언어/프레임워크**: [예: Ruby 3.3.x + Rails 8.0.x / TypeScript 5.x + Node.js 20+ / C++23 / Python 3.12+]
**실행 환경**: [로컬 / Docker (C++ 전용)]

---

**⚠️ 핵심 지침**: 각 Phase 완료 후 반드시 수행:
1. ✅ 완료된 태스크 체크박스 체크
2. 🧪 모든 품질 게이트 검증 명령어 실행
3. ⚠️ 모든 품질 게이트 항목 통과 확인
4. 📅 상단 "생성일" 업데이트
5. 📝 "구현 노트" 섹션에 학습 내용 기록
6. ➡️ 그 후에만 다음 Phase로 진행

⛔ **품질 게이트를 건너뛰거나 실패한 체크와 함께 진행하지 마세요**

---

## 📋 개요

### 기능 설명
[기능이 무엇을 하는지, 왜 필요한지]

### 성공 기준
- [ ] [측정 가능한 기준 1]
- [ ] [측정 가능한 기준 2]
- [ ] [측정 가능한 기준 3]

### 사용자 영향
[사용자에게 어떤 가치를 제공하는지]

---

## 🏗️ 아키텍처 결정사항

| 결정사항 | 근거 | 트레이드오프 |
|---------|------|-------------|
| [결정 1: 예: 멀티스레드 사용] | [이유: 성능 향상] | [장점: 빠름 / 단점: 복잡성 증가] |
| [결정 2: 예: 헤더 전용 라이브러리] | [이유: 배포 단순화] | [장점: 쉬운 통합 / 단점: 컴파일 시간 증가] |

### 주요 컴포넌트

#### 컴포넌트 1: [이름]
- **책임**: [무엇을 하는가]
- **인터페이스**: [API 또는 주요 메서드]
- **의존성**: [다른 컴포넌트]

#### 컴포넌트 2: [이름]
- **책임**: [무엇을 하는가]
- **인터페이스**: [API 또는 주요 메서드]
- **의존성**: [다른 컴포넌트]

---

## 📦 의존성

### 필수 의존성
- [ ] [라이브러리 1]: 버전 X.Y.Z (목적)
- [ ] [라이브러리 2]: 버전 X.Y.Z (목적)

### 빌드 전 요구사항 (언어별)

**Ruby/Rails 프로젝트:**
- [ ] Ruby 및 Bundler 설치 확인
- [ ] Gemfile 업데이트
- [ ] 테스트 디렉토리 구조 생성 (test/ 또는 spec/)

**Node.js/TypeScript 프로젝트:**
- [ ] Node.js 및 패키지 매니저 설치 확인
- [ ] package.json 업데이트
- [ ] 테스트 디렉토리 구조 생성 (test/ 또는 __tests__/)

**C++ 프로젝트:**
- [ ] Docker 컨테이너 실행 중
- [ ] CMakeLists.txt 업데이트
- [ ] 테스트 디렉토리 구조 생성 (test/)

### 테스트 파일 구조 및 실행 방법

**Ruby/Rails 프로젝트:**
- **테스트 파일 위치**: `test/` 또는 `spec/` 디렉토리
- **파일명 규칙**: `*_test.rb` (Minitest) 또는 `*_spec.rb` (RSpec)
- **테스트 실행**: `bundle exec rails test` 또는 `bundle exec rspec`
- **특정 파일 실행**: `bundle exec rails test test/models/user_test.rb`
- **특정 테스트**: `bundle exec rails test test/models/user_test.rb:23` (줄 번호 지정)

**Node.js/TypeScript 프로젝트:**
- **테스트 파일 위치**: `__tests__/` 디렉토리 또는 소스 파일과 같은 위치
- **파일명 규칙**: `*.test.ts`, `*.test.js`, `*.spec.ts`, `*.spec.js`
- **테스트 실행**: `npm test` 또는 `pnpm test` 또는 `yarn test`
- **특정 파일 실행**: `npm test -- path/to/file.spec.ts`
- **Watch 모드**: `npm test -- --watch`

**C++ 프로젝트:**
- **테스트 파일 위치**: `test/unit/`, `test/integration/`
- **파일명 규칙**: `*_test.cpp`
- **테스트 실행 (기본)**: `docker exec gcc15.1_22.04 bash -c "cd /workspace/build && ./test/unit/*_test"`
- **테스트 실행 (XML 출력 - CI/CD용)**: `docker exec gcc15.1_22.04 bash -c "cd /workspace/build && ./test/unit/*_test --gtest_output=xml"`
- **특정 테스트**: `./test/unit/my_test --gtest_filter=TestName*` (Google Test 필터)
- **상세 출력**: `./test/unit/*_test --gtest_verbose`

**Google Test 출력 형식 가이드:**
- `--gtest_output=xml`: CI/CD 파이프라인에서 사용 (테스트 결과를 XML로 저장)
- `--gtest_output=json`: JSON 형식 출력 (자동화 도구 통합용)
- 출력 형식 없음: 로컬 개발시 콘솔 출력 (사람이 읽기 쉬움)

**Python 프로젝트:**
- **테스트 파일 위치**: `tests/` 디렉토리
- **파일명 규칙**: `test_*.py` 또는 `*_test.py`
- **테스트 실행**: `pytest` 또는 `python -m pytest`
- **특정 파일 실행**: `pytest tests/test_module.py`
- **특정 테스트**: `pytest tests/test_module.py::test_function_name`

**공통 노트:**
- 단위 테스트는 테스트하는 코드 파일과 같은 디렉토리 또는 가까운 위치에 배치
- 모든 테스트는 프로덕션 코드를 import/include하여 사용
- 테스트 파일 내에서 프로덕션 코드를 정의하지 말 것

---

## 🧪 전체 테스트 전략

### 테스트 피라미드 (이 기능)

```
     /\        인수 테스트 (E2E)
    /  \       - [X개 시나리오]
   /----\
  /      \     시나리오 테스트
 /--------\    - [Y개 시나리오]
/          \
/------------\  통합 테스트
/              \ - [Z개 케이스]
/----------------\
/                  \ 단위 테스트
/____________________\ - [W개 케이스]
```

### 테스트 유형별 목표 (언어별 도구)

**Ruby/Rails 프로젝트:**
| 유형 | 개수 | 커버리지 | 도구 |
|-----|------|---------|------|
| 단위 테스트 | [예: 50개] | 85% | Minitest / RSpec |
| 통합 테스트 | [예: 15개] | 70% | Minitest + Fixtures |
| 시나리오 테스트 | [예: 8개] | - | Minitest / RSpec |
| 인수 테스트 | [예: 3개] | - | Minitest + Capybara / Playwright |

**Node.js/TypeScript 프로젝트:**
| 유형 | 개수 | 커버리지 | 도구 |
|-----|------|---------|------|
| 단위 테스트 | [예: 50개] | 85% | Jest / Vitest |
| 통합 테스트 | [예: 15개] | 70% | Jest / Vitest |
| 시나리오 테스트 | [예: 8개] | - | Jest / Vitest |
| 인수 테스트 | [예: 3개] | - | Playwright / Cypress |

**C++ 프로젝트:**
| 유형 | 개수 | 커버리지 | 도구 |
|-----|------|---------|------|
| 단위 테스트 | [예: 50개] | 85% | Google Test |
| 통합 테스트 | [예: 15개] | 70% | Google Test + Mock |
| 시나리오 테스트 | [예: 8개] | - | Google Test |
| 인수 테스트 | [예: 3개] | - | Google Test + 실제 환경 |
| 벤치마크 | [예: 5개] | - | Google Benchmark |

### 테스트 케이스 분류

**모든 테스트에 포함:**
- ✅ **Happy Path**: 정상 동작 경로
- 🔶 **Boundary Cases**: 경계값 (0, max, min, empty, null)
- ❌ **Exception Cases**: 예외 및 오류 처리
- 🔀 **Edge Cases**: 특수하거나 드문 상황

### 품질 게이트 (각 Phase - 언어별)

**공통 (모든 언어):**
- [ ] 모든 테스트 통과 (100%)
- [ ] 커버리지 ≥ 80%

**Ruby/Rails 프로젝트:**
- [ ] Bundle install 성공
- [ ] `bundle exec rails test` 또는 `bundle exec rake test` 통과
- [ ] RuboCop 검사 통과 (코드 스타일)
- [ ] Brakeman 검사 통과 (보안 취약점)
- [ ] Bundle Audit 통과 (의존성 보안)
- [ ] SimpleCov 커버리지 ≥ 80%

**검증 명령어 (Ruby):**
```bash
./scripts/ruby-quality-check.sh
```

**Node.js/TypeScript 프로젝트:**
- [ ] 의존성 설치 성공 (npm/yarn/pnpm install)
- [ ] TypeScript 타입 체크 통과 (tsconfig.json 있는 경우)
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용
- [ ] 테스트 통과 (Jest/Vitest)
- [ ] 커버리지 ≥ 80%
- [ ] 빌드 성공 (build 스크립트 있는 경우)

**검증 명령어 (Node.js):**
```bash
./scripts/node-quality-check.sh
```

**C++ 프로젝트:**
- [ ] 빌드 성공 (Docker 내부)
- [ ] clang-tidy 통과
- [ ] cppcheck 통과
- [ ] clang-format 적용됨
- [ ] Valgrind 통과 (메모리 누수 0)
- [ ] AddressSanitizer 통과
- [ ] ThreadSanitizer 통과 (멀티스레드 사용시)
- [ ] UndefinedBehaviorSanitizer 통과

**검증 명령어 (C++):**
```bash
# gcc15.1_22.04 인스턴스 내부에서 실행
docker exec gcc15.1_22.04 bash -c "cd /workspace && ./scripts/cpp-quality-check.sh"
docker exec gcc15.1_22.04 bash -c "cd /workspace && ./scripts/cpp-memory-check.sh all"
```

---

## 🚀 구현 Phase

### Phase 1: [Foundation - 기반 구조]
**목표**: [구체적인 목표]
**예상 시간**: X시간
**복잡도**: 낮음/중간/높음
**TDD**: 선택적/적용/필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 1.1**: [테스트 설명]
  - 파일: `test/unit/[component]_test.cpp`
  - 예상 결과: 실패 (기능 미구현)
  - 테스트 케이스:
    - ✅ Happy: [정상 동작]
    - 🔶 Boundary: [경계값]
    - ❌ Exception: [오류 처리]

- [ ] **Test 1.2**: [통합 테스트]
  - 파일: `test/integration/[feature]_test.cpp`
  - 예상 결과: 실패
  - Mock 필요: [의존성 리스트]

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 1.3**: [구현 작업]
  - 파일: `src/[component].cpp`, `include/[component].h`
  - 목표: Test 1.1 통과
  - 최소 구현만 수행

- [ ] **Task 1.4**: [통합 코드]
  - 파일: `src/[integration].cpp`
  - 목표: Test 1.2 통과

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 1.5**: 리팩토링
  - 중복 코드 제거 (DRY)
  - 네이밍 개선
  - 주석 추가
  - 성능 최적화 (필요시)
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 2로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성

**빌드 & 테스트 (언어별):**

*Ruby/Rails:*
```bash
bundle exec rails test  # 또는 bundle exec rake test
```

*Node.js/TypeScript:*
```bash
npm test  # 또는 pnpm test, yarn test
```

*C++:*
```bash
docker exec gcc15.1_22.04 bash -c "cd /workspace/build && ninja && ./test/unit/*_test"
```

**품질 검사 (언어별):**
- [ ] 해당 언어별 품질 검사 스크립트 실행 (위 "품질 게이트" 섹션 참조)

**문서화:**
- [ ] 코드 주석 추가
- [ ] API 문서 업데이트 (필요시)

**커밋:**
- [ ] 변경사항 스테이징
  ```bash
  git add src/ test/ include/
  ```
- [ ] 커밋 (호스트에서)
  ```bash
  git commit -m "feat(phase-1): [요약]

  - [변경사항 1]
  - [변경사항 2]
  - 테스트: [테스트 결과]
  - 커버리지: [퍼센트]%

  Phase 1/X 완료"
  ```

**Slack 알림:**
- [ ] Phase 완료 알림 전송
  ```bash
  ./scripts/slack-notify.sh "Phase 1 완료 ✅ - [기능명]" success
  ```

---

### Phase 2: [Core Logic - 핵심 로직]
**목표**: [구체적인 목표]
**예상 시간**: X시간
**복잡도**: 높음
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase**
- [ ] **Test 2.1**: [복잡한 로직 테스트]
  - 모든 경로 테스트
  - 모든 예외 상황 테스트

**🟢 GREEN Phase**
- [ ] **Task 2.2**: [로직 구현]
  - 최소 코드로 통과

**🔵 REFACTOR Phase**
- [ ] **Task 2.3**: 리팩토링
  - 알고리즘 최적화
  - 가독성 개선

#### Quality Gate ✋
[Phase 1과 동일한 체크리스트]

---

### Phase 3: [Integration - 통합]
**목표**: [구체적인 목표]
**예상 시간**: X시간
**복잡도**: 중간
**TDD**: 적용
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase**
- [ ] **Test 3.1**: [통합 테스트]
  - 컴포넌트 간 상호작용
  - 시나리오 테스트

**🟢 GREEN Phase**
- [ ] **Task 3.2**: [통합 코드]

**🔵 REFACTOR Phase**
- [ ] **Task 3.3**: [에러 핸들링 개선]

#### Quality Gate ✋
[Phase 1과 동일한 체크리스트]

---

### Phase 4: [Acceptance - 인수 테스트]
**목표**: 실제 사용 시나리오 검증
**예상 시간**: X시간
**복잡도**: 중간
**상태**: ⏳ 대기 중

#### Tasks

**인수 테스트**
- [ ] **Test 4.1**: E2E 시나리오 1
  - [사용자 관점 테스트]

- [ ] **Test 4.2**: E2E 시나리오 2
  - [실제 환경 테스트]

**성능 테스트**
- [ ] **Benchmark 4.3**: [성능 벤치마크]
  - Google Benchmark 사용
  - 목표: [응답시간] < Xms
  - 목표: [처리량] > Y ops/sec

#### Quality Gate ✋
[Phase 1과 동일 + 성능 기준]

---

## ⚠️ 위험 요소

| 위험 | 확률 | 영향 | 완화 전략 |
|-----|------|------|----------|
| [위험 1: 예: 멀티스레드 데드락] | 중간 | 높음 | TSan 필수 실행, 코드 리뷰 |
| [위험 2: 예: 성능 목표 미달] | 낮음 | 중간 | 조기 벤치마크, 프로파일링 |
| [위험 3: 예: 메모리 누수] | 낮음 | 높음 | Valgrind + ASan 필수 |

---

## 🔄 롤백 전략

### Phase 1 실패시
- 커밋 되돌리기: `git revert [commit-hash]`
- 영향 범위: [설명]

### Phase 2 실패시
- Phase 1 상태로 복구
- 재시도 전략: [설명]

### Phase 3 실패시
- Phase 2 상태로 복구
- 대안: [설명]

---

## 📊 진행 상황

### 완료율
- **Phase 1**: ⏳ 0% | 🔄 50% | ✅ 100%
- **Phase 2**: ⏳ 0% | 🔄 50% | ✅ 100%
- **Phase 3**: ⏳ 0% | 🔄 50% | ✅ 100%
- **Phase 4**: ⏳ 0% | 🔄 50% | ✅ 100%

**전체 진행도**: X%

### 시간 추적
| Phase | 예상 | 실제 | 차이 |
|-------|------|------|------|
| Phase 1 | Xh | - | - |
| Phase 2 | Xh | - | - |
| Phase 3 | Xh | - | - |
| Phase 4 | Xh | - | - |
| **합계** | Xh | - | - |

---

## 📝 구현 노트

### 학습한 내용
- [구현 중 발견한 인사이트]

### 해결한 문제
- **문제 1**: [설명] → [해결방법]
- **문제 2**: [설명] → [해결방법]

### 블로커
- **블로커 1**: [설명] → [해결상태]

### 향후 개선 사항
- [추후 리팩토링 또는 최적화할 부분]

---

## 📚 참고 자료

### 문서
- [C++ Reference](https://en.cppreference.com/)
- [Google Test 문서](https://google.github.io/googletest/)
- [프로젝트 내부 문서]

### 관련 이슈
- Issue #X: [설명]
- PR #Y: [설명]

---

## 📖 TDD 예제 워크플로우

### 예제: 사용자 인증 기능 추가

**Phase 1: RED (실패하는 테스트 작성)**

```
# 의사코드 - 테스팅 프레임워크에 맞게 조정하세요

test "사용자 자격증명 검증":
  // Arrange
  authService = new AuthService(mockDatabase)
  validCredentials = {username: "user", password: "pass"}

  // Act
  result = authService.authenticate(validCredentials)

  // Assert
  expect(result.isSuccess).toBe(true)
  expect(result.user).toBeDefined()
  // 테스트 실패 - AuthService가 아직 존재하지 않음
```

**Phase 2: GREEN (최소 구현)**

```
class AuthService:
  function authenticate(credentials):
    // 테스트를 통과시키는 최소 코드
    user = database.findUser(credentials.username)
    if user AND user.password == credentials.password:
      return Success(user)
    return Failure("Invalid credentials")
    // 테스트 통과 - 최소 기능이 작동함
```

**Phase 3: REFACTOR (설계 개선)**

```
class AuthService:
  function authenticate(credentials):
    // 검증 추가
    if not this.validateCredentials(credentials):
      return Failure("Invalid input")

    // 오류 처리 추가
    try:
      user = database.findUser(credentials.username)

      // 안전한 비밀번호 비교 사용
      if user AND this.secureCompare(user.password, credentials.password):
        return Success(user)

      return Failure("Invalid credentials")
    catch DatabaseError as error:
      logger.error(error)
      return Failure("Authentication failed")
    // 테스트 여전히 통과 - 코드 품질 개선됨
```

### TDD Red-Green-Refactor 사이클 시각화

```
Phase 1: 🔴 RED
├── 기능 X에 대한 테스트 작성
├── 테스트 실행 → 실패 ❌
└── 커밋: "기능 X에 대한 실패하는 테스트 추가"

Phase 2: 🟢 GREEN
├── 최소 코드 작성
├── 테스트 실행 → 통과 ✅
└── 커밋: "테스트를 통과하도록 X 구현"

Phase 3: 🔵 REFACTOR
├── 코드 품질 개선
├── 테스트 실행 → 여전히 통과 ✅
├── 헬퍼 메서드 추출
├── 테스트 실행 → 여전히 통과 ✅
├── 네이밍 개선
├── 테스트 실행 → 여전히 통과 ✅
└── 커밋: "더 나은 설계를 위해 X 리팩토링"

다음 기능으로 반복 →
```

### 이 접근 방식의 장점

**안전성**: 테스트가 즉시 회귀를 포착
**설계**: 테스트가 API 설계를 먼저 생각하도록 강제
**문서화**: 테스트가 예상 동작을 문서화
**자신감**: 기능을 망칠 걱정 없이 리팩토링
**품질**: 처음부터 높은 코드 커버리지
**디버깅**: 실패가 정확한 문제 영역을 가리킴

---

## ✅ 최종 체크리스트

**구현 완료 전 확인:**
- [ ] 모든 Phase 완료
- [ ] 모든 테스트 통과 (단위/통합/시나리오/인수)
- [ ] 커버리지 ≥ 80%
- [ ] 메모리 검사 통과 (Valgrind + ASan + TSan + UBSan)
- [ ] 정적 분석 통과 (clang-tidy + cppcheck)
- [ ] 코드 포매팅 적용 (clang-format)
- [ ] 성능 벤치마크 목표 달성
- [ ] 문서화 완료
- [ ] PR 생성 준비 완료
- [ ] 이해관계자 승인

---

**계획 상태**: 🔄 구현 대기 중
**다음 액션**: `/skill implement "[feature-name]"`
