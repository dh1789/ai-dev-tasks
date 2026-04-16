---
name: obsidian-template
description: Obsidian 템플릿 관리 스킬. 템플릿 목록 조회, 템플릿 삽입, 템플릿 내용 읽기를 수행합니다. 사용자가 '템플릿', 'template', '템플릿 삽입', '템플릿 목록', 'obsidian template' 등을 언급하면 이 스킬을 사용하세요.
argument-hint: "[command] [options]"
allowed-tools: Bash, Read
user-invocable: true
---

# Obsidian 템플릿 관리 스킬

Obsidian CLI를 통해 템플릿을 관리합니다.

## 사용법

```bash
/obsidian-template "list"
/obsidian-template "read 회의록"
/obsidian-template "insert 회의록"
```

## 지원 커맨드

### templates - 템플릿 목록 조회

사용 가능한 템플릿을 나열합니다.

```bash
obsidian templates
obsidian templates total
```

| 옵션 | 설명 |
|------|------|
| `total` | 템플릿 수만 반환 |

### template:read - 템플릿 내용 읽기

템플릿 파일의 내용을 읽어 반환합니다.

```bash
obsidian template:read name="회의록"
obsidian template:read name="회의록" resolve title="4월 팀 미팅"
```

| 옵션 | 설명 |
|------|------|
| `name=<template>` | 템플릿 이름 (필수) |
| `resolve` | 템플릿 변수 해석 |
| `title=<title>` | 변수 해석 시 사용할 제목 |

### template:insert - 활성 파일에 템플릿 삽입

현재 Obsidian에서 열려 있는 활성 파일에 템플릿을 삽입합니다.

```bash
obsidian template:insert name="회의록"
```

| 옵션 | 설명 |
|------|------|
| `name=<template>` | 템플릿 이름 (필수) |

## 활용 예시

### 사용 가능한 템플릿 확인
```bash
obsidian templates
```

### 템플릿 미리보기
```bash
# 변수 미해석 상태
obsidian template:read name="주간보고"
# 변수 해석 후 미리보기
obsidian template:read name="주간보고" resolve title="4월 2주차 보고"
```

### 새 노트에 템플릿 적용
```bash
# 1. 새 노트 생성 후 열기
obsidian create name="2026-04-12 팀 회의" open
# 2. 템플릿 삽입
obsidian template:insert name="회의록"
```

### 노트 생성 시 템플릿 직접 적용
```bash
obsidian create name="새 프로젝트" template="프로젝트 템플릿" open
```

## 실행 프로세스

1. 사용자 요청에서 커맨드와 옵션 파싱
2. `obsidian template*` CLI 명령어 조합
3. Bash를 통해 실행
4. 결과를 사용자에게 보고 (한글)

## 참고

- 템플릿 폴더는 Obsidian 설정에서 지정됩니다
- `template:insert`는 현재 Obsidian에서 활성화된 파일에 삽입합니다
- `resolve` 옵션은 `{{date}}`, `{{title}}` 같은 템플릿 변수를 실제 값으로 치환합니다
- `create` 명령의 `template=` 옵션으로도 노트 생성 시 바로 템플릿을 적용할 수 있습니다
