# Implementation Plan: 로깅 유틸리티 클래스

**Status**: 🔄 계획 수립 완료
**생성일**: 2026-03-13
**예상 완료**: 2026-03-14
**프로젝트 타입**: Node.js/TypeScript (자동 감지)
**언어/프레임워크**: TypeScript 5.x + Node.js 20+
**실행 환경**: 로컬

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
Node.js/TypeScript 프로젝트에서 사용할 로깅 유틸리티 클래스. 로그 레벨(DEBUG, INFO, WARN, ERROR)을 지원하고 콘솔 및 파일 출력을 동시에 처리할 수 있다. Transport 패턴을 통해 출력 대상을 유연하게 확장할 수 있다.

### 성공 기준
- [ ] 4개 로그 레벨(DEBUG, INFO, WARN, ERROR) 정상 동작
- [ ] 로그 레벨 필터링 정상 동작 (설정 레벨 미만의 로그 무시)
- [ ] 콘솔 출력 정상 동작
- [ ] 파일 출력 정상 동작 (비동기 쓰기)
- [ ] 테스트 커버리지 >= 90%
- [ ] TypeScript strict 모드 컴파일 통과

### 사용자 영향
개발자가 일관된 API로 로깅을 수행할 수 있어 디버깅 효율이 향상되고, 파일 출력을 통해 운영 환경에서의 로그 추적이 가능해진다.

---

## 🏗️ 아키텍처 결정사항

| 결정사항 | 근거 | 트레이드오프 |
|---------|------|-------------|
| Transport 패턴 사용 | 출력 대상 확장성 확보 | 장점: 새 Transport 추가 용이 / 단점: 초기 구조 약간 복잡 |
| 외부 의존성 없음 | 경량 유틸리티 유지 | 장점: 의존성 관리 불필요 / 단점: 고급 기능 직접 구현 |
| 비동기 파일 쓰기 | 메인 스레드 블로킹 방지 | 장점: 성능 / 단점: 로그 순서 보장에 주의 필요 |
| Enum 기반 로그 레벨 | 타입 안전성, 숫자 비교 가능 | 장점: 타입 체크 / 단점: 문자열 기반보다 약간 엄격 |

### 주요 컴포넌트

#### 컴포넌트 1: LogLevel (Enum)
- **책임**: 로그 레벨 정의 및 우선순위 관리
- **인터페이스**: `enum LogLevel { DEBUG = 0, INFO = 1, WARN = 2, ERROR = 3 }`
- **의존성**: 없음

#### 컴포넌트 2: Transport (인터페이스 + 구현체)
- **책임**: 로그 메시지를 특정 대상에 출력
- **인터페이스**: `interface Transport { log(entry: LogEntry): void; close?(): Promise<void>; }`
- **구현체**: `ConsoleTransport`, `FileTransport`
- **의존성**: Node.js fs (FileTransport만)

#### 컴포넌트 3: Logger (클래스)
- **책임**: 로그 생성, 레벨 필터링, Transport 라우팅
- **인터페이스**: `debug()`, `info()`, `warn()`, `error()`, `setLevel()`, `addTransport()`, `close()`
- **의존성**: LogLevel, Transport

---

## 📦 의존성

### 필수 의존성
- [ ] Node.js 내장 모듈: `fs`, `path`, `os` (외부 설치 불필요)

### 개발 의존성
- [ ] TypeScript: ^5.0.0 (컴파일러)
- [ ] Jest 또는 Vitest: 최신 안정 버전 (테스트)
- [ ] @types/node: 최신 (Node.js 타입)
- [ ] ESLint: 최신 (린트)
- [ ] Prettier: 최신 (포매팅)

### 빌드 전 요구사항

**Node.js/TypeScript 프로젝트:**
- [ ] Node.js 및 패키지 매니저 설치 확인
- [ ] package.json 업데이트
- [ ] 테스트 디렉토리 구조 생성 (`__tests__/` 또는 `src/**/*.test.ts`)

### 테스트 파일 구조 및 실행 방법

**Node.js/TypeScript 프로젝트:**
- **테스트 파일 위치**: `src/` 디렉토리 내 소스 파일과 같은 위치
- **파일명 규칙**: `*.test.ts`
- **테스트 실행**: `npm test` 또는 `pnpm test`
- **특정 파일 실행**: `npm test -- path/to/file.test.ts`
- **Watch 모드**: `npm test -- --watch`

