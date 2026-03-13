# 사용 예제

## 예제 1: 정상 완료

```
사용자: /implement "jwt-authentication"

AI: PLAN.md 로드 중...
    ✅ docs/features/2025-01-29-jwt-authentication/PLAN.md

    총 5개 Phase 발견
    예상 시간: 12시간

    Docker 컨테이너 확인 중...
    ✅ gcc15.1_22.04 실행 중

    PROGRESS.md 초기화 완료

    Phase 1/5 시작: Foundation

    🔴 RED Phase...
    [테스트 작성 중...]
    ✅ 테스트 실패 확인 (예상대로)

    🟢 GREEN Phase...
    [구현 중...]
    ✅ 테스트 통과

    🔵 REFACTOR Phase...
    [리팩토링 중...]
    ✅ 테스트 여전히 통과

    품질 검사 중...
    ✅ 빌드: 성공
    ✅ 테스트: 12/12 통과
    ✅ 커버리지: 85%
    ✅ clang-tidy: 통과
    ✅ Valgrind: Clean

    커밋 중...
    ✅ Commit: abc1234

    Slack 알림 전송...
    ✅ Phase 1 완료 알림 전송됨

    Phase 2/5 시작: Core Logic
    ...

    [5개 Phase 모두 완료]

    🎉 전체 구현 완료!

    최종 결과:
    - 5 Phases 완료
    - 52 테스트 통과
    - 커버리지: 87%
    - 5개 커밋

    다음 단계:
    1. PROGRESS.md 검토
    2. git push (수동)
```

## 예제 2: 중대한 문제 발생

```
사용자: /implement "complex-feature"

AI: ...

    Phase 3/7: Integration

    테스트 실행 중...
    ❌ 테스트 실패: 5/15

    재시도 1/3...
    ❌ 여전히 실패: 5/15

    재시도 2/3...
    ❌ 여전히 실패: 5/15

    재시도 3/3...
    ❌ 여전히 실패: 5/15

    🚨 중대한 문제 발생!

    Slack 알림 전송 중...
    ✅ 알림 전송 완료

    현재 상태 저장 중...
    ✅ PROGRESS.md 업데이트 완료

    [AskUserQuestion 도구로 사용자에게 질문]

사용자: "디버깅 후 재시도" 선택

AI: 로그 분석 중...
    [디버깅 수행]
    ...
```
