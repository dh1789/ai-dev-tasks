# Implementation Plan: JWT 기반 사용자 인증 시스템

**Status**: 🔄 계획 수립 완료
**생성일**: 2026-03-13
**예상 완료**: 2026-03-17
**프로젝트 타입**: Node.js/TypeScript (자동 감지)
**언어/프레임워크**: TypeScript 5.x + Node.js 20+ + Express 4.x
**실행 환경**: 로컬

---

**⚠️ 핵심 지침**: 각 Phase 완료 후 반드시 수행:
1. ✅ 완료된 태스크 체크박스 체크
2. 🧪 모든 품질 게이트 검증 명령어 실행
3. ⚠️ 모든 품질 게이트 항목 통과 확인
4. 📅 상단 "생성일" 업데이트
5. 📝 "구현 노트" 섹션에 학습 내용 기록
6. ➡️ 그 후에만 다음 Phase로 진행

⛔ **품질 게이트를 건너뛰거나 실패한 체크와 함께 진행하지 마세요**

---

## 📋 개요

### 기능 설명
JWT(JSON Web Token) 기반 사용자 인증 시스템으로, Access Token과 Refresh Token을 활용한 무상태 인증을 구현한다. Redis를 사용한 토큰 블랙리스트 관리로 즉시 토큰 무효화를 지원하며, Refresh Token 회전(Rotation)을 통해 토큰 탈취 공격에 대응한다.

### 성공 기준
- [ ] 토큰 검증 응답 시간 < 50ms (p95, Redis 조회 포함)
- [ ] 테스트 커버리지 >= 90% (비즈니스 로직)
- [ ] 모든 보안 테스트 100% 통과
- [ ] Redis 연결 실패 시 graceful degradation 동작 확인
- [ ] TypeScript strict 모드 에러 0개

### 사용자 영향
- API 소비자에게 안전하고 표준적인 JWT 인증 메커니즘 제공
- 토큰 만료 시 자동 리프레시로 끊김 없는 사용자 경험
- 로그아웃 시 즉시 토큰 무효화로 보안 강화

---

## 🏗️ 아키텍처 결정사항

| 결정사항 | 근거 | 트레이드오프 |
|---------|------|-------------|
| HS256 알고리즘 기본값 | 단일 서비스 환경에서 간단하고 빠름 | 장점: 설정 단순 / 단점: 비밀 키 공유 필요 (마이크로서비스 시 RS256 전환) |
| Access Token 15분 만료 | 보안과 UX 균형 | 장점: 탈취 시 피해 최소화 / 단점: 잦은 리프레시 필요 |
| Refresh Token 7일 만료 | 사용자 편의 | 장점: 재로그인 빈도 감소 / 단점: 긴 유효기간 리스크 |
| Redis 블랙리스트 | 빠른 조회, TTL 자동 관리 | 장점: O(1) 조회 / 단점: Redis 의존성 추가 |
| Refresh Token Rotation | 토큰 탈취 감지 가능 | 장점: 재사용 공격 방어 / 단점: 구현 복잡성 증가 |
| ioredis 클라이언트 | 클러스터 지원, 파이프라이닝 | 장점: 고성능 / 단점: node-redis 대비 약간 큰 번들 |

### 주요 컴포넌트

#### 컴포넌트 1: TokenService
- **책임**: JWT Access/Refresh Token 생성 및 검증
- **인터페이스**: `generateTokenPair(payload)`, `verifyAccessToken(token)`, `verifyRefreshToken(token)`
- **의존성**: jsonwebtoken, 설정(비밀 키, 만료 시간)

#### 컴포넌트 2: BlacklistService
- **책임**: Redis 기반 토큰 블랙리스트 관리
- **인터페이스**: `addToBlacklist(token, ttl)`, `isBlacklisted(token)`, `revokeAllForUser(userId)`
- **의존성**: ioredis, TokenService (토큰 디코딩)

#### 컴포넌트 3: RefreshTokenService
- **책임**: Refresh Token 회전 및 재사용 감지
- **인터페이스**: `rotateToken(oldRefreshToken)`, `detectReuse(token)`, `revokeFamily(familyId)`
- **의존성**: TokenService, BlacklistService, Redis

#### 컴포넌트 4: AuthMiddleware
- **책임**: Express 요청 파이프라인에서 JWT 검증
- **인터페이스**: `authenticate(req, res, next)`, `optionalAuth(req, res, next)`
- **의존성**: TokenService, BlacklistService

#### 컴포넌트 5: AuthConfig
- **책임**: 인증 관련 설정 중앙 관리
- **인터페이스**: `getConfig()`, 환경 변수 검증
- **의존성**: 환경 변수, zod (스키마 검증)

---

## 📦 의존성

