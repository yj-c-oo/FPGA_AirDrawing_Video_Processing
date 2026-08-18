# UART Packet Sender RTL-Only WaveDrom

골든 신호 없이 `uart_packet_sender` RTL 입력/내부상태/출력만 보는 용도입니다.

## Recommended Signals

- `/tb_uartsender/clk`
- `/tb_uartsender/rst`
- `/tb_uartsender/vif/send_trigger`
- `/tb_uartsender/vif/X_center`
- `/tb_uartsender/vif/Y_center`
- `/tb_uartsender/vif/sw_paint_red`
- `/tb_uartsender/vif/sw_paint_green`
- `/tb_uartsender/vif/sw_paint_blue`
- `/tb_uartsender/vif/sw_eraser`
- `/tb_uartsender/vif/sw_size`
- `/tb_uartsender/vif/sw_texture_enable`
- `/tb_uartsender/vif/texture_shape`
- `/tb_uartsender/vif/paper`
- `/tb_uartsender/vif/clear_btn`
- `/tb_uartsender/vif/busy`
- `/tb_uartsender/vif/state_dbg`
- `/tb_uartsender/vif/byte_index_dbg`
- `/tb_uartsender/vif/baud_tick_dbg`
- `/tb_uartsender/vif/tx_start_dbg`
- `/tb_uartsender/vif/tx_busy_dbg`
- `/tb_uartsender/vif/tx_done_dbg`
- `/tb_uartsender/vif/tx_data_dbg`
- `/tb_uartsender/vif/tx`

## WaveDrom Code

```json
{ "signal": [
  { "name": "clk",             "wave": "p....................................." },
  { "name": "rst",             "wave": "10...................................." },
  { "name": "send_trigger",    "wave": "0....10..............................." },
  { "name": "X_center",        "wave": "x....=................................",
    "data": ["100"] },
  { "name": "Y_center",        "wave": "x....=................................",
    "data": ["50"] },
  { "name": "sw_texture_enable","wave": "0....1................................" },
  { "name": "texture_shape",   "wave": "x....=................................",
    "data": ["4"] },
  { "name": "paper",           "wave": "0....1................................" },
  { "name": "busy",            "wave": "0........1........................0..." },
  { "name": "state_dbg",       "wave": "x....3.4........4........4........3...",
    "data": ["IDLE", "START", "WAIT", "WAIT", "WAIT", "IDLE"] },
  { "name": "byte_index_dbg",  "wave": "x......=........=........=........=...",
    "data": ["0", "1", "2", "3"] },
  { "name": "baud_tick_dbg",   "wave": "0...1...0...1...0...1...0...1...0....." },
  { "name": "tx_start_dbg",    "wave": "0.......10.......10.......10.........." },
  { "name": "tx_busy_dbg",     "wave": "0........1.......................0...." },
  { "name": "tx_data_dbg",     "wave": "x.......=........=........=........=..",
    "data": ["AA", "X[8:1]", "Y[7:0]", "CTRL"] },
  { "name": "tx_done_dbg",     "wave": "0...............10.......10.......10.." },
  { "name": "tx",              "wave": "1........0..=..1..=..0..=..1.........." }
]}
```

## Notes

- `send_trigger`는 2FF 동기화를 거친 뒤 `state_dbg=UART_START_BYTE`로 진입합니다.
- `tx_start_dbg`는 각 byte 시작 1클럭 펄스입니다.
- `tx_data_dbg`는 `AA -> X -> Y -> CTRL -> SHAPE -> 55` 순서로 바뀝니다.
- `busy`는 6바이트 전체 송신 동안 유지됩니다.
