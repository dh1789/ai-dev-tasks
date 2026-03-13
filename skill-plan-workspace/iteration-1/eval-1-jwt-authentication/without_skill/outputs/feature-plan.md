# JWT 기반 사용자 인증 시스템 구현 계획

## 1. 개요

JWT(JSON Web Token) 기반 사용자 인증 시스템을 구현한다. 핵심 기능은 토큰 생성, 검증, 리프레시이며, Redis를 활용한 토큰 블랙리스트 관리를 통해 보안을 강화한다.

## 2. 시스템 아키텍처

### 2.1 컴포넌트 구조

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│   Client    │────▶│  Auth Middleware  │────▶│  Protected  │
│             │     │  (토큰 검증)       │     │  Resources  │
└─────────────┘     └────────┬─────────┘     └─────────────┘
                             │
                    ┌────────▼─────────┐
                    │   Auth Service   │
                    │  ┌─────────────┐ │
                    │  │ Token 생성   │ │
                    │  │ Token 검증   │ │
                    │  │ Token 리프레시│ │
                    │  │ 블랙리스트   │ │
                    │  └─────────────┘ │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
      ┌───────▼──────┐ ┌────▼────┐ ┌───────▼──────┐
      │   Database   │ │  Redis  │ │   Config     │
      │  (사용자 저장) │ │(블랙리스트)│ │  (비밀키 관리) │
      └──────────────┘ └─────────┘ └──────────────┘
```

### 2.2 토큰 흐름

```
[로그인 요청] → [자격 증명 검증] → [Access Token + Refresh Token 발급]
                                          │
[API 요청 + Access Token] → [미들웨어 검증] → [블랙리스트 확인] → [리소스 접근]
                                          │
[Access Token 만료] → [Refresh Token으로 갱신 요청] → [새 Access Token 발급]
                                          │
[로그아웃] → [Access Token 블랙리스트 등록] → [Refresh Token 무효화]
```

## 3. 구현 태스크

### 태스크 1: 프로젝트 기본 설정 및 의존성 구성

**목적**: 인증 시스템에 필요한 패키지 설치 및 환경 설정

**작업 항목**:
- 필수 패키지 설치: `jsonwebtoken`, `bcryptjs`, `ioredis`, `uuid`
- 타입 패키지 설치 (TypeScript 사용 시): `@types/jsonwebtoken`, `@types/bcryptjs`
- 환경 변수 설정 파일 구성

**환경 변수 목록**:
```
JWT_ACCESS_SECRET=<256비트 이상 랜덤 문자열>
JWT_REFRESH_SECRET=<별도 256비트 이상 랜덤 문자열>
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=<비밀번호>
REDIS_TLS=true
```

**완료 기준**: 모든 패키지 설치 완료, 환경 변수 로드 확인

---

### 태스크 2: JWT 설정 및 유틸리티 모듈

**목적**: JWT 토큰 관련 설정값과 공통 유틸리티 구현

**파일**: `src/config/jwt.config.ts`

**구현 사항**:
- Access Token / Refresh Token 비밀키 분리 관리
- 토큰 만료 시간 설정 (Access: 15분, Refresh: 7일)
- 토큰 알고리즘 설정 (RS256 권장, 최소 HS256)
- JWT ID(jti) 생성을 위한 UUID 유틸리티

**보안 고려사항**:
- 비밀키는 환경 변수에서만 로드
- 비밀키 최소 길이 검증 (256비트 이상)
- 프로덕션 환경에서 기본값 사용 금지

**완료 기준**: 설정 모듈 단위 테스트 통과, 비밀키 검증 로직 동작 확인

---

### 태스크 3: 토큰 생성 서비스

**목적**: Access Token 및 Refresh Token 생성 기능 구현

**파일**: `src/services/token.service.ts`

**구현 사항**:

```typescript
// 인터페이스 정의
interface TokenPayload {
  userId: string;
  email: string;
  roles: string[];
}

interface TokenPair {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresAt: Date;
  refreshTokenExpiresAt: Date;
}

// 핵심 메서드
generateTokenPair(payload: TokenPayload): Promise<TokenPair>
generateAccessToken(payload: TokenPayload): string
generateRefreshToken(payload: TokenPayload): string
```

**보안 고려사항**:
- 각 토큰에 고유 jti(JWT ID) 포함하여 개별 무효화 가능하도록 구현
- Access Token에는 최소한의 정보만 포함 (민감 정보 제외)
- Refresh Token은 Access Token과 다른 비밀키 사용
- 토큰 페이로드에 `iss`(발급자), `aud`(대상), `iat`(발급시간) 클레임 포함

**완료 기준**: 토큰 생성 단위 테스트 통과, 토큰 디코딩 시 올바른 페이로드 확인

---

### 태스크 4: 토큰 검증 서비스

**목적**: 토큰 유효성 검증 및 페이로드 추출 기능 구현

**파일**: `src/services/token.service.ts` (기존 파일에 추가)

**구현 사항**:

```typescript
// 핵심 메서드
verifyAccessToken(token: string): Promise<TokenPayload>
verifyRefreshToken(token: string): Promise<TokenPayload>
isTokenBlacklisted(jti: string): Promise<boolean>