### 필수 의존성
- [ ] `jsonwebtoken`: ^9.0.0 (JWT 생성/검증)
- [ ] `@types/jsonwebtoken`: ^9.0.0 (TypeScript 타입)
- [ ] `ioredis`: ^5.3.0 (Redis 클라이언트)
- [ ] `zod`: ^3.22.0 (설정/입력 검증)
- [ ] `winston`: ^3.11.0 (구조화된 로깅)
- [ ] `uuid`: ^9.0.0 (토큰 패밀리 ID 생성)

### 개발 의존성
- [ ] `jest`: ^29.7.0 (테스트 프레임워크)
- [ ] `ts-jest`: ^29.1.0 (TypeScript Jest 변환)
- [ ] `@types/jest`: ^29.5.0 (Jest 타입)
- [ ] `ioredis-mock`: ^8.9.0 (Redis Mock)
- [ ] `supertest`: ^6.3.0 (HTTP 통합 테스트)

### 빌드 전 요구사항

**Node.js/TypeScript 프로젝트:**
- [ ] Node.js 20+ 및 npm/pnpm 설치 확인
- [ ] package.json에 의존성 추가
- [ ] tsconfig.json strict 모드 확인
- [ ] Jest 설정 파일 (jest.config.ts) 생성/업데이트
- [ ] 테스트 디렉토리 구조 생성

### 테스트 파일 구조 및 실행 방법

**프로젝트 구조:**
```
src/
├── auth/
│   ├── config/
│   │   └── auth.config.ts
│   ├── services/
│   │   ├── token.service.ts
│   │   ├── blacklist.service.ts
│   │   └── refresh-token.service.ts
│   ├── middleware/
│   │   └── auth.middleware.ts
│   ├── types/
│   │   └── auth.types.ts
│   └── index.ts
__tests__/
├── unit/
│   ├── token.service.test.ts
│   ├── blacklist.service.test.ts
│   ├── refresh-token.service.test.ts
│   └── auth.config.test.ts
├── integration/
│   ├── auth.middleware.test.ts
│   └── auth-flow.test.ts
└── helpers/
    ├── redis-mock.ts
    └── test-utils.ts
```

**테스트 실행:**
- **전체**: `npm test`
- **특정 파일**: `npm test -- __tests__/unit/token.service.test.ts`
- **커버리지**: `npm test -- --coverage`
- **Watch 모드**: `npm test -- --watch`

---

## 🧪 전체 테스트 전략

### 테스트 피라미드 (이 기능)

```
     /\        인수 테스트 (E2E)
    /  \       - 3개 시나리오
   /----\
  /      \     시나리오 테스트
 /--------\    - 6개 시나리오
/          \
/------------\  통합 테스트
/              \ - 15개 케이스
/----------------\
/                  \ 단위 테스트
/____________________\ - 45개 케이스
```

### 테스트 유형별 목표

| 유형 | 개수 | 커버리지 | 도구 |
|-----|------|---------|------|
| 단위 테스트 | ~45개 | 90% | Jest + ts-jest |
| 통합 테스트 | ~15개 | 80% | Jest + supertest + ioredis-mock |
| 시나리오 테스트 | ~6개 | - | Jest + supertest |
| 인수 테스트 | ~3개 | - | Jest + supertest |

### 테스트 케이스 분류

**모든 테스트에 포함:**
- ✅ **Happy Path**: 정상 동작 경로
- 🔶 **Boundary Cases**: 경계값 (빈 토큰, 최대 페이로드 크기, 만료 직전/직후)
- ❌ **Exception Cases**: 예외 및 오류 처리 (네트워크 오류, Redis 다운 등)
- 🔀 **Edge Cases**: 동시 리프레시 요청, 토큰 형식 변조, 클럭 스큐 등

### 품질 게이트 (각 Phase)

**Node.js/TypeScript 프로젝트:**
- [ ] 의존성 설치 성공 (npm install)
- [ ] TypeScript 타입 체크 통과 (`npx tsc --noEmit`)
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용
- [ ] 테스트 통과 (`npm test`)
- [ ] 커버리지 >= 80%
- [ ] 빌드 성공 (`npm run build`)

**검증 명령어:**
```bash
npx tsc --noEmit && npx eslint src/ __tests__/ && npm test -- --coverage
```

---

## 🚀 구현 Phase

