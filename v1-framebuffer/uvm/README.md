# UVM 검증 환경

`v1-framebuffer`의 RTL 모듈을 대상으로 한 UVM 1.2 검증 환경입니다. Synopsys VCS로 실행했습니다.

각 폴더는 `agent / driver / monitor / scoreboard / sequence / seq_item / coverage / env / test / interface / pkg / tb` 구성을 갖습니다.

| 폴더 | 대상 RTL | 주요 테스트 |
|---|---|---|
| `tb_memcontroller` | `ov7670_memcontroller` | 랜덤 픽셀 스트림, cycle 단위 write 이벤트 비교 |
| `tb_uartpacket` | `uart_packet_decoder` | 랜덤 패킷, Start/End bit 인식, 비정상 패킷 제거 |
| `tb_uartsender` | `uart_packet_sender` | 랜덤 패킷 송신 |
| `tb_pencontrol` | `pen_config_controller` | 랜덤 UART 명령, 랜덤 물리 버튼 |
| `tb_bbox_center_accum` | `bbox_center_accum` | `bbox_random_test`, `bbox_coverage_test`, `bbox_stress_test` |
| `tb_coord_filter` | `coord_filter` | `coord_basic_test`, `coord_jitter_test`, `coord_spike_test`, `coord_random_test` |
| `tb_brush_stroke_controller` | `brush_stroke_controller` | `stroke_basic / connect / penup / eraser / size / random / stress` |
| `tb_bresenham_interpolator` | `bresenham_interpolator` | `bresenham_random / boundary / regression` |
| `tb_brush_renderer` | `circular_brush_renderer` | `brush_random / boundary / texture / stress` |

각 폴더의 `docs/`에는 coverage 구성 문서, 커버리지 결과 캡처, WaveDrom 타이밍 문서가 있습니다.

## 참고

- `tb_coord_filter`는 문서와 커버리지 결과만 있고 소스는 포함되어 있지 않습니다.
- 원본 시뮬레이션 로그는 최대 174 MB로 커서 저장소에 포함하지 않았습니다.
- `tb_memcontroller/docs/TIMING_SCENARIOS.md`에 reset 해제, 단일 픽셀 latency, HREF gap 복구, odd-byte 종료, VSYNC abort, back-to-back 프레임, 랜덤 스트레스 등 8개 타이밍 시나리오가 정리되어 있습니다.
