---
name: obsidian-note
description: Obsidian 노트 관리 스킬. 노트 생성, 읽기, 내용 추가/삽입, 열기, 삭제, 이동, 이름 변경 등 노트 CRUD 작업을 수행합니다. 사용자가 '노트 생성', '노트 읽기', '노트 삭제', '파일 이동', '이름 변경', 'obsidian note', 'obsidian create', 'obsidian read' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 노트 관리 스킬

Obsidian CLI를 통해 볼트 내 노트의 CRUD 작업을 수행합니다.

## 사용법

```bash
/obsidian-note "create 노트제목"
/obsidian-note "read 노트이름"
/obsidian-note "append 노트이름 내용"
/obsidian-note "delete 노트이름"
```

## 지원 커맨드

### create - 새 노트 생성

새 마크다운 파일을 볼트에 생성합니다.

```bash
obsidian create name="노트 제목" content="초기 내용" template="템플릿명" open newtab overwrite
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `content=<text>` | 초기 내용 |
| `template=<name>` | 사용할 템플릿 |
| `overwrite` | 기존 파일 덮어쓰기 |
| `open` | 생성 후 파일 열기 |
| `newtab` | 새 탭에서 열기 |

### read - 노트 내용 읽기

파일의 전체 내용을 읽어 반환합니다.

```bash
obsidian read file="노트 이름"
obsidian read path="folder/note.md"
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 (위키링크 방식 해석) |
| `path=<path>` | 정확한 파일 경로 |

### append - 노트 끝에 내용 추가

파일 끝에 텍스트를 추가합니다.

```bash
obsidian append file="노트 이름" content="추가할 내용"
obsidian append file="노트 이름" content="같은 줄에 추가" inline
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `content=<text>` | 추가할 내용 (필수) |
| `inline` | 줄바꿈 없이 같은 줄에 추가 |

### prepend - 노트 앞에 내용 삽입

파일 시작 부분에 텍스트를 삽입합니다.

```bash
obsidian prepend file="노트 이름" content="삽입할 내용"
obsidian prepend file="노트 이름" content="같은 줄에 삽입" inline
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `content=<text>` | 삽입할 내용 (필수) |
| `inline` | 줄바꿈 없이 같은 줄에 삽입 |

### open - 노트 열기

Obsidian에서 파일을 엽니다.

```bash
obsidian open file="노트 이름"
obsidian open file="노트 이름" newtab
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `newtab` | 새 탭에서 열기 |

### delete - 노트 삭제

파일을 휴지통으로 이동하거나 영구 삭제합니다.

```bash
obsidian delete file="노트 이름"
obsidian delete file="노트 이름" permanent
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `permanent` | 휴지통 건너뛰고 영구 삭제 |

### move - 노트 이동

파일을 다른 폴더로 이동합니다.

```bash
obsidian move file="노트 이름" to="새폴더/새이름.md"
obsidian move path="old/path.md" to="new/path.md"
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `to=<path>` | 목적지 폴더 또는 경로 (필수) |

### rename - 노트 이름 변경

파일의 이름을 변경합니다.

```bash
obsidian rename file="기존 이름" name="새 이름"
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `name=<name>` | 새 파일 이름 (필수) |

### file - 파일 정보 조회

파일의 메타데이터 정보를 확인합니다.

```bash
obsidian file file="노트 이름"
obsidian file path="folder/note.md"
```

### files - 볼트 파일 목록

볼트 내 파일 목록을 조회합니다.

```bash
obsidian files
obsidian files folder="특정폴더" ext="md" total
```

| 옵션 | 설명 |
|------|------|
| `folder=<path>` | 폴더별 필터링 |
| `ext=<extension>` | 확장자별 필터링 |
| `total` | 파일 수만 반환 |

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- `file=`은 위키링크 방식으로 이름을 해석합니다
- `path=`는 정확한 파일 경로입니다 (예: `folder/note.md`)
- 대부분의 커맨드는 `file`/`path` 생략 시 현재 활성 파일을 대상으로 합니다
- 공백이 포함된 값은 따옴표로 감싸세요: `name="My Note"`
- `\n`은 줄바꿈, `\t`는 탭으로 해석됩니다
