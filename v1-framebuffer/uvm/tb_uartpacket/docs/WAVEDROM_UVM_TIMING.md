# UART Packet Decoder UVM Drive/Monitor Timing

`uartrxpacked_driver`와 `uartrxpacked_monitor`의 byte-event timing을 정리한 WaveDrom입니다.

## Timing Rules

- driver line drive: `drv_cb @(posedge clk)`에서 `rx` 갱신
- UART 1bit: `16 baud_tick`
- driver expected byte emit: stop bit 구간 중 `RX_DONE_ALIGN_TICKS=8` 위치
- monitor actual byte capture: `rx_done_dbg`가 1인 `mon_cb @(posedge clk)`
- packet capture: `o_packet_valid` 또는 `o_clear_pulse`가 1인 cycle

## WaveDrom Code

```json
{ "signal": [
  { "name": "clk",               "wave": "p................................." },
  { "name": "drv_cb edge",       "wave": "x.4.4.4.4.4.4.4.4.4.4.4.4.4.4.4.x.",
    "data": ["drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv"] },
  { "name": "mon_cb edge",       "wave": "x.5.5.5.5.5.5.5.5.5.5.5.5.5.5.5.x.",
    "data": ["mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon"] },
  { "name": "baud_tick_dbg",     "wave": "0..1..0..1..0..1..0..1..0..1..0..." },
  { "name": "rx",                "wave": "1..0..=..=..=..=..=..=..=..=.1....",
    "data": ["b0", "b1", "b2", "b3", "b4", "b5", "b6", "b7"] },
  { "name": "state_dbg",         "wave": "x..=..=..=..=..=..=..=..=..=..=...",
    "data": ["WAIT_START", "WAIT_START", "WAIT_START", "WAIT_START", "WAIT_CONTROL", "WAIT_CONTROL", "WAIT_CONTROL", "WAIT_CONTROL", "WAIT_CONTROL", "WAIT_CONTROL"] },
  { "name": "drv exp byte",      "wave": "0..........................10....." },
  { "name": "rx_done_dbg",       "wave": "0..........................10....." },
  { "name": "mon act byte",      "wave": "0..........................10....." },
  { "name": "o_packet_valid",    "wave": "0.............................10.." },
  { "name": "o_clear_pulse",     "wave": "0...............................0." },
  { "name": "mon act packet",    "wave": "0.............................10.." }
]}
```

## Notes

- 이 문서는 `clk` 1주기마다 실제 UART bit를 모두 펼친 파형이 아니라, driver/monitor 이벤트 정렬을 보기 위한 UVM timing view입니다.
- `drv exp byte`, `rx_done_dbg`, `mon act byte`는 같은 capture cycle로 맞춰집니다.
- 마지막 end byte가 정상일 때 다음 cycle 쪽에서 `o_packet_valid`와 packet monitor capture가 발생합니다.
