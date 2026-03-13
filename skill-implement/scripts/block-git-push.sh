#!/bin/bash
# block-git-push.sh - PreToolUse 훅: git push 명령 차단
# MUST 규칙: "푸시 금지 — git push는 사용자가 수동으로"
#
# stdin으로 tool_input JSON을 받아 git push 포함 여부를 검사합니다.
# 차단 시 JSON으로 deny 결정을 출력합니다.

command=$(cat /dev/stdin | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

if echo "$command" | grep -qE '\bgit\s+push\b'; then
    cat <<'DENY'
{"decision":"deny","reason":"🔴 git push 차단: implement 스킬 규칙에 의해 push는 금지됩니다. 사용자가 직접 수행하세요."}
DENY
    exit 0
fi

# 허용
exit 0
