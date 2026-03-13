# 로그 및 소스 코드 분석 가이드

NAC 서버 트러블슈팅의 핵심 — 로그 파일 분석과 소스 코드 추적 방법론.

> 대부분의 문제는 GDB/Valgrind 없이 로그와 소스만으로 진단 가능합니다.
> 도구 기반 진단은 로그/소스 분석으로 범위를 좁힌 후 사용하세요.

---

## 1. 로그 분석

### 1.1 로그 파일 탐색

```bash
# NAC 서버 로그 위치 탐색
find /var/log -name "*nac*" -o -name "*nacs*" 2>/dev/null
find . -name "*.log" -newer /tmp/marker -type f 2>/dev/null

# systemd 서비스 로그
journalctl -u nac-server --since "1 hour ago" --no-pager
journalctl -u nac-server -p err --no-pager | tail -50

# syslog에서 NAC 관련
grep -i "nac\|nacs" /var/log/syslog | tail -50
```

### 1.2 오류 패턴 추출

```bash
# 에러/경고 필터링
grep -inE "error|fail|fatal|exception|abort|segfault|panic" /path/to/nac.log | tail -30

# 타임스탬프 기반 시간대 필터
grep "2026-03-13 14:" /path/to/nac.log | grep -i error

# 반복 패턴 카운트 (가장 빈번한 오류 식별)
grep -i "error" /path/to/nac.log | sed 's/[0-9]//g' | sort | uniq -c | sort -rn | head -20

# 특정 시간대 전후 컨텍스트
grep -B5 -A10 "FATAL\|SIGSEGV\|SIGABRT" /path/to/nac.log
```

### 1.3 시간순 이벤트 재구성

```bash
# 여러 로그 파일을 시간순으로 병합
sort -t' ' -k1,2 /var/log/nac/*.log | grep -i "error\|warn" | tail -50

# 크래시 직전 N초간 로그
# (크래시 시각을 알 때 — 예: 14:32:15)
awk '/14:32:0[0-9]/,/14:32:15/' /path/to/nac.log

# 프로세스 시작~종료 구간
awk '/Starting NAC/,/Shutdown\|SIGNAL\|killed/' /path/to/nac.log
```

### 1.4 연결/세션 추적

```bash
# 특정 클라이언트 IP 추적
grep "192.168.1.100" /path/to/nac.log | tail -30

# 세션 ID로 추적
grep "session_id=ABC123" /path/to/nac.log

# 인증 실패 패턴
grep -i "auth.*fail\|deny\|reject\|unauthorized" /path/to/nac.log | tail -20

# 동시 연결 수 추이 (로그에 connection count가 있을 경우)
grep -i "connection\|accept\|close" /path/to/nac.log | tail -50
```

### 1.5 리소스 관련 로그

```bash
# 메모리/리소스 경고
grep -iE "memory|oom|alloc|resource|limit|exhaust|too many" /path/to/nac.log

# 파일 디스크립터 관련
grep -iE "fd|file descriptor|too many open|EMFILE|ENFILE" /path/to/nac.log

# 타임아웃
grep -iE "timeout|timed out|deadline|expire" /path/to/nac.log
```

---

## 2. 소스 코드 분석

### 2.1 시스템 개요 파악 (최우선)

```bash
# 프로젝트 구조 이해
Read docs/dev/INDEX.md

# 빌드 시스템에서 모듈 구조 파악
Grep "add_executable\|add_library\|target_link" CMakeLists.txt
find . -name "CMakeLists.txt" -exec grep -l "add_executable\|add_library" {} \;

# 메인 진입점
Grep "int main" --glob "*.cpp" --glob "*.cc"
```

### 2.2 오류 메시지에서 소스 위치 추적

로그에서 발견된 오류 메시지를 소스에서 찾는 과정:

```bash
# 로그 메시지 → 소스 위치 (가장 기본적인 추적)
Grep "로그에서_발견된_에러_메시지" --glob "*.cpp" --glob "*.h"

# 로그 매크로/함수 추적
Grep "LOG_ERROR\|LOG_FATAL\|SPDLOG\|syslog\|fprintf.*stderr" --glob "*.cpp" --glob "*.h"

# 에러 코드 추적
Grep "ERROR_CODE_123\|ERR_AUTH_FAIL" --glob "*.cpp" --glob "*.h"
```

### 2.3 호출 체인 추적

문제가 있는 함수에서 시작하여 호출 관계를 역추적:

```bash
# 함수 정의 찾기
Grep "함수명\s*\(" --glob "*.cpp" --glob "*.cc"

# 이 함수를 호출하는 곳 찾기 (caller 추적)
Grep "함수명\s*\(" --glob "*.cpp" --glob "*.h"

# 클래스 정의 및 멤버 함수
Grep "class ClassName" --glob "*.h" --glob "*.hpp"
Grep "ClassName::" --glob "*.cpp"

# 가상 함수 오버라이드 추적
Grep "override.*함수명\|함수명.*override" --glob "*.h" --glob "*.hpp"

# 콜백/함수 포인터 등록 추적
Grep "register.*callback\|set.*handler\|bind\|std::function" --glob "*.cpp"
```

