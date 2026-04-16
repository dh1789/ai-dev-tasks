---
name: obsidian-dev
description: Obsidian 개발자 도구 스킬. Chrome DevTools Protocol, DOM 조회, CSS 검사, 콘솔 로그, 에러 확인, 스크린샷, 모바일 에뮬레이션, JavaScript 실행을 수행합니다. 사용자가 '개발자 도구', 'devtools', 'DOM', 'CSS 검사', '콘솔', '스크린샷', 'eval', 'obsidian dev', '디버그' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 개발자 도구 스킬

Obsidian CLI를 통해 개발자 도구 기능을 사용합니다. 주로 플러그인 개발, 디버깅, UI 검사에 활용됩니다.

## 사용법

```bash
/obsidian-dev "dom .workspace"
/obsidian-dev "console"
/obsidian-dev "screenshot"
/obsidian-dev "eval document.title"
```

## 지원 커맨드

### dev:dom - DOM 요소 조회

CSS 선택자로 DOM 요소를 조회합니다.

```bash
obsidian dev:dom selector=".workspace"
obsidian dev:dom selector=".nav-file-title" all
obsidian dev:dom selector=".workspace" text
obsidian dev:dom selector=".workspace" inner
obsidian dev:dom selector=".nav-file-title" total
obsidian dev:dom selector=".workspace" attr="class"
obsidian dev:dom selector=".workspace" css="background-color"
```

| 옵션 | 설명 |
|------|------|
| `selector=<css>` | CSS 선택자 (필수) |
| `total` | 매칭 요소 수만 반환 |
| `text` | 텍스트 내용만 반환 |
| `inner` | outerHTML 대신 innerHTML 반환 |
| `all` | 첫 번째 대신 모든 매칭 반환 |
| `attr=<name>` | 특정 속성 값 반환 |
| `css=<prop>` | CSS 속성 값 반환 |

### dev:css - CSS 소스 검사

CSS 선택자의 스타일과 소스 위치를 검사합니다.

```bash
obsidian dev:css selector=".workspace"
obsidian dev:css selector=".workspace" prop="background-color"
```

| 옵션 | 설명 |
|------|------|
| `selector=<css>` | CSS 선택자 (필수) |
| `prop=<name>` | 특정 속성만 필터 |

### dev:console - 콘솔 메시지 조회

캡처된 콘솔 메시지를 확인합니다.

```bash
obsidian dev:console
obsidian dev:console limit=20
obsidian dev:console level=error
obsidian dev:console level=warn
obsidian dev:console clear
```

| 옵션 | 설명 |
|------|------|
| `clear` | 콘솔 버퍼 초기화 |
| `limit=<n>` | 최대 메시지 수 (기본: 50) |
| `level=log\|warn\|error\|info\|debug` | 로그 레벨 필터 |

### dev:errors - 에러 목록 조회

캡처된 에러를 확인합니다.

```bash
obsidian dev:errors
obsidian dev:errors clear
```

| 옵션 | 설명 |
|------|------|
| `clear` | 에러 버퍼 초기화 |

### dev:screenshot - 스크린샷 촬영

Obsidian 앱의 스크린샷을 촬영합니다.

```bash
obsidian dev:screenshot
obsidian dev:screenshot path="screenshot.png"
```

| 옵션 | 설명 |
|------|------|
| `path=<filename>` | 출력 파일 경로 |

### dev:debug - 디버거 연결/해제

Chrome DevTools Protocol 디버거를 연결하거나 해제합니다.

```bash
obsidian dev:debug on
obsidian dev:debug off
```

| 옵션 | 설명 |
|------|------|
| `on` | 디버거 연결 |
| `off` | 디버거 해제 |

### dev:mobile - 모바일 에뮬레이션

모바일 화면을 에뮬레이션합니다.

```bash
obsidian dev:mobile on
obsidian dev:mobile off
```

| 옵션 | 설명 |
|------|------|
| `on` | 모바일 에뮬레이션 활성화 |
| `off` | 모바일 에뮬레이션 비활성화 |

### dev:cdp - Chrome DevTools Protocol 명령 실행

CDP 명령을 직접 실행합니다.

```bash
obsidian dev:cdp method="Page.captureScreenshot"
obsidian dev:cdp method="Runtime.evaluate" params='{"expression":"document.title"}'
```

| 옵션 | 설명 |
|------|------|
| `method=<CDP.method>` | CDP 메서드 (필수) |
| `params=<json>` | 메서드 매개변수 (JSON) |

### devtools - 개발자 도구 토글

Electron 개발자 도구를 열거나 닫습니다.

```bash
obsidian devtools
```

### eval - JavaScript 실행

Obsidian 컨텍스트에서 JavaScript를 실행하고 결과를 반환합니다.

```bash
obsidian eval code="document.title"
obsidian eval code="app.vault.getFiles().length"
obsidian eval code="app.workspace.getActiveFile()?.basename"
```

| 옵션 | 설명 |
|------|------|
| `code=<javascript>` | 실행할 JavaScript 코드 (필수) |

## 활용 예시

### 플러그인 디버깅
```bash
# 에러 확인
obsidian dev:errors
# 콘솔 로그 확인
obsidian dev:console level=error
# 특정 DOM 요소 검사
obsidian dev:dom selector=".my-plugin-container"
```

### UI 검사
```bash
# DOM 구조 확인
obsidian dev:dom selector=".workspace-leaf-content" inner
# CSS 스타일 확인
obsidian dev:css selector=".nav-file-title" prop="color"
```

### Obsidian API 활용
```bash
# 활성 파일 이름
obsidian eval code="app.workspace.getActiveFile()?.basename"
# 전체 파일 수
obsidian eval code="app.vault.getFiles().length"
# 볼트 이름
obsidian eval code="app.vault.getName()"
```

### 스크린샷 및 모바일 테스트
```bash
# 데스크탑 스크린샷
obsidian dev:screenshot path="desktop.png"
# 모바일 모드 전환 후 스크린샷
obsidian dev:mobile on
obsidian dev:screenshot path="mobile.png"
obsidian dev:mobile off
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian dev:*` 또는 `obsidian eval` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- `eval`은 Obsidian의 전체 API에 접근할 수 있어 강력하지만 주의해서 사용하세요
- `dev:cdp`는 Chrome DevTools Protocol의 저수준 API입니다
- `dev:console`과 `dev:errors`는 이전에 캡처된 메시지만 표시합니다
- 개발자 도구는 주로 플러그인 개발 및 디버깅 목적으로 사용합니다
