# 언어 사용 정책 (Language Policy)

**참조**: Planner, Implementer, Reviewer 모두 이 언어 정책을 따릅니다.

## 기본 원칙

**모든 문서 콘텐츠, 로그 메시지, 사용자 커뮤니케이션은 한글(Korean)로 작성되어야 합니다.**

이는 주니어 개발자를 포함한 모든 대상 독자의 접근성을 보장하기 위함입니다.

---

## 한글 작성 필수 항목

### 문서 작성 시

**PLAN.md, REVIEW_REPORT.md, PRD 등 모든 문서**:
- ✅ 모든 섹션 제목 및 설명
- ✅ 목표, 요구사항, 아키텍처 결정 설명
- ✅ Phase 제목 및 작업 내용
- ✅ 품질 기준 및 검증 항목
- ✅ 제약사항 및 주의사항
- ✅ 발견된 문제점 및 개선 권장사항
- ✅ 최종 결정 및 근거
- ✅ 모든 서술형 텍스트

### 로그 메시지

**모든 logger 메시지**:
- ✅ DEBUG 레벨 메시지
- ✅ INFO 레벨 메시지
- ✅ WARN 레벨 메시지
- ✅ ERROR 레벨 메시지
- ✅ 함수 진입/종료 로그
- ✅ 상태 변경 로그
- ✅ 예외 처리 로그

### 사용자 커뮤니케이션

**모든 사용자 대면 메시지**:
- ✅ 진행 상황 보고
- ✅ Phase/Task 완료 알림
- ✅ 에러 설명 및 해결 방안
- ✅ 디버깅 결과 보고
- ✅ Slack 알림 메시지
- ✅ 질문 및 확인 요청
- ✅ 작업 완료 요약
- ✅ 리뷰 결과 보고
- ✅ 승인/거부 알림
- ✅ 개선 제안 및 피드백

---

## 영어 유지 항목

다음 항목은 **영어를 유지**합니다:

### 코드 관련

- ✅ 프로그래밍 언어 키워드 (예: `if`, `for`, `class`, `function`)
- ✅ 코드 식별자 (변수명, 함수명, 클래스명)
- ✅ 파일 경로 및 파일명 (예: `/src/components/Button.tsx`)
- ✅ 프레임워크 및 라이브러리 이름 (예: React, Express, Rails, Prisma)
- ✅ API endpoint 경로 (예: `/api/auth/login`)
- ✅ 코드 주석 (프로젝트 규칙에 따라, 일반적으로 영어)

### 기술 용어

- ✅ 기술 약어 (API, HTTP, REST, JSON, URL, CSS, HTML, SQL, JWT)
- ✅ 데이터베이스 관련 용어 (PostgreSQL, MongoDB, Redis)
- ✅ 도구 및 명령어 (npm, git, docker, kubectl)

---

## 올바른 예시

### ✅ PLAN.md 작성

```markdown
## 🎯 핵심 요구사항

1. 사용자는 프로필 사진을 업로드할 수 있어야 합니다.
   - API endpoint: `/api/upload/profile`
   - 지원 형식: JPG, PNG, WebP
   - 최대 파일 크기: 5MB

### Phase 1: API 엔드포인트 구현

**목표**: 파일 업로드 API를 Express middleware로 구현

**작업**:
- [ ] multer 라이브러리로 파일 업로드 처리
- [ ] 파일 형식 검증 로직 추가
- [ ] S3 버킷에 저장
```

### ✅ 로그 메시지 (Python)

```python
logger.info(f"결제 성공: transaction_id={transaction.id}, amount={amount}")
logger.error(f"API 호출 실패: endpoint=/api/payment, error={e}")
logger.debug(f"함수 시작: process_payment, transaction_id={transaction_id}")
```

### ✅ 로그 메시지 (TypeScript)

```typescript
logger.info(`주문 상태 변경: order_id=${order.id}, ${oldStatus} → ${newStatus}`);
logger.debug(`인증 시작: token=${token.substring(0, 10)}...`);
logger.error(`인증 실패: error=${error.message}`);
```

### ✅ Slack 알림

