# 파일 구조 명세

## 디렉토리 트리

```
src/
├── logger/
│   ├── index.ts
│   ├── Logger.ts
│   ├── LogLevel.ts
│   ├── transports/
│   │   ├── index.ts
│   │   ├── Transport.ts
│   │   ├── ConsoleTransport.ts
│   │   └── FileTransport.ts
│   └── formatter/
│       └── Formatter.ts
└── __tests__/
    ├── Logger.test.ts
    ├── ConsoleTransport.test.ts
    ├── FileTransport.test.ts
    └── Formatter.test.ts
```

## 파일별 역할

### src/logger/LogLevel.ts
- `LogLevel` enum 정의 (DEBUG=0, INFO=1, WARN=2, ERROR=3)
- `LogLevelName` 타입 (문자열 리터럴 유니온)
- `logLevelToString()` 유틸 함수

### src/logger/transports/Transport.ts
- `Transport` 인터페이스 정의
- `write(message: string, level: LogLevel): void`
- `close?(): Promise<void>`

### src/logger/transports/ConsoleTransport.ts
- `ConsoleTransport` 클래스
- 로그 레벨별 콘솔 메서드 매핑
- ANSI 컬러 코드 적용

### src/logger/transports/FileTransport.ts
- `FileTransport` 클래스
- `FileTransportOptions` 인터페이스 (filePath, encoding)
- `fs.createWriteStream` 기반 파일 쓰기
- `close()` 메서드로 스트림 정리

### src/logger/transports/index.ts
- Transport 관련 모듈 re-export

### src/logger/formatter/Formatter.ts
- `Formatter` 인터페이스
- `DefaultFormatter` 클래스
- ISO 8601 타임스탬프 포맷

### src/logger/Logger.ts
- `LoggerConfig` 인터페이스
- `Logger` 클래스 (핵심 로직)
- 레벨 필터링, Transport 관리, 포맷팅 위임

### src/logger/index.ts
- `createLogger()` 팩토리 함수
- 모든 공개 타입 및 클래스 re-export

### src/__tests__/*.test.ts
- 각 컴포넌트별 단위 테스트
