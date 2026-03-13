/**
 * 커서 기반 DB 쿼리 빌더
 *
 * 커서 데이터를 기반으로 WHERE 조건과 ORDER BY를 생성한다.
 * ORM에 독립적인 조건 객체를 반환하며, 각 ORM 어댑터에서 변환하여 사용한다.
 *
 * 핵심 원리:
 * - offset의 SKIP 대신 인덱스 기반 범위 쿼리(WHERE)를 사용
 * - LIMIT+1로 다음 페이지 존재 여부를 추가 쿼리 없이 판단
 * - 복합 정렬 시 tie-breaker로 id 필드를 항상 포함
 */

/**
 * 페이지네이션 쿼리 조건 생성
 *
 * @param {Object} pagination - req.pagination 객체
 * @param {Object} [pagination.cursor] - 디코딩된 커서 데이터
 * @param {string} pagination.sort - 정렬 기준 필드
 * @param {string} pagination.order - 정렬 방향 ('asc' | 'desc')
 * @param {number} pagination.limit - 조회 개수
 * @param {string} pagination.direction - 조회 방향 ('forward' | 'backward')
 * @returns {Object} 쿼리 조건 객체 { where, orderBy, limit }
 */
function buildCursorQuery(pagination) {
  const { cursor, sort, order, limit, direction } = pagination;

  // 실제 쿼리 방향 결정 (backward 시 정렬 방향 반전)
  const isReversed = direction === 'backward';
  const effectiveOrder = isReversed
    ? (order === 'asc' ? 'desc' : 'asc')
    : order;

  // ORDER BY 절
  const orderBy = [
    { field: sort, direction: effectiveOrder },
  ];
  // tie-breaker: sort 필드가 id가 아니면 id를 추가
  if (sort !== 'id') {
    orderBy.push({ field: 'id', direction: effectiveOrder });
  }

  // WHERE 절: 커서가 없으면 조건 없음
  let where = null;
  if (cursor) {
    where = buildCursorCondition(cursor, sort, effectiveOrder);
  }

  return {
    where,
    orderBy,
    limit: limit + 1, // +1로 hasNextPage 판단
  };
}

/**
 * 커서 기반 WHERE 조건 생성
 *
 * 복합 정렬을 지원하기 위해 OR 조건으로 구성한다.
 * 예: (createdAt < cursorCreatedAt) OR (createdAt = cursorCreatedAt AND id < cursorId)
 *
 * @param {Object} cursor - 디코딩된 커서 데이터
 * @param {string} sortField - 정렬 기준 필드
 * @param {string} effectiveOrder - 실제 정렬 방향
 * @returns {Object} WHERE 조건 객체
 */
function buildCursorCondition(cursor, sortField, effectiveOrder) {
  const comparator = effectiveOrder === 'desc' ? 'lt' : 'gt';

  // 정렬 필드가 id인 경우 단순 조건
  if (sortField === 'id') {
    return {
      type: 'simple',
      field: 'id',
      operator: comparator,
      value: cursor.id,
    };
  }

  // 복합 조건: (sortField <|> cursorValue) OR (sortField = cursorValue AND id <|> cursorId)
  return {
    type: 'compound',
    conditions: [
      {
        type: 'or',
        clauses: [
          {
            field: sortField,
            operator: comparator,
            value: cursor[sortField],
          },
          {
            type: 'and',
            clauses: [
              {
                field: sortField,
                operator: 'eq',
                value: cursor[sortField],
              },
              {
                field: 'id',
                operator: comparator,
                value: cursor.id,
              },
            ],
          },
        ],
      },
    ],
  };
}

// ----------------------------------------------------------------
// ORM 어댑터 예시들
// ----------------------------------------------------------------

/**
 * Sequelize용 WHERE 조건 변환
 */
function toSequelizeWhere(condition, Op) {
  if (!condition) return {};

  if (condition.type === 'simple') {
    const opMap = { lt: Op.lt, gt: Op.gt, eq: Op.eq };
    return { [condition.field]: { [opMap[condition.operator]]: condition.value } };
  }

  if (condition.type === 'compound') {
    const orClause = condition.conditions[0];
    return {
      [Op.or]: orClause.clauses.map((clause) => {
        if (clause.type === 'and') {
          return {
            [Op.and]: clause.clauses.map((c) => {
              const opMap = { lt: Op.lt, gt: Op.gt, eq: Op.eq };
              return { [c.field]: { [opMap[c.operator]]: c.value } };
            }),
          };
        }
        const opMap = { lt: Op.lt, gt: Op.gt, eq: Op.eq };
        return { [clause.field]: { [opMap[clause.operator]]: clause.value } };
      }),
    };
  }

  return {};
}

/**
 * Knex용 쿼리 빌더 적용
 */
function applyToKnex(queryBuilder, condition) {
  if (!condition) return queryBuilder;

  const opMap = { lt: '<', gt: '>', eq: '=' };

  if (condition.type === 'simple') {
    return queryBuilder.where(
      condition.field,
      opMap[condition.operator],
      condition.value,
    );
  }

  if (condition.type === 'compound') {
    const orClause = condition.conditions[0];
    return queryBuilder.where(function () {
      for (const clause of orClause.clauses) {
        if (clause.type === 'and') {
          this.orWhere(function () {
            for (const c of clause.clauses) {
              this.andWhere(c.field, opMap[c.operator], c.value);
            }
          });
        } else {
          this.orWhere(clause.field, opMap[clause.operator], clause.value);
        }
      }
    });
  }

  return queryBuilder;
}

module.exports = {
  buildCursorQuery,
  buildCursorCondition,
  toSequelizeWhere,
  applyToKnex,
};
