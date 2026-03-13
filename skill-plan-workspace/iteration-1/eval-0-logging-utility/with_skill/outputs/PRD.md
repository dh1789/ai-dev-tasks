# PRD: 로깅 유틸리티 클래스

**문서 버전**: 1.0
**생성일**: 2026-03-13
**프로젝트 타입**: Node.js/TypeScript (자동 감지)

---

## 1. 개요

### 1.1 목적
애플리케이션 전반에서 일관된 로깅을 제공하는 TypeScript 기반 유틸리티 클래스를 개발한다. 로그 레벨(DEBUG, INFO, WARN, ERROR)을 지원하고 콘솔 및 파일 출력을 지원한다.

### 1.2 배경
- 프로젝트에 통일된 로깅 시스템이 필요
- 개발 환경과 운영 환경에서 서로 다른 로그 레벨 설정 필요
- 파일 출력을 통한 로그 영속화 요구

### 1.3 목표
- 사용하기 쉬운 로깅 API 제공
- 로그 레벨별 필터링 지원
- 콘솔 및 파일 출력 동시 지원
- 확장 가능한 아키텍처 설계

---

## 2. 기능 요구사항

### 2.1 로그 레벨 지원
- **DEBUG**: 디버깅 용도의 상세 정보
- **INFO**: 일반적인 정보성 메시지
- **WARN**: 잠재적 문제 경고
- **ERROR**: 오류 상황 기록
- 로그 레벨 우선순위: DEBUG < INFO < WARN < ERROR
- 설정된 레벨 이상의 로그만 출력

### 2.2 출력 대상 (Transport)
- **콘솔 출력**: 기본 활성화, stdout/stderr 사용
- **파일 출력**: 선택적 활성화, 지정된 경로에 로그 파일 생성
- 여러 Transport 동시 사용 가능

### 2.3 로그 포맷
- 타임스탬프 포함 (ISO 8601 형식)
- 로그 레벨 표시
- 메시지 본문
- 선택적 메타데이터 (구조화된 데이터)
- 기본 포맷: `[2026-03-13T10:30:00.000Z] [INFO] 메시지`

### 2.4 설정
- 생성 시 로그 레벨 지정
- 런타임 로그 레벨 변경 가능
- Transport 추가/제거 가능
- 파일 출력 경로 지정

---

## 3. 비기능 요구사항

### 3.1 성능
- 로그 호출 당 처리 시간: < 1ms (콘솔), < 5ms (파일)
- 파일 쓰기는 비동기로 처리하여 메인 스레드 블로킹 최소화

### 3.2 안정성
- 파일 쓰기 실패 시 애플리케이션 중단 방지
- 에러 발생 시 콘솔 fallback

### 3.3 유지보수성
- 단일 책임 원칙 준수
- Transport 패턴으로 확장 가능
- TypeScript 타입 안전성 보장

---

## 4. 사용자 시나리오

### 시나리오 1: 기본 콘솔 로깅
```typescript
const logger = new Logger({ level: LogLevel.INFO });
logger.info('서버 시작됨', { port: 3001 });
logger.debug('이 메시지는 출력되지 않음'); // INFO 레벨이므로 DEBUG 무시
logger.error('데이터베이스 연결 실패', { host: 'localhost' });
```

### 시나리오 2: 파일 출력 로깅
```typescript
const logger = new Logger({
  level: LogLevel.DEBUG,
  transports: [
    new ConsoleTransport(),
    new FileTransport({ filePath: './logs/app.log' })
  ]
});
logger.info('애플리케이션 초기화 완료');
// 콘솔과 파일 모두에 로그 출력
```

### 시나리오 3: 런타임 레벨 변경
```typescript
const logger = new Logger({ level: LogLevel.ERROR });
// 운영 중 디버깅이 필요할 때
logger.setLevel(LogLevel.DEBUG);
logger.debug('디버깅 정보 출력 시작');
```

---

## 5. 기술 스택

- **언어**: TypeScript 5.x
- **런타임**: Node.js 20+
- **테스트**: Jest 또는 Vitest
- **빌드**: tsc (TypeScript Compiler)
- **패키지 매니저**: npm 또는 pnpm
- **의존성**: Node.js 내장 모듈만 사용 (fs, path, os)

---

## 6. 제약사항 및 가정

### 제약사항
- 외부 로깅 라이브러리(winston, pino 등) 사용하지 않음
- Node.js 내장 모듈만 활용
- 로그 로테이션은 초기 범위에서 제외

### 가정
- Node.js 20 이상 환경에서 실행
- TypeScript strict 모드 사용
- 파일 시스템 접근 권한이 있음
- 단일 프로세스 환경 (멀티 프로세스 로깅은 범위 외)

---

## 7. 성공 지표

| 지표 | 목표 | 측정 방법 |
|-----|------|----------|
| 테스트 커버리지 | >= 90% | Jest/Vitest coverage |
| 로그 호출 성능 (콘솔) | < 1ms | 벤치마크 테스트 |
| 로그 호출 성능 (파일) | < 5ms | 벤치마크 테스트 |
| TypeScript 타입 오류 | 0 | tsc --noEmit |
| 린트 오류 | 0 | ESLint |

---

## 8. 범위 외 (Out of Scope)

- 로그 로테이션 (추후 Phase로)
- 원격 로그 전송 (Syslog, HTTP 등)
- 로그 집계 및 검색
- 브라우저 환경 지원
- 멀티 프로세스 로깅