### Phase 1: 프로젝트 기반 구조 및 설정 관리
**목표**: 인증 모듈의 디렉토리 구조, 타입 정의, 설정 관리 시스템 구축
**예상 시간**: 2시간
**복잡도**: 낮음
**TDD**: 적용
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 1.1**: AuthConfig 설정 검증 테스트
  - 파일: `__tests__/unit/auth.config.test.ts`
  - 예상 결과: 실패 (AuthConfig 클래스 미구현)
  - 테스트 케이스:
    - ✅ Happy: 모든 환경 변수가 설정된 경우 올바른 설정 객체 반환
    - ✅ Happy: 기본값 적용 (ACCESS_TOKEN_EXPIRY 미설정 시 '15m')
    - 🔶 Boundary: 빈 문자열 환경 변수 처리
    - ❌ Exception: JWT_SECRET 미설정 시 에러 발생
    - ❌ Exception: 잘못된 만료 시간 형식 시 에러 발생
    - 🔀 Edge: 매우 짧은 만료 시간 ('1s') 허용

- [ ] **Test 1.2**: 타입 정의 컴파일 테스트
  - 파일: `__tests__/unit/auth.types.test.ts`
  - 예상 결과: TypeScript 컴파일 성공 확인
  - 테스트 케이스:
    - ✅ Happy: TokenPayload 인터페이스 호환성
    - ✅ Happy: AuthConfig 타입 구조 검증

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 1.3**: 디렉토리 구조 생성
  - `src/auth/` 하위 디렉토리 생성 (config/, services/, middleware/, types/)
- [ ] **Task 1.4**: 타입 정의 (`src/auth/types/auth.types.ts`)
  - TokenPayload, TokenPair, AuthConfig, BlacklistEntry 인터페이스 정의
- [ ] **Task 1.5**: 설정 관리 (`src/auth/config/auth.config.ts`)
  - zod 스키마로 환경 변수 검증
  - 기본값 설정 (ACCESS_TOKEN_EXPIRY: '15m', REFRESH_TOKEN_EXPIRY: '7d')
  - 목표: Test 1.1, Test 1.2 통과

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 1.6**: 리팩토링
  - 설정 키를 enum/const로 추출
  - JSDoc 주석 추가
  - 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 2로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (이 Phase: 90%)

**빌드 & 테스트:**
```bash
npx tsc --noEmit && npm test -- --coverage __tests__/unit/auth.config.test.ts
```

**품질 검사:**
- [ ] TypeScript strict 모드 에러 0개
- [ ] ESLint 경고/에러 0개

**커밋:**
- [ ] 변경사항 스테이징
  ```bash
  git add src/auth/ __tests__/unit/auth.config.test.ts __tests__/unit/auth.types.test.ts
  ```
- [ ] 커밋
  ```bash
  git commit -m "feat(auth): Phase 1 - 인증 모듈 기반 구조 및 설정 관리

  - 타입 정의 (TokenPayload, TokenPair, AuthConfig)
  - zod 기반 환경 변수 검증
  - 기본 설정값 적용
  - 테스트 커버리지: 90%+

  Phase 1/6 완료"
  ```

---

### Phase 2: JWT 토큰 생성 및 검증 서비스
**목표**: Access Token과 Refresh Token의 생성/검증 핵심 로직 구현
**예상 시간**: 3시간
**복잡도**: 높음
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 2.1**: TokenService 토큰 생성 테스트
  - 파일: `__tests__/unit/token.service.test.ts`
  - 예상 결과: 실패 (TokenService 미구현)
  - 테스트 케이스:
    - ✅ Happy: 유효한 페이로드로 Access Token 생성 성공
    - ✅ Happy: 유효한 페이로드로 Refresh Token 생성 성공
    - ✅ Happy: generateTokenPair()가 access + refresh 동시 반환
    - 🔶 Boundary: 빈 페이로드로 토큰 생성 시 에러
    - 🔶 Boundary: 최대 크기 페이로드 (8KB)
    - ❌ Exception: 비밀 키 미설정 시 에러
    - 🔀 Edge: 특수 문자가 포함된 사용자 ID

- [ ] **Test 2.2**: TokenService 토큰 검증 테스트
  - 파일: `__tests__/unit/token.service.test.ts` (동일 파일)
  - 예상 결과: 실패
  - 테스트 케이스:
    - ✅ Happy: 유효한 Access Token 검증 성공, 페이로드 반환
    - ✅ Happy: 유효한 Refresh Token 검증 성공
    - 🔶 Boundary: 만료 직전 토큰 (1초 전)
    - 🔶 Boundary: 방금 만료된 토큰 (1초 후)
    - ❌ Exception: 변조된 토큰 (서명 불일치) 거부
    - ❌ Exception: 잘못된 형식 문자열 거부
    - ❌ Exception: null/undefined 토큰 거부
    - 🔀 Edge: 다른 비밀 키로 서명된 토큰 거부
    - 🔀 Edge: Access Token을 Refresh Token으로 사용 시도 거부