// 에러 타입
enum TokenError {
  EXPIRED = 'TOKEN_EXPIRED',
  INVALID = 'TOKEN_INVALID',
  BLACKLISTED = 'TOKEN_BLACKLISTED',
  MALFORMED = 'TOKEN_MALFORMED',
}
```

**검증 단계**:
1. 토큰 형식 검증 (Bearer 스키마)
2. 서명 검증 (비밀키 일치 확인)
3. 만료 시간 검증
4. 블랙리스트 확인 (Redis 조회)
5. 필수 클레임 존재 확인 (userId, roles)

**보안 고려사항**:
- 알고리즘 고정 (alg 헤더 조작 방지: `algorithms: ['HS256']`)
- `none` 알고리즘 명시적 거부
- 타이밍 공격 방지를 위한 상수 시간 비교
- 검증 실패 시 구체적 에러 정보 외부 노출 금지

**완료 기준**: 유효/무효/만료/블랙리스트 토큰에 대한 테스트 모두 통과

---

### 태스크 5: Redis 블랙리스트 관리 서비스

**목적**: 로그아웃된 토큰의 블랙리스트 관리 및 TTL 기반 자동 정리

**파일**: `src/services/blacklist.service.ts`

**구현 사항**:

```typescript
interface BlacklistService {
  addToBlacklist(jti: string, expiresAt: Date): Promise<void>;
  isBlacklisted(jti: string): Promise<boolean>;
  removeExpired(): Promise<number>;  // TTL로 자동 처리되므로 보조적
  getBlacklistCount(): Promise<number>;
}
```

**Redis 키 설계**:
- 키 패턴: `blacklist:jwt:{jti}`
- 값: `1` (존재 여부만 확인)
- TTL: 원본 토큰의 남은 만료 시간과 동일 (만료된 토큰은 블랙리스트 불필요)

**구현 세부사항**:
- Redis 연결 풀 관리 (`ioredis` 사용)
- 연결 실패 시 재시도 로직 (최대 3회, 지수 백오프)
- Redis 장애 시 폴백 전략 (인메모리 캐시 또는 모든 토큰 거부)
- 파이프라인을 활용한 대량 블랙리스트 처리 (전체 로그아웃 시)

**보안 고려사항**:
- Redis 연결 시 TLS 사용
- Redis 인증(비밀번호) 필수
- 키 네임스페이스 분리로 다른 서비스와 충돌 방지
- Redis 장애 시 Fail-Closed 정책 (안전 우선: 토큰 거부)

**완료 기준**: 블랙리스트 추가/조회/TTL 만료 테스트 통과, Redis 장애 시나리오 테스트 통과

---

### 태스크 6: 토큰 리프레시 기능

**목적**: 만료된 Access Token을 Refresh Token으로 갱신하는 기능 구현

**파일**: `src/services/token.service.ts` (기존 파일에 추가)

**구현 사항**:

```typescript
// 핵심 메서드
refreshTokenPair(refreshToken: string): Promise<TokenPair>

// Refresh Token 저장소 (Redis)
interface RefreshTokenStore {
  storeRefreshToken(userId: string, jti: string, expiresAt: Date): Promise<void>;
  getRefreshToken(userId: string): Promise<string | null>;
  revokeRefreshToken(userId: string): Promise<void>;
  revokeAllUserTokens(userId: string): Promise<void>;
}
```

**리프레시 로직**:
1. Refresh Token 서명 및 만료 검증
2. Refresh Token 블랙리스트 확인
3. 저장소에서 Refresh Token 유효성 확인 (토큰 탈취 감지)
4. 기존 Refresh Token 무효화 (Rotation)
5. 새로운 Access Token + Refresh Token 쌍 발급
6. 새 Refresh Token 저장소에 기록

**Refresh Token Rotation**:
- 리프레시 시마다 새 Refresh Token 발급 (재사용 방지)
- 이미 사용된 Refresh Token 감지 시 해당 사용자의 모든 토큰 무효화 (탈취 대응)
- Refresh Token 패밀리 추적으로 연쇄 탈취 방지

**보안 고려사항**:
- Refresh Token은 httpOnly, secure, sameSite 쿠키로 전달
- Refresh Token 재사용 감지 시 전체 세션 무효화
- 동시 리프레시 요청 처리 (Race Condition 방지)
- 리프레시 빈도 제한 (Rate Limiting)

**완료 기준**: 정상 리프레시, 만료 토큰 거부, 재사용 감지, Rotation 테스트 모두 통과

---

### 태스크 7: 인증 미들웨어

**목적**: HTTP 요청에서 JWT를 추출하고 검증하는 미들웨어 구현

**파일**: `src/middleware/auth.middleware.ts`

**구현 사항**:

```typescript
// Express 미들웨어
function authenticate(req: Request, res: Response, next: NextFunction): Promise<void>
function authorize(...roles: string[]): RequestHandler
function optionalAuth(req: Request, res: Response, next: NextFunction): Promise<void>

