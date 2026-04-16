---
name: obsidian-link
description: Obsidian 링크 분석 스킬. 아웃고잉 링크, 백링크, 고아 노트, 데드엔드, 미해결 링크를 분석합니다. 사용자가 '링크 분석', '백링크', '고아 노트', 'orphan', 'deadend', '미해결 링크', 'unresolved', 'backlink', '연결 분석' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 링크 분석 스킬

Obsidian CLI를 통해 볼트의 링크 구조를 분석합니다.

## 사용법

```bash
/obsidian-link "backlinks 노트이름"
/obsidian-link "links 노트이름"
/obsidian-link "orphans"
/obsidian-link "deadends"
/obsidian-link "unresolved"
```

## 지원 커맨드

### links - 아웃고잉 링크 목록

파일에서 나가는 링크(해당 파일이 참조하는 다른 파일)를 나열합니다.

```bash
obsidian links file="노트 이름"
obsidian links path="folder/note.md" total
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 파일 이름 |
| `path=<path>` | 파일 경로 |
| `total` | 링크 수만 반환 |

### backlinks - 백링크 목록

특정 파일을 참조하는 다른 파일(들어오는 링크)을 나열합니다.

```bash
obsidian backlinks file="노트 이름"
obsidian backlinks file="노트 이름" counts total
obsidian backlinks file="노트 이름" format=json
```

| 옵션 | 설명 |
|------|------|
| `file=<name>` | 대상 파일 이름 |
| `path=<path>` | 대상 파일 경로 |
| `counts` | 링크 횟수 포함 |
| `total` | 백링크 수만 반환 |
| `format=json\|tsv\|csv` | 출력 형식 (기본: tsv) |

### orphans - 고아 노트 목록

어떤 파일에서도 링크되지 않은 파일(들어오는 링크가 없는 파일)을 나열합니다.

```bash
obsidian orphans
obsidian orphans total
obsidian orphans all
```

| 옵션 | 설명 |
|------|------|
| `total` | 고아 노트 수만 반환 |
| `all` | 마크다운 외 파일도 포함 |

### deadends - 데드엔드 노트 목록

나가는 링크가 없는 파일(다른 파일을 참조하지 않는 파일)을 나열합니다.

```bash
obsidian deadends
obsidian deadends total
obsidian deadends all
```

| 옵션 | 설명 |
|------|------|
| `total` | 데드엔드 수만 반환 |
| `all` | 마크다운 외 파일도 포함 |

### unresolved - 미해결 링크 목록

볼트 내에서 대상이 존재하지 않는 깨진 링크를 나열합니다.

```bash
obsidian unresolved
obsidian unresolved total counts verbose
obsidian unresolved format=json
```

| 옵션 | 설명 |
|------|------|
| `total` | 미해결 링크 수만 반환 |
| `counts` | 링크 횟수 포함 |
| `verbose` | 소스 파일 포함 |
| `format=json\|tsv\|csv` | 출력 형식 (기본: tsv) |

## 활용 예시

### 볼트 건강성 검사
```bash
# 고아 노트 확인
obsidian orphans total
# 데드엔드 확인
obsidian deadends total
# 미해결 링크 확인
obsidian unresolved total
```

### 특정 노트의 연결 관계 분석
```bash
# 이 노트가 참조하는 노트들
obsidian links file="프로젝트 메인"
# 이 노트를 참조하는 노트들
obsidian backlinks file="프로젝트 메인" counts
```

## 실행 프로세스

1. 사용자 요청에서 분석 유형과 옵션 파싱
2. `obsidian` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 정리하여 사용자에게 보고 (한글)

## 참고

- 고아 노트(orphans)는 정리가 필요한 미연결 노트를 의미합니다
- 데드엔드(deadends)는 다른 노트로 연결되지 않는 종착점입니다
- 미해결 링크(unresolved)는 존재하지 않는 노트를 가리키는 깨진 링크입니다
- 링크 분석은 볼트 관리 및 지식 그래프 정리에 유용합니다