- [ ] **Test 2.3**: 토큰 페이로드 무결성 테스트
  - 파일: `__tests__/unit/token.service.test.ts` (동일 파일)
  - 테스트 케이스:
    - ✅ Happy: 디코딩된 페이로드에 userId, email, role 포함
    - ❌ Exception: 페이로드에 password 필드 포함 시 자동 제거
    - 🔀 Edge: 토큰 타입(access/refresh) 구분 가능

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 2.4**: TokenService 구현 (`src/auth/services/token.service.ts`)
  - `generateAccessToken(payload: TokenPayload): string`
  - `generateRefreshToken(payload: TokenPayload): string`
  - `generateTokenPair(payload: TokenPayload): TokenPair`
  - `verifyAccessToken(token: string): TokenPayload`
  - `verifyRefreshToken(token: string): TokenPayload`
  - 민감 필드 자동 필터링 (password, secret 등)
  - 목표: Test 2.1, 2.2, 2.3 모두 통과

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 2.5**: 리팩토링
  - 토큰 생성/검증 공통 로직 추출
  - 에러 타입별 커스텀 에러 클래스 생성 (TokenExpiredError, TokenInvalidError 등)
  - 민감 필드 필터링 로직을 별도 유틸리티로 분리
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 3으로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (이 Phase: 90%)

**빌드 & 테스트:**
```bash
npx tsc --noEmit && npm test -- --coverage __tests__/unit/token.service.test.ts
```

**보안 체크:**
- [ ] 토큰 페이로드에 민감 정보 포함 불가 확인
- [ ] 비밀 키가 코드에 하드코딩되지 않았는지 확인

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add src/auth/services/token.service.ts __tests__/unit/token.service.test.ts
  git commit -m "feat(auth): Phase 2 - JWT 토큰 생성/검증 서비스

  - Access Token (15분) / Refresh Token (7일) 생성
  - 서명 검증, 만료 검증, 토큰 타입 검증
  - 민감 필드 자동 필터링
  - 커스텀 에러 클래스
  - 테스트 커버리지: 90%+

  Phase 2/6 완료"
  ```

---

### Phase 3: Redis 블랙리스트 서비스
**목표**: Redis 기반 토큰 블랙리스트 등록/조회/TTL 관리 구현
**예상 시간**: 3시간
**복잡도**: 중간
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 3.1**: BlacklistService 단위 테스트
  - 파일: `__tests__/unit/blacklist.service.test.ts`
  - Mock 필요: ioredis (ioredis-mock 사용)
  - 예상 결과: 실패 (BlacklistService 미구현)
  - 테스트 케이스:
    - ✅ Happy: 토큰을 블랙리스트에 등록 성공
    - ✅ Happy: 블랙리스트된 토큰 조회 시 true 반환
    - ✅ Happy: 블랙리스트에 없는 토큰 조회 시 false 반환
    - ✅ Happy: TTL이 토큰 만료 시간과 일치
    - 🔶 Boundary: 이미 만료된 토큰 블랙리스트 등록 시 무시 (TTL <= 0)
    - 🔶 Boundary: TTL이 1초인 토큰
    - ❌ Exception: Redis 연결 실패 시 isBlacklisted()가 false 반환 (fail-open)
    - ❌ Exception: Redis 연결 실패 시 addToBlacklist()가 에러 로깅 후 조용히 실패
    - 🔀 Edge: 동일 토큰 중복 블랙리스트 등록 (멱등성)

- [ ] **Test 3.2**: 사용자 전체 토큰 무효화 테스트
  - 파일: `__tests__/unit/blacklist.service.test.ts` (동일 파일)
  - 테스트 케이스:
    - ✅ Happy: 특정 사용자의 모든 토큰 무효화 성공
    - ✅ Happy: 무효화 후 해당 사용자 토큰 검증 실패 확인
    - ❌ Exception: 존재하지 않는 사용자 ID로 무효화 시도 (에러 없이 처리)

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 3.3**: Redis 연결 관리 (`src/auth/services/redis-client.ts`)
  - ioredis 클라이언트 싱글톤 생성
  - 연결 상태 모니터링 (connect, error, close 이벤트)
  - 재연결 전략 설정
- [ ] **Task 3.4**: BlacklistService 구현 (`src/auth/services/blacklist.service.ts`)
  - `addToBlacklist(token: string): Promise<void>`
  - `isBlacklisted(token: string): Promise<boolean>`
  - `revokeAllForUser(userId: string): Promise<void>`
  - Redis 키 패턴: `bl:{tokenHash}` (블랙리스트), `user_rev:{userId}` (사용자 무효화 타임스탬프)
  - 목표: Test 3.1, 3.2 모두 통과

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 3.5**: 리팩토링
  - 토큰 해싱 (SHA-256) 추가 (Redis에 원본 토큰 저장 방지)
  - Redis 키 네임스페이스 관리를 설정으로 분리
  - 연결 상태 헬스체크 메서드 추가
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 4로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (이 Phase: 85%)

**빌드 & 테스트:**
```bash
npx tsc --noEmit && npm test -- --coverage __tests__/unit/blacklist.service.test.ts
```

**보안 체크:**
- [ ] Redis에 원본 토큰이 아닌 해시값 저장 확인
- [ ] Redis 연결 실패 시 fail-open/fail-close 정책 확인

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add src/auth/services/blacklist.service.ts src/auth/services/redis-client.ts __tests__/unit/blacklist.service.test.ts __tests__/helpers/
  git commit -m "feat(auth): Phase 3 - Redis 블랙리스트 서비스

  - 토큰 블랙리스트 등록/조회 (SHA-256 해싱)
  - TTL 자동 관리 (토큰 만료 시간 연동)
  - 사용자별 전체 토큰 무효화
  - Redis 장애 시 graceful degradation
  - 테스트 커버리지: 85%+

  Phase 3/6 완료"
  ```

