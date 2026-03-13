# Implementation Plan: REST API 커서 기반 페이지네이션

**Status**: 🔄 계획 수립 완료
**생성일**: 2026-03-13
**예상 완료**: 2026-03-15
**프로젝트 타입**: 자동 감지됨: Node.js/TypeScript (Express)
**언어/프레임워크**: TypeScript 5.x + Node.js 20+ + Express 4.x + Prisma 5.x
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

## 📊 복잡도 분석

| 항목 | 점수 | 세부사항 |
|------|------|----------|
| 컴포넌트 수 (×2) | 8 | 커서 코덱, 쿼리 빌더, 미들웨어, 응답 포맷터 |
| 외부 의존성 (×3) | 3 | Prisma (기존 사용 중) |
| 보안 | 5 | 커서 위변조 방지, 입력 검증 |
| 성능 | 5 | 대량 데이터 처리 최적화 요구 |
| 불명확성 | 5 | DB 스키마, 기존 API 구조 확인 필요 |
| **총점** | **26** | **중간~높음 복잡도** |

**사고 모드**: Sequential Thinking (~10 steps)

---

## 📋 개요

### 기능 설명
기존 Express REST API의 offset 기반 페이지네이션을 커서(cursor) 기반으로 전환한다. 대량 데이터(수백만 건) 환경에서 일관된 응답 속도를 보장하며, Relay 스타일 커넥션 응답 구조를 채택한다.

### 성공 기준
- [ ] 1,000만 건 테이블에서 어떤 페이지든 응답 시간 < 50ms
- [ ] offset 대비 마지막 페이지 응답 시간 10x 이상 개선
- [ ] 페이징 중 데이터 변경에도 누락/중복 0건
- [ ] 비즈니스 로직 테스트 커버리지 >= 90%
- [ ] 기존 API 클라이언트 영향 0건

### 사용자 영향
API 클라이언트 개발자가 대량 데이터를 안정적으로 탐색할 수 있으며, 무한 스크롤 등의 UX 패턴을 신뢰성 있게 구현할 수 있다. 기존 offset API는 deprecated 처리하되 즉시 제거하지 않아 하위 호환성을 보장한다.

---

## 🏗️ 아키텍처 결정사항

| 결정사항 | 근거 | 트레이드오프 |
|---------|------|-------------|
| Relay 스타일 커넥션 응답 구조 | GraphQL 커뮤니티 표준, 클라이언트 구현 용이 | 장점: 표준화된 인터페이스 / 단점: 응답 크기 약간 증가 |
| Base64 + HMAC 커서 | 클라이언트에 불투명, 위변조 방지 | 장점: 보안성 / 단점: 서버 측 시크릿 관리 필요 |
| 복합 커서 (createdAt + id) | 동일 시간 데이터 구분, 안정적 정렬 | 장점: 정확한 페이징 / 단점: 커서 크기 증가 |
| Express 미들웨어 패턴 | 기존 Express 구조와 자연스러운 통합 | 장점: 비침투적 / 단점: 미들웨어 체인 복잡도 증가 |
| Prisma 쿼리 빌더 래핑 | 기존 ORM 활용, SQL 직접 작성 회피 | 장점: 타입 안전성 / 단점: Prisma 의존 |

### 주요 컴포넌트

#### 컴포넌트 1: CursorCodec
- **책임**: 커서 문자열의 인코딩/디코딩, HMAC 서명 생성/검증
- **인터페이스**: `encode(fields: CursorFields): string`, `decode(cursor: string): CursorFields`
- **의존성**: 없음 (crypto 표준 라이브러리만 사용)

#### 컴포넌트 2: PaginationQueryBuilder
- **책임**: 커서 값을 Prisma WHERE 조건으로 변환, 정렬/제한 처리
- **인터페이스**: `buildQuery(params: PaginationParams): PrismaQueryArgs`
- **의존성**: CursorCodec

#### 컴포넌트 3: PaginationMiddleware
- **책임**: Express 요청에서 페이지네이션 파라미터 파싱 및 검증
- **인터페이스**: `paginationMiddleware(options?: MiddlewareOptions): RequestHandler`
- **의존성**: CursorCodec

#### 컴포넌트 4: ConnectionResponseBuilder
- **책임**: Prisma 결과를 Relay 스타일 커넥션 응답으로 변환
- **인터페이스**: `buildConnection(items: T[], params: PaginationParams): Connection<T>`
- **의존성**: CursorCodec