### 2.4 메모리 관리 패턴 분석

```bash
# new/delete 쌍 확인
Grep "\bnew\b" --glob "*.cpp" | head -30
Grep "\bdelete\b" --glob "*.cpp" | head -30

# malloc/free 쌍 확인
Grep "\bmalloc\b\|\bcalloc\b\|\brealloc\b" --glob "*.cpp"
Grep "\bfree\b" --glob "*.cpp"

# 스마트 포인터 사용 확인
Grep "unique_ptr\|shared_ptr\|weak_ptr\|make_unique\|make_shared" --glob "*.cpp" --glob "*.h"

# RAII 패턴 (소멸자에서 리소스 해제)
Grep "~.*\(\)" --glob "*.h" --glob "*.hpp"
```

### 2.5 스레딩 패턴 분석

```bash
# 뮤텍스/락 사용
Grep "mutex\|lock_guard\|unique_lock\|shared_lock\|condition_variable" --glob "*.cpp" --glob "*.h"

# 스레드 생성
Grep "std::thread\|pthread_create\|std::async" --glob "*.cpp"

# 원자적 연산
Grep "std::atomic\|atomic_" --glob "*.cpp" --glob "*.h"

# 위험 패턴: 락 없는 공유 변수 접근 (수동 검토 필요)
# → 전역 변수나 멤버 변수가 여러 스레드에서 접근되는지 확인
Grep "static.*=\|global\|g_" --glob "*.cpp" --glob "*.h"
```

### 2.6 네트워크/소켓 코드 분석

```bash
# 소켓 API 사용
Grep "socket\|bind\|listen\|accept\|connect\|send\|recv\|select\|poll\|epoll" --glob "*.cpp"

# SSL/TLS 사용
Grep "SSL_\|TLS_\|openssl\|libssl" --glob "*.cpp" --glob "*.h"

# 버퍼 크기 관련
Grep "BUFFER_SIZE\|MAX_PACKET\|BUF_LEN\|recv.*sizeof" --glob "*.cpp" --glob "*.h"
```

### 2.7 최근 변경사항 분석

```bash
# 문제 파일의 최근 변경
git log --oneline -20 -- src/problematic_file.cpp

# 최근 N일간 변경된 파일 목록
git log --since="7 days ago" --name-only --pretty=format: | sort -u | grep -v '^$'

# 특정 함수 변경 이력
git log -p -S "function_name" -- "*.cpp"

# 두 시점 사이 변경사항 (정상 동작 시점 vs 문제 발생 시점)
git diff <good-commit>..<bad-commit> -- src/

# blame으로 특정 라인 마지막 수정자 확인
git blame src/problematic_file.cpp | grep -A2 -B2 "문제_라인_내용"
```

---

## 3. 로그 + 소스 교차 분석 워크플로우

가장 효과적인 분석 순서:

### Step 1: 로그에서 증상 파악
```
로그 파일 읽기 → 에러/경고 필터링 → 시간순 정렬 → 크래시 직전 이벤트 파악
```

### Step 2: 오류 메시지로 소스 위치 특정
```
에러 메시지 텍스트 → Grep으로 소스 검색 → 해당 파일/함수 Read
```

### Step 3: 호출 체인 역추적
```
문제 함수 → caller 검색 → caller의 caller → 트리거 지점 파악
```

### Step 4: 데이터 흐름 추적
```
입력 데이터 → 파싱/변환 → 처리 → 출력 경로에서 문제 지점 특정
```

### Step 5: 최근 변경과 교차 확인
```
문제 코드의 git log → 최근 커밋 확인 → 변경이 문제 원인인지 판단
```

---

## 4. 자주 발생하는 NAC 서버 문제 패턴

### 패턴 A: 인증 처리 중 크래시
```
로그: "Authentication failed" 직후 SIGSEGV
분석: 인증 실패 경로에서 null 포인터 역참조 가능성
추적: auth 관련 함수 → 실패 분기 → 포인터 검증 누락
```

### 패턴 B: 동시 접속 증가 시 hang
```
로그: accept() 성공 후 응답 없음
분석: 스레드 풀 고갈 또는 deadlock
추적: 스레드 생성/관리 코드 → 락 순서 → 리소스 한계
```

### 패턴 C: 장기 운영 후 메모리 증가
```
로그: 특이사항 없으나 RSS 꾸준히 증가
분석: 세션 정리 누락 또는 캐시 무한 증가
추적: 세션 생성/삭제 → 타이머/만료 로직 → 컨테이너 크기 확인
```

### 패턴 D: 특정 패킷에서 비정상 동작
```
로그: 특정 클라이언트에서만 에러 발생
분석: 패킷 파싱 오류 또는 엣지케이스 미처리
추적: 패킷 핸들러 → 파싱 로직 → 길이/타입 검증 → 경계값 처리
```
