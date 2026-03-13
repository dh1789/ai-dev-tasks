# 테스트 계획

## 테스트 프레임워크
- Jest + ts-jest

## Logger.test.ts

### 로그 레벨 필터링
- INFO 레벨 설정 시 DEBUG 메시지가 출력되지 않는다
- INFO 레벨 설정 시 INFO, WARN, ERROR 메시지가 출력된다
- ERROR 레벨 설정 시 ERROR만 출력된다
- DEBUG 레벨 설정 시 모든 메시지가 출력된다

### 다중 Transport
- 두 개의 Transport에 동시에 메시지가 전달된다
- addTransport로 런타임에 Transport를 추가할 수 있다

### setLevel
- setLevel로 런타임에 로그 레벨을 변경할 수 있다

### close
- close 호출 시 모든 Transport의 close가 호출된다
- close 메서드가 없는 Transport는 무시된다

### 포맷팅
- Formatter의 format 메서드가 올바른 인자로 호출된다
- 추가 인자가 Formatter에 전달된다

## ConsoleTransport.test.ts

### 레벨별 콘솔 메서드 매핑
- DEBUG 레벨 → console.debug 호출
- INFO 레벨 → console.info 호출
- WARN 레벨 → console.warn 호출
- ERROR 레벨 → console.error 호출

### 컬러 출력
- colorEnabled: true일 때 ANSI 코드가 포함된다
- colorEnabled: false일 때 ANSI 코드가 없다

## FileTransport.test.ts

### 파일 쓰기
- 지정된 경로에 로그가 기록된다
- 여러 메시지가 순서대로 기록된다
- 줄바꿈이 올바르게 추가된다

### 디렉토리 자동 생성
- 존재하지 않는 디렉토리가 자동 생성된다

### close
- close 호출 후 스트림이 정상 종료된다

### 에러 처리
- 잘못된 경로에 대한 에러가 처리된다

## Formatter.test.ts

### DefaultFormatter
- ISO 8601 타임스탬프가 포함된다
- 로그 레벨 문자열이 포함된다
- 메시지가 포함된다
- 추가 인자(객체)가 JSON으로 직렬화된다
- 추가 인자(Error)가 스택 트레이스로 변환된다
- 추가 인자가 없으면 메시지만 출력된다
