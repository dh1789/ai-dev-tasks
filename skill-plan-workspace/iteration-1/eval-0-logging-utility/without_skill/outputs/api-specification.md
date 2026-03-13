# API 명세

## LogLevel

```typescript
export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

export function logLevelToString(level: LogLevel): string;
```

## Transport

```typescript
export interface Transport {
  write(message: string, level: LogLevel): void;
  close?(): Promise<void>;
}
```

## ConsoleTransport

```typescript
export interface ConsoleTransportOptions {
  colorEnabled?: boolean; // 기본값: true
}

export class ConsoleTransport implements Transport {
  constructor(options?: ConsoleTransportOptions);
  write(message: string, level: LogLevel): void;
}
```

## FileTransport

```typescript
export interface FileTransportOptions {
  filePath: string;         // 로그 파일 경로 (필수)
  encoding?: BufferEncoding; // 기본값: 'utf-8'
}

export class FileTransport implements Transport {
  constructor(options: FileTransportOptions);
  write(message: string, level: LogLevel): void;
  close(): Promise<void>;
}
```

## Formatter

```typescript
export interface Formatter {
  format(
    level: LogLevel,
    message: string,
    timestamp: Date,
    args: unknown[]
  ): string;
}

export class DefaultFormatter implements Formatter {
  format(
    level: LogLevel,
    message: string,
    timestamp: Date,
    args: unknown[]
  ): string;
  // 출력 형식: "[2026-03-13T10:00:00.000Z] [INFO] 메시지 {"key":"value"}"
}
```

## Logger

```typescript
export interface LoggerConfig {
  level?: LogLevel;          // 기본값: LogLevel.INFO
  transports?: Transport[];  // 기본값: [new ConsoleTransport()]
  formatter?: Formatter;     // 기본값: new DefaultFormatter()
}

export class Logger {
  constructor(config?: LoggerConfig);

  debug(message: string, ...args: unknown[]): void;
  info(message: string, ...args: unknown[]): void;
  warn(message: string, ...args: unknown[]): void;
  error(message: string, ...args: unknown[]): void;

  setLevel(level: LogLevel): void;
  addTransport(transport: Transport): void;
  close(): Promise<void>;
}
```

## 팩토리 함수

```typescript
export function createLogger(config?: LoggerConfig): Logger;
```

## 사용 예시

```typescript
import { createLogger, LogLevel, FileTransport } from './logger';

// 기본 사용 (콘솔 출력, INFO 레벨)
const logger = createLogger();
logger.info('애플리케이션 시작');

// 커스텀 설정
const customLogger = createLogger({
  level: LogLevel.DEBUG,
  transports: [
    new FileTransport({ filePath: './logs/app.log' }),
  ],
});

customLogger.debug('디버그 메시지', { requestId: 'abc-123' });
customLogger.error('오류 발생', new Error('연결 실패'));

// 리소스 정리
await customLogger.close();
```
