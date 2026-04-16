---
name: obsidian-plugin
description: Obsidian 플러그인 관리 스킬. 플러그인 목록 조회, 설치, 활성화/비활성화, 제거, 리로드, 제한 모드 관리를 수행합니다. 사용자가 '플러그인', 'plugin', '확장 기능', '플러그인 설치', '플러그인 활성화', 'obsidian plugin' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 플러그인 관리 스킬

Obsidian CLI를 통해 플러그인을 관리합니다.

## 사용법

```bash
/obsidian-plugin "list"
/obsidian-plugin "install dataview"
/obsidian-plugin "enable dataview"
/obsidian-plugin "disable dataview"
```

## 지원 커맨드

### plugins - 설치된 플러그인 목록

설치된 모든 플러그인을 나열합니다.

```bash
obsidian plugins
obsidian plugins filter=core
obsidian plugins filter=community versions
obsidian plugins format=json
```

| 옵션 | 설명 |
|------|------|
| `filter=core\|community` | 코어/커뮤니티 필터 |
| `versions` | 버전 정보 포함 |
| `format=json\|tsv\|csv` | 출력 형식 (기본: tsv) |

### plugins:enabled - 활성화된 플러그인 목록

현재 활성화된 플러그인만 나열합니다.

```bash
obsidian plugins:enabled
obsidian plugins:enabled filter=community versions
obsidian plugins:enabled format=json
```

| 옵션 | 설명 |
|------|------|
| `filter=core\|community` | 코어/커뮤니티 필터 |
| `versions` | 버전 정보 포함 |
| `format=json\|tsv\|csv` | 출력 형식 (기본: tsv) |

### plugin - 플러그인 상세 정보

특정 플러그인의 상세 정보를 확인합니다.

```bash
obsidian plugin id="dataview"
```

| 옵션 | 설명 |
|------|------|
| `id=<plugin-id>` | 플러그인 ID (필수) |

### plugin:install - 커뮤니티 플러그인 설치

커뮤니티 플러그인을 설치합니다.

```bash
obsidian plugin:install id="dataview"
obsidian plugin:install id="dataview" enable
```

| 옵션 | 설명 |
|------|------|
| `id=<id>` | 플러그인 ID (필수) |
| `enable` | 설치 후 바로 활성화 |

### plugin:enable - 플러그인 활성화

설치된 플러그인을 활성화합니다.

```bash
obsidian plugin:enable id="dataview"
obsidian plugin:enable id="daily-notes" filter=core
```

| 옵션 | 설명 |
|------|------|
| `id=<id>` | 플러그인 ID (필수) |
| `filter=core\|community` | 플러그인 타입 |

### plugin:disable - 플러그인 비활성화

활성화된 플러그인을 비활성화합니다.

```bash
obsidian plugin:disable id="dataview"
obsidian plugin:disable id="daily-notes" filter=core
```

| 옵션 | 설명 |
|------|------|
| `id=<id>` | 플러그인 ID (필수) |
| `filter=core\|community` | 플러그인 타입 |

### plugin:uninstall - 커뮤니티 플러그인 제거

커뮤니티 플러그인을 제거합니다.

```bash
obsidian plugin:uninstall id="dataview"
```

| 옵션 | 설명 |
|------|------|
| `id=<id>` | 플러그인 ID (필수) |

### plugin:reload - 플러그인 리로드 (개발용)

플러그인을 리로드합니다. 주로 플러그인 개발 시 사용합니다.

```bash
obsidian plugin:reload id="my-plugin"
```

| 옵션 | 설명 |
|------|------|
| `id=<id>` | 플러그인 ID (필수) |

### plugins:restrict - 제한 모드 관리

제한 모드를 켜거나 끄거나 상태를 확인합니다.

```bash
obsidian plugins:restrict
obsidian plugins:restrict on
obsidian plugins:restrict off
```

| 옵션 | 설명 |
|------|------|
| `on` | 제한 모드 활성화 |
| `off` | 제한 모드 비활성화 |

## 활용 예시

### 플러그인 현황 확인
```bash
obsidian plugins filter=community versions format=json
```

### 새 플러그인 설치 및 활성화
```bash
obsidian plugin:install id="templater-obsidian" enable
```

### 사용하지 않는 플러그인 정리
```bash
# 활성화된 플러그인 확인
obsidian plugins:enabled filter=community
# 불필요한 플러그인 비활성화 후 제거
obsidian plugin:disable id="unused-plugin"
obsidian plugin:uninstall id="unused-plugin"
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian plugin(s)*` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- 코어 플러그인은 Obsidian에 내장된 기본 기능입니다
- 커뮤니티 플러그인은 제3자가 개발한 확장 기능입니다
- 제한 모드(restricted mode) 활성화 시 커뮤니티 플러그인이 비활성화됩니다
- 플러그인 ID는 `plugins` 커맨드로 확인할 수 있습니다