---

### Phase 4: Refresh Token 회전 및 재사용 감지
**목표**: Refresh Token Rotation 구현으로 토큰 탈취 공격 방어
**예상 시간**: 3시간
**복잡도**: 높음
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 4.1**: RefreshTokenService 회전 테스트
  - 파일: `__tests__/unit/refresh-token.service.test.ts`
  - Mock 필요: TokenService, BlacklistService, Redis
  - 예상 결과: 실패 (RefreshTokenService 미구현)
  - 테스트 케이스:
    - ✅ Happy: 유효한 Refresh Token으로 새 토큰 쌍 발급
    - ✅ Happy: 이전 Refresh Token 자동 무효화
    - ✅ Happy: 새 Refresh Token에 동일 토큰 패밀리 ID 유지
    - 🔶 Boundary: 만료 직전 Refresh Token으로 회전 성공
    - 🔶 Boundary: 방금 만료된 Refresh Token으로 회전 실패
    - ❌ Exception: 이미 사용된 Refresh Token으로 회전 시도 → 재사용 감지
    - ❌ Exception: 잘못된 형식의 Refresh Token 거부
    - 🔀 Edge: 동시에 같은 Refresh Token으로 2번 회전 시도 (경쟁 조건)

- [ ] **Test 4.2**: 재사용 감지 및 패밀리 무효화 테스트
  - 파일: `__tests__/unit/refresh-token.service.test.ts` (동일 파일)
  - 테스트 케이스:
    - ✅ Happy: 재사용 감지 시 해당 토큰 패밀리 전체 무효화
    - ✅ Happy: 재사용 감지 시 보안 경고 로그 기록
    - ❌ Exception: 패밀리 무효화 후 해당 패밀리의 모든 토큰 검증 실패
    - 🔀 Edge: 여러 디바이스에서 동시 리프레시 (패밀리 독립성)

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 4.3**: RefreshTokenService 구현 (`src/auth/services/refresh-token.service.ts`)
  - 토큰 패밀리 개념 도입 (familyId를 Refresh Token 페이로드에 포함)
  - `rotateToken(refreshToken: string): Promise<TokenPair>`
  - `detectReuse(token: string): Promise<boolean>`
  - `revokeFamily(familyId: string): Promise<void>`
  - Redis에 사용된 Refresh Token 해시 저장 (SET 자료구조)
  - 목표: Test 4.1, 4.2 모두 통과

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 4.4**: 리팩토링
  - 경쟁 조건 방어를 위한 Redis MULTI/EXEC 트랜잭션 적용
  - 보안 이벤트 로깅 구조화 (winston + 커스텀 포맷)
  - 토큰 패밀리 만료 관리 최적화
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 5로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (이 Phase: 90%)

**빌드 & 테스트:**
```bash
npx tsc --noEmit && npm test -- --coverage __tests__/unit/refresh-token.service.test.ts
```

