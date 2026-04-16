---
name: obsidian-task
description: Obsidian 태스크 관리 스킬. 볼트 내 체크리스트 태스크를 조회, 필터링, 상태 변경합니다. 사용자가 '태스크', '할 일', 'todo', 'task', '체크리스트', '완료 표시', 'obsidian task' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 태스크 관리 스킬

Obsidian CLI를 통해 볼트 내 체크리스트 태스크를 관리합니다.

## 사용법

```bash
/obsidian-task "list"
/obsidian-task "list todo"
/obsidian-task "toggle 노트이름 42"
/obsidian-task "done 노트이름 15"
```

## 지원 커맨드

### tasks - 태스크 목록 조회

볼트 내 체크리스트 태스크를 나열합니다.

```bash
obsidian tasks
obsidian tasks todo
obsidian tasks done
obsidian tasks file="노트 이름"
obsidian tasks status="/" verbose
obsidian tasks active daily
obsidian tasks total format=json
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 특정 파일의 태스크 |
| `path=<path>` | 특정 경로의 태스크 |
| `total` | 태스크 수만 반환 |
| `done` | 완료된 태스크만 |
| `todo` | 미완료 태스크만 |
| `status="<char>"` | 특정 상태 문자로 필터 (예: "/", "x", " ") |
| `verbose` | 파일별 그룹 + 줄 번호 포함 |
| `format=json\|tsv\|csv` | 출력 형식 (기본: text) |
| `active` | 현재 활성 파일의 태스크 |
| `daily` | 데일리 노트의 태스크 |

### task - 태스크 조회/상태 변경

특정 태스크를 조회하거나 상태를 변경합니다.

```bash
# 태스크 조회
obsidian task file="노트 이름" line=42
obsidian task ref="folder/note.md:42"

# 태스크 상태 변경
obsidian task file="노트 이름" line=42 toggle
obsidian task file="노트 이름" line=42 done
obsidian task file="노트 이름" line=42 todo
obsidian task file="노트 이름" line=42 status="/"
obsidian task daily line=5 toggle
```

| 옵션 | 설명 |
|------|------|
| `ref=<path:line>` | 태스크 참조 (경로:줄번호) |
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `line=<n>` | 줄 번호 |
| `toggle` | 태스크 상태 토글 (완료↔미완료) |
| `done` | 완료로 표시 |
| `todo` | 미완료로 표시 |
| `daily` | 데일리 노트 사용 |
| `status="<char>"` | 특정 상태 문자 설정 |

## 상태 문자 참고

| 문자 | 의미 |
|------|------|
| ` ` (공백) | 미완료 (todo) |
| `x` | 완료 (done) |
| `/` | 진행 중 |
| `-` | 취소됨 |
| `>` | 연기됨 |
| `?` | 질문/확인 필요 |

## 활용 예시

### 미완료 태스크 전체 확인
```bash
obsidian tasks todo verbose
```

### 데일리 노트의 할 일 확인
```bash
obsidian tasks daily todo
```

### 태스크 완료 처리
```bash
obsidian task file="프로젝트 A" line=15 done
```

### 특정 상태의 태스크 필터링
```bash
# 진행 중인 태스크만
obsidian tasks status="/"
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian task(s)` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- 태스크는 마크다운 체크리스트 형식 (`- [ ] 내용`)을 사용합니다
- `line` 번호는 파일 내 태스크의 줄 위치를 나타냅니다
- `verbose` 옵션으로 파일별 그룹화 및 줄 번호를 확인할 수 있습니다
- 커스텀 상태 문자(/, -, > 등)는 Obsidian Tasks 플러그인 설정에 따릅니다
