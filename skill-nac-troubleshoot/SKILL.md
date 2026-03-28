---
name: nac-troubleshoot
description: NAC 서버 C++ 바이너리 트러블슈팅 스킬. 크래시, 세그폴트, 메모리 누수, 스레딩 이슈, 빌드 오류 등을 체계적으로 진단합니다. Ubuntu 18.04~24.04 환경의 C++ 바이너리 프로젝트에 최적화되어 있습니다. 사용자가 'crash', 'segfault', 'core dump', '크래시', '메모리 누수', 'memory leak', 'valgrind', 'gdb', '디버깅', 'troubleshoot', '트러블슈팅', '오류 분석', 'SIGSEGV', 'SIGABRT', '빌드 실패', 'build error', 'undefined symbol' 등을 언급하면 자동으로 활성화됩니다.
argument-hint: "[증상 설명 또는 바이너리/로그 경로]"
allowed-tools: Read, Grep, Glob, Bash
user-invocable: true
context: fork
agent: general-purpose
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "~/.claude/skills/nac-troubleshoot/scripts/block-dangerous-commands.sh"
          timeout: 5
          statusMessage: "🛡️ 안전 정책 확인 중..."
---

# NAC Server C++ Troubleshooting Skill

---

## 목적

NAC 서버 C++ 바이너리의 문제를 체계적으로 진단하고 근본 원인을 파악합니다:
- 크래시 분석 (core dump, segfault, SIGABRT)
- 메모리 오류 (leak, use-after-free, buffer overflow)
- 스레딩 이슈 (data race, deadlock)
- 빌드/링크 오류 (undefined symbol, ABI 호환성)
- 런타임 이슈 (hang, 성능 저하, 리소스 고갈)

**대상 환경**: Ubuntu 18.04~24.04, C++ 바이너리 프로젝트

## 사용법

```bash
/nac-troubleshoot "segfault 발생 — /var/log/nac/nac-server.log 참조"
/nac-troubleshoot "valgrind 결과에서 메모리 누수 다수 발견"
/nac-troubleshoot "빌드 시 undefined reference to 오류"
/nac-troubleshoot "/path/to/core.12345"
```

## 시스템 컨텍스트 로딩

진단 시작 전 반드시 프로젝트의 시스템 개요를 로드합니다:

```bash
# NAC 서버 시스템 개요 — 아키텍처, 모듈 구조, 의존성 정보
docs/dev/INDEX.md
```

이 문서에서 모듈 간 관계, 빌드 구조, 주요 컴포넌트를 파악한 후 진단을 진행합니다.

## 진단 프로세스

### 1단계: 시스템 환경 및 상태 수집

증상 분석에 앞서 시스템 전반 상태를 파악합니다. 이를 통해 문제 범위를 크게 좁힐 수 있습니다.

**필수 수집 항목:**
```bash
# OS/커널/가동시간
cat /etc/os-release | grep PRETTY_NAME && uname -r && uptime

# 메모리/디스크/로드
free -h | head -3 && df -h | grep "^/dev" && cat /proc/loadavg

# NAC 프로세스 상태
NAC_PID=$(pgrep -f nac-server | head -1)
ps -o pid,%cpu,%mem,rss,vsz,etime,cmd -p $NAC_PID
cat /proc/$NAC_PID/status | grep -E "VmRSS|VmSwap|Threads|FDSize"
ls /proc/$NAC_PID/fd | wc -l

# DB 연결 상태
ss -tnp | grep $NAC_PID | grep -E "3306|5432" | wc -l
mysql -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null
```

**즉각적인 이상 징후 판단:**

| 지표 | 정상 | 이상 → 의심 |
|------|------|------------|
| MemAvailable | > 10% | 부족 → 메모리 누수, OOM |
| Swap 사용 | 0 | 사용 중 → 메모리 부족 |
| Load avg | < CPU 코어 수 | 초과 → 과부하, 무한 루프 |
| fd 수 | < 한계의 50% | 근접 → fd/소켓 누수 |
| 프로세스 etime | 기대 가동시간 | 짧음 → 최근 크래시 재시작 |
| DB 연결 | < max의 50% | 근접 → 커넥션 누수 |

**상세 수집/분석 기법** (시스템, NAC 프로세스, DB 각 영역): [references/system-collection.md](references/system-collection.md) 참조.

### 2단계: 증상 분류

사용자가 보고한 증상을 다음 카테고리로 분류합니다:

| 카테고리 | 키워드 | 1차 분석 | 2차 도구 |
|---------|--------|----------|----------|
| **크래시** | segfault, SIGSEGV, SIGABRT, core dump | 로그 + 소스 추적 | GDB, coredumpctl |
| **메모리** | leak, use-after-free, overflow, valgrind | 로그 + 할당/해제 패턴 | Valgrind, ASan |
| **스레딩** | race, deadlock, hang, TSan | 로그 + 락/스레드 코드 | TSan, GDB thread |
| **빌드** | undefined reference, link error, ABI | 빌드 로그 + CMake/소스 | nm, ldd, objdump |
| **런타임** | slow, timeout, resource, fd leak | 로그 + 리소스 관리 코드 | strace, ltrace, /proc |

### 3단계: 로그 분석 (최우선)

