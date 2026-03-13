# JWT 인증 시스템 - 태스크 분해

## 태스크 의존성 그래프

```
[T1: 프로젝트 설정]
    ├──▶ [T2: JWT 설정 모듈]
    │        └──▶ [T3: 토큰 생성]
    │                 └──▶ [T4: 토큰 검증]
    │                          ├──▶ [T6: 토큰 리프레시] ◀── [T5]
    │                          └──▶ [T7: 인증 미들웨어]
    │                                    └──▶ [T8: API 엔드포인트]
    │                                              └──▶ [T9: 보안 강화]
    │                                                        └──▶ [T10: 테스트]
    └──▶ [T5: Redis 블랙리스트] ──▶ [T6]
```

## 상세 태스크 목록

### T1: 프로젝트 기본 설정 및 의존성 구성
- **복잡도**: 낮음
- **예상 시간**: 1시간
- **의존성**: 없음
- **산출물**:
  - package.json 업데이트 (의존성 추가)
  - .env.example 파일 (환경 변수 템플릿)
  - tsconfig.json 업데이트 (필요 시)
- **인수 조건**:
  - 모든 패키지 설치 완료
  - 환경 변수 로드 검증

### T2: JWT 설정 및 유틸리티 모듈
- **복잡도**: 낮음
- **예상 시간**: 1시간
- **의존성**: T1
- **산출물**:
  - `src/config/jwt.config.ts`
  - `src/config/redis.config.ts`
- **인수 조건**:
  - 설정값 로드 및 검증 테스트 통과
  - 비밀키 최소 길이 검증 동작

### T3: 토큰 생성 서비스
- **복잡도**: 중간
- **예상 시간**: 2시간
- **의존성**: T2
- **산출물**:
  - `src/services/token.service.ts` (생성 부분)
  - `src/__tests__/unit/token.generate.test.ts`
- **인수 조건**:
  - Access Token 생성 및 페이로드 확인
  - Refresh Token 생성 및 별도 비밀키 사용 확인
  - jti 고유성 확인

### T4: 토큰 검증 서비스
- **복잡도**: 중간
- **예상 시간**: 2시간
- **의존성**: T3
- **산출물**:
  - `src/services/token.service.ts` (검증 부분 추가)
  - `src/__tests__/unit/token.verify.test.ts`
- **인수 조건**:
  - 유효한 토큰 검증 성공
  - 만료된 토큰 거부
  - 변조된 토큰 거부
  - 잘못된 알고리즘 거부

### T5: Redis 블랙리스트 관리 서비스
- **복잡도**: 중간
- **예상 시간**: 2시간
- **의존성**: T1
- **산출물**:
  - `src/services/blacklist.service.ts`
  - `src/__tests__/unit/blacklist.service.test.ts`
- **인수 조건**:
  - 토큰 블랙리스트 추가/조회
  - TTL 기반 자동 만료
  - Redis 연결 실패 시 재시도
  - Redis 장애 시 Fail-Closed 동작

### T6: 토큰 리프레시 기능
- **복잡도**: 높음
- **예상 시간**: 3시간
- **의존성**: T4, T5
- **산출물**:
  - `src/services/token.service.ts` (리프레시 부분 추가)
  - `src/__tests__/unit/token.refresh.test.ts`
- **인수 조건**:
  - 유효한 Refresh Token으로 새 토큰 쌍 발급
  - Refresh Token Rotation 동작
  - 재사용된 Refresh Token 감지 시 전체 세션 무효화
  - 만료된 Refresh Token 거부

### T7: 인증 미들웨어
- **복잡도**: 중간
- **예상 시간**: 2시간
- **의존성**: T4
- **산출물**:
  - `src/middleware/auth.middleware.ts`
  - `src/__tests__/unit/auth.middleware.test.ts`
- **인수 조건**:
  - Bearer 토큰 추출 및 검증
  - 역할 기반 인가 동작
  - 적절한 HTTP 상태 코드 응답
  - req.user 설정 확인

### T8: 인증 API 엔드포인트
- **복잡도**: 높음
- **예상 시간**: 3시간
- **의존성**: T6, T7
- **산출물**:
  - `src/routes/auth.routes.ts`
  - `src/controllers/auth.controller.ts`
  - `src/__tests__/integration/auth.flow.test.ts`
- **인수 조건**:
  - 로그인/로그아웃/리프레시/전체 로그아웃/사용자 정보 엔드포인트 동작
  - httpOnly 쿠키로 Refresh Token 전달
  - 입력 유효성 검증

### T9: 보안 강화 및 에러 처리
- **복잡도**: 중간
- **예상 시간**: 2시간
- **의존성**: T8
- **산출물**:
  - `src/middleware/security.middleware.ts`
  - `src/utils/error-handler.ts`
- **인수 조건**:
  - Rate Limiting 동작 (로그인: 5회/분, API: 100회/분)
  - 보안 헤더 설정 확인
  - 감사 로그 기록 확인
  - 통합 에러 처리 동작

### T10: 테스트 작성
- **복잡도**: 높음
- **예상 시간**: 4시간
- **의존성**: T1-T9
- **산출물**:
  - `src/__tests__/integration/auth.flow.test.ts`
  - `src/__tests__/integration/security.test.ts`
- **인수 조건**:
  - 단위 테스트 커버리지 80% 이상
  - 전체 인증 흐름 통합 테스트 통과
  - 보안 공격 시나리오 테스트 통과
  - Redis 장애 시나리오 테스트 통과

## 병렬 작업 가능 구간

- **T2와 T5**: JWT 설정과 Redis 블랙리스트는 독립적으로 병렬 진행 가능
- **T3-T4와 T5**: 토큰 서비스와 블랙리스트 서비스는 병렬 진행 가능
- **T7과 T5**: 미들웨어와 블랙리스트 서비스는 병렬 진행 가능 (T4 완료 후)

## 위험 요소

| 위험 | 영향 | 완화 방안 |
|------|------|-----------|
| Redis 연결 불안정 | 블랙리스트 검증 실패 | Fail-Closed 정책, 재시도 로직 |
| 비밀키 유출 | 전체 토큰 무효화 필요 | 키 로테이션 전략, 환경 변수 관리 |
| Refresh Token 탈취 | 무단 세션 갱신 | Rotation + 재사용 감지 |
| 동시 리프레시 요청 | Race Condition | Redis 원자적 연산, 분산 락 |
