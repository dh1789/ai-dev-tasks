---
name: obsidian-search
description: Obsidian 볼트 검색 스킬. 텍스트 검색, 컨텍스트 포함 검색, 검색 뷰 열기를 수행합니다. 사용자가 '검색', '찾기', 'search', 'obsidian 검색', '노트에서 찾기', '볼트 검색' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[query] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 검색 스킬

Obsidian CLI를 통해 볼트 내 텍스트를 검색합니다.

## 사용법

```bash
/obsidian-search "프로젝트 계획"
/obsidian-search "context API 설계"
/obsidian-search "open 검색어"
```

## 지원 커맨드

### search - 볼트 텍스트 검색

볼트 전체에서 텍스트를 검색합니다.

```bash
obsidian search query="검색어"
obsidian search query="검색어" path="특정폴더" limit=10 case
obsidian search query="검색어" format=json total
```

| 옵션 | 설명 |
|------|------|
| `query=<text>` | 검색 쿼리 (필수) |
| `path=<folder>` | 특정 폴더로 제한 |
| `limit=<n>` | 최대 파일 수 |
| `total` | 매칭 수만 반환 |
| `case` | 대소문자 구분 |
| `format=text\|json` | 출력 형식 (기본: text) |

### search:context - 컨텍스트 포함 검색

매칭된 줄의 전후 컨텍스트를 포함하여 검색합니다.

```bash
obsidian search:context query="검색어"
obsidian search:context query="검색어" path="폴더" limit=5 case
obsidian search:context query="검색어" format=json
```

| 옵션 | 설명 |
|------|------|
| `query=<text>` | 검색 쿼리 (필수) |
| `path=<folder>` | 특정 폴더로 제한 |
| `limit=<n>` | 최대 파일 수 |
| `case` | 대소문자 구분 |
| `format=text\|json` | 출력 형식 (기본: text) |

### search:open - Obsidian 검색 뷰 열기

Obsidian UI에서 검색 뷰를 열고 쿼리를 실행합니다.

```bash
obsidian search:open query="검색어"
```

| 옵션 | 설명 |
|------|------|
| `query=<text>` | 초기 검색 쿼리 |

## 활용 예시

### 특정 주제 노트 찾기
```bash
obsidian search query="프로젝트 일정" format=json
```

### 폴더 내 키워드 검색 (컨텍스트 포함)
```bash
obsidian search:context query="TODO" path="Projects" limit=20
```

### 검색 결과 수 확인
```bash
obsidian search query="회의록" total
```

## 실행 프로세스

1. 사용자 요청에서 검색 쿼리와 옵션 파싱
2. `obsidian search*` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 정리하여 사용자에게 보고 (한글)

## 참고

- `search`는 파일 이름만 반환하고 `search:context`는 매칭 줄도 포함합니다
- `format=json`으로 프로그래밍적 처리에 적합한 형식을 얻을 수 있습니다
- `total` 옵션으로 매칭 파일 수만 빠르게 확인 가능합니다
