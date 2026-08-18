# Pen Config Controller Full-Run WaveDrom

## Recommended Verdi Windows

- Full run: `0 ps ~ 8000000000 ps`
- UART update / clamp / buttons: `0 ps ~ 2000000000 ps`
- Clear stretch region: `2000000000 ps ~ 5000000000 ps`
- Clear retrigger region: `5000000000 ps ~ 7600000000 ps`

## WaveDrom Code

```json
{ "signal": [
  { "name": "phase", "wave": "x.=.=.=.=.=.=.=.=.=.x",
    "data": [
      "RESET",
      "UART_UPDATE",
      "SHAPE_CLAMP",
      "BTN_ERASER",
      "BTN_MODE",
      "BTN_SIZE",
      "BTN_MODE",
      "UART+BTN_PRIORITY",
      "CLEAR_STRETCH",
      "CLEAR_RETRIGGER",
      "RANDOM_MIX"
    ]
  },
  { "name": "i_uart_valid", "wave": "0.1.1.0.0.0.0.1.0.0.0" },
  { "name": "i_btn_eraser", "wave": "0.0.0.1.0.0.0.0.0.0.0" },
  { "name": "i_btn_mode",   "wave": "0.0.0.0.1.0.1.1.0.0.0" },
  { "name": "i_btn_size",   "wave": "0.0.0.0.0.1.0.0.0.0.0" },
  { "name": "i_uart_clear", "wave": "0.0.0.0.0.0.0.0.1.1.0" },
  { "name": "golden_clear", "wave": "0........1....0.1....0" },
  { "name": "rtl_clear",    "wave": "0........1....0.1....0" },
  { "name": "golden_mode",  "wave": "x.=.=.=.=.=.=.=.=.=.x",
    "data": ["PEN", "SPRAY", "SPRAY", "SPRAY", "DIAG", "DIAG", "PEN", "SPRAY", "SPRAY", "SPRAY", "MIX"]
  },
  { "name": "rtl_mode",     "wave": "x.=.=.=.=.=.=.=.=.=.x",
    "data": ["PEN", "SPRAY", "SPRAY", "SPRAY", "DIAG", "DIAG", "PEN", "SPRAY", "SPRAY", "SPRAY", "MIX"]
  }
]}
```

## Notes

- `o_clear` is expected to stay high for `CLEAR_STRETCH` clocks after each clear request.
- In `UART+BTN_PRIORITY`, button updates override the UART config on the same clock.
