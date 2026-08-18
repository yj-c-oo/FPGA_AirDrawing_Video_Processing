# Memcontroller Timing Scenarios

The timing reference compares input-driven expected write events against
the observed DUT write events in cycle units.

## Core scenarios

1. Reset release
   - Reset keeps write disabled and the address at zero.
   - The first write after reset must start from address zero.

2. Single-pixel latency
   - The first byte of a pixel must not assert write.
   - The second byte must assert write in the expected cycle.

3. Full-frame write stream
   - Every pixel write must appear with zero-cycle delta versus the reference.
   - Addresses must be contiguous for the whole frame.

4. HREF gap recovery
   - When HREF drops in the middle of a frame, the half-byte state is discarded.
   - The next valid pixel must restart with a fresh first byte.

5. Odd-byte termination
   - If the frame ends after only the first byte of a pixel, no write event may be emitted.

6. VSYNC abort
   - If VSYNC arrives in the middle of a frame, writes stop immediately and the next frame restarts at address zero.

7. Back-to-back frames
   - Frame transitions must not leak state across frame boundaries.
   - The first write of the new frame must match frame-local address zero timing.

8. Random stress
   - Random frame payloads and repeated frames must preserve zero-cycle write latency and matching write data.

## 한글 설명

이 타이밍 레퍼런스는 입력 기준으로 예상한 write 이벤트와 DUT에서 실제로 관측한
write 이벤트를 cycle 단위로 비교합니다.

### 주요 시나리오

1. Reset 해제
   - Reset 동안에는 write가 비활성화되고 address는 0이어야 합니다.
   - Reset 해제 후 첫 write는 반드시 address 0부터 시작해야 합니다.

2. 단일 픽셀 latency
   - 픽셀의 첫 번째 byte에서는 write가 올라오면 안 됩니다.
   - 두 번째 byte에서만 기대한 cycle에 write가 올라와야 합니다.

3. 전체 프레임 write 스트림
   - 모든 픽셀 write는 reference 대비 cycle delta 0이어야 합니다.
   - address는 프레임 전체에서 연속적으로 증가해야 합니다.

4. HREF gap 복구
   - 프레임 중간에 HREF가 내려가면 half-byte 상태는 버려져야 합니다.
   - 다음 정상 픽셀은 다시 첫 번째 byte부터 새로 시작해야 합니다.

5. 홀수 byte 종료
   - 픽셀의 첫 번째 byte만 들어오고 프레임이 끝나면 write 이벤트가 발생하면 안 됩니다.

6. VSYNC 중단
   - 프레임 중간에 VSYNC가 들어오면 write는 즉시 멈춰야 합니다.
   - 다음 프레임은 address 0부터 다시 시작해야 합니다.

7. Back-to-back 프레임
   - 프레임 경계에서 이전 프레임의 상태가 다음 프레임으로 넘어가면 안 됩니다.
   - 새 프레임의 첫 write는 해당 프레임 기준 address 0 타이밍과 일치해야 합니다.

8. 랜덤 스트레스
   - 랜덤 payload와 반복 프레임에서도 zero-cycle write latency가 유지되어야 합니다.
   - `wdata`도 reference와 계속 일치해야 합니다.
