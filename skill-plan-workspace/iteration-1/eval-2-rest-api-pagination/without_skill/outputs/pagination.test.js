/**
 * 페이지네이션 미들웨어 및 응답 빌더 테스트
 */

const { buildPaginatedResponse } = require('./pagination-response');
const { buildCursorQuery } = require('./cursor-query-builder');
const { decodeCursor } = require('./cursor');

describe('buildPaginatedResponse', () => {
  const makeRecords = (count) =>
    Array.from({ length: count }, (_, i) => ({
      id: i + 1,
      name: `item-${i + 1}`,
      createdAt: new Date(2026, 0, 1, 0, 0, i).toISOString(),
    }));

  it('LIMIT+1개가 오면 hasNextPage를 true로 설정한다', () => {
    const records = makeRecords(21); // limit=20, 21개 조회
    const result = buildPaginatedResponse({
      records,
      limit: 20,
      direction: 'forward',
    });

    expect(result.data).toHaveLength(20);
    expect(result.pagination.hasNextPage).toBe(true);
  });

  it('LIMIT 이하이면 hasNextPage를 false로 설정한다', () => {
    const records = makeRecords(15);
    const result = buildPaginatedResponse({
      records,
      limit: 20,
      direction: 'forward',
    });

    expect(result.data).toHaveLength(15);
    expect(result.pagination.hasNextPage).toBe(false);
  });

  it('빈 결과셋을 처리한다', () => {
    const result = buildPaginatedResponse({
      records: [],
      limit: 20,
      direction: 'forward',
    });

    expect(result.data).toHaveLength(0);
    expect(result.pagination.hasNextPage).toBe(false);
    expect(result.pagination.startCursor).toBeNull();
    expect(result.pagination.endCursor).toBeNull();
  });

  it('startCursor와 endCursor를 올바르게 생성한다', () => {
    const records = makeRecords(5);
    const result = buildPaginatedResponse({
      records,
      limit: 10,
      direction: 'forward',
    });

    const startData = decodeCursor(result.pagination.startCursor);
    const endData = decodeCursor(result.pagination.endCursor);

    expect(startData.id).toBe(1);
    expect(endData.id).toBe(5);
  });

  it('역방향 조회 시 결과 순서를 되돌린다', () => {
    const records = makeRecords(5);
    const result = buildPaginatedResponse({
      records,
      limit: 10,
      direction: 'backward',
    });

    // 역방향이므로 원래 순서의 역순
    expect(result.data[0].id).toBe(5);
    expect(result.data[4].id).toBe(1);
  });

  it('totalCount가 제공되면 응답에 포함한다', () => {
    const records = makeRecords(5);
    const result = buildPaginatedResponse({
      records,
      limit: 10,
      direction: 'forward',
      totalCount: 1500,
    });

    expect(result.pagination.totalCount).toBe(1500);
  });

  it('totalCount가 없으면 응답에 포함하지 않는다', () => {
    const records = makeRecords(5);
    const result = buildPaginatedResponse({
      records,
      limit: 10,
      direction: 'forward',
    });

    expect(result.pagination).not.toHaveProperty('totalCount');
  });
});

describe('buildCursorQuery', () => {
  it('커서가 없으면 WHERE 조건이 null이다', () => {
    const result = buildCursorQuery({
      cursor: null,
      sort: 'createdAt',
      order: 'desc',
      limit: 20,
      direction: 'forward',
    });

    expect(result.where).toBeNull();
    expect(result.limit).toBe(21); // +1
    expect(result.orderBy[0]).toEqual({ field: 'createdAt', direction: 'desc' });
  });

  it('정방향 커서가 있으면 적절한 WHERE 조건을 생성한다', () => {
    const result = buildCursorQuery({
      cursor: { createdAt: '2026-03-13T00:00:00.000Z', id: 42 },
      sort: 'createdAt',
      order: 'desc',
      limit: 20,
      direction: 'forward',
    });

    expect(result.where).not.toBeNull();
    expect(result.where.type).toBe('compound');
  });

  it('역방향 조회 시 정렬 방향을 반전한다', () => {
    const result = buildCursorQuery({
      cursor: null,
      sort: 'createdAt',
      order: 'desc',
      limit: 20,
      direction: 'backward',
    });

    // desc의 반전 → asc
    expect(result.orderBy[0].direction).toBe('asc');
  });

  it('id 정렬 시 단순 조건을 생성한다', () => {
    const result = buildCursorQuery({
      cursor: { id: 100 },
      sort: 'id',
      order: 'desc',
      limit: 10,
      direction: 'forward',
    });

    expect(result.where.type).toBe('simple');
    expect(result.where.field).toBe('id');
    expect(result.where.operator).toBe('lt');
    expect(result.where.value).toBe(100);
  });

  it('id가 아닌 정렬 시 tie-breaker로 id를 orderBy에 추가한다', () => {
    const result = buildCursorQuery({
      cursor: null,
      sort: 'createdAt',
      order: 'desc',
      limit: 20,
      direction: 'forward',
    });

    expect(result.orderBy).toHaveLength(2);
    expect(result.orderBy[1].field).toBe('id');
  });
});
