/**
 * 커서 인코딩/디코딩 유틸리티
 *
 * 커서는 정렬 기준 필드의 마지막 값을 Base64url로 인코딩한 불투명(opaque) 문자열이다.
 * 클라이언트는 커서의 내부 구조를 알 필요 없이 그대로 전달하면 된다.
 */

/**
 * 커서 데이터를 Base64url 문자열로 인코딩
 * @param {Object} data - 커서에 포함할 데이터 (예: { id, createdAt })
 * @returns {string} Base64url 인코딩된 커서 문자열
 */
function encodeCursor(data) {
  const json = JSON.stringify(data);
  return Buffer.from(json, 'utf-8')
    .toString('base64url');
}

/**
 * Base64url 커서 문자열을 원본 데이터로 디코딩
 * @param {string} cursor - Base64url 인코딩된 커서 문자열
 * @returns {Object|null} 디코딩된 커서 데이터 또는 실패 시 null
 */
function decodeCursor(cursor) {
  if (!cursor || typeof cursor !== 'string') {
    return null;
  }
  try {
    const json = Buffer.from(cursor, 'base64url').toString('utf-8');
    return JSON.parse(json);
  } catch {
    return null;
  }
}

/**
 * 레코드에서 커서 데이터를 추출하여 인코딩
 * @param {Object} record - DB 레코드
 * @param {string[]} sortFields - 정렬 기준 필드 목록 (예: ['createdAt', 'id'])
 * @returns {string} 인코딩된 커서
 */
function createCursorFromRecord(record, sortFields = ['createdAt', 'id']) {
  const cursorData = {};
  for (const field of sortFields) {
    if (record[field] !== undefined) {
      cursorData[field] = record[field] instanceof Date
        ? record[field].toISOString()
        : record[field];
    }
  }
  return encodeCursor(cursorData);
}

module.exports = {
  encodeCursor,
  decodeCursor,
  createCursorFromRecord,
};
