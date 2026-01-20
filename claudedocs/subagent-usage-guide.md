# 서브에이전트 사용 가이드

**작성일**: 2026-01-20
**대상**: 3-tier 서브에이전트 시스템 (Planner → Implementer → Reviewer)

---

## 📚 목차

1. [서브에이전트 개요](#서브에이전트-개요)
2. [기본 사용법](#기본-사용법)
3. [실전 예제: JWT 인증 시스템 구현](#실전-예제-jwt-인증-시스템-구현)
4. [주요 체크포인트](#주요-체크포인트)
5. [트러블슈팅](#트러블슈팅)

---

## 서브에이전트 개요

### 🎯 3-Tier 아키텍처

```
┌─────────────┐
│   Planner   │  계획 수립 (PLAN.md 작성)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Implementer │  구현 실행 (Phase별 코드 작성)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Reviewer   │  품질 검증 (REVIEW_REPORT.md 작성)
└─────────────┘
```

### 역할 분담

| 에이전트 | 주요 역할 | 입력 | 출력 |
|---------|----------|------|------|
| **Planner** | 구현 계획 수립 | 사용자 요청, 프로젝트 컨텍스트 | PLAN.md |
| **Implementer** | Phase별 구현 및 테스트 | PLAN.md | 구현 코드, PROGRESS.md |
| **Reviewer** | 요구사항 및 품질 검증 | PLAN.md, 구현 코드 | REVIEW_REPORT.md |

---

## 기본 사용법

### 1. Planner 호출

```bash
# Claude Code에서 대화형으로 호출
"Planner 에이전트를 사용해서 JWT 인증 기능 구현 계획을 세워줘"

# 또는 스킬 사용 (있는 경우)
/plan "JWT 인증 기능 추가"
```

**Planner가 하는 일**:
1. 프로젝트 타입 감지 (Node.js, Ruby, C++ 등)
2. 요구사항 분석 및 구체화
3. 3-7개 Phase로 분해
4. 각 Phase별 TDD 구조 정의
5. Quality Gate 및 롤백 전략 수립
6. `docs/features/YYYY-MM-DD-feature-name/PLAN.md` 생성

### 2. Implementer 호출

```bash
# PLAN.md가 준비된 후
"Implementer 에이전트를 사용해서 docs/features/2026-01-20-jwt-auth/PLAN.md를 구현해줘"

# 또는 스킬 사용
/implement docs/features/2026-01-20-jwt-auth/PLAN.md
```

**Implementer가 하는 일**:
1. PLAN.md 읽기 및 검증
2. 프로젝트 타입별 빌드/테스트 명령어 자동 감지
3. Phase별 순차 구현 (TDD Cycle: RED → GREEN → REFACTOR)
4. 디버그 로깅 5가지 위치 추가
5. 각 Phase 완료 시 테스트, 빌드, 품질 검사 실행
6. PROGRESS.md 업데이트
7. Slack 알림 전송 (Phase 완료/실패)
8. 커밋 (Conventional Commit)

### 3. Reviewer 호출

```bash
# 구현 완료 후
"Reviewer 에이전트를 사용해서 docs/features/2026-01-20-jwt-auth/PLAN.md 구현을 검토해줘"

# 또는 스킬 사용
/review docs/features/2026-01-20-jwt-auth/PLAN.md
```

**Reviewer가 하는 일**:
1. PLAN.md 요구사항 추출
2. 구현 코드 탐색 및 분석
3. 요구사항 충족도 계산 (%)
4. 코드 품질 평가 (아키텍처, 가독성, 완전성)
5. 테스트 품질 검증 (커버리지, 테스트 품질)
6. PROGRESS.md 검증
7. 언어별 품질 검사 검증
8. 보안 및 성능 검토
9. `docs/features/YYYY-MM-DD-feature-name/REVIEW_REPORT.md` 생성
10. 최종 결정 (승인/거부/조건부 승인)

---

## 실전 예제: JWT 인증 시스템 구현

### 시나리오

**프로젝트**: Node.js + TypeScript + Express 백엔드 API
**요구사항**: JWT 기반 사용자 인증 시스템 추가

---

### Phase 1: Planner 실행

#### 1.1 사용자 요청

```
"JWT 인증 시스템을 추가하고 싶어.
요구사항은 다음과 같아:
- 회원가입 (POST /api/auth/signup)
- 로그인 (POST /api/auth/login) - JWT 토큰 발급
- 토큰 검증 미들웨어
- 보호된 엔드포인트 예제 (GET /api/users/me)

프로젝트는 Node.js + TypeScript + Express를 사용하고 있어."
```

#### 1.2 Planner 응답

Planner는 프로젝트를 분석하고 다음과 같은 PLAN.md를 생성합니다:

**생성 위치**: `docs/features/2026-01-20-jwt-auth/PLAN.md`

```markdown
# JWT 인증 시스템 구현 계획

**Status**: 🟡 Planning
**생성일**: 2026-01-20
**예상 완료**: 2026-01-20
**프로젝트 타입**: Node.js/TypeScript
**언어/프레임워크**: TypeScript/Express
**실행 환경**: Local Development

## 📋 목표

Express 애플리케이션에 JWT 기반 사용자 인증 시스템을 추가하여
안전한 회원가입, 로그인, 토큰 검증 기능을 제공한다.

## 🎯 핵심 요구사항

### 기능 요구사항
1. **회원가입**: POST /api/auth/signup
   - 이메일, 비밀번호 검증
   - 비밀번호 암호화 (bcrypt)
   - 중복 사용자 체크

2. **로그인**: POST /api/auth/login
   - 인증 정보 검증
   - JWT 토큰 발급 (15분 만료)
   - Refresh Token 발급 (7일 만료)

3. **토큰 검증 미들웨어**: authMiddleware
   - Authorization 헤더 검증
   - JWT 토큰 파싱 및 검증
   - req.user에 사용자 정보 첨부

4. **보호된 엔드포인트**: GET /api/users/me
   - 현재 로그인한 사용자 정보 반환

### 품질 요구사항
- 테스트 커버리지 ≥ 80%
- 비밀번호는 bcrypt로 암호화 (salt rounds: 10)
- JWT 시크릿은 환경변수로 관리
- 에러 핸들링 철저 (401, 400, 500)

## 🏗️ 아키텍처 결정

### 기술 스택
- **언어**: TypeScript
- **프레임워크**: Express
- **인증**: jsonwebtoken, bcrypt
- **테스트**: Jest, Supertest
- **검증**: Zod (요청 데이터 검증)

### 파일 구조
```
src/
├── models/
│   └── User.ts              # 사용자 모델 (메모리 저장소)
├── routes/
│   └── auth.ts              # 인증 라우트
├── middleware/
│   └── authMiddleware.ts    # JWT 검증 미들웨어
├── controllers/
│   └── authController.ts    # 인증 컨트롤러
└── utils/
    └── jwt.ts               # JWT 유틸리티

tests/
└── auth.test.ts             # 통합 테스트
```

### 디자인 패턴
- **MVC**: Controller-Route 분리
- **Middleware Pattern**: 인증 로직 재사용
- **Repository Pattern**: User 데이터 접근 추상화

## 📝 구현 Phase

### Phase 1: 데이터 모델 및 유틸리티 (1-2시간)

**목표**: User 모델과 JWT 유틸리티 함수 구현

**TDD 구조**:
- 🔴 RED: User 모델 테스트 작성 (비밀번호 해싱, 검증)
- 🟢 GREEN: User 모델 구현
- 🔵 REFACTOR: 타입 정의 개선, 로깅 추가

**작업**:
1. `src/models/User.ts` 생성
   - 인터페이스: IUser { id, email, password }
   - 메서드: hashPassword(), comparePassword()
   - 메모리 저장소: users[] 배열

2. `src/utils/jwt.ts` 생성
   - generateToken(userId): Access Token 생성
   - generateRefreshToken(userId): Refresh Token 생성
   - verifyToken(token): 토큰 검증

3. 테스트 작성 (`tests/models/User.test.ts`)
   - 비밀번호 해싱 검증
   - 비밀번호 비교 검증

**Quality Gate**:
- [ ] 모든 테스트 통과 (User 모델, JWT 유틸)
- [ ] TypeScript 타입 에러 0개
- [ ] ESLint 에러 0개
- [ ] 디버그 로깅 추가 (함수 진입/종료, 상태 변경)

**롤백 전략**:
```bash
git revert HEAD
rm -rf src/models/User.ts src/utils/jwt.ts tests/models/
```

---

### Phase 2: 인증 컨트롤러 (2-3시간)

**목표**: 회원가입, 로그인 비즈니스 로직 구현

**TDD 구조**:
- 🔴 RED: authController 단위 테스트 작성
- 🟢 GREEN: signup, login 함수 구현
- 🔵 REFACTOR: 에러 핸들링 개선, 로깅 추가

**작업**:
1. `src/controllers/authController.ts` 생성
   - signup(req, res): 회원가입 처리
   - login(req, res): 로그인 처리

2. 요청 검증 (Zod)
   - signupSchema: email, password 검증
   - loginSchema: email, password 검증

3. 테스트 작성 (`tests/controllers/authController.test.ts`)
   - 회원가입 성공/실패 케이스
   - 로그인 성공/실패 케이스
   - 중복 이메일 체크

**Quality Gate**:
- [ ] 모든 테스트 통과
- [ ] 에러 처리 완비 (400, 401, 500)
- [ ] 디버그 로깅 (비즈니스 로직, 예외 처리)
- [ ] TypeScript, ESLint 통과

**롤백 전략**:
```bash
git revert HEAD
rm -rf src/controllers/authController.ts tests/controllers/
```

---

### Phase 3: 라우트 및 미들웨어 (1-2시간)

**목표**: Express 라우트와 JWT 검증 미들웨어 구현

**TDD 구조**:
- 🔴 RED: 미들웨어 및 라우트 통합 테스트 작성
- 🟢 GREEN: authMiddleware, auth 라우트 구현
- 🔵 REFACTOR: 코드 정리, 로깅 추가

**작업**:
1. `src/middleware/authMiddleware.ts` 생성
   - Authorization 헤더 검증
   - JWT 토큰 파싱 및 검증
   - req.user에 사용자 정보 첨부

2. `src/routes/auth.ts` 생성
   - POST /api/auth/signup
   - POST /api/auth/login

3. `src/routes/users.ts` 생성 (보호된 엔드포인트)
   - GET /api/users/me (authMiddleware 사용)

4. 통합 테스트 (`tests/auth.integration.test.ts`)
   - 회원가입 → 로그인 → 보호된 엔드포인트 접근

**Quality Gate**:
- [ ] 통합 테스트 통과
- [ ] 미들웨어 단위 테스트 통과
- [ ] 401 에러 처리 검증
- [ ] 디버그 로깅 (미들웨어 진입/종료, 토큰 검증)

**롤백 전략**:
```bash
git revert HEAD
rm -rf src/routes/auth.ts src/middleware/authMiddleware.ts
```

---

### Phase 4: 통합 및 최종 검증 (1시간)

**목표**: 전체 시스템 통합 및 E2E 테스트

**작업**:
1. app.ts에 라우트 등록
2. .env.example 업데이트 (JWT_SECRET, JWT_EXPIRES_IN)
3. E2E 시나리오 테스트
   - 회원가입 → 로그인 → 토큰으로 보호된 리소스 접근
   - 잘못된 토큰으로 접근 시도 (401)
   - 만료된 토큰 처리

4. 보안 검증
   - 비밀번호 평문 노출 체크
   - JWT 시크릿 하드코딩 체크
   - 민감 정보 로그 출력 체크

**Quality Gate**:
- [ ] E2E 테스트 통과
- [ ] 커버리지 ≥ 80%
- [ ] ESLint, TypeScript 에러 0개
- [ ] 보안 체크리스트 통과
- [ ] PROGRESS.md 업데이트

**롤백 전략**:
```bash
git revert HEAD~3..HEAD  # 전체 Phase 롤백
```

## ✅ 품질 기준

### 코드 품질
- [ ] TypeScript strict mode 활성화
- [ ] ESLint 에러 0개
- [ ] 모든 함수에 타입 정의
- [ ] 일관된 네이밍 컨벤션

### 테스트
- [ ] 단위 테스트: User, JWT 유틸, Controller
- [ ] 통합 테스트: 라우트, 미들웨어
- [ ] E2E 테스트: 전체 플로우
- [ ] 커버리지 ≥ 80%

### 보안
- [ ] 비밀번호 bcrypt 암호화 (salt rounds: 10)
- [ ] JWT 시크릿 환경변수로 관리
- [ ] 민감 정보 로그 출력 금지
- [ ] SQL Injection 방어 (해당 시)

### 성능
- [ ] bcrypt salt rounds ≤ 12
- [ ] JWT 토큰 만료 시간 적절 (15분)
- [ ] 불필요한 데이터베이스 조회 없음

## ⚠️ 위험 요소

1. **JWT 시크릿 노출**
   - 완화: .env 사용, .gitignore에 .env 추가

2. **비밀번호 평문 저장**
   - 완화: bcrypt 사용, 테스트로 검증

3. **토큰 만료 처리 미흡**
   - 완화: Refresh Token 구현, 에러 처리

## 🔗 참고 자료

- [JWT 공식 문서](https://jwt.io/)
- [bcrypt npm 패키지](https://www.npmjs.com/package/bcrypt)
- [Express 보안 Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
```

#### 1.3 PLAN.md 검증

Planner는 자동으로 검증 스크립트를 실행합니다:

```bash
# 검증 스크립트 (존재하는 경우)
~/.claude/skills/plan/scripts/validate-plan.sh docs/features/2026-01-20-jwt-auth/

# 수동 검증 체크리스트
✅ 파일 위치: docs/features/2026-01-20-jwt-auth/PLAN.md
✅ Phase 개수: 4개 (3-7개 범위 내)
✅ 각 Phase에 TDD 구조 (RED-GREEN-REFACTOR)
✅ 각 Phase에 Quality Gate 정의
✅ 롤백 전략 작성
✅ 모든 섹션 한글로 작성 (기술 용어 제외)
✅ Phase 크기: 각 1-4시간
```

---

### Phase 2: Implementer 실행

#### 2.1 Implementer 호출

```
"Implementer 에이전트를 사용해서 docs/features/2026-01-20-jwt-auth/PLAN.md를 구현해줘"
```

#### 2.2 Implementer 작업 흐름

**Phase 0: 준비 및 검증**

```bash
# 0.1 PLAN.md 읽기
Read "docs/features/2026-01-20-jwt-auth/PLAN.md"

# 0.2 프로젝트 타입 감지
✅ 감지됨: Node.js/TypeScript
   - package.json 존재
   - tsconfig.json 존재
   - 빌드: npm run build
   - 테스트: npm test
   - 린트: npm run lint

# 0.2.1 언어별 품질 검사 설정
✅ Node.js/TypeScript 검사 도구:
   - ESLint (코드 품질)
   - TypeScript 타입체크
   - Jest (테스트)
   - Prettier (포맷팅)

# 0.3 TodoWrite 초기화
✅ Todo 리스트 생성:
   - [ ] Phase 1: 데이터 모델 및 유틸리티
   - [ ] Phase 2: 인증 컨트롤러
   - [ ] Phase 3: 라우트 및 미들웨어
   - [ ] Phase 4: 통합 및 최종 검증
   - [ ] 최종 품질 검증
```

**Phase 1: 데이터 모델 및 유틸리티**

```bash
# Step 1: TDD RED - 테스트 먼저 작성
Write "tests/models/User.test.ts"
```

```typescript
// tests/models/User.test.ts
import { User } from '../../src/models/User';

describe('User Model', () => {
  describe('hashPassword', () => {
    it('비밀번호를 bcrypt로 해싱해야 함', async () => {
      const user = new User({ email: 'test@example.com', password: 'password123' });
      await user.hashPassword();

      expect(user.password).not.toBe('password123');
      expect(user.password).toMatch(/^\$2[aby]\$.{56}$/); // bcrypt 형식
    });
  });

  describe('comparePassword', () => {
    it('올바른 비밀번호 비교 시 true 반환', async () => {
      const user = new User({ email: 'test@example.com', password: 'password123' });
      await user.hashPassword();

      const isMatch = await user.comparePassword('password123');
      expect(isMatch).toBe(true);
    });

    it('잘못된 비밀번호 비교 시 false 반환', async () => {
      const user = new User({ email: 'test@example.com', password: 'password123' });
      await user.hashPassword();

      const isMatch = await user.comparePassword('wrongpassword');
      expect(isMatch).toBe(false);
    });
  });
});
```

```bash
# 테스트 실행 → 실패 확인 (RED)
npm test -- tests/models/User.test.ts
❌ FAIL  tests/models/User.test.ts
  ● Cannot find module '../../src/models/User'
```

```bash
# Step 2: TDD GREEN - 최소 구현
Write "src/models/User.ts"
```

```typescript
// src/models/User.ts
import bcrypt from 'bcrypt';
import { logger } from '../utils/logger';

export interface IUser {
  id: string;
  email: string;
  password: string;
}

export class User implements IUser {
  id: string;
  email: string;
  password: string;

  constructor(data: { email: string; password: string; id?: string }) {
    this.id = data.id || Math.random().toString(36).substr(2, 9);
    this.email = data.email;
    this.password = data.password;

    logger.debug(`User 생성: email=${this.email}, id=${this.id}`);
  }

  async hashPassword(): Promise<void> {
    logger.debug(`비밀번호 해싱 시작: user_id=${this.id}`);
    const saltRounds = 10;
    this.password = await bcrypt.hash(this.password, saltRounds);
    logger.info(`비밀번호 해싱 완료: user_id=${this.id}`);
  }

  async comparePassword(candidatePassword: string): Promise<boolean> {
    logger.debug(`비밀번호 비교 시작: user_id=${this.id}`);
    const isMatch = await bcrypt.compare(candidatePassword, this.password);
    logger.info(`비밀번호 비교 완료: user_id=${this.id}, match=${isMatch}`);
    return isMatch;
  }
}

// 메모리 저장소
export const users: User[] = [];
```

```bash
# 테스트 재실행 → 통과 확인 (GREEN)
npm test -- tests/models/User.test.ts
✅ PASS  tests/models/User.test.ts
  User Model
    hashPassword
      ✓ 비밀번호를 bcrypt로 해싱해야 함 (52ms)
    comparePassword
      ✓ 올바른 비밀번호 비교 시 true 반환 (48ms)
      ✓ 잘못된 비밀번호 비교 시 false 반환 (49ms)

Test Suites: 1 passed, 1 total
Tests:       3 passed, 3 total
```

```bash
# Step 3: TDD REFACTOR - 개선 (이미 로깅 추가됨)
# JWT 유틸리티 구현 (동일한 TDD 사이클)
Write "src/utils/jwt.ts"
Write "tests/utils/jwt.test.ts"
npm test
```

```bash
# Step 4: Phase 완료 조건 확인
✅ TDD Cycle 완료 (RED → GREEN → REFACTOR)
✅ 디버그 로깅 5가지 위치 추가
✅ 모든 테스트 통과 (5/5 tests)
✅ 테스트 커버리지 ≥ 80% (User: 95%, JWT: 92%)
✅ 빌드 성공
✅ 언어별 품질 검사 통과:
   - ESLint: 0 errors
   - TypeScript: 0 errors
✅ PROGRESS.md 업데이트
```

```bash
# Step 5: PROGRESS.md 업데이트
Write "docs/features/2026-01-20-jwt-auth/PROGRESS.md"
```

```markdown
# Implementation Progress

## Phase 1: 데이터 모델 및 유틸리티
- Status: ✅ Completed
- Started: 2026-01-20 10:00
- Completed: 2026-01-20 11:15
- Tests: 5/5 passed, Coverage: 93%
- Commit: a1b2c3d
- Files:
  - src/models/User.ts
  - src/utils/jwt.ts
  - tests/models/User.test.ts
  - tests/utils/jwt.test.ts

## Phase 2: 인증 컨트롤러
- Status: ⏳ Pending
```

```bash
# Step 6: Slack 알림
./scripts/slack-notify.sh "**[JWT 인증]** Phase 1 완료 ✅

**작업:** 데이터 모델 및 유틸리티
**경로:** docs/features/2026-01-20-jwt-auth/
**테스트:** 5/5 통과, Coverage: 93%
**커밋:** a1b2c3d

모든 서브태스크 완료. 다음 지시 대기 중입니다." "success"
```

```bash
# Step 7: 커밋
git add .
git commit -m "feat: Phase 1 - User 모델 및 JWT 유틸리티 구현

- User 모델: 비밀번호 해싱 및 비교 기능
- JWT 유틸: 토큰 생성 및 검증
- 테스트: 5개, 커버리지 93%
- 디버그 로깅 추가 (5가지 위치)

Related to Phase 1 in docs/features/2026-01-20-jwt-auth/PLAN.md"
```

**Phase 2-4: 동일한 프로세스 반복**

각 Phase마다:
1. TDD RED → GREEN → REFACTOR
2. 디버그 로깅 추가
3. 테스트 실행 (30분 타임아웃)
4. 품질 검사 (ESLint, TypeScript, 커버리지)
5. PROGRESS.md 업데이트
6. Slack 알림
7. 커밋

#### 2.3 중단 조건 예시

만약 Phase 2에서 테스트가 3회 재시도 후에도 실패하면:

```bash
# 즉시 작업 중단
./scripts/slack-notify.sh "🚨 **[JWT 인증]** 작업 중단

**사유:** 테스트 실패 (3회 재시도 후)
**위치:** Phase 2, src/controllers/authController.ts:45
**상세:** signup 함수에서 중복 이메일 체크 실패
  Expected: 400
  Received: 500
**시도한 해결:**
  1. 에러 핸들링 추가
  2. 로깅 강화
  3. 테스트 케이스 검토
**필요 조치:** 중복 이메일 체크 로직 재설계 필요" "failure"

# 작업 중단, 사용자 지시 대기
```

---

### Phase 3: Reviewer 실행

#### 3.1 Reviewer 호출

```
"Reviewer 에이전트를 사용해서 docs/features/2026-01-20-jwt-auth/PLAN.md 구현을 검토해줘"
```

#### 3.2 Reviewer 작업 흐름

**Phase 1: 컨텍스트 수집**

```bash
# 1. PLAN.md 읽기
Read "docs/features/2026-01-20-jwt-auth/PLAN.md"

# 2. 구현 코드 탐색
Glob "src/**/*.ts"
Glob "tests/**/*.test.ts"

# 3. 빌드/테스트 실행
npm test
npm run lint
npm run build
```

**Phase 2: 요구사항 검증**

```markdown
## 요구사항 충족도

### 기능 요구사항 (4개)
- [x] 회원가입: POST /api/auth/signup ✅
- [x] 로그인: POST /api/auth/login ✅
- [x] 토큰 검증 미들웨어 ✅
- [x] 보호된 엔드포인트: GET /api/users/me ✅

**충족도**: 100% (4/4)

### 품질 요구사항 (4개)
- [x] 테스트 커버리지 ≥ 80% ✅ (실제: 87%)
- [x] bcrypt 암호화 (salt rounds: 10) ✅
- [x] JWT 시크릿 환경변수 관리 ✅
- [x] 에러 핸들링 (401, 400, 500) ✅

**충족도**: 100% (4/4)

**전체 충족도**: 100% (8/8)
```

**Phase 3: 코드 품질 평가**

```markdown
## 코드 품질 점수: 14/15

### 3.1 아키텍처 (5/5)
✅ MVC 패턴 준수
✅ Controller-Route 분리
✅ 미들웨어 재사용
✅ 레이어 구조 명확

### 3.2 가독성 (4/5)
✅ 의미있는 변수명/함수명
✅ 적절한 주석 (복잡한 로직에만)
✅ 함수 크기 적절 (<50줄)
⚠️ 일부 중복 코드 존재 (에러 핸들링)

**개선 사항**:
- authController.ts에서 에러 처리 로직 중복 (signup, login)
- 공통 에러 핸들러 함수 추출 권장

### 3.3 완전성 (5/5)
✅ 모든 기능 완전히 구현
✅ TODO 주석 없음
✅ Mock 객체 없음
✅ console.log 없음 (logger 사용)
```

**Phase 4: 테스트 품질 검증**

```markdown
## 테스트 품질 점수: 5/5

### 4.1 테스트 커버리지
Statements:  87.5% ✅ (목표: 80%)
Branches:    85.2% ✅ (목표: 75%)
Functions:   90.0% ✅ (목표: 80%)
Lines:       87.8% ✅ (목표: 80%)

### 4.2 테스트 품질
✅ Happy Path 테스트 존재
✅ Exception/Edge Case 테스트 (잘못된 토큰, 중복 이메일)
✅ Boundary 테스트 (빈 값, 긴 문자열)
✅ 테스트 설명 명확함
✅ 테스트 독립성 (서로 영향 없음)

**점수**: 5/5 (포괄적인 테스트)
```

**Phase 4.5: PROGRESS.md 검증**

```markdown
## PROGRESS.md 검증

✅ PROGRESS.md 존재: docs/features/2026-01-20-jwt-auth/PROGRESS.md
✅ 모든 Phase 기록됨 (Phase 1-4)
✅ 시작/완료 시간 기록됨
✅ 테스트 결과 포함 (X/Y passed, Coverage: Z%)
✅ 커밋 해시 포함

**평가**: ✅ 완벽
```

**Phase 5: 보안 검토**

```markdown
## 보안 검토

### 5.1 보안 체크리스트

**일반 보안**:
✅ 민감 정보 하드코딩 없음
✅ SQL Injection 방어 (해당 없음 - 메모리 저장소)
✅ 인증/인가 적절

**프로젝트별 보안**:
✅ JWT 시크릿 환경변수로 관리 (.env)
✅ 비밀번호 bcrypt 암호화
✅ 토큰 검증 완비
✅ 에러 메시지에 민감 정보 없음

**평가**: ✅ 보안 문제 없음
```

**Phase 6: 성능 검토**

```markdown
## 성능 검토

✅ bcrypt salt rounds: 10 (적절, ≤12)
✅ 토큰 검증 중복 호출 없음
✅ 불필요한 데이터 직렬화 없음
✅ 비동기 처리 적절

**평가**: ✅ 성능 문제 없음
```

**Phase 3.4: 언어별 품질 검사 검증**

```bash
# Node.js/TypeScript 검사 실행
npm run lint
✅ ESLint: 0 errors, 0 warnings

npx tsc --noEmit
✅ TypeScript: 0 errors

npm test -- --coverage
✅ Tests: 23/23 passed
✅ Coverage: 87%

npm run build
✅ Build: success

# 검증 기준
✅ 모든 필수 도구 실행됨
✅ 모든 필수 검사 통과 (에러 0)
✅ 테스트 커버리지 ≥ 80%

**평가**: ✅ 완벽
```

#### 3.3 최종 리뷰 보고서

**생성 위치**: `docs/features/2026-01-20-jwt-auth/REVIEW_REPORT.md`

```markdown
# 구현 리뷰 보고서

**리뷰 일시**: 2026-01-20 15:30
**리뷰어**: Reviewer Agent
**프로젝트**: JWT 인증 시스템

---

## 📊 종합 평가

### 요구사항 충족도
- **기능 요구사항**: 100% (4/4) ✅
- **품질 요구사항**: 100% (4/4) ✅
- **전체 충족도**: **100%** ✅

### 코드 품질 점수
- **아키텍처**: 5/5 ✅
- **가독성**: 4/5 ⚠️
- **완전성**: 5/5 ✅
- **총점**: **14/15** (93%)

### 테스트 품질 점수
- **커버리지**: ✅ 87% (목표: 80%)
- **테스트 품질**: 5/5 ✅

### 보안 및 성능
- **보안**: ✅ 문제 없음
- **성능**: ✅ 문제 없음

---

## ✅ 강점

1. **완전한 구현**: 모든 요구사항 100% 충족
2. **높은 테스트 커버리지**: 87% (목표 초과)
3. **보안 Best Practices**: bcrypt, JWT 환경변수, 에러 처리 완비
4. **TDD 준수**: RED → GREEN → REFACTOR 사이클 확인됨
5. **디버그 로깅**: 5가지 위치 모두 추가됨

---

## ⚠️ 개선 사항

### 1. 에러 처리 로직 중복 (가독성)

**위치**: `src/controllers/authController.ts`

**문제**:
signup과 login 함수에서 동일한 에러 처리 패턴 반복

**현재 코드** (signup):
```typescript
try {
  // ... 로직
} catch (error) {
  logger.error(`회원가입 실패: ${error.message}`, { error });
  if (error.code === 'DUPLICATE_EMAIL') {
    return res.status(400).json({ error: '이미 존재하는 이메일입니다' });
  }
  return res.status(500).json({ error: '서버 오류' });
}
```

**현재 코드** (login):
```typescript
try {
  // ... 로직
} catch (error) {
  logger.error(`로그인 실패: ${error.message}`, { error });
  return res.status(401).json({ error: '인증 실패' });
}
```

**권장 개선**:
```typescript
// src/utils/errorHandler.ts (새 파일)
export const handleAuthError = (error: Error, res: Response, operation: string) => {
  logger.error(`${operation} 실패: ${error.message}`, { error });

  if (error.code === 'DUPLICATE_EMAIL') {
    return res.status(400).json({ error: '이미 존재하는 이메일입니다' });
  }

  if (error.code === 'INVALID_CREDENTIALS') {
    return res.status(401).json({ error: '인증 실패' });
  }

  return res.status(500).json({ error: '서버 오류' });
};

// 사용
try {
  // ... 로직
} catch (error) {
  return handleAuthError(error, res, '회원가입');
}
```

**우선순위**: 🟡 SHOULD (조건부 승인 가능, 개선 권장)

---

## 📋 체크리스트

### 필수 항목 (🔴 MUST)
- [x] 모든 요구사항 구현
- [x] 테스트 커버리지 ≥ 80%
- [x] 빌드 성공
- [x] 린트 에러 0개
- [x] 보안 체크 통과
- [x] PROGRESS.md 존재

### 권장 항목 (🟡 SHOULD)
- [x] 코드 리뷰 가능 상태
- [ ] 에러 처리 중복 제거
- [x] 디버그 로깅 충분

---

## 🎯 최종 결정

**✅ 조건부 승인**

**사유**:
- 모든 필수 요구사항 충족
- 테스트, 보안, 성능 모두 기준 통과
- 개선 사항은 비필수 (가독성 향상)

**조건**:
- 🟡 에러 처리 중복 제거 권장 (필수 아님)

**다음 단계**:
1. (선택) 에러 처리 리팩토링
2. 프로덕션 배포 준비
3. API 문서화 작성

---

**리뷰 완료 시각**: 2026-01-20 15:45
**총 리뷰 소요 시간**: 15분
```

---

## 주요 체크포인트

### ✅ Planner 체크포인트

1. **PLAN.md 위치**: `docs/features/YYYY-MM-DD-feature-name/PLAN.md`
2. **Phase 개수**: 3-7개
3. **각 Phase**: TDD 구조 (RED-GREEN-REFACTOR) 포함
4. **Quality Gate**: 각 Phase 완료 조건 명시
5. **롤백 전략**: Phase별 복구 방법 작성

### ✅ Implementer 체크포인트

1. **TDD Cycle**: 모든 Phase에서 RED → GREEN → REFACTOR
2. **테스트 정책**:
   - 테스트 스킵 절대 금지
   - 전체 테스트 실행
   - 100% 통과 필수
3. **디버그 로깅**: 5가지 위치 (함수 진입/종료, 상태 변경, 외부 시스템, 비즈니스 로직, 예외 처리)
4. **Phase 완료 조건**:
   - 모든 테스트 통과
   - 커버리지 ≥ 80%
   - 빌드 성공
   - 언어별 품질 검사 통과
   - PROGRESS.md 업데이트
5. **순차 실행**: 현재 Phase 100% 완료 전 다음 Phase 시작 금지
6. **중단 조건**: 테스트 실패/메모리 오류/빌드 실패/타임아웃 시 즉시 중단

### ✅ Reviewer 체크포인트

1. **요구사항 충족도**: ≥80% (100% 목표)
2. **코드 품질 점수**: ≥12/15 (80%)
3. **테스트 커버리지**: ≥80%
4. **보안 검토**: Critical 이슈 0개
5. **PROGRESS.md 검증**: 모든 Phase 기록됨
6. **언어별 품질 검증**: 필수 도구 모두 실행, 에러 0

---

## 트러블슈팅

### 문제 1: Implementer가 테스트를 스킵함

**증상**:
```bash
npm test -- --skip-tests
```

**원인**: 테스트 정책 위반

**해결**:
1. Implementer.md 확인: 테스트 스킵 절대 금지 정책 (76-96번 줄)
2. 에이전트에 명시적 지시: "테스트를 절대 스킵하지 말고 전체 실행해"
3. PLAN.md에 명시: "모든 Phase에서 전체 테스트 실행 필수"

---

### 문제 2: Phase를 건너뛰고 다음 Phase 시작

**증상**:
Phase 1 미완료 상태에서 Phase 2 시작

**원인**: Phase 순차 실행 규칙 위반

**해결**:
1. Implementer.md 확인: Phase 순차 실행 규칙 (124-147번 줄)
2. TodoWrite로 진행 상황 추적
3. 각 Phase 완료 후 명시적 확인: "Phase 1이 완료되었는지 확인해"

---

### 문제 3: 테스트 내 중복 구현 발견

**증상**:
```typescript
// test_payment.py
def process_payment(amount):  # 프로덕션에 없는 함수
    return amount * 1.1

def test_process_payment():
    assert process_payment(100) == 110  # 무의미한 테스트
```

**원인**: Unit Test 구현 요구사항 위반

**해결**:
1. Implementer.md 확인: Unit Test 요구사항 (98-122번 줄)
2. Reviewer가 자동 감지하여 거부
3. 수정: 실제 프로덕션 코드 import 사용

---

### 문제 4: PROGRESS.md가 업데이트되지 않음

**증상**:
Phase 완료 후에도 PROGRESS.md가 비어있음

**원인**: PROGRESS.md 관리 정책 미준수

**해결**:
1. Implementer.md 확인: PROGRESS.md 관리 (203-237번 줄)
2. Phase 완료 조건에 포함: PROGRESS.md 업데이트 (157번 줄)
3. 수동 업데이트 또는 Implementer에게 재요청

---

### 문제 5: 언어별 품질 검사가 실행되지 않음

**증상**:
ESLint, TypeScript 타입 체크가 실행되지 않음

**원인**: 프로젝트 타입 감지 실패 또는 품질 검사 생략

**해결**:
1. package.json, tsconfig.json 존재 확인
2. Implementer.md 확인: 언어별 품질 검사 (256-308번 줄)
3. Phase 완료 조건에 포함: 언어별 품질 검사 통과 (156번 줄)
4. 수동 실행:
   ```bash
   npm run lint
   npx tsc --noEmit
   npm test -- --coverage
   ```

---

## 🎉 요약

### 서브에이전트 사용의 핵심

1. **Planner**: 명확한 계획 수립 (PLAN.md)
2. **Implementer**: TDD + 품질 검증 + PROGRESS.md 추적
3. **Reviewer**: 요구사항 + 품질 + 보안 검증

### 성공 조건

✅ PLAN.md가 완전하고 구체적
✅ 각 Phase가 독립적이고 테스트 가능
✅ TDD Cycle 철저히 준수
✅ 모든 Phase에서 품질 검사 통과
✅ PROGRESS.md로 진행 상황 추적
✅ 중단 조건 발생 시 즉시 보고

### 권장 워크플로우

```
사용자 요청
    ↓
Planner (계획 수립)
    ↓
PLAN.md 검토 및 승인
    ↓
Implementer (Phase별 구현)
    ↓
각 Phase 완료 시 품질 검사
    ↓
모든 Phase 완료
    ↓
Reviewer (최종 검증)
    ↓
REVIEW_REPORT.md 확인
    ↓
승인 시 배포, 거부 시 수정
```

---

**마지막 업데이트**: 2026-01-20
**버전**: 1.0
**작성자**: AI Dev Tasks Team