**보안 체크:**
- [ ] Refresh Token 재사용 감지 동작 확인
- [ ] 패밀리 무효화 시 모든 관련 토큰 차단 확인
- [ ] 보안 경고 로그 기록 확인

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add src/auth/services/refresh-token.service.ts __tests__/unit/refresh-token.service.test.ts
  git commit -m "feat(auth): Phase 4 - Refresh Token 회전 및 재사용 감지

  - Refresh Token Rotation (패밀리 기반)
  - 재사용 감지 시 전체 패밀리 무효화
  - Redis 트랜잭션으로 경쟁 조건 방어
  - 보안 이벤트 로깅
  - 테스트 커버리지: 90%+

  Phase 4/6 완료"
  ```

---

### Phase 5: Express 인증 미들웨어 및 라우트 통합
**목표**: Express 미들웨어로 인증 파이프라인 통합, API 엔드포인트 제공
**예상 시간**: 3시간
**복잡도**: 중간
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 5.1**: AuthMiddleware 단위 테스트
  - 파일: `__tests__/unit/auth.middleware.test.ts`
  - Mock 필요: TokenService, BlacklistService, Express req/res/next
  - 테스트 케이스:
    - ✅ Happy: 유효한 Bearer 토큰으로 요청 시 req.user에 페이로드 설정 + next() 호출
    - ✅ Happy: optionalAuth에서 토큰 없이도 next() 호출 (req.user = undefined)
    - 🔶 Boundary: 'Bearer ' 접두사 없는 토큰 헤더
    - 🔶 Boundary: Authorization 헤더 없는 요청
    - ❌ Exception: 만료된 토큰 → 401 + 구체적 에러 코드 반환
    - ❌ Exception: 변조된 토큰 → 401
    - ❌ Exception: 블랙리스트된 토큰 → 401
    - 🔀 Edge: 'bearer' (소문자) 접두사 허용

- [ ] **Test 5.2**: 인증 API 엔드포인트 통합 테스트
  - 파일: `__tests__/integration/auth.middleware.test.ts`
  - Mock 필요: ioredis-mock
  - 테스트 케이스:
    - ✅ Happy: POST /auth/refresh - 유효한 Refresh Token으로 새 토큰 쌍 발급
    - ✅ Happy: POST /auth/logout - Access Token 블랙리스트 등록 후 200
    - ❌ Exception: POST /auth/refresh - 만료된 Refresh Token → 401
    - ❌ Exception: POST /auth/refresh - 재사용된 Refresh Token → 403
    - ❌ Exception: POST /auth/logout - 토큰 없이 요청 → 401

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 5.3**: AuthMiddleware 구현 (`src/auth/middleware/auth.middleware.ts`)
  - `authenticate`: 필수 인증 미들웨어
  - `optionalAuth`: 선택적 인증 미들웨어
  - Authorization 헤더 파싱 (Bearer 토큰 추출)
  - 구조화된 에러 응답 (에러 코드 + 메시지)
- [ ] **Task 5.4**: 인증 라우터 구현 (`src/auth/routes/auth.routes.ts`)
  - `POST /auth/refresh`: 토큰 리프레시
  - `POST /auth/logout`: 로그아웃 (토큰 블랙리스트)
- [ ] **Task 5.5**: 모듈 공개 인터페이스 (`src/auth/index.ts`)
  - 모든 서비스, 미들웨어, 타입 export
  - 목표: Test 5.1, 5.2 모두 통과

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 5.6**: 리팩토링
  - 에러 응답 형식 표준화 (RFC 7807 Problem Details 참고)
  - 요청 로깅 미들웨어 추가 (인증 시도 기록)
  - 미들웨어 팩토리 패턴 적용 (설정 주입 가능)
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 6으로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (이 Phase: 85%)

**빌드 & 테스트:**
```bash
npx tsc --noEmit && npm test -- --coverage __tests__/unit/auth.middleware.test.ts __tests__/integration/auth.middleware.test.ts
```

**통합 검증:**
- [ ] 미들웨어가 Express 앱에 정상 등록됨
- [ ] 에러 응답 형식이 일관적임
- [ ] 보호된 라우트에 인증 없이 접근 시 401 반환

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add src/auth/middleware/ src/auth/routes/ src/auth/index.ts __tests__/unit/auth.middleware.test.ts __tests__/integration/
  git commit -m "feat(auth): Phase 5 - Express 인증 미들웨어 및 라우트 통합

  - authenticate / optionalAuth 미들웨어
  - POST /auth/refresh, POST /auth/logout 엔드포인트
  - 구조화된 에러 응답 (RFC 7807)
  - 요청 로깅
  - 테스트 커버리지: 85%+

  Phase 5/6 완료"
  ```

---

### Phase 6: 전체 통합 테스트, 보안 검증 및 인수 테스트
**목표**: 전체 인증 플로우 E2E 검증, 보안 시나리오 테스트, 성능 확인
**예상 시간**: 3시간
**복잡도**: 높음
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 6.1**: 전체 인증 플로우 E2E 테스트
  - 파일: `__tests__/integration/auth-flow.test.ts`
  - Mock 필요: ioredis-mock
  - 테스트 케이스:
    - ✅ Happy: 로그인 → API 호출 → 토큰 만료 → 리프레시 → API 재호출 → 로그아웃 → 접근 거부
    - ✅ Happy: 여러 디바이스에서 동시 로그인/로그아웃
    - ❌ Exception: 로그아웃 후 동일 토큰으로 API 호출 거부

