# Pen Config Controller RTL-Only WaveDrom

골든 신호 없이 `pen_config_controller` RTL 입력/내부상태/출력만 보는 용도입니다.

## Recommended Signals

- `/tb_pencontrol/clk`
- `/tb_pencontrol/rst`
- `/tb_pencontrol/vif/i_uart_valid`
- `/tb_pencontrol/vif/i_uart_pen_color`
- `/tb_pencontrol/vif/i_uart_eraser`
- `/tb_pencontrol/vif/i_uart_size`
- `/tb_pencontrol/vif/i_uart_texture_enable`
- `/tb_pencontrol/vif/i_uart_texture_shape`
- `/tb_pencontrol/vif/i_uart_paper`
- `/tb_pencontrol/vif/i_uart_clear_pulse`
- `/tb_pencontrol/vif/i_btn_eraser`
- `/tb_pencontrol/vif/i_btn_mode`
- `/tb_pencontrol/vif/i_btn_size`
- `/tb_pencontrol/vif/o_pen_color`
- `/tb_pencontrol/vif/o_eraser`
- `/tb_pencontrol/vif/o_size`
- `/tb_pencontrol/vif/o_texture_enable`
- `/tb_pencontrol/vif/o_texture_shape`
- `/tb_pencontrol/vif/o_paper`
- `/tb_pencontrol/vif/o_clear`
- `/tb_pencontrol/vif/clear_active_dbg`
- `/tb_pencontrol/vif/clear_cnt_dbg`

## WaveDrom Code

```json
{ "signal": [
  { "name": "clk",                 "wave": "p................................." },
  { "name": "rst",                 "wave": "10................................" },
  { "name": "i_uart_valid",        "wave": "0...10...........10..............." },
  { "name": "i_uart_pen_color",    "wave": "x...=............=................",
    "data": ["100", "011"] },
  { "name": "i_uart_texture_shape","wave": "x...=............=................",
    "data": ["000", "101"] },
  { "name": "i_btn_eraser",        "wave": "0........10......................." },
  { "name": "i_btn_mode",          "wave": "0............10.....10............" },
  { "name": "i_btn_size",          "wave": "0................10..............." },
  { "name": "i_uart_clear_pulse",  "wave": "0.....................10.........." },
  { "name": "o_pen_color",         "wave": "x...=.............................",
    "data": ["100"] },
  { "name": "o_eraser",            "wave": "0........10..0...................." },
  { "name": "o_size",              "wave": "0................10..............." },
  { "name": "o_texture_enable",    "wave": "0............1.......1............" },
  { "name": "o_texture_shape",     "wave": "x............=...=.....=..........",
    "data": ["0", "3", "4"] },
  { "name": "o_paper",             "wave": "0...0............1................" },
  { "name": "clear_active_dbg",    "wave": "0.....................1.....0....." },
  { "name": "clear_cnt_dbg",       "wave": "x.....................=.=.=.=.....",
    "data": ["0", "1", "2", "..."] },
  { "name": "o_clear",             "wave": "0.....................1.....0....." }
]}
```

## Notes

- `i_uart_valid`가 1이면 UART 설정이 먼저 반영되고, 같은 클럭의 버튼 펄스가 있으면 버튼이 우선합니다.
- `i_btn_mode`는 `PEN -> SPRAY -> DIAG -> PEN` 순환을 만들고 `o_eraser`를 내립니다.
- `i_uart_clear_pulse` 이후 `o_clear`는 `CLEAR_STRETCH` 동안 유지됩니다.