---

## 📦 의존성

### 필수 의존성
- [ ] `express`: 4.x (기존 설치됨)
- [ ] `@prisma/client`: 5.x (기존 설치됨)
- [ ] `supertest`: 6.x (개발 의존성 - 통합 테스트용)

### 추가 설치 불필요
- `crypto`: Node.js 내장 모듈 (HMAC 서명용)
- `buffer`: Node.js 내장 모듈 (Base64 인코딩용)

### 빌드 전 요구사항

**Node.js/TypeScript 프로젝트:**
- [ ] Node.js 20+ 및 패키지 매니저 설치 확인
- [ ] package.json에 supertest 개발 의존성 추가
- [ ] 테스트 디렉토리 구조 생성
  ```
  src/
  ├── pagination/
  │   ├── cursor-codec.ts
  │   ├── query-builder.ts
  │   ├── middleware.ts
  │   ├── response-builder.ts
  │   ├── types.ts
  │   └── index.ts
  __tests__/
  ├── unit/
  │   ├── cursor-codec.test.ts
  │   ├── query-builder.test.ts
  │   └── response-builder.test.ts
  ├── integration/
  │   └── pagination-api.test.ts
  └── performance/
      └── pagination-benchmark.test.ts
  ```

### 테스트 파일 구조 및 실행 방법

**Node.js/TypeScript 프로젝트:**
- **테스트 파일 위치**: `__tests__/` 디렉토리
- **파일명 규칙**: `*.test.ts`
- **테스트 실행**: `npm test` 또는 `pnpm test`
- **특정 파일 실행**: `npm test -- __tests__/unit/cursor-codec.test.ts`
- **커버리지**: `npm test -- --coverage`

---

## 🧪 전체 테스트 전략

### 테스트 피라미드 (이 기능)

```
     /\        성능 테스트
    /  \       - 2개 벤치마크
   /----\
  /      \     통합 테스트
 /--------\    - 12개 케이스
/          \
/------------\  단위 테스트
/______________\ - 35개 케이스
```

### 테스트 유형별 목표

| 유형 | 개수 | 커버리지 | 도구 |
|-----|------|---------|------|
| 단위 테스트 | 35개 | 90% | Jest |
| 통합 테스트 | 12개 | 75% | Jest + Supertest |
| 성능 테스트 | 2개 | - | Jest + 커스텀 벤치마크 |

### 테스트 케이스 분류

**모든 테스트에 포함:**
- ✅ **Happy Path**: 정상 동작 경로
- 🔶 **Boundary Cases**: 경계값 (빈 결과, limit=1, limit=max, 첫/마지막 페이지)
- ❌ **Exception Cases**: 잘못된 커서, 위변조 커서, 범위 초과 limit
- 🔀 **Edge Cases**: 삭제된 데이터 커서, 동시 삽입/삭제, 동일 타임스탬프

### 품질 게이트 (각 Phase)

**Node.js/TypeScript 프로젝트:**
- [ ] 의존성 설치 성공 (npm install)
- [ ] TypeScript 타입 체크 통과
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용
- [ ] 테스트 통과 (Jest)
- [ ] 커버리지 >= 80%

**검증 명령어:**
```bash
npx tsc --noEmit && npx eslint src/ __tests__/ && npm test -- --coverage
```

---

## 🚀 구현 Phase

### Phase 1: 커서 코덱 (CursorCodec)
**목표**: 커서 인코딩/디코딩 및 HMAC 서명 검증 로직 구현
**예상 시간**: 2시간
**복잡도**: 중간
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 1.1**: 커서 인코딩 테스트
  - 파일: `__tests__/unit/cursor-codec.test.ts`
  - 예상 결과: 실패 (CursorCodec 미구현)
  - 테스트 케이스:
    - ✅ Happy: `{ id: 100, createdAt: '2026-01-01' }` 인코딩 → 유효한 Base64 문자열
    - ✅ Happy: 인코딩된 커서 디코딩 → 원본 필드 값 복원
    - 🔶 Boundary: 빈 필드 객체 인코딩 → 에러 발생
    - 🔶 Boundary: 단일 필드만 있는 커서 인코딩 → 정상 동작
    - ❌ Exception: 잘못된 Base64 문자열 디코딩 → `InvalidCursorError`
    - ❌ Exception: 위변조된 커서(HMAC 불일치) 디코딩 → `CursorTamperedError`
    - 🔀 Edge: 특수문자 포함 필드값 인코딩/디코딩 → 정상 동작
    - 🔀 Edge: 매우 긴 문자열 필드 인코딩 → 정상 동작

