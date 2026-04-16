---
name: obsidian-ui
description: Obsidian UI 제어 스킬. 탭 관리, 워크스페이스, 아웃라인, 최근 파일, 랜덤 노트, 명령어 실행, 단축키 조회를 수행합니다. 사용자가 '탭', '워크스페이스', '아웃라인', '최근 파일', '랜덤 노트', '단축키', 'hotkey', 'obsidian ui', '명령어 실행' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian UI 제어 스킬

Obsidian CLI를 통해 UI 요소를 제어합니다.

## 사용법

```bash
/obsidian-ui "tabs"
/obsidian-ui "outline 노트이름"
/obsidian-ui "recents"
/obsidian-ui "random"
/obsidian-ui "command editor:toggle-fold"
```

## 지원 커맨드

### tabs - 열린 탭 목록

현재 열려 있는 모든 탭을 나열합니다.

```bash
obsidian tabs
obsidian tabs ids
```

| 옵션 | 설명 |
|------|------|
| `ids` | 탭 ID 포함 |

### tab:open - 새 탭 열기

새 탭을 열거나 특정 파일/뷰를 새 탭에서 엽니다.

```bash
obsidian tab:open
obsidian tab:open file="folder/note.md"
obsidian tab:open view="graph"
obsidian tab:open group="1"
```

| 옵션 | 설명 |
|------|------|
| `group=<id>` | 탭 그룹 ID |
| `file=<path>` | 열 파일 |
| `view=<type>` | 열 뷰 타입 |

### workspace - 워크스페이스 트리

현재 워크스페이스의 레이아웃 트리를 보여줍니다.

```bash
obsidian workspace
obsidian workspace ids
```

| 옵션 | 설명 |
|------|------|
| `ids` | 워크스페이스 항목 ID 포함 |

### outline - 파일 헤딩 아웃라인

파일의 헤딩(목차) 구조를 보여줍니다.

```bash
obsidian outline
obsidian outline file="노트 이름"
obsidian outline file="노트 이름" format=tree
obsidian outline file="노트 이름" format=md
obsidian outline file="노트 이름" format=json
obsidian outline file="노트 이름" total
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `format=tree\|md\|json` | 출력 형식 (기본: tree) |
| `total` | 헤딩 수만 반환 |

### recents - 최근 열린 파일 목록

최근에 열었던 파일을 나열합니다.

```bash
obsidian recents
obsidian recents total
```

| 옵션 | 설명 |
|------|------|
| `total` | 최근 파일 수만 반환 |

### random - 랜덤 노트 열기

볼트에서 임의의 노트를 엽니다.

```bash
obsidian random
obsidian random folder="특정폴더"
obsidian random newtab
```

| 옵션 | 설명 |
|------|------|
| `folder=<path>` | 특정 폴더로 제한 |
| `newtab` | 새 탭에서 열기 |

### random:read - 랜덤 노트 읽기

볼트에서 임의의 노트 내용을 읽어 반환합니다.

```bash
obsidian random:read
obsidian random:read folder="지식"
```

| 옵션 | 설명 |
|------|------|
| `folder=<path>` | 특정 폴더로 제한 |

### command - Obsidian 명령어 실행

Obsidian의 커맨드 팔레트 명령어를 실행합니다.

```bash
obsidian command id="editor:toggle-fold"
obsidian command id="app:toggle-left-sidebar"
```

| 옵션 | 설명 |
|------|------|
| `id=<command-id>` | 명령어 ID (필수) |

### commands - 사용 가능한 명령어 목록

Obsidian에서 사용 가능한 모든 명령어를 나열합니다.

```bash
obsidian commands
obsidian commands filter="editor"
```

| 옵션 | 설명 |
|------|------|
| `filter=<prefix>` | ID 접두사로 필터 |

### hotkey - 단축키 조회

특정 명령어의 단축키를 확인합니다.

```bash
obsidian hotkey id="editor:toggle-bold"
obsidian hotkey id="editor:toggle-bold" verbose
```

| 옵션 | 설명 |
|------|------|
| `id=<command-id>` | 명령어 ID (필수) |
| `verbose` | 커스텀/기본 여부 표시 |

### hotkeys - 전체 단축키 목록

설정된 모든 단축키를 나열합니다.

```bash
obsidian hotkeys
obsidian hotkeys total verbose
obsidian hotkeys all format=json
```

| 옵션 | 설명 |
|------|------|
| `total` | 단축키 수만 반환 |
| `verbose` | 커스텀/기본 여부 표시 |
| `format=json\|tsv\|csv` | 출력 형식 (기본: tsv) |
| `all` | 단축키 없는 명령어도 포함 |

## 활용 예시

### 현재 작업 환경 확인
```bash
obsidian tabs
obsidian workspace
```

### 문서 구조 파악
```bash
obsidian outline file="프로젝트 문서" format=tree
```

### 랜덤 복습
```bash
obsidian random:read folder="학습"
```

### 명령어 검색 및 실행
```bash
# 에디터 관련 명령어 검색
obsidian commands filter="editor"
# 명령어 실행
obsidian command id="editor:toggle-fold"
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- `command` 명령어의 ID는 `commands` 목록에서 확인할 수 있습니다
- `random`은 Obsidian에서 파일을 열고, `random:read`는 내용만 반환합니다
- `outline`의 `format=tree`가 가장 읽기 좋은 형식입니다
- `hotkeys all`은 단축키가 없는 명령어까지 전부 포함합니다
