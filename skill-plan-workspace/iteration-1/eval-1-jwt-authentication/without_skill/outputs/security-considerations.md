# JWT 인증 시스템 - 보안 고려사항

## 1. 토큰 보안

### 1.1 비밀키 관리
- Access Token과 Refresh Token에 서로 다른 비밀키 사용
- 비밀키 최소 256비트 (32바이트) 이상
- 환경 변수를 통한 비밀키 관리 (코드에 하드코딩 금지)
- 프로덕션 환경에서 기본값 사용 시 서버 시작 거부
- 비밀키 로테이션 전략 수립 (이전 키로 서명된 토큰 검증 지원)

### 1.2 토큰 설계
- Access Token 수명: 15분 (짧게 유지)
- Refresh Token 수명: 7일 (적절한 균형)
- 토큰 페이로드에 민감 정보 포함 금지 (비밀번호, 개인정보 등)
- 각 토큰에 고유 jti(JWT ID) 포함
- 알고리즘 고정: `algorithms: ['HS256']` (또는 RS256)
- `none` 알고리즘 명시적 거부

### 1.3 Refresh Token Rotation
- 리프레시 시마다 새 Refresh Token 발급
- 사용된 Refresh Token 즉시 무효화
- 이미 사용된 Refresh Token 재사용 감지 시:
  - 해당 사용자의 모든 Refresh Token 무효화
  - 보안 경고 로그 기록
  - 선택적: 사용자에게 보안 알림 발송

## 2. 전송 보안

### 2.1 쿠키 설정 (Refresh Token)
```
httpOnly: true      // JavaScript 접근 차단 (XSS 방어)
secure: true        // HTTPS 전용 전송
sameSite: 'strict'  // CSRF 방어
path: '/api/auth'   // 인증 엔드포인트에서만 전송
maxAge: 604800000   // 7일 (밀리초)
```

### 2.2 HTTPS 강제
- HSTS 헤더 설정: `Strict-Transport-Security: max-age=31536000; includeSubDomains`
- HTTP → HTTPS 리다이렉트

### 2.3 CORS 설정
- 허용 도메인 명시적 설정 (와일드카드 금지)
- credentials: true 설정 (쿠키 전송 허용)

## 3. Redis 보안

### 3.1 연결 보안
- TLS 암호화 연결 사용
- 비밀번호 인증 필수
- 네트워크 격리 (VPC 내부 통신)

### 3.2 장애 대응
- **Fail-Closed 정책**: Redis 장애 시 모든 토큰 검증 거부
  - 이유: 블랙리스트 확인 불가 시 무효화된 토큰 허용 위험
- 연결 실패 시 지수 백오프 재시도 (최대 3회)
- Redis Sentinel 또는 Cluster 구성 권장 (고가용성)

### 3.3 키 관리
- 네임스페이스 분리: `blacklist:jwt:{jti}`, `refresh:{userId}`
- TTL 설정으로 자동 정리 (토큰 만료 시간과 동일)

## 4. API 보안

### 4.1 Rate Limiting
| 엔드포인트 | 제한 | 윈도우 |
|-----------|------|--------|
| POST /api/auth/login | 5회 | 1분 |
| POST /api/auth/refresh | 10회 | 1분 |
| 일반 API | 100회 | 1분 |

### 4.2 입력 유효성 검증
- 이메일 형식 검증
- 비밀번호 길이 제한 (최소 8자, 최대 128자)
- 요청 본문 크기 제한
- SQL Injection / NoSQL Injection 방어
- XSS 방어 (출력 이스케이핑)

### 4.3 에러 응답
- 외부 응답: 통합 에러 메시지 ("인증에 실패했습니다")
- 내부 로그: 상세 에러 정보 기록
- 스택 트레이스 외부 노출 금지

## 5. 공격 방어

### 5.1 방어 대상
| 공격 유형 | 방어 방법 |
|-----------|----------|
| 토큰 탈취 | 짧은 Access Token 수명, Refresh Token Rotation |
| XSS | httpOnly 쿠키, CSP 헤더, 출력 이스케이핑 |
| CSRF | SameSite 쿠키, CSRF 토큰 |
| 브루트포스 | Rate Limiting, 계정 잠금 |
| 알고리즘 변조 | 알고리즘 고정, none 거부 |
| 리플레이 공격 | jti 기반 블랙리스트, 토큰 만료 |
| 타이밍 공격 | 상수 시간 비교 함수 사용 |

### 5.2 감사 로그
기록 대상:
- 로그인 성공/실패 (IP, 타임스탬프, 사용자 에이전트)
- 토큰 리프레시 (이전 jti, 새 jti)
- 로그아웃 (단일/전체)
- 블랙리스트 추가
- Rate Limit 초과
- Refresh Token 재사용 감지 (보안 경고)