### 파일 구조
```
src/
├── logger/
│   ├── index.ts              # 공개 API (re-export)
│   ├── log-level.ts          # LogLevel enum
│   ├── log-level.test.ts     # LogLevel 테스트
│   ├── types.ts              # LogEntry, LoggerOptions, Transport 인터페이스
│   ├── logger.ts             # Logger 클래스
│   ├── logger.test.ts        # Logger 테스트
│   ├── transports/
│   │   ├── index.ts          # Transport re-export
│   │   ├── console-transport.ts
│   │   ├── console-transport.test.ts
│   │   ├── file-transport.ts
│   │   └── file-transport.test.ts
│   └── formatter.ts          # 로그 포맷터
│       formatter.test.ts     # 포맷터 테스트
```

---

## 🧪 전체 테스트 전략

### 테스트 피라미드 (이 기능)

```
     /\        인수 테스트 (E2E)
    /  \       - 2개 시나리오
   /----\
  /      \     시나리오 테스트
 /--------\    - 3개 시나리오
/          \
/------------\  통합 테스트
/              \ - 5개 케이스
/----------------\
/                  \ 단위 테스트
/____________________\ - 20개 케이스
```

### 테스트 유형별 목표

**Node.js/TypeScript 프로젝트:**
| 유형 | 개수 | 커버리지 | 도구 |
|-----|------|---------|------|
| 단위 테스트 | 20개 | 90% | Jest / Vitest |
| 통합 테스트 | 5개 | 80% | Jest / Vitest |
| 시나리오 테스트 | 3개 | - | Jest / Vitest |
| 인수 테스트 | 2개 | - | Jest / Vitest |

### 테스트 케이스 분류

**모든 테스트에 포함:**
- ✅ **Happy Path**: 정상 동작 경로
- 🔶 **Boundary Cases**: 경계값 (빈 문자열, undefined, null 메타데이터)
- ❌ **Exception Cases**: 예외 및 오류 처리 (파일 쓰기 실패, 잘못된 경로)
- 🔀 **Edge Cases**: 동시 다수 로그 호출, 대용량 메시지

### 품질 게이트 (각 Phase)

**Node.js/TypeScript 프로젝트:**
- [ ] 의존성 설치 성공 (npm install)
- [ ] TypeScript 타입 체크 통과 (`npx tsc --noEmit`)
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용
- [ ] 테스트 통과 (Jest/Vitest)
- [ ] 커버리지 >= 80%
- [ ] 빌드 성공 (build 스크립트 있는 경우)

**검증 명령어 (Node.js):**
```bash
npm test
npx tsc --noEmit
npx eslint src/
npx prettier --check src/
```

---

## 🚀 구현 Phase

### Phase 1: 기반 구조 - LogLevel 및 타입 정의
**목표**: LogLevel enum, 핵심 인터페이스(LogEntry, Transport, LoggerOptions) 정의 및 테스트
**예상 시간**: 1시간
**복잡도**: 낮음
**TDD**: 적용
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 1.1**: LogLevel enum 테스트
  - 파일: `src/logger/log-level.test.ts`
  - 예상 결과: 실패 (LogLevel 미구현)
  - 테스트 케이스:
    - ✅ Happy: LogLevel 값이 DEBUG=0, INFO=1, WARN=2, ERROR=3
    - ✅ Happy: LogLevel 비교 연산 (DEBUG < INFO < WARN < ERROR)
    - 🔶 Boundary: 유효하지 않은 레벨 값 처리

- [ ] **Test 1.2**: LogEntry 타입 및 포맷터 테스트
  - 파일: `src/logger/formatter.test.ts`
  - 예상 결과: 실패 (포맷터 미구현)
  - 테스트 케이스:
    - ✅ Happy: 기본 포맷 출력 (`[timestamp] [LEVEL] message`)
    - ✅ Happy: 메타데이터 포함 포맷 출력
    - 🔶 Boundary: 빈 문자열 메시지
    - 🔶 Boundary: undefined 메타데이터
    - 🔀 Edge: 매우 긴 메시지 (10KB 이상)

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 1.3**: LogLevel enum 구현
  - 파일: `src/logger/log-level.ts`
  - 목표: Test 1.1 통과
  - 최소 구현만 수행

- [ ] **Task 1.4**: 타입 정의 및 포맷터 구현
  - 파일: `src/logger/types.ts`, `src/logger/formatter.ts`
  - 목표: Test 1.2 통과
  - LogEntry, Transport, LoggerOptions 인터페이스 정의

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 1.5**: 리팩토링
  - 타입 이름 및 주석 개선
  - 불필요한 코드 제거
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 2로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (>= 90%)

**빌드 & 테스트:**
```bash
npm test
npx tsc --noEmit
```

**품질 검사:**
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용

**문서화:**
- [ ] JSDoc 주석 추가
- [ ] 타입 export 확인

