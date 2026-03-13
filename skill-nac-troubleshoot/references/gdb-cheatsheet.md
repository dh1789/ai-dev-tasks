# GDB 빠른 참조

NAC 서버 C++ 바이너리 디버깅을 위한 GDB 명령어 요약.

---

## Core Dump 분석 (가장 빈번)

```bash
# 기본 분석
gdb /path/to/binary /path/to/core
(gdb) bt full              # 전체 백트레이스 + 로컬 변수
(gdb) info threads         # 모든 스레드 목록
(gdb) thread apply all bt  # 모든 스레드 백트레이스

# 배치 모드 (스크립트용)
gdb -batch \
  -ex "set pagination off" \
  -ex "bt full" \
  -ex "info threads" \
  -ex "thread apply all bt full" \
  -ex "quit" /path/to/binary /path/to/core
```

## 실행 중 프로세스 연결

```bash
# attach
gdb -p <PID>
(gdb) info threads
(gdb) thread apply all bt
(gdb) detach
(gdb) quit

# 배치 모드
gdb -batch -ex "attach <PID>" -ex "thread apply all bt" -ex "detach" -ex "quit"
```

## 스택 탐색

```bash
(gdb) bt              # 백트레이스
(gdb) bt full          # 백트레이스 + 로컬 변수
(gdb) frame N          # N번 프레임 선택
(gdb) info locals      # 현재 프레임 로컬 변수
(gdb) info args        # 현재 프레임 인자
(gdb) up / down        # 프레임 이동
(gdb) list             # 현재 위치 소스 코드
```

## 메모리 검사

```bash
(gdb) x/16xb <addr>   # 16바이트 hex 출력
(gdb) x/s <addr>      # 문자열 출력
(gdb) info proc mappings  # 메모리 맵
(gdb) print *ptr       # 포인터 역참조
(gdb) print sizeof(obj) # 객체 크기
```

## 스레드 디버깅

```bash
(gdb) info threads     # 스레드 목록
(gdb) thread N         # N번 스레드 전환
(gdb) thread apply all bt  # 모든 스레드 백트레이스
(gdb) thread apply all info locals  # 모든 스레드 로컬 변수
```

## 시그널 분석

```bash
(gdb) info signals     # 시그널 핸들링 설정
(gdb) print $_siginfo  # 시그널 상세 정보
(gdb) print $_siginfo.si_addr  # 폴트 주소 (SIGSEGV)
```

## 유용한 설정

```bash
(gdb) set pagination off      # 페이지 나눔 비활성화
(gdb) set print pretty on     # 구조체 예쁘게 출력
(gdb) set print elements 0    # 배열 전체 출력
(gdb) set logging on          # 출력 파일 저장
```
