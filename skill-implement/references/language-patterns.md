# 언어별 실행 패턴

Phase별 빌드, 테스트, 품질 검사의 언어별 상세 명령어와 검사 항목.

## 목차
- [Ruby/Rails](#rubyrails)
- [Node.js/TypeScript](#nodejstypescript)
- [C++](#c)
- [Bash/Shell](#bashshell)
- [Ansible](#ansible)
- [공통 요구사항](#공통-요구사항)

---

## Ruby/Rails

**실행 위치**: 로컬

### 환경 설정
```bash
bundle install
```

### 테스트 실행
```bash
bundle exec rails test  # 또는 bundle exec rake test
```

### 품질 검사
```bash
~/.claude/skills/ai-dev-tasks/scripts/ruby-quality-check.sh
```

**검사 항목:**
- ✅ 모든 테스트 통과 (100%)
- ✅ 커버리지 ≥ 80% (SimpleCov)
- ✅ RuboCop 통과 (코드 스타일)
- ✅ Brakeman 통과 (보안)
- ✅ Bundle Audit 통과 (의존성 보안)

---

## Node.js/TypeScript

**실행 위치**: 로컬

### 환경 설정
```bash
npm install  # 또는 pnpm install, yarn install (패키지 매니저 자동 감지)
```

### 테스트 실행
```bash
npm test  # 또는 pnpm test, yarn test
```

### 품질 검사
```bash
~/.claude/skills/ai-dev-tasks/scripts/node-quality-check.sh
```

**검사 항목:**
- ✅ 모든 테스트 통과 (100%)
- ✅ 커버리지 ≥ 80%
- ✅ TypeScript 타입 체크 통과
- ✅ ESLint 통과
- ✅ Prettier 포매팅 적용
- ✅ 빌드 성공 (해당시)

---

## C++

**실행 위치**: Docker 컨테이너 (gcc15.1_22.04)

### 환경 확인
```bash
docker ps | grep gcc15.1_22.04
# 실행 중이 아니면: ./scripts/docker-setup.sh start
```

### 빌드
```bash
docker exec gcc15.1_22.04 bash -c "cd /workspace/build && ninja"
```

### 테스트 실행
```bash
docker exec gcc15.1_22.04 bash -c "cd /workspace/build && ./test/unit/*_test"
```

### 품질 검사
```bash
docker exec gcc15.1_22.04 bash -c "cd /workspace && ./scripts/cpp-quality-check.sh"
docker exec gcc15.1_22.04 bash -c "cd /workspace && ./scripts/cpp-memory-check.sh build all"
```

**검사 항목:**
- ✅ 빌드 성공
- ✅ 모든 테스트 통과 (100%)
- ✅ 커버리지 ≥ 80%
- ✅ clang-tidy 통과
- ✅ cppcheck 통과
- ✅ clang-format 적용
- ✅ Valgrind: 메모리 누수 0
- ✅ AddressSanitizer: 메모리 오류 0
- ✅ ThreadSanitizer: 데이터 레이스 0 (멀티스레드시)
- ✅ UndefinedBehaviorSanitizer: UB 0

### TDD 예시 (C++ Docker)
```bash
# RED Phase
docker exec gcc15.1_22.04 bash -c "
  cd /workspace
  # 테스트 파일 생성 → 테스트 실행 → 실패 확인
"

# GREEN Phase
# 구현 코드 작성 → 테스트 실행 → 통과 확인

# REFACTOR Phase
# 코드 개선 → 테스트 여전히 통과 확인
```

### 성능 최적화
```bash
# ccache: 자동 활성화 (Dockerfile에서 설정), 재빌드 시간 대폭 단축
# 병렬 빌드: ninja -j$(nproc) — 모든 CPU 코어 활용
```

---

## Bash/Shell

**실행 위치**: 로컬

### 품질 검사
- ✅ shellcheck 통과
- ✅ bats 테스트 통과
- 🟡 shfmt 포매팅

---

## Ansible

**실행 위치**: 로컬

### 품질 검사
- ✅ ansible-lint 통과
- ✅ molecule test 통과

---

## 공통 요구사항

### 테스트 정책
- **타임아웃**: 30분 (1800000ms) — 모든 언어 공통
- **절대 스킵 불가**: 모든 테스트는 반드시 완료까지 실행
- **실패시**: 최대 3회 재시도 → 실패시 중단 및 보고

### 커밋 (호스트에서 — 모든 언어 공통)
```bash
git add .
git commit -m "feat(phase-X): [요약]

- [변경사항 1]
- [변경사항 2]

Tests: X/X passed
Coverage: Y%
Memory: Clean (Valgrind + ASan + TSan + UBSan)

Phase X/Total completed"
```

**푸시는 하지 않음** — 사용자가 수동으로 결정

### 호스트에서 공통 작업 (모든 언어)
- git 작업 (add, commit)
- 파일 편집
- Slack 알림
- PROGRESS.md 업데이트
