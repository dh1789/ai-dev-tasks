/**
 * 커서 유틸리티 단위 테스트
 */

const { encodeCursor, decodeCursor, createCursorFromRecord } = require('./cursor');

describe('cursor 유틸리티', () => {
  describe('encodeCursor / decodeCursor', () => {
    it('객체를 인코딩하고 동일한 객체로 디코딩한다', () => {
      const data = { id: 42, createdAt: '2026-03-13T00:00:00.000Z' };
      const cursor = encodeCursor(data);
      const decoded = decodeCursor(cursor);
      expect(decoded).toEqual(data);
    });

    it('빈 객체를 처리한다', () => {
      const cursor = encodeCursor({});
      const decoded = decodeCursor(cursor);
      expect(decoded).toEqual({});
    });

    it('null 입력 시 null을 반환한다', () => {
      expect(decodeCursor(null)).toBeNull();
    });

    it('undefined 입력 시 null을 반환한다', () => {
      expect(decodeCursor(undefined)).toBeNull();
    });

    it('빈 문자열 입력 시 null을 반환한다', () => {
      expect(decodeCursor('')).toBeNull();
    });

    it('잘못된 Base64 문자열 입력 시 null을 반환한다', () => {
      expect(decodeCursor('not-valid-base64!!!')).toBeNull();
    });

    it('유효한 Base64이지만 JSON이 아닌 경우 null을 반환한다', () => {
      const notJson = Buffer.from('hello world', 'utf-8').toString('base64url');
      expect(decodeCursor(notJson)).toBeNull();
    });

    it('URL-safe 인코딩을 생성한다 (+ / = 없음)', () => {
      const data = { id: 999999, name: '한글 테스트 데이터/특수문자+포함' };
      const cursor = encodeCursor(data);
      expect(cursor).not.toMatch(/[+/=]/);
    });
  });

  describe('createCursorFromRecord', () => {
    it('기본 필드(createdAt, id)로 커서를 생성한다', () => {
      const record = {
        id: 1,
        createdAt: new Date('2026-03-13T00:00:00.000Z'),
        name: '테스트',
      };
      const cursor = createCursorFromRecord(record);
      const decoded = decodeCursor(cursor);

      expect(decoded).toEqual({
        id: 1,
        createdAt: '2026-03-13T00:00:00.000Z',
      });
    });

    it('사용자 지정 정렬 필드로 커서를 생성한다', () => {
      const record = { id: 1, name: '가나다', score: 95 };
      const cursor = createCursorFromRecord(record, ['score', 'id']);
      const decoded = decodeCursor(cursor);

      expect(decoded).toEqual({ score: 95, id: 1 });
    });

    it('Date 객체를 ISO 문자열로 변환한다', () => {
      const date = new Date('2026-01-01T12:00:00.000Z');
      const record = { id: 1, createdAt: date };
      const cursor = createCursorFromRecord(record);
      const decoded = decodeCursor(cursor);

      expect(decoded.createdAt).toBe('2026-01-01T12:00:00.000Z');
    });

    it('존재하지 않는 필드는 무시한다', () => {
      const record = { id: 1 };
      const cursor = createCursorFromRecord(record, ['createdAt', 'id']);
      const decoded = decodeCursor(cursor);

      expect(decoded).toEqual({ id: 1 });
      expect(decoded.createdAt).toBeUndefined();
    });
  });
});
