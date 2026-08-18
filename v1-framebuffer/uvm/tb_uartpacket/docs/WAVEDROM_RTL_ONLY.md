# UART Packet Decoder RTL-Only WaveDrom

골든 신호 없이 `uart_packet_decoder` RTL 입력/내부상태/출력만 보는 용도입니다.

## Recommended Signals

- `/tb_uartrxpacked/clk`
- `/tb_uartrxpacked/rst`
- `/tb_uartrxpacked/vif/rx`
- `/tb_uartrxpacked/vif/baud_tick_dbg`
- `/tb_uartrxpacked/vif/rx_done_dbg`
- `/tb_uartrxpacked/vif/rx_data_dbg`
- `/tb_uartrxpacked/vif/state_dbg`
- `/tb_uartrxpacked/vif/o_packet_valid`
- `/tb_uartrxpacked/vif/o_clear_pulse`
- `/tb_uartrxpacked/vif/o_pen_color`
- `/tb_uartrxpacked/vif/o_eraser`
- `/tb_uartrxpacked/vif/o_size`
- `/tb_uartrxpacked/vif/o_texture_enable`
- `/tb_uartrxpacked/vif/o_texture_shape`
- `/tb_uartrxpacked/vif/o_paper`

## WaveDrom Code

```json
{ "signal": [
  { "name": "clk",              "wave": "p...................................." },
  { "name": "rst",              "wave": "10..................................." },
  { "name": "rx",               "wave": "1.0..1..0..1..0..1..0..1..0..1......." },
  { "name": "baud_tick_dbg",    "wave": "0...1...0...1...0...1...0...1........" },
  { "name": "rx_done_dbg",      "wave": "0.......1.......1.......1.......1...." },
  { "name": "rx_data_dbg",      "wave": "x.......=.......=.......=.......=....",
    "data": ["A5", "control", "shape", "5A"] },
  { "name": "state_dbg",        "wave": "x.3.......4.......5.......6.......3..",
    "data": ["WAIT_START", "WAIT_CONTROL", "WAIT_SHAPE", "WAIT_END", "WAIT_START"] },
  { "name": "o_packet_valid",   "wave": "0..............................10...." },
  { "name": "o_clear_pulse",    "wave": "0...................................0" },
  { "name": "o_pen_color",      "wave": "x..............................=.....",
    "data": ["RGB"] },
  { "name": "o_eraser",         "wave": "0...................................0" },
  { "name": "o_size",           "wave": "0...................................1" },
  { "name": "o_texture_enable", "wave": "0...................................1" },
  { "name": "o_texture_shape",  "wave": "x..............................=.....",
    "data": ["shape"] },
  { "name": "o_paper",          "wave": "0...................................0" }
]}
```

## Notes

- `rx_done_dbg`가 올라오는 클럭에서 `state_dbg`가 다음 단계로 진행됩니다.
- `WAIT_END`에서 end byte가 `0x5A`이면 같은 출력 구간에서 `o_packet_valid`가 1클럭 올라갑니다.
- `o_clear_pulse`는 control byte bit[1]이 1일 때만 1클럭 펄스로 나옵니다.
