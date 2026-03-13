# 시스템 정보 수집 및 분석 가이드

NAC 서버 트러블슈팅의 첫 단계 — 시스템 환경, NAC 프로세스 상태, DB 정보를 수집하고 분석합니다.

> 증상에 바로 뛰어들기 전에 시스템 전체 상태를 파악하면 문제 범위를 크게 좁힐 수 있습니다.

---

## 1. 시스템 환경 수집

### 1.1 OS 및 커널 정보

```bash
# OS 버전 (Ubuntu 18.04~24.04 확인)
cat /etc/os-release | grep -E "PRETTY_NAME|VERSION_ID"
uname -a

# 커널 버전 (드라이버/모듈 호환성 확인)
uname -r

# 시스템 가동 시간
uptime

# 최근 재부팅 이력
last reboot | head -5
```

**분석 포인트:**
- Ubuntu 버전에 따라 사용 가능한 디버깅 도구가 다름 (18.04의 GDB 8.1 vs 24.04의 GDB 14.2)
- 커널 버전이 특정 syscall이나 네트워크 기능에 영향
- uptime이 짧으면 최근 크래시/재시작 의심

### 1.2 하드웨어 리소스

```bash
# CPU 정보
nproc
lscpu | grep -E "Model name|CPU\(s\)|Thread"

# 메모리 (전체/사용/가용)
free -h
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree|Buffers|Cached"

# 디스크
df -h
df -ih  # inode 사용량 (파일 수 한계)

# 로드 평균
cat /proc/loadavg
```

**분석 포인트:**
- MemAvailable < 총 메모리의 10% → 메모리 부족 의심
- Swap 사용량 증가 → NAC 프로세스 메모리 누수 가능성
- 디스크 사용률 > 90% → 로그 로테이션 실패 또는 코어 덤프 축적
- inode 사용률 > 90% → 작은 파일 과다 (세션 파일, 임시 파일)
- load average > CPU 코어 수 → 과부하 상태

### 1.3 네트워크 환경

```bash
# 네트워크 인터페이스
ip addr show
ip route show

# DNS 설정
cat /etc/resolv.conf

# 방화벽 규칙 (NAC 포트 접근 확인)
iptables -L -n 2>/dev/null | head -30
ufw status verbose 2>/dev/null

# 열린 포트
ss -tlnp | grep -E "nac|8443|1812|1813|3799"

# 네트워크 연결 통계
ss -s
cat /proc/net/sockstat
```

**분석 포인트:**
- NAC 서비스 포트가 LISTEN 상태인지 확인
- TIME_WAIT 소켓 과다 → 연결 해제 이슈
- 방화벽 규칙이 정상 트래픽을 차단하고 있지 않은지 확인

### 1.4 시스템 리소스 한계

```bash
# 시스템 전역 한계
sysctl -a 2>/dev/null | grep -E "file-max|somaxconn|tcp_max|ip_local_port|nf_conntrack_max"

# NAC 프로세스의 리소스 한계
cat /proc/$(pgrep -f nac)/limits 2>/dev/null

# 커널 로그 (OOM, 오류)
dmesg | grep -iE "oom|killed|error|nac" | tail -20
journalctl -k --since "1 hour ago" | grep -iE "oom|killed|segfault" | tail -10
```

**분석 포인트:**
- Max open files < 예상 동시 연결 수 → fd 고갈 가능성
- OOM killer 로그 → 메모리 관리 문제
- nf_conntrack_max 초과 → 네트워크 연결 추적 테이블 포화

---

## 2. NAC 프로세스 상태 수집

### 2.1 프로세스 기본 정보

```bash
# NAC 프로세스 확인
ps aux | grep -i nac | grep -v grep
pgrep -a -f nac

# 프로세스 트리 (부모-자식 관계)
pstree -p $(pgrep -f nac-server) 2>/dev/null

# 프로세스 시작 시간
ps -o pid,lstart,etime,cmd -p $(pgrep -f nac) 2>/dev/null

# 서비스 상태 (systemd)
systemctl status nac-server 2>/dev/null
systemctl is-active nac-server 2>/dev/null
```

**분석 포인트:**
- 프로세스가 여러 개 → fork 기반 아키텍처인지, 비정상 다중 실행인지 확인
- etime(경과시간)이 짧으면 최근 재시작됨 → 크래시 후 자동 재시작 의심
- systemd 상태가 `activating (auto-restart)` → 반복 크래시

### 2.2 프로세스 리소스 사용량

