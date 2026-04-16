---
name: obsidian-daily
description: Obsidian 데일리 노트 관리 스킬. 데일리 노트 열기, 읽기, 내용 추가/삽입, 경로 확인 등 일일 노트 워크플로우를 수행합니다. 사용자가 '데일리 노트', '오늘 노트', '일기', 'daily note', '일일 기록', 'obsidian daily' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 데일리 노트 스킬

Obsidian CLI를 통해 데일리 노트를 관리합니다.

## 사용법

```bash
/obsidian-daily "open"
/obsidian-daily "read"
/obsidian-daily "append 오늘 할 일 목록"
/obsidian-daily "prepend 아침 메모"
```

## 지원 커맨드

### daily - 데일리 노트 열기

오늘의 데일리 노트를 Obsidian에서 엽니다. 없으면 자동 생성됩니다.

```bash
obsidian daily
obsidian daily paneType=tab
obsidian daily paneType=split
obsidian daily paneType=window
```

| 옵션 | 설명 |
|------|------|
| `paneType=tab\|split\|window` | 열기 방식 (탭/분할/새 창) |

### daily:read - 데일리 노트 읽기

오늘의 데일리 노트 내용을 읽어 반환합니다.

```bash
obsidian daily:read
```

### daily:append - 데일리 노트 끝에 내용 추가

데일리 노트 끝에 텍스트를 추가합니다.

```bash
obsidian daily:append content="추가할 내용"
obsidian daily:append content="같은 줄에 추가" inline
obsidian daily:append content="내용" open paneType=tab
```

| 옵션 | 설명 |
|------|------|
| `content=<text>` | 추가할 내용 (필수) |
| `inline` | 줄바꿈 없이 같은 줄에 추가 |
| `open` | 추가 후 파일 열기 |
| `paneType=tab\|split\|window` | 열기 방식 |

### daily:prepend - 데일리 노트 앞에 내용 삽입

데일리 노트 시작 부분에 텍스트를 삽입합니다.

```bash
obsidian daily:prepend content="삽입할 내용"
obsidian daily:prepend content="같은 줄에 삽입" inline
obsidian daily:prepend content="내용" open paneType=split
```

| 옵션 | 설명 |
|------|------|
| `content=<text>` | 삽입할 내용 (필수) |
| `inline` | 줄바꿈 없이 같은 줄에 삽입 |
| `open` | 삽입 후 파일 열기 |
| `paneType=tab\|split\|window` | 열기 방식 |

### daily:path - 데일리 노트 경로 확인

오늘의 데일리 노트 파일 경로를 반환합니다.

```bash
obsidian daily:path
```

## 활용 예시

### 아침 루틴 기록
```bash
obsidian daily:prepend content="## 아침 메모\n- 오늘 할 일: ..."
```

### 회의 메모 추가
```bash
obsidian daily:append content="\n## 회의 메모 (14:00)\n- 참석자: ...\n- 논의 사항: ..."
```

### 데일리 노트 내용 확인 후 분석
```bash
obsidian daily:read
# 결과를 바탕으로 작업 목록 추출 가능
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian daily:*` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- 데일리 노트 플러그인이 활성화되어 있어야 합니다
- 데일리 노트의 경로/형식은 Obsidian 설정에 따릅니다
- `\n`으로 줄바꿈, `\t`로 탭을 삽입할 수 있습니다
