---
name: obsidian-tag
description: Obsidian 태그, 속성, 별칭 관리 스킬. 태그 목록/정보 조회, 속성(프론트매터) 읽기/쓰기/삭제, 별칭 조회를 수행합니다. 사용자가 '태그', '속성', '프론트매터', 'property', 'tag', 'alias', '별칭', 'frontmatter', 'obsidian tag', 'obsidian property' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 태그/속성/별칭 관리 스킬

Obsidian CLI를 통해 태그, 속성(프론트매터), 별칭을 관리합니다.

## 사용법

```bash
/obsidian-tag "tags"
/obsidian-tag "tag 프로젝트"
/obsidian-tag "property:set 노트이름 status done"
/obsidian-tag "aliases 노트이름"
```

## 지원 커맨드

### tags - 태그 목록 조회

볼트 내 모든 태그 또는 특정 파일의 태그를 나열합니다.

```bash
obsidian tags
obsidian tags counts sort=count
obsidian tags file="노트 이름" total
obsidian tags active
obsidian tags format=json
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 특정 파일의 태그 |
| `path=<path>` | 특정 경로의 태그 |
| `total` | 태그 수만 반환 |
| `counts` | 태그 사용 횟수 포함 |
| `sort=count` | 횟수 기준 정렬 (기본: 이름순) |
| `format=json\|tsv\|csv` | 출력 형식 (기본: tsv) |
| `active` | 현재 활성 파일의 태그 |

### tag - 태그 상세 정보

특정 태그의 사용 현황을 확인합니다.

```bash
obsidian tag name="프로젝트"
obsidian tag name="프로젝트" total
obsidian tag name="프로젝트" verbose
```

| 옵션 | 설명 |
|------|------|
| `name=<tag>` | 태그 이름 (필수) |
| `total` | 사용 횟수만 반환 |
| `verbose` | 파일 목록과 횟수 포함 |

### properties - 속성(프론트매터) 목록

볼트 또는 특정 파일의 속성 목록을 조회합니다.

```bash
obsidian properties
obsidian properties file="노트 이름"
obsidian properties counts sort=count
obsidian properties name="status" total
obsidian properties active format=json
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 특정 파일의 속성 |
| `path=<path>` | 특정 경로의 속성 |
| `name=<name>` | 특정 속성의 횟수 |
| `total` | 속성 수만 반환 |
| `sort=count` | 횟수 기준 정렬 (기본: 이름순) |
| `counts` | 사용 횟수 포함 |
| `format=yaml\|json\|tsv` | 출력 형식 (기본: yaml) |
| `active` | 현재 활성 파일의 속성 |

### property:read - 속성 값 읽기

파일의 특정 속성 값을 읽습니다.

```bash
obsidian property:read name="status" file="노트 이름"
obsidian property:read name="tags" path="folder/note.md"
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 속성 이름 (필수) |
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |

### property:set - 속성 값 설정

파일에 속성을 설정하거나 업데이트합니다.

```bash
obsidian property:set name="status" value="done" file="노트 이름"
obsidian property:set name="priority" value="1" type=number file="노트 이름"
obsidian property:set name="due" value="2026-04-15" type=date file="노트 이름"
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 속성 이름 (필수) |
| `value=<value>` | 속성 값 (필수) |
| `type=text\|list\|number\|checkbox\|date\|datetime` | 속성 타입 |
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |

### property:remove - 속성 삭제

파일에서 특정 속성을 제거합니다.

```bash
obsidian property:remove name="status" file="노트 이름"
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 속성 이름 (필수) |
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |

### aliases - 별칭 목록

볼트 또는 특정 파일의 별칭을 조회합니다.

```bash
obsidian aliases
obsidian aliases file="노트 이름"
obsidian aliases total verbose
obsidian aliases active
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 특정 파일의 별칭 |
| `path=<path>` | 특정 경로의 별칭 |
| `total` | 별칭 수만 반환 |
| `verbose` | 파일 경로 포함 |
| `active` | 현재 활성 파일의 별칭 |

## 활용 예시

### 태그 현황 분석
```bash
obsidian tags counts sort=count format=json
```

### 노트 상태 일괄 관리
```bash
# 속성 확인
obsidian property:read name="status" file="프로젝트 A"
# 속성 변경
obsidian property:set name="status" value="completed" file="프로젝트 A"
```

### 속성 타입별 관리
```bash
obsidian property:set name="reviewed" value="true" type=checkbox file="노트"
obsidian property:set name="count" value="42" type=number file="노트"
```

## 실행 프로세스

1. 사용자 요청에서 커맨드, 대상, 옵션 파싱
2. `obsidian` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- 속성(property)은 YAML 프론트매터에 저장됩니다
- `type` 옵션으로 속성의 데이터 타입을 명시할 수 있습니다
- 별칭(alias)은 프론트매터의 `aliases` 속성에 해당합니다
- `active` 옵션은 Obsidian에서 현재 열려 있는 파일을 대상으로 합니다