```bash
NAC_PID=$(pgrep -f nac-server | head -1)

# CPU/메모리 사용량
ps -o pid,%cpu,%mem,rss,vsz,cmd -p $NAC_PID

# 상세 메모리 정보
cat /proc/$NAC_PID/status 2>/dev/null | grep -E "VmSize|VmRSS|VmSwap|VmPeak|Threads|FDSize"

# 메모리 맵 요약
pmap -x $NAC_PID 2>/dev/null | tail -5

# 열린 파일 디스크립터 수
ls /proc/$NAC_PID/fd 2>/dev/null | wc -l

# 열린 파일 디스크립터 상세 (소켓, 파일, 파이프)
ls -la /proc/$NAC_PID/fd 2>/dev/null | awk '{print $NF}' | sort | uniq -c | sort -rn | head -20

# 스레드 수
ls /proc/$NAC_PID/task 2>/dev/null | wc -l

# 스레드별 CPU 사용량
ps -T -p $NAC_PID -o tid,%cpu,time,comm 2>/dev/null | sort -k2 -rn | head -20
```

**분석 포인트:**
- VmRSS 지속 증가 → 메모리 누수
- VmSwap > 0 → 메모리 부족으로 스왑 사용
- VmPeak >> VmRSS → 일시적 메모리 스파이크 발생
- fd 수가 Max open files에 근접 → fd 고갈 위험
- 특정 스레드가 CPU 100% → busy loop 또는 무한 루프
- socket 타입 fd가 비정상적으로 많음 → 소켓 누수

### 2.3 NAC 프로세스 로그

```bash
# NAC 애플리케이션 로그 위치 탐색
find /var/log -name "*nac*" -type f 2>/dev/null
find /opt -name "*nac*" -path "*/log*" -type f 2>/dev/null
find /home -name "*nac*" -path "*/log*" -type f 2>/dev/null

# systemd 저널
journalctl -u nac-server --since "30 min ago" --no-pager

# 최근 에러 로그
journalctl -u nac-server -p err --since "1 hour ago" --no-pager

# 로그 크기 확인 (비정상적 성장 감지)
du -sh /var/log/nac/ 2>/dev/null
ls -lhrt /var/log/nac/ 2>/dev/null | tail -10

# 로그 로테이션 설정
cat /etc/logrotate.d/*nac* 2>/dev/null
```

**분석 포인트:**
- 로그 크기가 비정상적으로 큼 → 반복 에러 또는 디버그 레벨 로깅
- 로그 타임스탬프에 갭 → 프로세스 중단 기간
- 로그가 없음 → 로그 경로 설정 오류 또는 권한 문제

### 2.4 NAC 설정 파일

```bash
# 설정 파일 위치 탐색
find /etc -name "*nac*" -type f 2>/dev/null
find /opt -name "*.conf" -path "*nac*" -type f 2>/dev/null

# 설정 파일 내용 (비밀번호 마스킹)
cat /etc/nac/nac-server.conf 2>/dev/null | grep -v -iE "password|secret|key"

# 환경 변수
cat /proc/$(pgrep -f nac-server | head -1)/environ 2>/dev/null | tr '\0' '\n' | grep -i nac
```

**분석 포인트:**
- 최대 연결 수, 타임아웃, 스레드 풀 크기 등 성능 관련 설정
- 로그 레벨 설정 (debug → 성능 저하 가능)
- DB 연결 설정 (호스트, 포트, 풀 크기)

---

## 3. 데이터베이스 정보 수집

### 3.1 DB 연결 상태

```bash
# NAC 프로세스에서 DB 연결 확인
ss -tnp | grep $(pgrep -f nac-server | head -1) | grep -E "3306|5432|27017|6379"

# MySQL/MariaDB 연결 수
mysql -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null
mysql -e "SHOW STATUS LIKE 'Max_used_connections';" 2>/dev/null

# PostgreSQL 연결 수
psql -c "SELECT count(*) FROM pg_stat_activity WHERE datname = 'nac_db';" 2>/dev/null

# Redis 연결 (세션/캐시용)
redis-cli info clients 2>/dev/null | grep connected_clients
```

**분석 포인트:**
- 연결 수가 max_connections에 근접 → 커넥션 풀 고갈
- 연결이 0 → DB 접근 불가 (인증 실패, 네트워크 문제)
- TIME_WAIT 상태 DB 연결 → 커넥션 풀링 미사용

### 3.2 DB 성능 상태

```bash
# MySQL/MariaDB 상태
mysql -e "SHOW GLOBAL STATUS LIKE 'Slow_queries';" 2>/dev/null
mysql -e "SHOW GLOBAL STATUS LIKE 'Questions';" 2>/dev/null
mysql -e "SHOW GLOBAL STATUS LIKE 'Innodb_row_lock_waits';" 2>/dev/null
mysql -e "SHOW PROCESSLIST;" 2>/dev/null

# 슬로우 쿼리 로그
cat /var/log/mysql/slow-query.log 2>/dev/null | tail -30

# PostgreSQL 슬로우 쿼리
psql -c "SELECT pid, now() - pg_stat_activity.query_start AS duration, query FROM pg_stat_activity WHERE state = 'active' AND now() - pg_stat_activity.query_start > interval '5 seconds';" 2>/dev/null

# PostgreSQL 락 대기
psql -c "SELECT * FROM pg_locks WHERE NOT granted LIMIT 10;" 2>/dev/null
```