- [ ] **Test 1.2**: HMAC 서명 테스트
  - 파일: `__tests__/unit/cursor-codec.test.ts`
  - 예상 결과: 실패
  - 테스트 케이스:
    - ✅ Happy: 동일 데이터는 동일 서명 생성
    - ❌ Exception: 다른 시크릿으로 검증 시 실패
    - 🔀 Edge: 시크릿 키 로테이션 시나리오

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 1.3**: 타입 정의 작성
  - 파일: `src/pagination/types.ts`
  - 내용: `CursorFields`, `PaginationParams`, `Connection<T>`, `Edge<T>`, `PageInfo` 인터페이스
  - 최소 구현만 수행

- [ ] **Task 1.4**: CursorCodec 클래스 구현
  - 파일: `src/pagination/cursor-codec.ts`
  - 내용: `encode()`, `decode()`, `sign()`, `verify()` 메서드
  - 목표: Test 1.1, 1.2 통과

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 1.5**: 리팩토링
  - 에러 클래스 분리 (`InvalidCursorError`, `CursorTamperedError`)
  - JSDoc 주석 추가
  - 상수 추출 (기본 알고리즘 등)
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**⚠️ Phase 2로 진행하기 전 모든 항목 체크 필수**

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (CursorCodec >= 95%)

**빌드 & 테스트:**
```bash
npx tsc --noEmit
npm test -- __tests__/unit/cursor-codec.test.ts --coverage
```

**품질 검사:**
- [ ] TypeScript 타입 체크 통과
- [ ] ESLint 검사 통과
- [ ] 커버리지 >= 95% (이 모듈)

**문서화:**
- [ ] 코드 주석 추가 (JSDoc)
- [ ] 타입 정의 문서화

**커밋:**
- [ ] 변경사항 스테이징
  ```bash
  git add src/pagination/types.ts src/pagination/cursor-codec.ts __tests__/unit/cursor-codec.test.ts
  ```
- [ ] 커밋
  ```bash
  git commit -m "feat(pagination): Phase 1 - 커서 코덱 구현

  - CursorCodec 클래스: Base64 인코딩/디코딩
  - HMAC 서명 기반 위변조 방지
  - 커스텀 에러 클래스 (InvalidCursorError, CursorTamperedError)
  - 타입 정의 (CursorFields, PaginationParams, Connection 등)
  - 테스트: 10개 케이스, 커버리지 95%+

  Phase 1/5 완료"
  ```

---

### Phase 2: 쿼리 빌더 (PaginationQueryBuilder)
**목표**: 커서 값을 Prisma WHERE 조건으로 변환하는 쿼리 빌더 구현
**예상 시간**: 3시간
**복잡도**: 높음
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 2.1**: 기본 쿼리 빌드 테스트
  - 파일: `__tests__/unit/query-builder.test.ts`
  - 예상 결과: 실패 (QueryBuilder 미구현)
  - 테스트 케이스:
    - ✅ Happy: 커서 없이 첫 페이지 쿼리 → `{ take: limit + 1, orderBy: [...] }`
    - ✅ Happy: forward 커서로 다음 페이지 쿼리 → 올바른 WHERE 조건
    - ✅ Happy: backward 커서로 이전 페이지 쿼리 → 역순 WHERE + 결과 뒤집기
    - 🔶 Boundary: limit=1 → 정상 동작
    - 🔶 Boundary: limit=최대값(100) → 정상 동작
    - ❌ Exception: limit=0 → 에러
    - ❌ Exception: limit=음수 → 에러
    - ❌ Exception: limit>최대값 → 에러