// 요청 객체 확장
interface AuthenticatedRequest extends Request {
  user?: {
    userId: string;
    email: string;
    roles: string[];
  };
  tokenJti?: string;
}
```

**미들웨어 동작**:
1. `Authorization: Bearer <token>` 헤더에서 토큰 추출
2. 토큰 검증 서비스 호출
3. 블랙리스트 확인
4. 검증 성공 시 `req.user`에 페이로드 설정
5. 검증 실패 시 적절한 HTTP 상태 코드 응답

**응답 코드**:
- `401 Unauthorized`: 토큰 누락, 만료, 무효, 블랙리스트
- `403 Forbidden`: 권한 부족 (역할 불일치)

**보안 고려사항**:
- 에러 응답에서 구체적 실패 원인 노출 금지 (외부)
- 내부 로그에는 상세 에러 기록
- 요청당 토큰 검증은 1회만 수행

**완료 기준**: 미들웨어 통합 테스트 통과, 각 시나리오별 올바른 응답 확인

---

### 태스크 8: 인증 API 엔드포인트

**목적**: 로그인, 로그아웃, 토큰 리프레시 API 구현

**파일**: `src/routes/auth.routes.ts`, `src/controllers/auth.controller.ts`

**엔드포인트 정의**:

| 메서드 | 경로 | 설명 | 인증 필요 |
|--------|------|------|-----------|
| POST | `/api/auth/login` | 로그인 및 토큰 발급 | 아니오 |
| POST | `/api/auth/logout` | 로그아웃 및 토큰 무효화 | 예 |
| POST | `/api/auth/refresh` | 토큰 갱신 | 아니오 (Refresh Token 필요) |
| POST | `/api/auth/logout-all` | 모든 세션 로그아웃 | 예 |
| GET | `/api/auth/me` | 현재 사용자 정보 | 예 |

**각 엔드포인트 세부 사항**:

**POST /api/auth/login**:
- 입력: `{ email: string, password: string }`
- 비밀번호 해싱 검증 (bcrypt, saltRounds >= 12)
- 성공: Access Token(응답 본문) + Refresh Token(httpOnly 쿠키)
- 실패: 통합 에러 메시지 ("이메일 또는 비밀번호가 올바르지 않습니다")
- Rate Limiting: IP당 분당 5회

**POST /api/auth/logout**:
- Access Token의 jti를 블랙리스트에 추가
- Refresh Token 무효화
- 클라이언트 쿠키 삭제

**POST /api/auth/refresh**:
- httpOnly 쿠키에서 Refresh Token 추출
- Refresh Token Rotation 적용
- 새 토큰 쌍 발급

**보안 고려사항**:
- 모든 입력 데이터 유효성 검증 (이메일 형식, 비밀번호 길이)
- CORS 설정 (허용 도메인 명시)
- CSRF 방지 (SameSite 쿠키 + CSRF 토큰)
- Rate Limiting 적용 (로그인, 리프레시 엔드포인트)

**완료 기준**: 모든 엔드포인트 통합 테스트 통과, 보안 시나리오 테스트 통과

---

### 태스크 9: 보안 강화 및 에러 처리

**목적**: 전반적인 보안 강화 및 통합 에러 처리 구현

**파일**: `src/middleware/security.middleware.ts`, `src/utils/error-handler.ts`

**구현 사항**:

**Rate Limiting**:
- 로그인 엔드포인트: IP당 분당 5회
- 리프레시 엔드포인트: IP당 분당 10회
- 일반 API: 사용자당 분당 100회
- Redis 기반 분산 Rate Limiter

**보안 헤더**:
- `Strict-Transport-Security`: HTTPS 강제
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Content-Security-Policy`: 적절한 정책 설정

**에러 처리**:
```typescript
class AuthenticationError extends AppError {
  constructor(message: string, code: TokenError) {
    super(message, 401, code);
  }
}

class AuthorizationError extends AppError {
  constructor(message: string) {
    super(message, 403, 'INSUFFICIENT_PERMISSIONS');
  }
}
```