**분석 포인트:**
- Slow_queries 증가 → 인덱스 누락 또는 비효율 쿼리
- Innodb_row_lock_waits 높음 → 동시 트랜잭션 충돌
- PROCESSLIST에서 장기 실행 쿼리 → 테이블 락 또는 deadlock 가능성

### 3.3 DB 스키마 및 데이터 상태

```bash
# 테이블 크기 (MySQL)
mysql -e "SELECT table_name, table_rows, ROUND(data_length/1024/1024, 2) AS data_mb, ROUND(index_length/1024/1024, 2) AS index_mb FROM information_schema.tables WHERE table_schema = 'nac_db' ORDER BY data_length DESC LIMIT 20;" 2>/dev/null

# 테이블 크기 (PostgreSQL)
psql -c "SELECT relname, n_live_tup, pg_size_pretty(pg_total_relation_size(relid)) FROM pg_stat_user_tables ORDER BY pg_total_relation_size(relid) DESC LIMIT 20;" nac_db 2>/dev/null

# 최근 변경 (MySQL binlog 위치)
mysql -e "SHOW MASTER STATUS;" 2>/dev/null

# 테이블 상태 확인
mysql -e "CHECK TABLE nac_sessions, nac_devices, nac_policies;" nac_db 2>/dev/null
```

**분석 포인트:**
- 특정 테이블이 비정상적으로 큼 → 정리 미수행 (만료 세션, 오래된 로그)
- table_rows가 매우 많은데 인덱스 없음 → 풀 스캔으로 성능 저하
- CHECK TABLE에서 오류 → 테이블 손상

### 3.4 NAC 관련 핵심 테이블 조회

```bash
# 활성 세션 수
mysql -e "SELECT COUNT(*) AS active_sessions FROM nac_sessions WHERE status = 'active';" nac_db 2>/dev/null

# 최근 인증 실패
mysql -e "SELECT * FROM nac_auth_log WHERE result = 'FAIL' ORDER BY created_at DESC LIMIT 20;" nac_db 2>/dev/null

# 디바이스 등록 현황
mysql -e "SELECT status, COUNT(*) FROM nac_devices GROUP BY status;" nac_db 2>/dev/null

# 정책 적용 상태
mysql -e "SELECT policy_name, is_active, last_applied FROM nac_policies ORDER BY last_applied DESC LIMIT 10;" nac_db 2>/dev/null
```

**분석 포인트:**
- 활성 세션이 비정상적으로 많음 → 세션 만료 로직 오류
- 인증 실패 급증 → 특정 클라이언트/정책 문제 또는 공격 가능성
- 디바이스 상태 불일치 → 동기화 이슈

---

## 4. 종합 수집 스크립트

모든 정보를 한 번에 수집하는 체크리스트:

```bash
echo "=== 1. 시스템 환경 ==="
cat /etc/os-release | grep PRETTY_NAME
uname -r
uptime
free -h | head -3
df -h | grep -E "^/dev|Filesystem"
cat /proc/loadavg

echo "=== 2. NAC 프로세스 ==="
NAC_PID=$(pgrep -f nac-server | head -1)
ps -o pid,%cpu,%mem,rss,vsz,etime,cmd -p $NAC_PID 2>/dev/null
cat /proc/$NAC_PID/status 2>/dev/null | grep -E "VmRSS|VmSwap|Threads|FDSize"
ls /proc/$NAC_PID/fd 2>/dev/null | wc -l
systemctl status nac-server --no-pager 2>/dev/null | head -15

echo "=== 3. 네트워크 ==="
ss -tlnp | grep -E "nac|8443|1812|1813"
ss -s

echo "=== 4. 최근 에러 로그 ==="
journalctl -u nac-server -p err --since "30 min ago" --no-pager | tail -20

echo "=== 5. DB 상태 ==="
mysql -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null
mysql -e "SHOW PROCESSLIST;" 2>/dev/null | head -20
```

---

## 5. 수집 결과 분석 체크리스트

수집된 정보를 다음 관점에서 교차 분석합니다:

| 확인 항목 | 정상 범위 | 이상 시 의심 |
|-----------|----------|------------|
| 메모리 사용률 | < 80% | 메모리 누수, OOM |
| Swap 사용량 | 0 또는 최소 | 메모리 부족, 프로세스 비정상 |
| CPU load avg | < CPU 코어 수 | 무한 루프, 과부하 |
| 열린 fd 수 | < Max open files의 50% | fd 누수, 소켓 누수 |
| 스레드 수 | 설정된 풀 크기 이내 | 스레드 누수, deadlock |
| DB 연결 수 | < max_connections의 50% | 커넥션 누수 |
| 디스크 사용률 | < 90% | 로그 폭주, 코어 덤프 축적 |
| NAC 프로세스 etime | 기대 가동 시간 | 짧으면 최근 재시작/크래시 |
| 슬로우 쿼리 | 0 또는 최소 | 인덱스 누락, 비효율 쿼리 |
| 활성 세션 수 | 정상 범위 내 | 세션 만료 미처리 |