- [ ] **Test 2.2**: 복합 커서 쿼리 테스트
  - 파일: `__tests__/unit/query-builder.test.ts`
  - 예상 결과: 실패
  - 테스트 케이스:
    - ✅ Happy: `(createdAt, id)` 복합 커서 → 올바른 OR/AND 조합의 WHERE
    - 🔀 Edge: 동일 `createdAt` 값 다수 → id로 정확히 구분
    - 🔀 Edge: DESC 정렬 시 비교 연산자 방향 전환
    - 🔀 Edge: 커서가 가리키는 레코드가 삭제된 경우 → 안정적 동작

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 2.3**: PaginationQueryBuilder 구현
  - 파일: `src/pagination/query-builder.ts`
  - 내용:
    - `buildQuery(params)`: 커서 + 방향 → Prisma findMany 인자
    - `buildWhereClause(cursor, direction, orderBy)`: 커서 조건 WHERE 생성
    - `hasMore` 판단 로직 (limit + 1 기법)
  - 목표: Test 2.1, 2.2 통과

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 2.4**: 리팩토링
  - WHERE 절 빌드 로직 추상화
  - 정렬 방향에 따른 비교 연산자 매핑 테이블
  - 복합 커서 조건 생성기 분리
  - **중요**: 테스트는 계속 통과해야 함

#### Quality Gate ✋

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (QueryBuilder >= 90%)

**빌드 & 테스트:**
```bash
npx tsc --noEmit
npm test -- __tests__/unit/query-builder.test.ts --coverage
```

