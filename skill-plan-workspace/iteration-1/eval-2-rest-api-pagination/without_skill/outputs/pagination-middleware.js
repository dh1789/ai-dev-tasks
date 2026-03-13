/**
 * Express 페이지네이션 미들웨어
 *
 * 쿼리 파라미터를 파싱하여 req.pagination 객체에 주입한다.
 * 기존 라우트에 미들웨어만 추가하면 커서 기반 페이지네이션이 적용된다.
 *
 * 사용법:
 *   const { paginationMiddleware } = require('./middleware/pagination');
 *   router.get('/items', paginationMiddleware(), controller.listItems);
 */

const { decodeCursor } = require('./cursor');

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 100;
const ALLOWED_SORT_FIELDS = ['createdAt', 'updatedAt', 'id', 'name'];
const ALLOWED_ORDERS = ['asc', 'desc'];

/**
 * 페이지네이션 미들웨어 팩토리
 *
 * @param {Object} [options]
 * @param {number} [options.defaultLimit=20] - 기본 조회 개수
 * @param {number} [options.maxLimit=100] - 최대 조회 개수
 * @param {string[]} [options.allowedSortFields] - 허용 정렬 필드
 * @param {string} [options.defaultSort='createdAt'] - 기본 정렬 필드
 * @param {string} [options.defaultOrder='desc'] - 기본 정렬 방향
 * @returns {Function} Express 미들웨어
 */
function paginationMiddleware(options = {}) {
  const {
    defaultLimit = DEFAULT_LIMIT,
    maxLimit = MAX_LIMIT,
    allowedSortFields = ALLOWED_SORT_FIELDS,
    defaultSort = 'createdAt',
    defaultOrder = 'desc',
  } = options;

  return (req, _res, next) => {
    const { first, last, after, before, sort, order, includeTotalCount } = req.query;

    // first와 last가 동시에 제공되면 에러
    if (first !== undefined && last !== undefined) {
      const err = new Error('first와 last를 동시에 사용할 수 없습니다.');
      err.status = 400;
      return next(err);
    }

    // 방향 결정
    const direction = last !== undefined ? 'backward' : 'forward';

    // limit 파싱 및 범위 검증
    const rawLimit = direction === 'backward' ? last : (first || defaultLimit);
    const limit = Math.min(Math.max(parseInt(rawLimit, 10) || defaultLimit, 1), maxLimit);

    // 커서 디코딩
    const cursor = direction === 'backward' ? before : after;
    let cursorData = null;
    if (cursor) {
      cursorData = decodeCursor(cursor);
      if (!cursorData) {
        const err = new Error('유효하지 않은 커서입니다.');
        err.status = 400;
        return next(err);
      }
    }

    // 정렬 필드 검증
    const sortField = allowedSortFields.includes(sort) ? sort : defaultSort;
    const sortOrder = ALLOWED_ORDERS.includes(order) ? order : defaultOrder;

    req.pagination = {
      limit,
      direction,
      cursor: cursorData,
      rawCursor: cursor || null,
      sort: sortField,
      order: sortOrder,
      includeTotalCount: includeTotalCount === 'true',
    };

    return next();
  };
}

module.exports = { paginationMiddleware };