- [ ] **Test 6.2**: 보안 시나리오 테스트
  - 파일: `__tests__/integration/auth-security.test.ts`
  - 테스트 케이스:
    - ✅ Happy: 정상 인증 플로우 보안 로그 기록 확인
    - ❌ Exception: 변조된 토큰 → 거부 + 보안 로그
    - ❌ Exception: Refresh Token 재사용 → 패밀리 무효화 + 보안 경고 로그
    - ❌ Exception: Redis 다운 시 인증 서비스 지속 동작 (degraded mode)
    - 🔀 Edge: 동시 리프레시 요청 경쟁 조건 (1개만 성공)
    - 🔀 Edge: 시계 오차(clock skew) 허용 범위 테스트

- [ ] **Test 6.3**: 성능 벤치마크 테스트
  - 파일: `__tests__/integration/auth-performance.test.ts`
  - 테스트 케이스:
    - ✅ Happy: 토큰 검증 100회 반복 평균 < 50ms
    - ✅ Happy: 토큰 생성 100회 반복 평균 < 100ms
    - ✅ Happy: 블랙리스트 조회 100회 반복 평균 < 10ms

**🟢 GREEN Phase: 이전 Phase 통합으로 테스트 통과**
- [ ] **Task 6.4**: 모든 서비스 통합 검증
  - 서비스 간 의존성 주입 정리
  - 초기화 순서 확인 (Config → Redis → Blacklist → Token → Refresh → Middleware)
  - 목표: Test 6.1, 6.2, 6.3 모두 통과

**🔵 REFACTOR Phase: 최종 품질 개선**
- [ ] **Task 6.5**: 최종 리팩토링
  - 코드 중복 최종 제거
  - TSDoc 주석 완성
  - 사용 예제 코드 작성 (README 또는 examples/)
  - 환경 변수 설정 가이드 작성
  - **중요**: 모든 테스트가 통과해야 함

#### Quality Gate ✋

**⚠️ 최종 완료 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 전체 커버리지 목표 달성 (90%)

**전체 빌드 & 테스트:**
```bash
npx tsc --noEmit && npm test -- --coverage
```

