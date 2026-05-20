#!/bin/sh
# Claude Code 상태 표시줄 스크립트
# 형식: 🟢 컨텍스트 N% │ 🟡 세션 N% (리셋 HH:MM) │ 🟢 주간 N% (리셋 M/D) │ ~/path@branch │ 모델 💭level

input=$(cat)

# --- 이모지 상태 함수 ---
# 인자: 정수 퍼센트
status_emoji() {
  pct="$1"
  if [ -z "$pct" ] || [ "$pct" = "?" ]; then
    echo "⚪"
  elif [ "$pct" -ge 80 ]; then
    echo "🔴"
  elif [ "$pct" -ge 50 ]; then
    echo "🟡"
  else
    echo "🟢"
  fi
}

# ANSI 색상 강조 함수 (50%↑ 노랑, 80%↑ 빨강)
ansi_label() {
  label="$1"
  pct="$2"
  if [ -z "$pct" ] || [ "$pct" = "?" ]; then
    echo "$label"
  elif [ "$pct" -ge 80 ]; then
    printf "\033[31m%s\033[0m" "$label"
  elif [ "$pct" -ge 50 ]; then
    printf "\033[33m%s\033[0m" "$label"
  else
    echo "$label"
  fi
}

# --- 1. 컨텍스트 사용률 ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
if [ -z "$used_pct" ]; then
  # used_percentage가 null이면 current_usage.input_tokens / context_window_size로 계산
  cur_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty' 2>/dev/null)
  win_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty' 2>/dev/null)
  if [ -n "$cur_input" ] && [ -n "$win_size" ] && [ "$win_size" -gt 0 ] 2>/dev/null; then
    used_pct=$(echo "$cur_input $win_size" | awk '{printf "%.1f", $1/$2*100}')
  fi
fi
if [ -n "$used_pct" ]; then
  ctx_int=$(echo "$used_pct" | awk '{printf "%.0f", $1}')
  ctx_emoji=$(status_emoji "$ctx_int")
  ctx_label=$(ansi_label "컨텍스트" "$ctx_int")
  ctx_display="${ctx_emoji} ${ctx_label} ${ctx_int}%"
else
  ctx_display="⚪ 컨텍스트 ?%"
fi

# --- 2. 세션 사용량 + 리셋 시각 (5시간 윈도우) ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)

if [ -n "$five_pct" ]; then
  sess_int=$(echo "$five_pct" | awk '{printf "%.0f", $1}')
  sess_emoji=$(status_emoji "$sess_int")
  sess_label=$(ansi_label "세션" "$sess_int")
  if [ -n "$five_reset" ] && [ "$five_reset" != "null" ]; then
    reset_time=$(TZ=Asia/Seoul date -r "$five_reset" "+%H:%M" 2>/dev/null || TZ=Asia/Seoul date -d "@${five_reset}" "+%H:%M" 2>/dev/null)
    if [ -n "$reset_time" ]; then
      sess_display="${sess_emoji} ${sess_label} ${sess_int}% (리셋 ${reset_time})"
    else
      sess_display="${sess_emoji} ${sess_label} ${sess_int}% (리셋 ?)"
    fi
  else
    sess_display="${sess_emoji} ${sess_label} ${sess_int}% (리셋 ?)"
  fi
else
  sess_display="⚪ 세션 ?% (리셋 ?)"
fi

# --- 3. 주간 사용량 + 리셋 일자 ---
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)

if [ -n "$week_pct" ]; then
  week_int=$(echo "$week_pct" | awk '{printf "%.0f", $1}')
  week_emoji=$(status_emoji "$week_int")
  week_label=$(ansi_label "주간" "$week_int")
  if [ -n "$week_reset" ] && [ "$week_reset" != "null" ]; then
    reset_date=$(TZ=Asia/Seoul date -r "$week_reset" "+%-m/%-d" 2>/dev/null || TZ=Asia/Seoul date -d "@${week_reset}" "+%-m/%-d" 2>/dev/null)
    if [ -n "$reset_date" ]; then
      week_display="${week_emoji} ${week_label} ${week_int}% (리셋 ${reset_date})"
    else
      week_display="${week_emoji} ${week_label} ${week_int}% (리셋 ?)"
    fi
  else
    week_display="${week_emoji} ${week_label} ${week_int}% (리셋 ?)"
  fi
else
  # ccusage CLI 시도 (없으면 조용히 실패)
  ccusage_out=""
  if command -v ccusage >/dev/null 2>&1; then
    ccusage_out=$(ccusage blocks --json 2>/dev/null | jq -r '.[0].usagePercent // empty' 2>/dev/null)
  fi
  if [ -n "$ccusage_out" ]; then
    week_int=$(echo "$ccusage_out" | awk '{printf "%.0f", $1}')
    week_emoji=$(status_emoji "$week_int")
    week_label=$(ansi_label "주간" "$week_int")
    week_display="${week_emoji} ${week_label} ${week_int}% (리셋 ?)"
  else
    week_display="⚪ 주간 ?% (리셋 ?)"
  fi
fi

# --- 4. 호스트네임 + 현재 디렉토리 + git 브랜치 ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
if [ -z "$cwd" ]; then
  cwd=$(pwd)
fi

# 호스트네임 (short)
host_name=$(hostname -s 2>/dev/null)

# ~/로 치환
home_dir="$HOME"
short_cwd=$(echo "$cwd" | sed "s|^${home_dir}|~|")

dir_display="${host_name}:${short_cwd}"
if [ -d "$cwd" ]; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$git_branch" ]; then
    dir_display="${host_name}:${short_cwd}@${git_branch}"
  fi
fi

# --- 5. 모델 + thinking 레벨 ---
model_name=$(echo "$input" | jq -r '.model.display_name // empty' 2>/dev/null)
if [ -z "$model_name" ]; then
  model_name=$(echo "$input" | jq -r '.model.id // "unknown"' 2>/dev/null)
fi

effort=$(echo "$input" | jq -r '.effort.level // empty' 2>/dev/null)
thinking=$(echo "$input" | jq -r '.thinking.enabled // false' 2>/dev/null)

if [ -n "$effort" ]; then
  case "$effort" in
    low)    think_label="💭 low" ;;
    medium) think_label="💭 med" ;;
    high)   think_label="💭 high" ;;
    xhigh)  think_label="💭 xhigh" ;;
    max)    think_label="💭 max" ;;
    *)      think_label="💭 ${effort}" ;;
  esac
elif [ "$thinking" = "true" ]; then
  think_label="💭 on"
else
  think_label="💭 off"
fi

model_display="${model_name} ${think_label}"

# --- 최종 출력 (한 줄) ---
SEP=" │ "
printf "%s%s%s%s%s%s%s%s%s" \
  "$model_display" \
  "$SEP" \
  "$ctx_display" \
  "$SEP" \
  "$sess_display" \
  "$SEP" \
  "$week_display" \
  "$SEP" \
  "$dir_display"
