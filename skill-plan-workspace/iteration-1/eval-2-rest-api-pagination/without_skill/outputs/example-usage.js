/**
 * 커서 기반 페이지네이션 적용 예시
 *
 * 기존 Express 라우트에 커서 기반 페이지네이션을 적용하는 방법을 보여준다.
 */

const express = require('express');
const router = express.Router();
const { paginationMiddleware } = require('./pagination-middleware');
const { buildCursorQuery } = require('./cursor-query-builder');
const { buildPaginatedResponse } = require('./pagination-response');

// ----------------------------------------------------------------
// 예시 1: 기본 적용 (Knex 사용)
// ----------------------------------------------------------------
router.get(
  '/api/items',
  paginationMiddleware({ defaultLimit: 20, maxLimit: 100 }),
  async (req, res, next) => {
    try {
      const { where, orderBy, limit } = buildCursorQuery(req.pagination);

      // Knex 쿼리 빌드
      let query = db('items');

      // 커서 조건 적용
      if (where) {
        const { applyToKnex } = require('./cursor-query-builder');
        query = applyToKnex(query, where);
      }

      // 정렬 적용
      for (const o of orderBy) {
        query = query.orderBy(o.field, o.direction);
      }

      // LIMIT+1 적용
      const records = await query.limit(limit);

      // totalCount (선택적)
      let totalCount;
      if (req.pagination.includeTotalCount) {
        const [{ count }] = await db('items').count('* as count');
        totalCount = parseInt(count, 10);
      }

      // 응답 생성
      const response = buildPaginatedResponse({
        records,
        limit: req.pagination.limit,
        direction: req.pagination.direction,
        totalCount,
      });

      res.json(response);
    } catch (err) {
      next(err);
    }
  },
);

// ----------------------------------------------------------------
// 예시 2: 검색 필터와 함께 사용
// ----------------------------------------------------------------
router.get(
  '/api/items/search',
  paginationMiddleware({
    defaultLimit: 10,
    allowedSortFields: ['createdAt', 'updatedAt', 'name', 'id'],
    defaultSort: 'name',
    defaultOrder: 'asc',
  }),
  async (req, res, next) => {
    try {
      const { keyword, category } = req.query;
      const { where, orderBy, limit } = buildCursorQuery(req.pagination);

      let query = db('items');

      // 검색 필터 (커서 조건과 별도로 적용)
      if (keyword) {
        query = query.where('name', 'like', `%${keyword}%`);
      }
      if (category) {
        query = query.where('category', category);
      }

      // 커서 조건 적용
      if (where) {
        const { applyToKnex } = require('./cursor-query-builder');
        query = applyToKnex(query, where);
      }

      for (const o of orderBy) {
        query = query.orderBy(o.field, o.direction);
      }

      const records = await query.limit(limit);

      const response = buildPaginatedResponse({
        records,
        limit: req.pagination.limit,
        direction: req.pagination.direction,
        sortFields: [req.pagination.sort, 'id'],
      });

      res.json(response);
    } catch (err) {
      next(err);
    }
  },
);

// ----------------------------------------------------------------
// 예시 3: 에러 핸들러
// ----------------------------------------------------------------
router.use((err, _req, res, _next) => {
  const status = err.status || 500;
  res.status(status).json({
    error: {
      message: err.message,
      status,
    },
  });
});

module.exports = router;
