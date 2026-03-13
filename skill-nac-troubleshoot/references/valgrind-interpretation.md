# Valgrind 출력 해석 가이드

NAC 서버 Valgrind 결과를 해석하는 방법.

---

## 오류 유형별 해석

### 1. Invalid Read/Write (버퍼 오버플로우, use-after-free)

```
==12345== Invalid read of size 4
==12345==    at 0x4C2B6F: process_packet (packet_handler.cpp:142)
==12345==    by 0x4C3A1E: main_loop (server.cpp:89)
==12345==  Address 0x5a1c040 is 0 bytes after a block of size 64 alloc'd
==12345==    at 0x4A06A2E: malloc (vg_replace_malloc.c:270)
==12345==    by 0x4C2B2A: allocate_buffer (packet_handler.cpp:130)
```

**해석**: `packet_handler.cpp:142`에서 64바이트 버퍼 끝을 벗어나 4바이트 읽기 시도.
**수정**: 버퍼 크기 확인, 인덱스 범위 검증 필요.

### 2. Definitely Lost (확실한 메모리 누수)

```
==12345== 1,024 bytes in 4 blocks are definitely lost in loss record 42 of 100
==12345==    at 0x4A06A2E: malloc (vg_replace_malloc.c:270)
==12345==    by 0x4C5D1F: create_session (session_mgr.cpp:67)
==12345==    by 0x4C6A3B: handle_connect (connection.cpp:145)
```

**해석**: `session_mgr.cpp:67`에서 할당한 메모리가 해제되지 않음. `handle_connect`에서 세션 생성 후 해제 경로 누락.
**수정**: `create_session`의 반환 포인터가 모든 경로에서 `free`/`delete` 되는지 확인.

### 3. Possibly Lost (의심스러운 누수)

```
==12345== 256 bytes in 1 blocks are possibly lost in loss record 15 of 100
==12345==    at 0x4A07B9A: operator new(unsigned long) (vg_replace_malloc.c:342)
==12345==    by 0x4C8F2A: std::vector<...>::reserve (stl_vector.h:...)
```

**해석**: STL 컨테이너 내부 할당. 대부분 false positive이지만, 컨테이너를 소유한 객체의 소멸자가 호출되는지 확인.
**수정**: 소유 객체의 생명주기 확인. `std::unique_ptr` 또는 RAII 패턴 적용 권장.

### 4. Conditional Jump on Uninitialized Value

```
==12345== Conditional jump or move depends on uninitialised value(s)
==12345==    at 0x4C3B2E: check_policy (policy_engine.cpp:203)
==12345==    by 0x4C3F1A: evaluate_request (policy_engine.cpp:185)
==12345==  Uninitialised value was created by a stack allocation
==12345==    at 0x4C3E00: evaluate_request (policy_engine.cpp:180)
```

**해석**: `policy_engine.cpp:180`에서 스택 변수가 초기화 없이 사용됨.
**수정**: 해당 변수에 초기값 할당.

### 5. Use After Free

```
==12345== Invalid read of size 8
==12345==    at 0x4C7A1B: send_response (response.cpp:56)
==12345==  Address 0x5a2d040 is 16 bytes inside a block of size 128 free'd
==12345==    at 0x4A06B2F: free (vg_replace_malloc.c:446)
==12345==    by 0x4C79F3: cleanup_session (session_mgr.cpp:112)
```

**해석**: `session_mgr.cpp:112`에서 해제된 메모리를 `response.cpp:56`에서 접근.
**수정**: 해제 순서 검토. 세션 정리와 응답 전송의 타이밍 이슈.

---

## LEAK SUMMARY 해석

```
==12345== LEAK SUMMARY:
==12345==    definitely lost: 4,096 bytes in 16 blocks
==12345==    indirectly lost: 1,024 bytes in 4 blocks
==12345==      possibly lost: 256 bytes in 1 blocks
==12345==    still reachable: 8,192 bytes in 32 blocks
==12345==         suppressed: 0 bytes in 0 blocks
```

| 항목 | 심각도 | 의미 | 조치 |
|------|--------|------|------|
| **definitely lost** | 높음 | 포인터가 완전히 소실됨 | 반드시 수정 |
| **indirectly lost** | 높음 | definitely lost 블록이 참조하던 메모리 | definitely lost 수정 시 함께 해결 |
| **possibly lost** | 중간 | 포인터 산술로 도달 가능할 수 있음 | 검토 필요 |
| **still reachable** | 낮음 | 프로그램 종료 시 아직 참조 가능 | 대부분 무시 가능 |

---

## 심각도 판단 기준

| 심각도 | 조건 | 조치 |
|--------|------|------|
| **긴급** | Invalid read/write, use-after-free | 즉시 수정 (보안 취약점 가능) |
| **높음** | definitely lost > 1KB | 빠른 수정 (리소스 고갈 가능) |
| **중간** | possibly lost, uninitialized | 코드 리뷰 시 수정 |
| **낮음** | still reachable | 선택적 정리 |
