# 실행 흐름 예제

## 예제 1: 간단한 기능

```
사용자: /plan "로깅 유틸리티 클래스"

AI: 기능 분석 중...
    복잡도: 낮음 - 자동 플래닝 진행

    계획:
    - Phase 1: Logger 클래스 구현
    - Phase 2: 파일 출력 기능
    - Phase 3: 로그 레벨 필터링

    예상 시간: 3시간

    PLAN.md를 생성하시겠습니까? (y/n)

사용자: y

AI: ✅ docs/features/2025-01-29-logging-utility/PLAN.md 생성 완료
```

## 예제 2: 복잡한 기능

```
사용자: /plan "OAuth2 인증 시스템"

AI: 기능 분석 중...
    복잡도: 높음 - 상세 요구사항 수집 필요

    OAuth2 인증 시스템에 대해 질문드리겠습니다.

Q1. 지원할 OAuth2 Grant Type은 무엇인가요?
  a) Authorization Code
  b) Implicit
  c) Resource Owner Password
  d) Client Credentials
  e) 여러 개 (직접 입력)

답변: ___

[10-15개 질문 진행]

AI: 모든 정보를 수집했습니다.

    계획:
    - Phase 1: OAuth2 토큰 생성/검증
    - Phase 2: Authorization Code Flow
    - Phase 3: Token Refresh 메커니즘
    - Phase 4: 보안 검증 (취약점 테스트)
    - Phase 5: 성능 최적화
    - Phase 6: 인수 테스트

    예상 시간: 18시간

    PLAN.md를 생성하시겠습니까? (y/n)

사용자: y

AI: ✅ docs/features/2025-01-29-oauth2-authentication/PLAN.md 생성 완료
```

## 예제 3: 테스트 시나리오 문서화 예시

```markdown
### Phase 2: Core Logic - 테스트 시나리오

**파일**: `test/unit/payment/processor_test.cpp`

**테스트 케이스**:
1. `test_process_payment_with_valid_card`
   - 설명: 유효한 카드로 결제 처리 시 성공 응답 반환
   - 입력: 유효한 카드 정보 (번호, 만료일, CVV)
   - 기대: `PaymentResult.success == true`

2. `test_process_payment_with_expired_card`
   - 설명: 만료된 카드로 결제 시도 시 실패 응답 반환
   - 입력: 만료일이 지난 카드 정보
   - 기대: `PaymentResult.success == false`, 에러 메시지 포함

3. `test_process_payment_with_insufficient_funds`
   - 설명: 잔액 부족 시 거래 거부
   - 입력: 잔액보다 큰 금액
   - 기대: `PaymentResult.errorCode == INSUFFICIENT_FUNDS`
```
