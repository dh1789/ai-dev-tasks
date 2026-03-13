# REST API 커서 기반 페이지네이션 구현 계획

## 1. 개요

기존 Express 서버에 커서(cursor) 기반 페이지네이션을 추가한다.
offset 방식 대비 대량 데이터에서 일정한 성능을 보장하는 구조로 설계한다.

### offset 방식 vs cursor 방식

| 항목 | offset | cursor |
|------|--------|--------|
| 페이지 이동 | 임의 페이지 가능 | 순차 이동만 가능 |
| 대량 데이터 성능 | O(n) - 페이지 깊어질수록 느림 | O(1) - 일정한 성능 |
| 실시간 데이터 | 중복/누락 발생 가능 | 안정적 |
| 구현 난이도 | 낮음 | 중간 |

## 2. 기술 설계

### 2.1 커서 인코딩 전략

커서는 정렬 기준 필드의 마지막 값을 Base64로 인코딩하여 클라이언트에 전달한다.

```
cursor = base64url({ id: "last_record_id", createdAt: "2026-03-13T..." })
```

- 복합 정렬 지원: 여러 필드를 커서에 포함
- 불투명(opaque) 커서: 클라이언트가 내부 구조를 알 필요 없음
- base64url 인코딩으로 URL-safe 보장

### 2.2 API 응답 형식

```json
{
  "data": [...],
  "pagination": {
    "hasNextPage": true,
    "hasPreviousPage": false,
    "startCursor": "eyJpZCI6MX0",
    "endCursor": "eyJpZCI6MjB9",
    "totalCount": 1500
  }
}
```

### 2.3 요청 파라미터

| 파라미터 | 타입 | 기본값 | 설명 |
|----------|------|--------|------|
| `first` | number | 20 | 정방향 조회 개수 (최대 100) |
| `after` | string | null | 정방향 커서 (이 커서 다음부터) |
| `last` | number | 20 | 역방향 조회 개수 (최대 100) |
| `before` | string | null | 역방향 커서 (이 커서 이전까지) |
| `sort` | string | "createdAt" | 정렬 기준 필드 |
| `order` | string | "desc" | 정렬 방향 (asc/desc) |

### 2.4 DB 쿼리 전략

인덱스 기반 범위 쿼리를 사용하여 offset의 SKIP 비용을 제거한다.

```sql
-- 정방향 (after 커서 사용)
SELECT * FROM items
WHERE created_at < :cursor_created_at
   OR (created_at = :cursor_created_at AND id < :cursor_id)
ORDER BY created_at DESC, id DESC
LIMIT :first + 1;  -- +1로 hasNextPage 판단

-- 역방향 (before 커서 사용)
SELECT * FROM items
WHERE created_at > :cursor_created_at
   OR (created_at = :cursor_created_at AND id > :cursor_id)
ORDER BY created_at ASC, id ASC
LIMIT :last + 1;
```

핵심: `LIMIT + 1` 패턴으로 다음 페이지 존재 여부를 추가 쿼리 없이 판단한다.

### 2.5 인덱스 설계

```sql
CREATE INDEX idx_items_cursor ON items (created_at DESC, id DESC);
```

복합 인덱스로 커서 쿼리의 WHERE + ORDER BY를 커버링 인덱스로 처리한다.

## 3. 구현 파일 구조

```
src/
  middleware/
    pagination.js          # 페이지네이션 미들웨어
  utils/
    cursor.js              # 커서 인코딩/디코딩 유틸
    pagination-response.js # 응답 포맷 헬퍼
  validators/
    pagination.js          # 입력 검증 (first/last 범위 등)
  tests/
    cursor.test.js         # 커서 유틸 단위 테스트
    pagination.test.js     # 페이지네이션 통합 테스트
```

## 4. 구현 단계

### Phase 1: 핵심 유틸리티 (cursor.js, pagination-response.js)
- 커서 인코딩/디코딩 함수
- 응답 포맷 생성 함수
- 단위 테스트

### Phase 2: 입력 검증 미들웨어 (validators/pagination.js)
- first/last 범위 검증 (1~100)
- first+after, last+before 조합 검증
- 잘못된 커서 값 에러 처리

### Phase 3: 페이지네이션 미들웨어 (middleware/pagination.js)
- Express 미들웨어로 구현
- req.pagination 객체에 파싱된 파라미터 주입
- 기존 라우트에 미들웨어 추가만으로 적용 가능

### Phase 4: DB 쿼리 빌더 통합
- 사용 중인 ORM/쿼리빌더에 맞는 커서 조건 생성
- Sequelize, Knex, Prisma 등 어댑터 패턴 적용
- 복합 정렬 지원

### Phase 5: 기존 엔드포인트 마이그레이션
- 기존 offset 방식 엔드포인트에 커서 방식 병행 지원
- 점진적 마이그레이션 (기존 API 호환성 유지)

### Phase 6: 성능 테스트 및 최적화
- 100만 건 이상 데이터로 성능 벤치마크
- 인덱스 최적화 확인 (EXPLAIN ANALYZE)
- 응답 시간 목표: < 50ms (인덱스 히트 시)

## 5. 성능 고려사항

### 5.1 대량 데이터 처리 최적화

1. **인덱스 커버링**: 커서 쿼리에 필요한 모든 컬럼을 인덱스에 포함
2. **LIMIT+1 패턴**: hasNextPage 판단을 위한 추가 COUNT 쿼리 제거
3. **totalCount 선택적 제공**: `includeTotalCount=true` 파라미터로 필요할 때만 COUNT 실행
4. **커넥션 풀 관리**: 동시 요청 처리를 위한 DB 커넥션 풀 최적화
5. **응답 캐싱**: 동일 커서 요청에 대한 Redis 캐싱 (선택)

### 5.2 에지 케이스 처리

- 빈 결과셋: `data: [], hasNextPage: false`
- 삭제된 레코드의 커서: 해당 커서 이후 유효한 데이터부터 반환
- 동시 삽입/삭제: 커서 기반이므로 중복/누락 없음
- 잘못된 커서 포맷: 400 Bad Request 응답

### 5.3 보안 고려사항

- 커서 값 변조 방지: HMAC 서명 추가 (선택)
- first/last 최대값 제한: DoS 방지
- Rate limiting: 과도한 페이지네이션 요청 제한

## 6. 예상 작업량

| Phase | 예상 시간 | 난이도 |
|-------|----------|--------|
| Phase 1: 핵심 유틸리티 | 2시간 | 낮음 |
| Phase 2: 입력 검증 | 1시간 | 낮음 |
| Phase 3: 미들웨어 | 2시간 | 중간 |
| Phase 4: DB 통합 | 3시간 | 중간 |
| Phase 5: 마이그레이션 | 2시간 | 중간 |
| Phase 6: 성능 테스트 | 2시간 | 중간 |
| **합계** | **12시간** | - |
