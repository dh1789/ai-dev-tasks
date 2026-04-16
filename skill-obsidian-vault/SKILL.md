---
name: obsidian-vault
description: Obsidian 볼트 관리 스킬. 볼트 정보 조회, 볼트 목록, 폴더 관리, 리로드, 재시작, 버전 확인을 수행합니다. 사용자가 '볼트', 'vault', '폴더', '볼트 정보', '볼트 목록', 'obsidian vault', '리로드', '재시작' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 볼트 관리 스킬

Obsidian CLI를 통해 볼트와 폴더를 관리합니다.

## 사용법

```bash
/obsidian-vault "info"
/obsidian-vault "vaults"
/obsidian-vault "folders"
/obsidian-vault "reload"
```

## 지원 커맨드

### vault - 볼트 정보 조회

현재 볼트의 정보를 확인합니다.

```bash
obsidian vault
obsidian vault info=name
obsidian vault info=path
obsidian vault info=files
obsidian vault info=folders
obsidian vault info=size
```

| 옵션 | 설명 |
|------|------|
| `info=name\|path\|files\|folders\|size` | 특정 정보만 반환 |

### vaults - 볼트 목록

시스템에 등록된 모든 Obsidian 볼트를 나열합니다.

```bash
obsidian vaults
obsidian vaults total
obsidian vaults verbose
```

| 옵션 | 설명 |
|------|------|
| `total` | 볼트 수만 반환 |
| `verbose` | 볼트 경로 포함 |

### folders - 폴더 목록

볼트 내 폴더를 나열합니다.

```bash
obsidian folders
obsidian folders folder="특정폴더"
obsidian folders total
```

| 옵션 | 설명 |
|------|------|
| `folder=<path>` | 특정 부모 폴더로 필터 |
| `total` | 폴더 수만 반환 |

### folder - 폴더 정보 조회

특정 폴더의 상세 정보를 확인합니다.

```bash
obsidian folder path="Projects"
obsidian folder path="Projects" info=files
obsidian folder path="Projects" info=folders
obsidian folder path="Projects" info=size
```

| 옵션 | 설명 |
|------|------|
| `path=<path>` | 폴더 경로 (필수) |
| `info=files\|folders\|size` | 특정 정보만 반환 |

### reload - 볼트 리로드

볼트를 다시 로드합니다. 외부에서 파일을 변경한 후 Obsidian에 반영할 때 유용합니다.

```bash
obsidian reload
```

### restart - 앱 재시작

Obsidian 앱을 재시작합니다.

```bash
obsidian restart
```

### version - 버전 확인

Obsidian 앱의 버전을 확인합니다.

```bash
obsidian version
```

## 활용 예시

### 볼트 현황 파악
```bash
obsidian vault
# 또는 개별 정보
obsidian vault info=files
obsidian vault info=size
```

### 폴더 구조 탐색
```bash
# 전체 폴더 목록
obsidian folders
# 특정 폴더 하위 구조
obsidian folders folder="Projects"
# 폴더 상세 정보
obsidian folder path="Projects" info=files
```

### 외부 변경 후 동기화
```bash
# 파일 시스템에서 직접 파일 수정 후
obsidian reload
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- `vault` 옵션으로 특정 볼트를 지정할 수 있습니다: `obsidian vault="볼트이름" ...`
- `reload`는 파일 인덱스를 새로 고칩니다
- `restart`는 앱 전체를 재시작하므로 주의하세요
