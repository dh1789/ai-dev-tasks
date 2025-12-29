# 구현 진행 상황: [Feature Name]

**프로젝트**: /workspace
**기능**: [Feature Name]
**시작 시각**: YYYY-MM-DD HH:MM:SS
**현재 Phase**: X/Total
**전체 상태**: 🔄 진행 중 | ✅ 완료 | ❌ 실패

---

## 📊 전체 진행도

```
████████████░░░░░░░░ 60% (Phase 3/5 완료)
```

**예상 완료**: YYYY-MM-DD HH:MM
**경과 시간**: X시간 Y분
**남은 시간**: 약 Z시간 (예상)

---

## Phase 상세 진행 상황

### Phase 1: [Foundation] ✅
**상태**: 완료
**시작**: YYYY-MM-DD HH:MM
**완료**: YYYY-MM-DD HH:MM
**소요 시간**: X분

#### 작업 내용
- 🔴 RED: 테스트 작성
- 🟢 GREEN: 구현 완료
- 🔵 REFACTOR: 리팩토링 완료

#### 결과
- ✅ 빌드: 성공
- ✅ 테스트: 12/12 통과
- ✅ 커버리지: 85%
- ✅ 메모리: Clean (Valgrind + ASan)
- ✅ 정적 분석: 통과 (clang-tidy, cppcheck)
- ✅ 포매팅: 적용됨 (clang-format)

#### 변경 파일
- `src/[component].cpp` - [설명]
- `include/[component].h` - [설명]
- `test/unit/[component]_test.cpp` - [설명]

#### 커밋 정보
- **Hash**: abc1234
- **Message**: feat(phase-1): implement [component]
- **시각**: YYYY-MM-DD HH:MM

---

### Phase 2: [Core Logic] ✅
**상태**: 완료
**시작**: YYYY-MM-DD HH:MM
**완료**: YYYY-MM-DD HH:MM
**소요 시간**: X분

#### 작업 내용
- 🔴 RED: 비즈니스 로직 테스트 작성
- 🟢 GREEN: 로직 구현
- 🔵 REFACTOR: 성능 최적화

#### 결과
- ✅ 빌드: 성공
- ✅ 테스트: 25/25 통과
- ✅ 커버리지: 90%
- ✅ 메모리: Clean
- ✅ 정적 분석: 통과

#### 변경 파일
- `src/[logic].cpp`
- `test/unit/[logic]_test.cpp`
- `test/integration/[feature]_test.cpp`

#### 커밋 정보
- **Hash**: def5678
- **Message**: feat(phase-2): implement core logic

---

### Phase 3: [Integration] 🔄
**상태**: 진행 중
**시작**: YYYY-MM-DD HH:MM
**현재 작업**: 🟢 GREEN Phase - 통합 코드 작성 중
**진행률**: 60%

#### 작업 내용
- ✅ 🔴 RED: 통합 테스트 작성 완료
- 🔄 🟢 GREEN: 통합 코드 작성 중 (60%)
- ⏳ 🔵 REFACTOR: 대기 중

#### 현재 상태
- 빌드: 진행 중
- 테스트: 작성 완료, 실행 대기
- 예상 완료: XX분 후

---

### Phase 4: [Acceptance] ⏳
**상태**: 대기 중
**예상 시작**: YYYY-MM-DD HH:MM
**예상 소요**: X시간

---

### Phase 5: [Performance] ⏳
**상태**: 대기 중
**예상 시작**: YYYY-MM-DD HH:MM
**예상 소요**: X시간

---

## 📈 누적 통계

### 테스트 결과
- **총 테스트**: 37개
- **통과**: 37개 (100%)
- **실패**: 0개
- **스킵**: 0개

### 코드 커버리지
- **전체**: 87%
- **비즈니스 로직**: 92%
- **유틸리티**: 80%
- **목표**: 80% ✅

### 메모리 검사
- **Valgrind**: ✅ 누수 0
- **AddressSanitizer**: ✅ 통과
- **ThreadSanitizer**: ✅ 통과
- **UBSan**: ✅ 통과

### 정적 분석
- **clang-tidy**: ✅ 경고 0개
- **cppcheck**: ✅ 경고 0개
- **clang-format**: ✅ 적용됨

### 커밋 이력
1. `abc1234` - feat(phase-1): implement foundation
2. `def5678` - feat(phase-2): implement core logic
3. `ghi9012` - (진행 중)

---

## 🚨 문제 및 해결

### 해결된 문제
1. **문제**: [설명]
   - **발생 시각**: YYYY-MM-DD HH:MM
   - **Phase**: X
   - **해결**: [어떻게 해결했는지]
   - **소요 시간**: X분

### 현재 블로커
_(현재 블로커 없음)_

---

## ⚠️ 경고 및 주의사항

### 발생한 경고
1. **Phase 2**: 메모리 사용량 높음 (1.2GB)
   - 상태: 모니터링 중
   - 조치: 필요시 최적화 예정

---

## 📝 구현 노트

### 학습한 내용
- [Phase 진행 중 얻은 인사이트]
- [발견한 베스트 프랙티스]

### 기술적 결정
1. **결정**: [무엇을]
   - **근거**: [왜]
   - **영향**: [어떤 영향]

### 개선 아이디어
- [향후 리팩토링 후보]
- [성능 최적화 아이디어]

---

## 🔔 Slack 알림 이력

1. **14:30** - 구현 시작
2. **15:15** - Phase 1 완료 ✅
3. **16:45** - Phase 2 완료 ✅
4. **17:20** - Phase 3 진행 중 (60%)

---

## 🎯 다음 단계

### 즉시 수행
- [ ] Phase 3 GREEN Phase 완료
- [ ] Phase 3 REFACTOR Phase 수행
- [ ] Phase 3 품질 검사

### 이후 계획
- [ ] Phase 4: 인수 테스트
- [ ] Phase 5: 성능 최적화
- [ ] 최종 검토 및 문서화
- [ ] git push
- [ ] PR 생성

---

## 📊 시간 분석

| Phase | 예상 | 실제 | 차이 | 효율 |
|-------|------|------|------|------|
| Phase 1 | 2h | 45min | -1h 15min | 162% |
| Phase 2 | 3h | 1h 30min | -1h 30min | 200% |
| Phase 3 | 2h | (진행 중) | - | - |
| Phase 4 | 1.5h | - | - | - |
| Phase 5 | 2h | - | - | - |
| **총계** | 10.5h | 2h 15min | - | - |

**평균 효율**: 181% (예상보다 빠름)

---

## ✅ 완료 체크리스트

**Phase 완료 기준** (각 Phase마다):
- [x] 🔴 RED: 테스트 먼저 작성
- [x] 🟢 GREEN: 테스트 통과
- [x] 🔵 REFACTOR: 코드 개선
- [x] 빌드 성공
- [x] 모든 테스트 통과
- [x] 커버리지 목표 달성
- [x] 메모리 검사 통과
- [x] 정적 분석 통과
- [x] 커밋 완료
- [x] Slack 알림 전송

**전체 완료 기준** (최종):
- [ ] 모든 Phase 완료
- [ ] 모든 품질 게이트 통과
- [ ] 문서화 완료
- [ ] 코드 리뷰 준비 완료
- [ ] PR 생성 준비 완료

---

**마지막 업데이트**: YYYY-MM-DD HH:MM:SS
**다음 업데이트**: Phase 완료시 자동