**커밋:**
- [ ] 변경사항 스테이징
  ```bash
  git add src/logger/
  ```
- [ ] 커밋
  ```bash
  git commit -m "feat(phase-1): LogLevel enum 및 핵심 타입 정의

  - LogLevel enum (DEBUG, INFO, WARN, ERROR) 구현
  - LogEntry, Transport, LoggerOptions 인터페이스 정의
  - 로그 포맷터 구현
  - 테스트: 전체 통과
  - 커버리지: 90%+

  Phase 1/4 완료"
  ```

---

### Phase 2: 콘솔 Transport 및 Logger 핵심 로직
**목표**: ConsoleTransport 구현 및 Logger 클래스의 핵심 로직(레벨 필터링, 메시지 라우팅) 구현
**예상 시간**: 2시간
**복잡도**: 중간
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 2.1**: ConsoleTransport 테스트
  - 파일: `src/logger/transports/console-transport.test.ts`
  - 예상 결과: 실패
  - 테스트 케이스:
    - ✅ Happy: INFO 레벨 로그가 stdout으로 출력
    - ✅ Happy: ERROR 레벨 로그가 stderr로 출력
    - ✅ Happy: WARN 레벨 로그가 stderr로 출력
    - 🔶 Boundary: 빈 메시지 처리
  - Mock 필요: `console.log`, `console.error`, `console.warn`

- [ ] **Test 2.2**: Logger 클래스 핵심 로직 테스트
  - 파일: `src/logger/logger.test.ts`
  - 예상 결과: 실패
  - 테스트 케이스:
    - ✅ Happy: `logger.info('메시지')` 정상 출력
    - ✅ Happy: `logger.debug('메시지')` — INFO 레벨 설정 시 출력되지 않음
    - ✅ Happy: `logger.error('메시지', { code: 500 })` 메타데이터 포함
    - ✅ Happy: `logger.setLevel(LogLevel.DEBUG)` 런타임 레벨 변경
    - 🔶 Boundary: 메타데이터 없이 호출
    - ❌ Exception: Transport 없이 Logger 생성 시 기본 ConsoleTransport 사용
    - 🔀 Edge: 연속 다수 로그 호출

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 2.3**: ConsoleTransport 구현
  - 파일: `src/logger/transports/console-transport.ts`
  - 목표: Test 2.1 통과
  - DEBUG/INFO → stdout, WARN/ERROR → stderr

- [ ] **Task 2.4**: Logger 클래스 구현
  - 파일: `src/logger/logger.ts`
  - 목표: Test 2.2 통과
  - 레벨 필터링, Transport 라우팅, 메타데이터 처리

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 2.5**: 리팩토링
  - 공통 로직 추출 (debug/info/warn/error → 내부 _log 메서드)
  - 에러 핸들링 개선
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 3으로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (>= 85%)

**빌드 & 테스트:**
```bash
npm test
npx tsc --noEmit
```

