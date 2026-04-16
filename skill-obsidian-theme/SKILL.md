---
name: obsidian-theme
description: Obsidian 테마 및 CSS 스니펫 관리 스킬. 테마 목록 조회, 설치, 적용, 제거, CSS 스니펫 활성화/비활성화를 수행합니다. 사용자가 '테마', 'theme', 'CSS', '스니펫', 'snippet', '외관', 'obsidian theme', '테마 설치' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 테마/CSS 스니펫 관리 스킬

Obsidian CLI를 통해 테마와 CSS 스니펫을 관리합니다.

## 사용법

```bash
/obsidian-theme "list"
/obsidian-theme "install Minimal"
/obsidian-theme "set Minimal"
/obsidian-theme "snippets"
```

## 지원 커맨드

### theme - 현재 테마 정보

현재 활성 테마 또는 특정 테마의 정보를 확인합니다.

```bash
obsidian theme
obsidian theme name="Minimal"
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 특정 테마 상세 정보 |

### themes - 설치된 테마 목록

설치된 모든 테마를 나열합니다.

```bash
obsidian themes
obsidian themes versions
```

| 옵션 | 설명 |
|------|------|
| `versions` | 버전 정보 포함 |

### theme:install - 커뮤니티 테마 설치

커뮤니티 테마를 설치합니다.

```bash
obsidian theme:install name="Minimal"
obsidian theme:install name="Minimal" enable
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 테마 이름 (필수) |
| `enable` | 설치 후 바로 활성화 |

### theme:set - 테마 적용

활성 테마를 변경합니다.

```bash
obsidian theme:set name="Minimal"
obsidian theme:set name=""
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 테마 이름 (필수, 빈 값=기본 테마) |

### theme:uninstall - 테마 제거

설치된 테마를 제거합니다.

```bash
obsidian theme:uninstall name="Minimal"
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 테마 이름 (필수) |

### snippets - CSS 스니펫 목록

설치된 모든 CSS 스니펫을 나열합니다.

```bash
obsidian snippets
```

### snippets:enabled - 활성 CSS 스니펫 목록

현재 활성화된 CSS 스니펫만 나열합니다.

```bash
obsidian snippets:enabled
```

### snippet:enable - CSS 스니펫 활성화

CSS 스니펫을 활성화합니다.

```bash
obsidian snippet:enable name="custom-font"
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 스니펫 이름 (필수) |

### snippet:disable - CSS 스니펫 비활성화

CSS 스니펫을 비활성화합니다.

```bash
obsidian snippet:disable name="custom-font"
```

| 옵션 | 설명 |
|------|------|
| `name=<name>` | 스니펫 이름 (필수) |

## 활용 예시

### 테마 변경
```bash
# 설치된 테마 확인
obsidian themes versions
# 새 테마 설치 및 적용
obsidian theme:install name="Minimal" enable
```

### 기본 테마로 복원
```bash
obsidian theme:set name=""
```

### CSS 스니펫 관리
```bash
# 전체 스니펫 확인
obsidian snippets
# 활성 스니펫 확인
obsidian snippets:enabled
# 스니펫 토글
obsidian snippet:enable name="my-style"
obsidian snippet:disable name="my-style"
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian theme*` 또는 `obsidian snippet*` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- `theme:set name=""`으로 기본 테마로 되돌릴 수 있습니다
- CSS 스니펫은 `.obsidian/snippets/` 폴더의 CSS 파일입니다
- 스니펫 이름은 `.css` 확장자를 제외한 파일 이름입니다