> 대부분의 문제는 로그와 소스만으로 진단 가능합니다. 도구 기반 진단은 범위를 좁힌 후 사용하세요.

**로그 탐색 및 오류 추출:**
```bash
# 에러/경고 필터링
grep -inE "error|fail|fatal|exception|abort|segfault" /path/to/nac.log | tail -30

# 크래시 직전 컨텍스트
grep -B5 -A10 "FATAL\|SIGSEGV\|SIGABRT" /path/to/nac.log

# 반복 오류 패턴 (가장 빈번한 문제 식별)
grep -i "error" /path/to/nac.log | sed 's/[0-9]//g' | sort | uniq -c | sort -rn | head -20

# systemd 서비스 로그
journalctl -u nac-server --since "1 hour ago" --no-pager | tail -50
```

**상세 로그 분석 기법**: [references/log-and-source-analysis.md](references/log-and-source-analysis.md) 참조.

### 4단계: 소스 코드 추적

로그에서 발견된 오류 메시지/위치를 소스 코드에서 추적합니다:

```bash
# 오류 메시지 → 소스 위치 특정
Grep "로그에서_발견된_에러_메시지" --glob "*.cpp" --glob "*.h"

# 문제 함수의 호출 체인 역추적
Grep "함수명\s*\(" --glob "*.cpp"

# 메모리 관리 패턴 확인
Grep "new\b\|delete\b\|malloc\|free" --glob "*.cpp" -- path/to/suspect/

# 최근 변경사항과 교차 확인
git log --oneline -20 -- <suspect-file>
git log -p -S "문제_함수명" -- "*.cpp"
```

**자주 발생하는 NAC 서버 문제 패턴** (인증 크래시, 동시접속 hang, 메모리 증가, 패킷 파싱 등):
[references/log-and-source-analysis.md](references/log-and-source-analysis.md) 참조.

### 5단계: 도구 기반 심층 진단

로그/소스 분석으로 범위를 좁힌 후, 필요시 진단 도구를 사용합니다.
상세 명령어: [references/diagnostic-commands.md](references/diagnostic-commands.md) 참조.

**크래시:** GDB로 core dump 스택 트레이스 추출
**메모리:** Valgrind로 leak/use-after-free 검증
**스레딩:** TSan 또는 GDB thread로 race condition 확인
**시스템:** strace로 시스템 콜 추적

### 6단계: 근본 원인 분석

수집된 증거를 종합하여 근본 원인을 판단합니다:
- 로그 이벤트 ↔ 소스 코드 ↔ 도구 출력 교차 검증
- 재현 조건 파악
- 영향 범위 평가
- git blame/log로 최근 변경이 원인인지 확인

### 7단계: 진단 보고서 작성

다음 형식으로 보고합니다:

```markdown
## 진단 보고서

### 증상
[사용자가 보고한 증상]

### 근본 원인
[분석 결과 — 구체적인 코드 위치 포함]

### 증거
- 시스템 환경: [OS, 메모리, CPU, 디스크 요약]
- NAC 프로세스: [PID, RSS, fd 수, 스레드 수, 가동시간]
- DB 상태: [연결 수, 슬로우 쿼리, 핵심 테이블 상태]
- 로그 분석: [주요 에러 패턴, 시간대]
- 소스 추적: [관련 파일:라인]
- 도구 출력: [GDB/Valgrind/strace 요약]

### 수정 방안
1. [구체적 수정 — 파일:라인 포함]
2. [대안]

### 재현 방법
[재현 단계]

### 예방 조치
[향후 방지를 위한 권장사항]
```

## Ubuntu 버전별 차이

| 도구 | 18.04 | 20.04 | 22.04 | 24.04 |
|------|-------|-------|-------|-------|
| GDB | 8.1 | 9.2 | 12.1 | 14.2 |
| Valgrind | 3.13 | 3.15 | 3.18 | 3.22 |
| coredumpctl | systemd 237 | 245 | 249 | 255 |
| ASan | GCC 7 | GCC 9 | GCC 11 | GCC 13 |

> 18.04에서는 `coredumpctl`이 제한적입니다. `/var/lib/systemd/coredump/`에서 직접 core dump를 확인하세요.

## 안전 정책

이 스킬은 **진단 전용**입니다. PreToolUse 훅이 다음 명령을 자동 차단합니다:
- `rm -rf`, `kill -9`, `pkill`, `killall` — 프로세스/파일 파괴 방지
- `git push`, `git reset --hard` — 코드 변경 방지
- `make install`, `cmake --install` — 바이너리 배포 방지
- `reboot`, `shutdown` — 시스템 재시작 방지

## 지원 파일

- `references/system-collection.md`: 시스템 환경, NAC 프로세스, DB 상태 수집 및 분석 방법
- `references/log-and-source-analysis.md`: 로그 분석 및 소스 코드 추적 방법론
- `references/diagnostic-commands.md`: 카테고리별 진단 명령어 상세
- `references/gdb-cheatsheet.md`: GDB 명령어 빠른 참조
- `references/valgrind-interpretation.md`: Valgrind 출력 해석 가이드
- `scripts/block-dangerous-commands.sh`: PreToolUse 안전 정책 스크립트
