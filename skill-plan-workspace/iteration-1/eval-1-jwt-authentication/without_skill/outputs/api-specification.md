# JWT 인증 시스템 - API 명세

## 기본 정보
- Base URL: `/api/auth`
- Content-Type: `application/json`
- 인증 방식: Bearer Token (Authorization 헤더)

---

## POST /api/auth/login

사용자 로그인 및 토큰 발급

### 요청
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

### 성공 응답 (200)
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "accessTokenExpiresAt": "2026-03-13T12:15:00.000Z",
    "user": {
      "userId": "uuid-string",
      "email": "user@example.com",
      "roles": ["user"]
    }
  }
}
```
- Refresh Token은 `Set-Cookie` 헤더로 httpOnly 쿠키 설정

### 실패 응답 (401)
```json
{
  "success": false,
  "error": {
    "code": "AUTHENTICATION_FAILED",
    "message": "이메일 또는 비밀번호가 올바르지 않습니다."
  }
}
```

### 실패 응답 (429)
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "요청 횟수를 초과했습니다. 잠시 후 다시 시도해 주세요.",
    "retryAfter": 60
  }
}
```

---

## POST /api/auth/logout

현재 세션 로그아웃 (토큰 무효화)

### 요청 헤더
```
Authorization: Bearer <accessToken>
```

### 성공 응답 (200)
```json
{
  "success": true,
  "message": "로그아웃되었습니다."
}
```
- Refresh Token 쿠키 삭제 (`Set-Cookie`로 만료 처리)

### 실패 응답 (401)
```json
{
  "success": false,
  "error": {
    "code": "TOKEN_INVALID",
    "message": "유효하지 않은 인증 정보입니다."
  }
}
```

---

## POST /api/auth/refresh

Access Token 갱신

### 요청
- Refresh Token은 쿠키에서 자동 전송 (별도 요청 본문 불필요)

### 성공 응답 (200)
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...(새 토큰)",
    "accessTokenExpiresAt": "2026-03-13T12:30:00.000Z"
  }
}
```
- 새 Refresh Token이 `Set-Cookie` 헤더로 설정 (Rotation)

### 실패 응답 (401)
```json
{
  "success": false,
  "error": {
    "code": "REFRESH_TOKEN_INVALID",
    "message": "세션이 만료되었습니다. 다시 로그인해 주세요."
  }
}
```

---

## POST /api/auth/logout-all

모든 세션 로그아웃 (해당 사용자의 모든 토큰 무효화)

### 요청 헤더
```
Authorization: Bearer <accessToken>
```

### 성공 응답 (200)
```json
{
  "success": true,
  "message": "모든 세션에서 로그아웃되었습니다."
}
```

---

## GET /api/auth/me

현재 인증된 사용자 정보 조회

### 요청 헤더
```
Authorization: Bearer <accessToken>
```

### 성공 응답 (200)
```json
{
  "success": true,
  "data": {
    "userId": "uuid-string",
    "email": "user@example.com",
    "roles": ["user"]
  }
}
```

---

## 공통 에러 응답

### 401 Unauthorized
```json
{
  "success": false,
  "error": {
    "code": "TOKEN_EXPIRED | TOKEN_INVALID | TOKEN_BLACKLISTED",
    "message": "유효하지 않은 인증 정보입니다."
  }
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "접근 권한이 없습니다."
  }
}
```

### 422 Unprocessable Entity
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "입력 데이터가 올바르지 않습니다.",
    "details": [
      { "field": "email", "message": "유효한 이메일 형식이 아닙니다." }
    ]
  }
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "서버 내부 오류가 발생했습니다."
  }
}
```
