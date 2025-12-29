#!/usr/bin/env bash

# Slack Notification Script for AI Dev Tasks
# Sends formatted messages to Slack webhook
# Usage: ./slack-notify.sh "message" [status]
#   status: success | error | info | warning (default: info)

set -euo pipefail

# Slack webhook URL (must be set in environment)
if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "❌ 오류: SLACK_WEBHOOK_URL 환경 변수가 설정되지 않았습니다."
    echo "   ~/.zshrc 또는 ~/.bashrc에 다음을 추가하세요:"
    echo "   export SLACK_WEBHOOK_URL=\"your_webhook_url_here\""
    exit 1
fi

# Check if message is provided
if [ $# -lt 1 ]; then
    echo "사용법: $0 \"메시지\" [status]"
    echo "  status: success | error | info | warning (기본값: info)"
    exit 1
fi

MESSAGE="$1"
STATUS="${2:-info}"

# Determine emoji based on status
case "$STATUS" in
    success)
        EMOJI=":white_check_mark:"
        COLOR="#36a64f"  # Green
        ;;
    error)
        EMOJI=":x:"
        COLOR="#ff0000"  # Red
        ;;
    warning)
        EMOJI=":warning:"
        COLOR="#ff9900"  # Orange
        ;;
    info|*)
        EMOJI=":information_source:"
        COLOR="#0099ff"  # Blue
        ;;
esac

# Get current timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Get project path
PROJECT_PATH=$(pwd)

# Truncate message to 1000 characters if needed
if [ ${#MESSAGE} -gt 1000 ]; then
    MESSAGE="${MESSAGE:0:997}..."
fi

# Prepare JSON payload
PAYLOAD=$(cat <<EOF
{
    "attachments": [
        {
            "color": "$COLOR",
            "fallback": "$MESSAGE",
            "title": "$EMOJI AI Dev Tasks 알림",
            "text": "$MESSAGE",
            "fields": [
                {
                    "title": "프로젝트 경로",
                    "value": "$PROJECT_PATH",
                    "short": false
                },
                {
                    "title": "시간",
                    "value": "$TIMESTAMP",
                    "short": true
                },
                {
                    "title": "상태",
                    "value": "$STATUS",
                    "short": true
                }
            ],
            "footer": "AI Dev Tasks",
            "ts": $(date +%s)
        }
    ]
}
EOF
)

# Send to Slack
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H 'Content-Type: application/json' \
    -d "$PAYLOAD" \
    "$SLACK_WEBHOOK_URL")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Slack 알림 전송 완료"
    exit 0
else
    echo "❌ Slack 알림 전송 실패 (HTTP $HTTP_CODE)"
    exit 1
fi
