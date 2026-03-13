# 기능 구현 계획: 로깅 유틸리티 클래스

## 개요

Node.js TypeScript 프로젝트용 로깅 유틸리티 클래스를 구현한다.
로그 레벨(DEBUG, INFO, WARN, ERROR)을 지원하고, 콘솔 및 파일 출력을 모두 지원한다.

## 요구사항 분석

### 핵심 요구사항
1. 로그 레벨 지원: DEBUG, INFO, WARN, ERROR
2. 파일 출력 기능
3. Node.js TypeScript 기반

### 파생 요구사항
- 로그 레벨 필터링 (설정된 레벨 이상만 출력)
- 타임스탬프 포함
- 콘솔 출력 (기본)
- 파일 출력 (선택적 활성화)
- 로그 포맷 설정 가능
- 싱글톤 또는 인스턴스 기반 사용 모두 지원

## 아키텍처 설계

### 파일 구조
```
src/
  logger/
    index.ts              # 공개 API (re-export)
    Logger.ts             # Logger 메인 클래스
    LogLevel.ts           # 로그 레벨 enum 및 타입 정의
    transports/
      index.ts            # Transport re-export
      Transport.ts        # Transport 인터페이스
      ConsoleTransport.ts # 콘솔 출력 Transport
      FileTransport.ts    # 파일 출력 Transport
    formatter/
      Formatter.ts        # 로그 포맷터 인터페이스 및 기본 구현
  __tests__/
    Logger.test.ts        # Logger 단위 테스트
    ConsoleTransport.test.ts
    FileTransport.test.ts
    Formatter.test.ts
```

### 핵심 컴포넌트

#### 1. LogLevel (enum)
```typescript
export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}
```

#### 2. Transport 인터페이스
```typescript
export interface Transport {
  write(message: string, level: LogLevel): void;
  close?(): Promise<void>;
}
```

#### 3. LoggerConfig 타입
```typescript
export interface LoggerConfig {
  level: LogLevel;
  transports: Transport[];
  formatter?: Formatter;
}
```

#### 4. Logger 클래스
- `debug(message: string, ...args: unknown[]): void`
- `info(message: string, ...args: unknown[]): void`
- `warn(message: string, ...args: unknown[]): void`
- `error(message: string, ...args: unknown[]): void`
- `setLevel(level: LogLevel): void`
- `addTransport(transport: Transport): void`
- `close(): Promise<void>`

#### 5. ConsoleTransport
- `console.log`, `console.info`, `console.warn`, `console.error`에 매핑
- 컬러 출력 지원 (chalk 없이 ANSI 코드 사용)

#### 6. FileTransport
- `fs.createWriteStream`을 사용한 비동기 파일 쓰기
- 로그 파일 경로 설정
- 파일 로테이션은 초기 버전에서 미지원 (향후 확장)

#### 7. Formatter
```typescript
export interface Formatter {
  format(level: LogLevel, message: string, timestamp: Date, args: unknown[]): string;
}
```
- 기본 포맷: `[2026-03-13T10:00:00.000Z] [INFO] 메시지`

## 구현 계획

### 단계 1: 프로젝트 기반 설정
- `package.json` 생성 (TypeScript, jest 의존성)
- `tsconfig.json` 설정
- 디렉토리 구조 생성

### 단계 2: 핵심 타입 정의
- `LogLevel.ts` - enum 및 유틸 함수
- `Transport.ts` - Transport 인터페이스
- `Formatter.ts` - Formatter 인터페이스 및 DefaultFormatter

### 단계 3: Transport 구현
- `ConsoleTransport.ts` - 콘솔 출력
- `FileTransport.ts` - 파일 출력 (fs.createWriteStream)

### 단계 4: Logger 클래스 구현
- 로그 레벨 필터링 로직
- 다중 Transport 지원
- Formatter 적용

### 단계 5: 테스트 작성
- Logger 단위 테스트 (레벨 필터링, 포맷팅)
- ConsoleTransport 테스트
- FileTransport 테스트 (임시 파일 사용)
- Formatter 테스트

### 단계 6: 편의 기능
- `index.ts`에서 깔끔한 API export
- 기본 로거 인스턴스 제공
- `createLogger()` 팩토리 함수

## 설계 결정사항

| 항목 | 결정 | 근거 |
|------|------|------|
| 외부 의존성 | 없음 (Node.js 내장 모듈만 사용) | 경량화, 의존성 최소화 |
| 패턴 | Transport 패턴 | 출력 대상 확장 용이 |
| 비동기 처리 | FileTransport만 비동기 | 콘솔은 동기 처리로 충분 |
| 포맷터 | 인터페이스 기반 | 사용자 정의 포맷 지원 |
| 파일 로테이션 | 미지원 (v1) | 초기 범위 제한, 향후 확장 |
| 컬러 출력 | ANSI 코드 직접 사용 | 외부 라이브러리 불필요 |

## 사용 예시

```typescript
import { createLogger, LogLevel, FileTransport } from './logger';

// 기본 사용 (콘솔 출력만)
const logger = createLogger({ level: LogLevel.DEBUG });
logger.info('서버가 시작되었습니다');
logger.error('연결 실패', { host: 'localhost', port: 3001 });

// 파일 출력 추가
const fileLogger = createLogger({
  level: LogLevel.INFO,
  transports: [
    new FileTransport({ filePath: './logs/app.log' }),
  ],
});
fileLogger.warn('디스크 사용량이 높습니다', { usage: '85%' });

// 종료 시 리소스 정리
await fileLogger.close();
```

## 예상 작업량

| 단계 | 파일 수 | 예상 시간 |
|------|---------|----------|
| 프로젝트 설정 | 2 | 10분 |
| 타입 정의 | 3 | 15분 |
| Transport 구현 | 2 | 30분 |
| Logger 구현 | 2 | 30분 |
| 테스트 | 4 | 45분 |
| 편의 기능 | 1 | 10분 |
| **합계** | **14** | **약 2시간 20분** |

## 확장 가능성 (향후)

- 파일 로테이션 (크기/날짜 기반)
- JSON 포맷 출력
- 비동기 로깅 (버퍼링)
- 로그 컨텍스트 (request ID 등)
- 원격 전송 Transport (HTTP, Syslog)