**품질 검사:**
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add src/logger/
  git commit -m "feat(phase-2): ConsoleTransport 및 Logger 핵심 로직 구현

  - ConsoleTransport 구현 (stdout/stderr 분리)
  - Logger 클래스 구현 (레벨 필터링, Transport 라우팅)
  - debug/info/warn/error 메서드 및 setLevel 구현
  - 테스트: 전체 통과
  - 커버리지: 85%+

  Phase 2/4 완료"
  ```

---

### Phase 3: FileTransport 구현
**목표**: 파일 출력 Transport 구현 (비동기 쓰기, 에러 핸들링)
**예상 시간**: 2시간
**복잡도**: 중간
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 3.1**: FileTransport 단위 테스트
  - 파일: `src/logger/transports/file-transport.test.ts`
  - 예상 결과: 실패
  - 테스트 케이스:
    - ✅ Happy: 지정 경로에 로그 파일 생성
    - ✅ Happy: 로그 메시지가 파일에 append 방식으로 기록
    - ✅ Happy: 여러 로그가 순서대로 기록
    - 🔶 Boundary: 빈 메시지 기록
    - ❌ Exception: 존재하지 않는 디렉토리 경로 → 자동 생성
    - ❌ Exception: 파일 쓰기 권한 없음 → 에러 이벤트 발생 (애플리케이션 중단 없음)
    - 🔀 Edge: close() 호출 후 추가 로그 시도 → 무시 또는 경고
  - Mock 필요: `fs.appendFile`, `fs.mkdir` (일부 테스트)
  - 테스트 데이터: 임시 디렉토리 (os.tmpdir 활용)

- [ ] **Test 3.2**: Logger + FileTransport 통합 테스트
  - 파일: `src/logger/logger.test.ts` (통합 테스트 섹션 추가)
  - 예상 결과: 실패
  - 테스트 케이스:
    - ✅ Happy: Logger에 FileTransport 추가 후 로그 기록 확인
    - ✅ Happy: ConsoleTransport + FileTransport 동시 사용
    - ✅ Happy: logger.close() 호출 시 모든 Transport 정리
    - 🔀 Edge: Transport 추가/제거 동적 변경

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 3.3**: FileTransport 구현
  - 파일: `src/logger/transports/file-transport.ts`
  - 목표: Test 3.1 통과
  - fs.appendFile 비동기 사용
  - 디렉토리 자동 생성 (fs.mkdir recursive)
  - 에러 핸들링 (파일 쓰기 실패 시 콘솔 fallback)

- [ ] **Task 3.4**: Logger에 close() 메서드 추가
  - 파일: `src/logger/logger.ts`
  - 목표: Test 3.2 통과
  - 모든 Transport의 close() 호출

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 3.5**: 리팩토링
  - FileTransport 에러 핸들링 강화
  - 쓰기 버퍼링 최적화 검토
  - Transport 공통 인터페이스 정합성 확인
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 4로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (>= 85%)

**빌드 & 테스트:**
```bash
npm test
npx tsc --noEmit
```

**품질 검사:**
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add src/logger/
  git commit -m "feat(phase-3): FileTransport 구현

  - FileTransport 비동기 파일 쓰기 구현
  - 디렉토리 자동 생성 기능
  - 에러 핸들링 (콘솔 fallback)
  - Logger.close() 메서드 추가
  - 통합 테스트 추가
  - 테스트: 전체 통과
  - 커버리지: 85%+

  Phase 3/4 완료"
  ```

---

### Phase 4: 통합 및 인수 테스트
**목표**: 실제 사용 시나리오 검증, 공개 API 정리, 인수 테스트 수행
**예상 시간**: 1.5시간
**복잡도**: 낮음
**TDD**: 적용
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 4.1**: E2E 시나리오 1 — 기본 콘솔 로깅
  - 파일: `src/logger/logger.e2e.test.ts`
  - 테스트 케이스:
    - Logger 생성 → info/debug/warn/error 호출 → 레벨 필터링 확인 → 출력 형식 확인

- [ ] **Test 4.2**: E2E 시나리오 2 — 파일 + 콘솔 동시 로깅
  - 파일: `src/logger/logger.e2e.test.ts`
  - 테스트 케이스:
    - Logger 생성 (ConsoleTransport + FileTransport) → 로그 기록 → 파일 내용 확인 → close() 호출 → 리소스 정리 확인

- [ ] **Test 4.3**: 공개 API 호환성 테스트
  - 파일: `src/logger/index.test.ts`
  - 테스트 케이스:
    - index.ts에서 export된 모든 타입/클래스 접근 가능 확인
    - 기본 사용법 동작 확인

**🟢 GREEN Phase: 구현 완료**
- [ ] **Task 4.4**: 공개 API 정리 (index.ts)
  - 파일: `src/logger/index.ts`
  - Logger, LogLevel, ConsoleTransport, FileTransport, LogEntry 등 re-export

- [ ] **Task 4.5**: JSDoc 문서화 보강
  - 모든 공개 API에 JSDoc 주석 추가
  - 사용 예제 포함

**🔵 REFACTOR Phase: 최종 정리**
- [ ] **Task 4.6**: 최종 코드 리뷰 및 정리
  - 불필요한 import 제거
  - 코드 일관성 확인
  - 라인 끝 공백 제거

#### Quality Gate ✋

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (>= 90%)

**빌드 & 테스트:**
```bash
npm test
npx tsc --noEmit
```

