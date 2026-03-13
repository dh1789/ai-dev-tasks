# 구현 태스크 목록

## 태스크 1: 프로젝트 초기 설정
- **우선순위**: 높음
- **의존성**: 없음
- **작업 내용**:
  - `package.json` 생성 (typescript, @types/node, jest, ts-jest 의존성)
  - `tsconfig.json` 설정 (strict 모드, ES2020 타겟, CommonJS 모듈)
  - 디렉토리 구조 생성

## 태스크 2: LogLevel enum 구현
- **우선순위**: 높음
- **의존성**: 태스크 1
- **파일**: `src/logger/LogLevel.ts`
- **작업 내용**:
  - `LogLevel` enum 정의 (DEBUG=0, INFO=1, WARN=2, ERROR=3)
  - `logLevelToString()` 헬퍼 함수
  - `LogLevelName` 타입 정의

## 태스크 3: Transport 인터페이스 정의
- **우선순위**: 높음
- **의존성**: 태스크 2
- **파일**: `src/logger/transports/Transport.ts`
- **작업 내용**:
  - `Transport` 인터페이스 정의
  - `write` 메서드 시그니처
  - 선택적 `close` 메서드

## 태스크 4: Formatter 구현
- **우선순위**: 중간
- **의존성**: 태스크 2
- **파일**: `src/logger/formatter/Formatter.ts`
- **작업 내용**:
  - `Formatter` 인터페이스 정의
  - `DefaultFormatter` 클래스 구현
  - ISO 8601 타임스탬프 포맷팅
  - 추가 인자(args) 직렬화 처리

## 태스크 5: ConsoleTransport 구현
- **우선순위**: 높음
- **의존성**: 태스크 3
- **파일**: `src/logger/transports/ConsoleTransport.ts`
- **작업 내용**:
  - `ConsoleTransport` 클래스 구현
  - 로그 레벨별 콘솔 메서드 매핑 (debug→console.debug, info→console.info 등)
  - ANSI 컬러 코드 적용 (DEBUG: 회색, INFO: 파랑, WARN: 노랑, ERROR: 빨강)
  - 컬러 비활성화 옵션

## 태스크 6: FileTransport 구현
- **우선순위**: 높음
- **의존성**: 태스크 3
- **파일**: `src/logger/transports/FileTransport.ts`
- **작업 내용**:
  - `FileTransportOptions` 인터페이스 정의
  - `FileTransport` 클래스 구현
  - `fs.createWriteStream` 기반 비동기 파일 쓰기
  - 로그 디렉토리 자동 생성 (recursive mkdir)
  - `close()` 메서드로 스트림 정리
  - 에러 핸들링 (스트림 에러 이벤트)

## 태스크 7: Logger 클래스 구현
- **우선순위**: 높음
- **의존성**: 태스크 4, 5, 6
- **파일**: `src/logger/Logger.ts`
- **작업 내용**:
  - `LoggerConfig` 인터페이스 정의
  - `Logger` 클래스 구현
  - 로그 레벨 필터링 로직 (설정 레벨 이상만 출력)
  - 다중 Transport 지원
  - `debug()`, `info()`, `warn()`, `error()` 메서드
  - `setLevel()`, `addTransport()`, `close()` 메서드
  - Formatter를 통한 메시지 포맷팅

## 태스크 8: 공개 API (index.ts) 구성
- **우선순위**: 중간
- **의존성**: 태스크 7
- **파일**: `src/logger/index.ts`, `src/logger/transports/index.ts`
- **작업 내용**:
  - `createLogger()` 팩토리 함수 (기본 ConsoleTransport 포함)
  - 모든 공개 타입/클래스 re-export
  - 기본 설정값 정의

## 태스크 9: 단위 테스트 작성
- **우선순위**: 중간
- **의존성**: 태스크 7, 8
- **파일**: `src/__tests__/*.test.ts`
- **작업 내용**:
  - Logger 테스트: 레벨 필터링, 다중 Transport, 포맷팅
  - ConsoleTransport 테스트: 올바른 콘솔 메서드 호출 확인
  - FileTransport 테스트: 파일 쓰기/닫기, 에러 처리
  - Formatter 테스트: 포맷 문자열 검증, 인자 직렬화

## 의존성 그래프

```
태스크 1 (프로젝트 설정)
  └── 태스크 2 (LogLevel)
       ├── 태스크 3 (Transport 인터페이스)
       │    ├── 태스크 5 (ConsoleTransport)
       │    └── 태스크 6 (FileTransport)
       └── 태스크 4 (Formatter)
            └── 태스크 7 (Logger) ← 태스크 5, 6도 의존
                 └── 태스크 8 (공개 API)
                      └── 태스크 9 (테스트)
```
