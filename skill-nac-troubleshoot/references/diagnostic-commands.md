# 진단 명령어 레퍼런스

NAC 서버 트러블슈팅에서 사용하는 카테고리별 진단 명령어 모음.

---

## 크래시 분석

### Core Dump 확인
```bash
# systemd 코어 덤프 목록
coredumpctl list | grep -i nac

# 최신 코어 덤프 정보
coredumpctl info

# 코어 덤프 파일 추출
coredumpctl dump -o /tmp/core.<PID>

# 직접 확인 (18.04 호환)
ls -lt /var/lib/systemd/coredump/ | head -10
```

### GDB 스택 트레이스
```bash
# 전체 백트레이스
gdb -batch -ex "bt full" -ex "quit" /path/to/binary /path/to/core

# 모든 스레드 백트레이스
gdb -batch -ex "thread apply all bt" -ex "quit" /path/to/binary /path/to/core

# 레지스터 + 백트레이스
gdb -batch \
  -ex "bt full" \
  -ex "info registers" \
  -ex "info threads" \
  -ex "thread apply all bt" \
  -ex "quit" /path/to/binary /path/to/core

# 시그널 정보
gdb -batch -ex "info signals" -ex "quit" /path/to/binary /path/to/core
```

### 시그널 분석
```bash
# dmesg에서 segfault 확인
dmesg | grep -i "segfault\|killed\|oom" | tail -20

# 커널 로그
journalctl -k | grep -i "segfault\|oom\|killed" | tail -20
```

---

## 메모리 분석

### Valgrind
```bash
# 전체 메모리 검사
valgrind --leak-check=full \
  --show-leak-kinds=all \
  --track-origins=yes \
  --verbose \
  --log-file=/tmp/valgrind-nac.log \
  /path/to/binary [args]

# 스레드 오류 검사
valgrind --tool=helgrind --log-file=/tmp/helgrind-nac.log /path/to/binary [args]

# 캐시 프로파일링
valgrind --tool=cachegrind --log-file=/tmp/cachegrind-nac.log /path/to/binary [args]
```

### Address Sanitizer (재컴파일 필요)
```bash
# ASan 빌드
cmake -DCMAKE_CXX_FLAGS="-fsanitize=address -fno-omit-frame-pointer -g" ..
make -j$(nproc)

# ASan 실행
ASAN_OPTIONS=detect_leaks=1:halt_on_error=0:log_path=/tmp/asan-nac ./binary [args]
```

### Thread Sanitizer (재컴파일 필요)
```bash
# TSan 빌드
cmake -DCMAKE_CXX_FLAGS="-fsanitize=thread -g" ..
make -j$(nproc)

# TSan 실행
TSAN_OPTIONS=report_bugs=1:log_path=/tmp/tsan-nac ./binary [args]
```

### 프로세스 메모리 상태
```bash
# 메모리 맵
cat /proc/<PID>/maps | head -50
pmap -x <PID> | tail -5

# 메모리 사용량
cat /proc/<PID>/status | grep -E "VmSize|VmRSS|VmSwap|Threads"

# OOM 점수
cat /proc/<PID>/oom_score
```

---

## 스레딩 분석

### 스레드 상태
```bash
# 스레드 목록
ls /proc/<PID>/task/
ps -T -p <PID>

# 스레드별 CPU 사용량
top -H -p <PID> -b -n 1

# GDB에서 스레드 분석
gdb -batch \
  -ex "attach <PID>" \
  -ex "info threads" \
  -ex "thread apply all bt" \
  -ex "detach" \
  -ex "quit"
```

### Deadlock 진단
```bash
# 뮤텍스 상태 (GDB)
gdb -batch \
  -ex "attach <PID>" \
  -ex "thread apply all bt" \
  -ex "info threads" \
  -ex "detach" \
  -ex "quit"

# futex 대기 확인
cat /proc/<PID>/wchan
strace -e futex -p <PID> 2>&1 | head -50
```

---

## 빌드/링크 분석

### 심볼 분석
```bash
# 정의되지 않은 심볼 확인
nm -u /path/to/binary | head -30

# 동적 라이브러리 의존성
ldd /path/to/binary

# 누락된 라이브러리
ldd /path/to/binary | grep "not found"

# 심볼 테이블
nm -D /path/to/binary | grep <symbol_name>
```

### ABI 호환성
```bash
# C++ 디맹글링
nm -C /path/to/binary | grep <function>
c++filt <mangled_name>

# ELF 헤더 확인
readelf -h /path/to/binary
file /path/to/binary

# RPATH 확인
readelf -d /path/to/binary | grep -E "RPATH|RUNPATH|NEEDED"
```

---

## 시스템 콜 추적

### strace
```bash
# 네트워크 + 파일 시스템 콜
strace -f -e trace=network,file -p <PID> 2>&1 | head -200

# 시간 포함 추적
strace -f -T -e trace=all -p <PID> 2>&1 | head -200

# 특정 시스템 콜 통계
strace -c -p <PID> -S time 2>&1
```

### ltrace
```bash
# 라이브러리 호출 추적
ltrace -f -e malloc+free -p <PID> 2>&1 | head -100

# 특정 라이브러리 추적
ltrace -f -l libssl.so -p <PID> 2>&1 | head -100
```

---

## 네트워크 진단

```bash
# 열린 소켓
ss -tlnp | grep <PID_or_PORT>
netstat -tlnp | grep <PID_or_PORT>

# 소켓 상태
cat /proc/<PID>/net/tcp | head -20

# 연결 상태 카운트
ss -s

# 패킷 캡처 (root 필요)
tcpdump -i any port <PORT> -c 100 -w /tmp/nac-capture.pcap
```

---

## 리소스 진단

```bash
# 파일 디스크립터 사용량
ls /proc/<PID>/fd | wc -l
cat /proc/<PID>/limits | grep "open files"

# 시스템 리소스
ulimit -a
sysctl -a 2>/dev/null | grep -E "file-max|somaxconn|tcp"

# 디스크 사용량
df -h
du -sh /var/log/nac/ 2>/dev/null
```