**감사 로그**:
- 로그인 성공/실패 기록
- 토큰 리프레시 기록
- 로그아웃 기록
- 블랙리스트 추가 기록
- 비정상 패턴 감지 (짧은 시간 내 다수 실패)

**완료 기준**: 보안 테스트 통과, Rate Limiting 동작 확인, 감사 로그 기록 확인

---

### 태스크 10: 테스트 작성

**목적**: 단위 테스트, 통합 테스트 작성

**파일**: `src/__tests__/`

**테스트 범위**:

**단위 테스트**:
- 토큰 생성: 올바른 페이로드, 만료 시간, 서명 검증
- 토큰 검증: 유효/무효/만료/변조 토큰 처리
- 블랙리스트: 추가, 조회, TTL 만료
- Refresh Token Rotation: 정상 갱신, 재사용 감지

**통합 테스트**:
- 로그인 → API 호출 → 토큰 만료 → 리프레시 → API 호출 전체 흐름
- 로그아웃 후 토큰 사용 시도 → 거부 확인
- 동시 리프레시 요청 처리
- Redis 장애 시 폴백 동작

**보안 테스트**:
- 알고리즘 변조 공격 (alg: none)
- 서명 키 변조 공격
- 만료된 토큰 재사용
- Refresh Token 탈취 시나리오
- Rate Limiting 동작 확인
- SQL Injection / XSS 방어 확인

**완료 기준**: 커버리지 80% 이상, 모든 보안 테스트 통과

## 4. 디렉토리 구조

```
src/
├── config/
│   ├── jwt.config.ts          # JWT 설정
│   └── redis.config.ts        # Redis 연결 설정
├── controllers/
│   └── auth.controller.ts     # 인증 API 컨트롤러
├── middleware/
│   ├── auth.middleware.ts      # 인증/인가 미들웨어
│   └── security.middleware.ts  # Rate Limiting, 보안 헤더
├── routes/
│   └── auth.routes.ts         # 인증 라우트 정의
├── services/
│   ├── token.service.ts       # 토큰 생성/검증/리프레시
│   └── blacklist.service.ts   # Redis 블랙리스트 관리
├── utils/
│   └── error-handler.ts       # 통합 에러 처리
└── __tests__/
    ├── unit/
    │   ├── token.service.test.ts
    │   └── blacklist.service.test.ts
    └── integration/
        ├── auth.flow.test.ts
        └── security.test.ts
```

## 5. 의존성 목록

| 패키지 | 용도 | 버전 (권장) |
|--------|------|-------------|
| jsonwebtoken | JWT 생성/검증 | ^9.x |
| bcryptjs | 비밀번호 해싱 | ^2.x |
| ioredis | Redis 클라이언트 | ^5.x |
| uuid | JWT ID 생성 | ^9.x |
| express-rate-limit | Rate Limiting | ^7.x |
| rate-limit-redis | Redis 기반 Rate Limiter | ^4.x |
| helmet | 보안 헤더 | ^7.x |
| cookie-parser | 쿠키 파싱 | ^1.x |

## 6. 보안 체크리스트

- [ ] Access/Refresh Token 비밀키 분리
- [ ] 비밀키 최소 256비트 검증
- [ ] 알고리즘 고정 (alg 헤더 조작 방지)
- [ ] Refresh Token Rotation 구현
- [ ] Refresh Token 재사용 감지 시 전체 세션 무효화
- [ ] Redis TLS 연결
- [ ] Redis 장애 시 Fail-Closed 정책
- [ ] 로그인 Rate Limiting
- [ ] httpOnly + Secure + SameSite 쿠키
- [ ] 에러 응답에서 내부 정보 노출 금지
- [ ] HTTPS 강제 (HSTS)
- [ ] 감사 로그 기록
- [ ] bcrypt saltRounds >= 12
- [ ] 입력 데이터 유효성 검증

## 7. 구현 우선순위 및 예상 일정

| 순서 | 태스크 | 예상 시간 | 의존성 |
|------|--------|-----------|--------|
| 1 | 프로젝트 설정 | 1시간 | 없음 |
| 2 | JWT 설정 모듈 | 1시간 | 태스크 1 |
| 3 | 토큰 생성 서비스 | 2시간 | 태스크 2 |
| 4 | 토큰 검증 서비스 | 2시간 | 태스크 3 |
| 5 | Redis 블랙리스트 서비스 | 2시간 | 태스크 1 |
| 6 | 토큰 리프레시 기능 | 3시간 | 태스크 4, 5 |
| 7 | 인증 미들웨어 | 2시간 | 태스크 4 |
| 8 | 인증 API 엔드포인트 | 3시간 | 태스크 6, 7 |
| 9 | 보안 강화 | 2시간 | 태스크 8 |
| 10 | 테스트 작성 | 4시간 | 태스크 1-9 |

**총 예상 시간**: 약 22시간