**보안 최종 검증:**
- [ ] 모든 보안 시나리오 테스트 통과
- [ ] 비밀 키가 코드에 하드코딩되지 않았는지 최종 확인
- [ ] 민감 정보 로그 출력 여부 확인

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add __tests__/integration/ src/auth/
  git commit -m "feat(auth): Phase 6 - 전체 통합 테스트 및 보안 검증

  - E2E 인증 플로우 테스트
  - 보안 시나리오 테스트 (변조, 재사용 감지, Redis 장애)
  - 성능 벤치마크
  - TSDoc 문서화 완료
  - 전체 테스트 커버리지: 90%+

  Phase 6/6 완료"
  ```

---

## ⚠️ 위험 요소

| 위험 | 확률 | 영향 | 완화 전략 |
|-----|------|------|----------|
| Redis 연결 불안정 | 중간 | 높음 | fail-open 정책 + 재연결 로직 + 연결 풀 + 헬스체크 |
| Refresh Token 경쟁 조건 | 낮음 | 높음 | Redis MULTI/EXEC 트랜잭션 + 원자적 연산 |
| 시계 동기화 문제 (clock skew) | 낮음 | 중간 | JWT clockTolerance 옵션 설정 (30초) |
| 토큰 비밀 키 유출 | 낮음 | 매우 높음 | 환경 변수 전용 + 키 로테이션 가이드 문서화 |
| 메모리 사용량 급증 (블랙리스트) | 낮음 | 중간 | TTL 자동 만료 + Redis 메모리 모니터링 |
| 대량 로그아웃 시 Redis 부하 | 낮음 | 중간 | Redis 파이프라이닝 + 배치 처리 |

---

## 🔄 롤백 전략

### Phase 1 실패시
- 커밋 되돌리기: `git revert [commit-hash]`
- 영향 범위: 설정 파일과 타입만 포함, 다른 기능에 영향 없음

### Phase 2 실패시
- Phase 1 상태로 복구: `git revert [commit-hash]`
- 재시도 전략: 토큰 라이브러리 변경 검토 (jose 라이브러리 대안)

### Phase 3 실패시
- Phase 2 상태로 복구
- 대안: 인메모리 블랙리스트로 임시 대체 (Map + setInterval 정리)

### Phase 4 실패시
- Phase 3 상태로 복구
- 대안: Refresh Token 회전 없이 단순 리프레시로 우선 구현

### Phase 5 실패시
- Phase 4 상태로 복구
- 대안: 미들웨어 없이 서비스 레이어만 제공

### Phase 6 실패시
- Phase 5 상태로 복구
- 대안: 실패한 테스트 시나리오를 별도 이슈로 분리

---

## 📊 진행 상황

### 완료율
- **Phase 1**: ⏳ 0%
- **Phase 2**: ⏳ 0%
- **Phase 3**: ⏳ 0%
- **Phase 4**: ⏳ 0%
- **Phase 5**: ⏳ 0%
- **Phase 6**: ⏳ 0%

**전체 진행도**: 0%

### 시간 추적
| Phase | 예상 | 실제 | 차이 |
|-------|------|------|------|
| Phase 1: 기반 구조 및 설정 | 2h | - | - |
| Phase 2: 토큰 생성/검증 | 3h | - | - |
| Phase 3: Redis 블랙리스트 | 3h | - | - |
| Phase 4: Refresh Token 회전 | 3h | - | - |
| Phase 5: 미들웨어 통합 | 3h | - | - |
| Phase 6: 통합/보안/인수 테스트 | 3h | - | - |
| **합계** | **17h** | - | - |

---

## 📝 구현 노트

### 학습한 내용
- [구현 중 발견한 인사이트]

### 해결한 문제
- **문제 1**: [설명] → [해결방법]

### 블로커
- **블로커 1**: [설명] → [해결상태]

### 향후 개선 사항
- RS256 알고리즘 지원 (마이크로서비스 환경)
- 역할 기반 접근 제어 (RBAC) 미들웨어 확장
- OAuth2 / 소셜 로그인 통합
- 토큰 비밀 키 자동 로테이션
- Redis Cluster 지원
- Rate Limiting (인증 시도 횟수 제한)

---

## 📚 참고 자료

### 문서
- [JSON Web Token RFC 7519](https://tools.ietf.org/html/rfc7519)
- [OWASP Authentication Cheatsheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [jsonwebtoken npm](https://www.npmjs.com/package/jsonwebtoken)
- [ioredis npm](https://www.npmjs.com/package/ioredis)
- [RFC 7807 Problem Details](https://tools.ietf.org/html/rfc7807)

### 관련 이슈
- (해당 시 추가)

---

## ✅ 최종 체크리스트

**구현 완료 전 확인:**
- [ ] 모든 Phase 완료 (6/6)
- [ ] 모든 테스트 통과 (단위/통합/시나리오/인수)
- [ ] 커버리지 >= 90%
- [ ] TypeScript strict 모드 에러 0개
- [ ] ESLint 경고/에러 0개
- [ ] 보안 테스트 전체 통과
- [ ] 성능 벤치마크 목표 달성
- [ ] TSDoc 문서화 완료
- [ ] 사용 예제 코드 작성
- [ ] 환경 변수 설정 가이드 작성
- [ ] PR 생성 준비 완료

---

**계획 상태**: 🔄 구현 대기 중
**다음 액션**: `/implement "jwt-authentication"`

---

## 📊 복잡도 분석

### 복잡도 점수 산출
| 요소 | 값 | 점수 |
|------|-----|------|
| 컴포넌트 수 | 5 (TokenService, BlacklistService, RefreshTokenService, AuthMiddleware, AuthConfig) | 10 |
| 외부 의존성 | 3 (jsonwebtoken, ioredis, zod) | 9 |
| 보안 요구 | 높음 (인증 시스템) | 10 |
| 성능 요구 | 중간 (토큰 검증 < 50ms) | 5 |
| 불명확성 | 낮음 (명확한 요구사항) | 3 |
| **총 복잡도** | | **37점 (높음)** |

### 사고 모드 선택
- **적용**: Sequential Thinking 확장 (~10-15 steps)
- **근거**: 보안이 핵심인 인증 시스템으로, 토큰 생성/검증/회전/블랙리스트 간 상호작용이 복잡하며 보안 취약점 분석이 필수

### 요구사항 수집 결과 (AskUserQuestion 시뮬레이션)

| 질문 영역 | 선택된 옵션 | 근거 |
|-----------|------------|------|
| 핵심 동작 | 비즈니스 로직 | 인증/인가 핵심 업무 규칙 |
| 데이터 형식 | JSON | JWT 표준 |
| 성능 요구 | 중간 (<100ms) | API 응답 속도 |
| 보안 요구 | 인증/인가, 암호화, 입력 검증, 감사 | 인증 시스템 특성상 모두 필요 |
| 안정성 목표 | 높음 (99.9%) | 인증 실패 시 전체 서비스 접근 불가 |
| 테스트 커버리지 | 90% 이상 | 보안 핵심 코드 |
| 로깅 수준 | 기본 + 보안 감사 | 인증 이벤트 추적 필수 |
| Node.js 버전 | 20+ with TypeScript (권장) | 최신 LTS + 타입 안전성 |
| 프레임워크 | Express | 요청에 명시 |
| 테스트 프레임워크 | Jest | 가장 널리 사용 |