**품질 검사:**
- [ ] TypeScript 타입 체크 통과
- [ ] ESLint 검사 통과
- [ ] 커버리지 >= 90% (이 모듈)

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add src/pagination/query-builder.ts __tests__/unit/query-builder.test.ts
  git commit -m "feat(pagination): Phase 2 - Prisma 쿼리 빌더 구현

  - PaginationQueryBuilder: 커서 → Prisma WHERE 조건 변환
  - 복합 커서 (createdAt + id) 지원
  - forward/backward 방향 처리
  - limit + 1 기법으로 hasMore 판단
  - 테스트: 12개 케이스, 커버리지 90%+

  Phase 2/5 완료"
  ```

---

### Phase 3: 미들웨어 및 응답 빌더
**목표**: Express 미들웨어와 Relay 스타일 응답 빌더 구현
**예상 시간**: 2.5시간
**복잡도**: 중간
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 3.1**: 미들웨어 파라미터 파싱 테스트
  - 파일: `__tests__/unit/middleware.test.ts` (Jest mock Express req/res)
  - 예상 결과: 실패
  - 테스트 케이스:
    - ✅ Happy: 유효한 쿼리 파라미터 → `req.pagination`에 파싱 결과 할당
    - ✅ Happy: 파라미터 없이 요청 → 기본값 (limit=20, direction=forward)
    - 🔶 Boundary: limit=1 → 정상 허용
    - 🔶 Boundary: limit=100 (최대) → 정상 허용
    - ❌ Exception: limit=101 → 400 에러 응답
    - ❌ Exception: limit="abc" → 400 에러 응답
    - ❌ Exception: 잘못된 커서 → 400 에러 응답 + 명확한 메시지

- [ ] **Test 3.2**: 응답 빌더 테스트
  - 파일: `__tests__/unit/response-builder.test.ts`
  - 예상 결과: 실패
  - 테스트 케이스:
    - ✅ Happy: 아이템 배열 → Relay 커넥션 구조 변환 (edges, pageInfo)
    - ✅ Happy: hasNextPage/hasPreviousPage 정확한 판단
    - 🔶 Boundary: 빈 배열 → `{ data: [], edges: [], pageInfo: { hasNextPage: false, ... } }`
    - 🔶 Boundary: 단일 아이템 → 올바른 startCursor = endCursor
    - 🔀 Edge: totalCount 포함/미포함 옵션

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 3.3**: PaginationMiddleware 구현
  - 파일: `src/pagination/middleware.ts`
  - 내용: 쿼리 파라미터 파싱, 검증, `req.pagination` 할당
  - Express 타입 확장 (declare module)

- [ ] **Task 3.4**: ConnectionResponseBuilder 구현
  - 파일: `src/pagination/response-builder.ts`
  - 내용: 아이템 배열 → `Connection<T>` 변환

- [ ] **Task 3.5**: 모듈 인덱스 작성
  - 파일: `src/pagination/index.ts`
  - 내용: 모든 컴포넌트 재수출

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 3.6**: 리팩토링
  - 미들웨어 옵션 패턴 정리 (기본값 병합)
  - 에러 응답 포맷 표준화
  - Express 타입 확장 깔끔하게 정리

#### Quality Gate ✋

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (미들웨어 >= 85%, 응답 빌더 >= 90%)

**빌드 & 테스트:**
```bash
npx tsc --noEmit
npm test -- __tests__/unit/middleware.test.ts __tests__/unit/response-builder.test.ts --coverage
```

**커밋:**
- [ ] 변경사항 스테이징 및 커밋
  ```bash
  git add src/pagination/ __tests__/unit/middleware.test.ts __tests__/unit/response-builder.test.ts
  git commit -m "feat(pagination): Phase 3 - 미들웨어 및 응답 빌더 구현

  - PaginationMiddleware: Express 쿼리 파라미터 파싱/검증
  - ConnectionResponseBuilder: Relay 스타일 커넥션 응답
  - Express 타입 확장 (req.pagination)
  - 모듈 인덱스 재수출
  - 테스트: 13개 케이스, 커버리지 85%+

  Phase 3/5 완료"
  ```

---

### Phase 4: API 통합 및 통합 테스트
**목표**: 기존 Express 라우터에 커서 페이지네이션 통합 및 E2E 파이프라인 검증
**예상 시간**: 3시간
**복잡도**: 높음
**TDD**: 필수
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 테스트 먼저 작성**
- [ ] **Test 4.1**: 통합 테스트 (Supertest)
  - 파일: `__tests__/integration/pagination-api.test.ts`
  - 예상 결과: 실패 (라우터 미연결)
  - Mock 필요: Prisma Client (jest-mock-extended 또는 수동 Mock)
  - 테스트 케이스:
    - ✅ Happy: `GET /api/posts?limit=5` → 5건 + pageInfo
    - ✅ Happy: `GET /api/posts?cursor=xxx&limit=5` → 다음 5건
    - ✅ Happy: 연속 페이지 탐색 → 모든 데이터 순회 완료, 누락 없음
    - ✅ Happy: backward 탐색 → 이전 페이지 정확히 반환
    - 🔶 Boundary: 데이터 없을 때 → 빈 결과 + hasNextPage: false
    - 🔶 Boundary: 마지막 페이지 → hasNextPage: false
    - ❌ Exception: 잘못된 커서 → 400 + 에러 메시지
    - ❌ Exception: limit 범위 초과 → 400 + 에러 메시지
    - 🔀 Edge: 커서가 가리키는 레코드 삭제됨 → 이후 데이터 정상 반환
    - 🔀 Edge: 기존 offset API 호환 → deprecated 응답 헤더 포함

- [ ] **Test 4.2**: 기존 API 호환 테스트
  - 파일: `__tests__/integration/pagination-api.test.ts`
  - 테스트 케이스:
    - ✅ Happy: 기존 `GET /api/posts?page=1&per_page=20` → 여전히 동작
    - ✅ Happy: 응답에 `Deprecation` 헤더 포함

**🟢 GREEN Phase: 테스트 통과하도록 구현**
- [ ] **Task 4.3**: 라우터에 미들웨어 연결
  - 파일: 기존 라우터 파일 (예: `src/routes/posts.ts`)
  - 내용: `paginationMiddleware()` 적용, 컨트롤러에서 `req.pagination` 사용

- [ ] **Task 4.4**: 컨트롤러 수정
  - 파일: 기존 컨트롤러 파일 (예: `src/controllers/posts.ts`)
  - 내용: `PaginationQueryBuilder`로 Prisma 쿼리 구성, `ConnectionResponseBuilder`로 응답

- [ ] **Task 4.5**: 기존 offset API deprecated 처리
  - 파일: 기존 라우터
  - 내용: offset 방식 엔드포인트에 `Deprecation` 헤더 추가

**🔵 REFACTOR Phase: 코드 품질 개선**
- [ ] **Task 4.6**: 리팩토링
  - 컨트롤러 로직을 서비스 레이어로 분리 (필요시)
  - 에러 핸들링 일관성 확보
  - 재사용 가능한 페이지네이션 헬퍼 함수 추출

#### Quality Gate ✋

**TDD 준수:**
- [ ] 🔴 테스트 먼저 작성하고 실패 확인
- [ ] 🟢 최소 코드로 테스트 통과
- [ ] 🔵 리팩토링 후에도 테스트 통과
- [ ] 커버리지 목표 달성 (전체 >= 85%)

**빌드 & 테스트:**
```bash
npx tsc --noEmit
npm test -- --coverage
```

**전체 테스트 통과 확인:**
- [ ] 기존 테스트 스위트 통과 (회귀 없음)
- [ ] 새 통합 테스트 통과
- [ ] 커버리지 >= 85%

**커밋:**
- [ ] 커밋
  ```bash
  git commit -m "feat(pagination): Phase 4 - API 통합 및 호환 레이어

  - 기존 라우터에 커서 페이지네이션 미들웨어 연결
  - 컨트롤러에서 QueryBuilder + ResponseBuilder 사용
  - 기존 offset API deprecated 처리 (Deprecation 헤더)
  - 통합 테스트: 12개 케이스
  - 전체 커버리지 85%+

  Phase 4/5 완료"
  ```

---

### Phase 5: 성능 테스트 및 최적화
**목표**: 대량 데이터 성능 검증, offset vs cursor 비교, 최적화
**예상 시간**: 2.5시간
**복잡도**: 높음
**TDD**: 적용
**상태**: ⏳ 대기 중

#### Tasks

**🔴 RED Phase: 성능 테스트 작성**
- [ ] **Test 5.1**: 성능 벤치마크 테스트
  - 파일: `__tests__/performance/pagination-benchmark.test.ts`
  - Mock 필요: Prisma Client (지연 시뮬레이션 포함)
  - 테스트 케이스:
    - 📊 첫 페이지 응답 시간 < 50ms
    - 📊 중간 페이지 (500,000번째) 응답 시간 < 50ms
    - 📊 마지막 페이지 응답 시간 < 50ms
    - 📊 첫 페이지 vs 마지막 페이지 응답 시간 차이 < 10%
    - 📊 offset 방식 대비 마지막 페이지 10x+ 개선

- [ ] **Test 5.2**: 메모리 사용량 테스트
  - 파일: `__tests__/performance/pagination-benchmark.test.ts`
  - 테스트 케이스:
    - 📊 페이지네이션 처리당 메모리 증가 < 5MB
    - 📊 연속 100페이지 탐색 시 메모리 누수 없음

**🟢 GREEN Phase: 최적화 구현**
- [ ] **Task 5.3**: 쿼리 최적화
  - DB 인덱스 활용 확인 (EXPLAIN ANALYZE 가이드 문서)
  - 불필요한 SELECT 필드 제거 (Prisma select)
  - totalCount 쿼리 최적화 (캐싱 또는 근사값 옵션)

- [ ] **Task 5.4**: 응답 최적화
  - totalCount를 선택적 필드로 (별도 요청 또는 캐시)
  - 커서 인코딩 최적화 (불필요한 필드 제거)

**🔵 REFACTOR Phase: 문서화 및 마무리**
- [ ] **Task 5.5**: 성능 가이드 문서 작성
  - 인덱스 설정 가이드 (복합 인덱스 권장 사항)
  - 성능 벤치마크 결과 기록
  - offset → cursor 마이그레이션 가이드

- [ ] **Task 5.6**: 최종 리팩토링
  - 모든 모듈 간 일관성 확인
  - 불필요한 코드 제거
  - 최종 JSDoc 검토

#### Quality Gate ✋

**성능 기준:**
- [ ] 어떤 페이지든 응답 시간 < 50ms
- [ ] 첫/마지막 페이지 응답 시간 차이 < 10%
- [ ] 메모리 사용량 < 5MB/요청
- [ ] offset 대비 10x+ 개선

**전체 테스트:**
```bash
npx tsc --noEmit
npm test -- --coverage
```

**최종 확인:**
- [ ] 전체 테스트 통과 (단위 + 통합 + 성능)
- [ ] 전체 커버리지 >= 85%
- [ ] TypeScript 타입 체크 통과
- [ ] ESLint 통과
- [ ] Prettier 포매팅 적용

**커밋:**
- [ ] 커밋
  ```bash
  git commit -m "feat(pagination): Phase 5 - 성능 테스트 및 최적화

  - 성능 벤치마크: offset vs cursor 비교
  - 메모리 사용량 프로파일링
  - totalCount 캐싱/선택적 조회 최적화
  - 인덱스 설정 가이드 문서
  - 전체 테스트: 49개 케이스, 커버리지 85%+

  Phase 5/5 완료"
  ```

---

## ⚠️ 위험 요소

| 위험 | 확률 | 영향 | 완화 전략 |
|-----|------|------|----------|
| 기존 API 클라이언트 호환성 깨짐 | 낮음 | 높음 | offset API 유지 + deprecated 헤더, 통합 테스트 |
| 복합 커서 WHERE 절 성능 이슈 | 중간 | 중간 | 복합 인덱스 필수, EXPLAIN ANALYZE로 검증 |
| Prisma ORM 커서 쿼리 제한 | 낮음 | 중간 | rawQuery 폴백 준비, Prisma 공식 cursor API 검토 |
| HMAC 시크릿 키 유출 | 낮음 | 높음 | 환경변수 관리, 키 로테이션 전략 |
| totalCount 쿼리 성능 | 중간 | 중간 | 선택적 조회, 캐싱, 근사값(pg_class) 활용 |

---

## 🔄 롤백 전략

### Phase 1 실패시
- 커밋 되돌리기: `git revert [commit-hash]`
- 영향 범위: 신규 파일만 (기존 코드 변경 없음)

### Phase 2 실패시
- Phase 1 상태로 복구 (Phase 1 커밋까지 보존)
- 재시도 전략: WHERE 절 생성 로직 재설계

### Phase 3 실패시
- Phase 2 상태로 복구
- 대안: 미들웨어 대신 데코레이터 패턴 또는 직접 파싱

### Phase 4 실패시
- Phase 3 상태로 복구
- 영향 범위: 기존 라우터/컨트롤러 변경 되돌리기
- 대안: 새 라우터 엔드포인트로 분리 (기존 변경 최소화)

### Phase 5 실패시
- Phase 4 상태로 복구 (기능은 동작하나 최적화 미적용)
- 대안: 성능 목표 조정 또는 DB 인덱스 튜닝으로 보완

---

## 📊 진행 상황

### 완료율
- **Phase 1**: ⏳ 0%
- **Phase 2**: ⏳ 0%
- **Phase 3**: ⏳ 0%
- **Phase 4**: ⏳ 0%
- **Phase 5**: ⏳ 0%

**전체 진행도**: 0%

### 시간 추적
| Phase | 예상 | 실제 | 차이 |
|-------|------|------|------|
| Phase 1: 커서 코덱 | 2h | - | - |
| Phase 2: 쿼리 빌더 | 3h | - | - |
| Phase 3: 미들웨어/응답 | 2.5h | - | - |
| Phase 4: API 통합 | 3h | - | - |
| Phase 5: 성능 최적화 | 2.5h | - | - |
| **합계** | **13h** | - | - |

---

## 📝 구현 노트

### 학습한 내용
- [구현 중 발견한 인사이트]

### 해결한 문제
- **문제 1**: [설명] → [해결방법]

### 블로커
- **블로커 1**: [설명] → [해결상태]

### 향후 개선 사항
- GraphQL Relay 커넥션 지원 추가
- Redis 기반 커서 캐싱
- 커서 만료 정책 구현
- 실시간 데이터 스트리밍과의 통합

---

## 📚 참고 자료

### 문서
- [Relay Cursor Connections Specification](https://relay.dev/graphql/connections.htm)
- [Prisma Pagination](https://www.prisma.io/docs/concepts/components/prisma-client/pagination)
- [PostgreSQL Index Types](https://www.postgresql.org/docs/current/indexes-types.html)
- [Express Middleware](https://expressjs.com/en/guide/using-middleware.html)

### 관련 패턴
- Keyset Pagination (cursor-based)
- Relay Connection Specification
- HMAC-based token signing

---

## ✅ 최종 체크리스트

**구현 완료 전 확인:**
- [ ] 모든 Phase 완료 (5/5)
- [ ] 모든 테스트 통과 (단위 35개 + 통합 12개 + 성능 2개)
- [ ] 전체 커버리지 >= 85%
- [ ] TypeScript 타입 체크 통과
- [ ] ESLint 검사 통과
- [ ] Prettier 포매팅 적용
- [ ] 성능 벤치마크 목표 달성 (< 50ms, 10x 개선)
- [ ] 기존 API 호환성 확인
- [ ] 문서화 완료 (JSDoc + 마이그레이션 가이드)
- [ ] PR 생성 준비 완료
- [ ] 이해관계자 승인

---

**계획 상태**: 🔄 구현 대기 중
**다음 액션**: `/implement "cursor-based-pagination"`
