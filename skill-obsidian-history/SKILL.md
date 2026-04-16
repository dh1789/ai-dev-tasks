---
name: obsidian-history
description: Obsidian 히스토리 및 버전 관리 스킬. 파일 히스토리 조회, 버전 읽기, 복원, diff 비교를 수행합니다. 사용자가 '히스토리', '버전', '복원', 'history', 'restore', 'diff', '변경 이력', '이전 버전', 'obsidian history' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 히스토리/버전 관리 스킬

Obsidian CLI를 통해 파일 히스토리와 버전을 관리합니다.

## 사용법

```bash
/obsidian-history "list 노트이름"
/obsidian-history "read 노트이름 version=3"
/obsidian-history "restore 노트이름 version=2"
/obsidian-history "diff 노트이름 from=1 to=3"
```

## 지원 커맨드

### history - 파일 히스토리 버전 목록

특정 파일의 히스토리 버전을 나열합니다.

```bash
obsidian history file="노트 이름"
obsidian history path="folder/note.md"
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |

### history:list - 히스토리가 있는 파일 목록

히스토리 버전이 존재하는 파일 목록을 조회합니다.

```bash
obsidian history:list
```

### history:read - 특정 버전 내용 읽기

파일의 특정 히스토리 버전 내용을 읽습니다.

```bash
obsidian history:read file="노트 이름" version=1
obsidian history:read file="노트 이름" version=3
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `version=<n>` | 버전 번호 (기본: 1, 가장 최근) |

### history:restore - 이전 버전 복원

파일을 특정 히스토리 버전으로 복원합니다.

```bash
obsidian history:restore file="노트 이름" version=2
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `version=<n>` | 복원할 버전 번호 (필수) |

### history:open - 파일 복구 UI 열기

Obsidian의 파일 복구 인터페이스를 엽니다.

```bash
obsidian history:open file="노트 이름"
obsidian history:open path="folder/note.md"
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |

### diff - 버전 간 차이 비교

로컬/싱크 버전 간 차이를 비교합니다.

```bash
# 버전 목록 조회
obsidian diff file="노트 이름"
obsidian diff file="노트 이름" filter=local
obsidian diff file="노트 이름" filter=sync

# 두 버전 간 diff
obsidian diff file="노트 이름" from=1 to=3
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `from=<n>` | 비교 시작 버전 번호 |
| `to=<n>` | 비교 끝 버전 번호 |
| `filter=local\|sync` | 버전 소스별 필터 |

## 활용 예시

### 파일 변경 이력 확인
```bash
# 히스토리 버전 목록
obsidian history file="프로젝트 노트"
# 특정 버전 내용 확인
obsidian history:read file="프로젝트 노트" version=2
```

### 실수로 삭제한 내용 복원
```bash
# 이전 버전 내용 먼저 확인
obsidian history:read file="중요 노트" version=1
# 복원
obsidian history:restore file="중요 노트" version=1
```

### 버전 간 변경사항 비교
```bash
obsidian diff file="설계 문서" from=1 to=5
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian history*` 또는 `obsidian diff` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- 버전 번호 1이 가장 최근 버전입니다
- File Recovery 코어 플러그인이 활성화되어 있어야 합니다
- `diff`의 `filter` 옵션으로 로컬 버전과 싱크 버전을 구분할 수 있습니다
- `history:restore`는 현재 파일을 덮어쓰므로 주의하세요
