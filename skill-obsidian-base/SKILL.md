---
name: obsidian-base
description: Obsidian 베이스(데이터베이스) 관리 스킬. 베이스 파일 목록 조회, 뷰 목록, 데이터 쿼리, 새 항목 생성을 수행합니다. 사용자가 '베이스', 'base', '데이터베이스', 'DB', '테이블', 'obsidian base', '쿼리' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 베이스(데이터베이스) 관리 스킬

Obsidian CLI를 통해 베이스(데이터베이스) 기능을 관리합니다.

## 사용법

```bash
/obsidian-base "list"
/obsidian-base "query 프로젝트DB"
/obsidian-base "create 프로젝트DB name=새항목"
/obsidian-base "views 프로젝트DB"
```

## 지원 커맨드

### bases - 베이스 파일 목록

볼트 내 모든 베이스 파일을 나열합니다.

```bash
obsidian bases
```

### base:views - 베이스 뷰 목록

베이스 파일 내 뷰(테이블, 보드, 캘린더 등)를 나열합니다.

```bash
obsidian base:views file="프로젝트 DB"
obsidian base:views path="bases/projects.md"
```

### base:query - 베이스 데이터 쿼리

베이스의 특정 뷰에서 데이터를 조회합니다.

```bash
obsidian base:query file="프로젝트 DB"
obsidian base:query file="프로젝트 DB" view="진행중"
obsidian base:query file="프로젝트 DB" format=json
obsidian base:query file="프로젝트 DB" format=csv
obsidian base:query file="프로젝트 DB" format=md
obsidian base:query file="프로젝트 DB" format=paths
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 베이스 파일 이름 |
| `path=<path>` | 베이스 파일 경로 |
| `view=<name>` | 쿼리할 뷰 이름 |
| `format=json\|csv\|tsv\|md\|paths` | 출력 형식 (기본: json) |

### base:create - 베이스에 새 항목 생성

베이스에 새 항목(노트)을 추가합니다.

```bash
obsidian base:create file="프로젝트 DB" name="새 프로젝트"
obsidian base:create file="프로젝트 DB" view="진행중" name="태스크" content="내용"
obsidian base:create file="프로젝트 DB" name="항목" open newtab
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 베이스 파일 이름 |
| `path=<path>` | 베이스 파일 경로 |
| `view=<name>` | 뷰 이름 |
| `name=<name>` | 새 파일 이름 |
| `content=<text>` | 초기 내용 |
| `open` | 생성 후 파일 열기 |
| `newtab` | 새 탭에서 열기 |

## 활용 예시

### 베이스 현황 파악
```bash
# 전체 베이스 목록
obsidian bases
# 특정 베이스의 뷰 확인
obsidian base:views file="프로젝트 DB"
```

### 데이터 조회
```bash
# JSON 형식으로 전체 데이터 조회
obsidian base:query file="프로젝트 DB" format=json
# 특정 뷰의 데이터만
obsidian base:query file="프로젝트 DB" view="완료" format=md
# 파일 경로만 추출
obsidian base:query file="프로젝트 DB" format=paths
```

### 새 항목 추가
```bash
obsidian base:create file="독서 목록" name="클린 코드" content="저자: 로버트 C. 마틴" open
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian base*` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- 베이스는 Obsidian의 내장 데이터베이스 기능입니다
- 뷰(view)는 테이블, 보드, 캘린더 등 다양한 표시 방식을 제공합니다
- `format=paths`는 베이스 항목의 파일 경로만 반환합니다
- `format=md`는 마크다운 테이블 형식으로 출력합니다
