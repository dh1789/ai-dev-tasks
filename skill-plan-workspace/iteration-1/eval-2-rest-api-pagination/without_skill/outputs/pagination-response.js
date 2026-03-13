/**
 * 페이지네이션 응답 포맷 헬퍼
 *
 * LIMIT+1 패턴을 활용하여 hasNextPage/hasPreviousPage를 판단하고
 * 표준화된 응답 구조를 생성한다.
 */

const { createCursorFromRecord } = require('./cursor');

/**
 * 커서 기반 페이지네이션 응답 생성
 *
 * @param {Object} params
 * @param {Object[]} params.records - DB에서 조회한 레코드 (LIMIT+1 개수)
 * @param {number} params.limit - 요청한 조회 개수 (first 또는 last)
 * @param {string} [params.direction='forward'] - 조회 방향 ('forward' | 'backward')
 * @param {string[]} [params.sortFields=['createdAt', 'id']] - 정렬 기준 필드
 * @param {number} [params.totalCount] - 전체 레코드 수 (선택적)
 * @returns {Object} 표준 페이지네이션 응답
 */
function buildPaginatedResponse({
  records,
  limit,
  direction = 'forward',
  sortFields = ['createdAt', 'id'],
  totalCount,
}) {
  const hasMore = records.length > limit;
  const data = hasMore ? records.slice(0, limit) : [...records];

  // 역방향 조회 시 결과 순서를 원래대로 되돌림
  if (direction === 'backward') {
    data.reverse();
  }

  const startCursor = data.length > 0
    ? createCursorFromRecord(data[0], sortFields)
    : null;
  const endCursor = data.length > 0
    ? createCursorFromRecord(data[data.length - 1], sortFields)
    : null;

  const pagination = {
    hasNextPage: direction === 'forward' ? hasMore : false,
    hasPreviousPage: direction === 'backward' ? hasMore : false,
    startCursor,
    endCursor,
  };

  if (totalCount !== undefined) {
    pagination.totalCount = totalCount;
  }

  return { data, pagination };
}

module.exports = { buildPaginatedResponse };