```bash
./scripts/slack-notify.sh "**[프로젝트명]** Phase 2 완료 ✅

**작업:** 사용자 인증 API 구현
**테스트:** 15/15 통과" "success"
```

### ✅ REVIEW_REPORT.md

```markdown
## ✅ 요구사항 검증

### 기능 요구사항
- [x] REQ-001: 회원가입 API 구현 → `src/controllers/auth.controller.ts:register`
- [x] REQ-002: 비밀번호 bcrypt 암호화 → `src/utils/bcrypt.ts`

## 🏗️ 코드 품질 평가

### 아키텍처 점수: 4/5
- Controller → Service → Repository 레이어 구조 준수
- 개선사항: Service 레이어에 일부 비즈니스 로직 누락
```

---

## 잘못된 예시

### ❌ 영어로 작성된 PLAN.md

```markdown
## Core Requirements

1. User must be able to upload profile picture.

### Phase 1: API Endpoint Implementation

**Goal**: Implement file upload API with Express middleware
```

**문제점**: 문서 전체가 영어로 작성됨

---

### ❌ 영어 로그 메시지

```python
logger.info(f"Payment successful: transaction_id={transaction.id}")
logger.error(f"API call failed: endpoint=/api/payment")
```

**문제점**: 로그 메시지가 영어로 작성됨

---

### ❌ 한글 과다 사용 (기술 용어까지 번역)

```markdown
- [ ] 멀터 도서관으로 파일 올리기 처리
- [ ] 에스삼 버켓에 저장
- [ ] 제이슨 형식으로 응답
```

**문제점**:
- "multer" → "멀터 도서관" (라이브러리 이름 번역 불필요)
- "S3" → "에스삼" (기술 용어 번역 불필요)
- "JSON" → "제이슨" (약어 번역 불필요)

**올바른 표현**:
```markdown
- [ ] multer 라이브러리로 파일 업로드 처리
- [ ] S3 버킷에 저장
- [ ] JSON 형식으로 응답
```

---

## 품질 체크리스트

문서 작성 완료 전 다음 사항을 확인하세요:

- [ ] 모든 설명 및 서술형 텍스트가 한글로 작성되었는가?
- [ ] 기술 용어는 적절하게 영어로 유지되었는가?
- [ ] 한글 설명이 필요한 복잡한 개념에 설명이 추가되었는가?
- [ ] 사용자 커뮤니케이션이 모두 한글로 작성되었는가?
- [ ] 파일 경로, 코드 식별자는 원래 형태를 유지하는가?
- [ ] 문장이 자연스럽고 읽기 쉬운가?
- [ ] 로그 메시지가 한글로 작성되었는가?
- [ ] Slack 메시지가 한글로 작성되었는가?

---

## 혼용 가이드라인

### 적절한 혼용 (권장)

```markdown
✅ "JWT 기반 토큰 발급"
✅ "Express middleware로 구현"
✅ "PostgreSQL 데이터베이스 연결"
✅ "API endpoint 경로: `/api/users`"
✅ "HTTP 상태 코드 200 반환"
```

### 부적절한 혼용 (지양)

```markdown
❌ "제이더블유티 기반 토큰 발급"
❌ "익스프레스 미들웨어로 구현"
❌ "포스트그레에스큐엘 데이터베이스 연결"
❌ "에이피아이 엔드포인트 경로"
```

---

## 예외 사항

다음 경우는 영어 사용을 허용합니다:

1. **공식 외부 API 문서 인용**: 원문 유지가 필요한 경우
2. **오픈소스 기여 문서**: 영어권 커뮤니티 대상 문서
3. **국제 협업 프로젝트**: 다국적 팀과 공유하는 문서
4. **기술 RFC/제안서**: 표준화 문서

예외 사항 적용 시에는 문서 상단에 명시적으로 표기해야 합니다:

```markdown
**언어 정책 예외**: 이 문서는 국제 협업 프로젝트를 위해 영어로 작성되었습니다.
```

---

## 버전 및 업데이트

- **Version**: 1.0.0
- **Last Updated**: 2026-01-20
- **Changelog**:
  - 1.0.0: 언어 사용 정책 공통 파일 생성