**품질 검사:**
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add src/logger/
  git commit -m "feat(phase-4): 통합 테스트 및 공개 API 정리

  - E2E 시나리오 테스트 추가
  - 공개 API (index.ts) 정리
  - JSDoc 문서화 완료
  - 최종 코드 정리
  - 테스트: 전체 통과
  - 커버리지: 90%+

  Phase 4/4 완료"
  ```

---

## ⚠️ 위험 요소

| 위험 | 확률 | 영향 | 완화 전략 |
|-----|------|------|----------|
| 비동기 파일 쓰기 순서 보장 실패 | 중간 | 중간 | 순차 쓰기 큐 구현, 또는 write stream 활용 |
| 파일 시스템 권한 문제 | 낮음 | 높음 | 초기화 시 쓰기 권한 확인, 에러 시 콘솔 fallback |
| 대량 로그 시 메모리 증가 | 낮음 | 중간 | 버퍼 크기 제한, flush 주기 설정 |
| TypeScript 타입 호환성 | 낮음 | 낮음 | strict 모드 사용, 타입 테스트 포함 |

---

## 🔄 롤백 전략

### Phase 1 실패시
- 커밋 되돌리기: `git revert [commit-hash]`
- 영향 범위: 타입 정의만 영향, 기존 코드에 영향 없음

### Phase 2 실패시
- Phase 1 상태로 복구: `git revert [commit-hash]`
- 재시도 전략: ConsoleTransport를 단순화하여 재구현

### Phase 3 실패시
- Phase 2 상태로 복구: `git revert [commit-hash]`
- 대안: 파일 쓰기를 동기 방식으로 우선 구현 후 비동기 전환

### Phase 4 실패시
- Phase 3 상태로 복구
- 대안: E2E 테스트 범위 축소 후 재실행

---

## 📊 진행 상황

### 완료율
- **Phase 1**: ⏳ 0%
- **Phase 2**: ⏳ 0%
- **Phase 3**: ⏳ 0%
- **Phase 4**: ⏳ 0%

**전체 진행도**: 0%

### 시간 추적
| Phase | 예상 | 실제 | 차이 |
|-------|------|------|------|
| Phase 1 | 1h | - | - |
| Phase 2 | 2h | - | - |
| Phase 3 | 2h | - | - |
| Phase 4 | 1.5h | - | - |
| **합계** | **6.5h** | - | - |

---

## 📝 구현 노트

### 학습한 내용
- (구현 중 기록)

### 해결한 문제
- (구현 중 기록)

### 블로커
- (구현 중 기록)

### 향후 개선 사항
- 로그 로테이션 지원 (일별, 크기별)
- JSON 포맷 출력 옵션
- 로그 수준별 파일 분리
- 원격 로그 전송 Transport (HTTP, Syslog)
- 구조화된 로깅 (structured logging) 강화
- Child Logger 지원 (컨텍스트 전파)

---

## 📚 참고 자료

### 문서
- [Node.js fs API](https://nodejs.org/api/fs.html)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [Jest 공식 문서](https://jestjs.io/docs/getting-started)

### 관련 패턴
- Transport 패턴 (winston 참고)
- Strategy 패턴 (출력 방식 교체)
- Observer 패턴 (다중 Transport 알림)

---

## ✅ 최종 체크리스트

**구현 완료 전 확인:**
- [ ] 모든 Phase 완료
- [ ] 모든 테스트 통과 (단위/통합/E2E)
- [ ] 커버리지 >= 90%
- [ ] TypeScript 타입 체크 통과 (`npx tsc --noEmit`)
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용
- [ ] JSDoc 문서화 완료
- [ ] 공개 API 정리 (index.ts export)
- [ ] PR 생성 준비 완료

---

## 📊 복잡도 분석

| 항목 | 점수 | 설명 |
|-----|------|------|
| 컴포넌트 수 | 6점 (3 x 2) | Logger, LogLevel, Transport(3개) |
| 외부 의존성 | 3점 (1 x 3) | Node.js fs (내장 모듈) |
| 보안 | 0점 | 보안 민감 기능 아님 |
| 성능 | 5점 | 파일 I/O 비동기 처리 필요 |
| 불명확성 | 2점 | 요구사항 비교적 명확 |
| **총점** | **16점 (중간)** | 일반 추론으로 충분, Sequential Thinking 선택적 |

**사고 모드**: 일반 추론 (복잡도 16점, 중간 범위)

---

## 💬 AskUserQuestion (시뮬레이션)

> 이 기능을 실제로 계획할 때 사용자에게 다음 질문을 할 것입니다:

1. **로그 포맷**: 텍스트 기반 포맷과 JSON 포맷 중 어떤 것을 기본으로 사용할까요?
   - **가정**: 텍스트 기반 (`[timestamp] [LEVEL] message`)

2. **로그 로테이션**: 파일 로테이션(일별, 크기별) 기능이 필요한가요?
   - **가정**: 초기 범위에서 제외 (추후 확장)

3. **비동기 처리**: 파일 쓰기 시 버퍼링/배칭을 적용할까요?
   - **가정**: 기본 비동기 append, 버퍼링은 추후 최적화

4. **기존 로깅 호환**: winston, pino 등 기존 라이브러리와의 호환성이 필요한가요?
   - **가정**: 불필요, 독립적인 유틸리티

---

**계획 상태**: 🔄 구현 대기 중
**다음 액션**: `/implement "logging-utility"`
