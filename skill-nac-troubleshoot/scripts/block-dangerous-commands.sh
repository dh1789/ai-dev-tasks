#!/bin/bash
# block-dangerous-commands.sh - PreToolUse 훅: 위험 명령 차단
# NAC 트러블슈팅은 진단 전용 — 파괴적 명령을 차단합니다.
#
# stdin으로 tool_input JSON을 받아 위험 명령 포함 여부를 검사합니다.

command=$(cat /dev/stdin | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# 차단 패턴 목록
BLOCKED_PATTERNS=(
    'rm -rf'
    'rm -r /'
    'kill -9'
    'kill -KILL'
    'pkill'
    'killall'
    'git push'
    'git reset --hard'
    'git clean -f'
    'make install'
    'cmake --install'
    'reboot'
    'shutdown'
    'systemctl stop'
    'systemctl restart'
    'dd if='
    'mkfs'
    'fdisk'
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$command" | grep -qE "\b${pattern}\b"; then
        cat <<DENY
{"decision":"deny","reason":"🛡️ 차단: '${pattern}' — NAC 트러블슈팅은 진단 전용입니다. 파괴적/변경 명령은 사용자가 직접 실행하세요."}
DENY
        exit 0
    fi
done

# 허용
exit 0
