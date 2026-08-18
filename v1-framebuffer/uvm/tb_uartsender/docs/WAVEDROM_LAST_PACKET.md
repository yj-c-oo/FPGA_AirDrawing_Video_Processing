# UART Packet Sender Last Packet WaveDrom

## Expected Packet Format

- `byte0 = 0xAA`
- `byte1 = X_center[8:1]`
- `byte2 = Y_center[7:0]`
- `byte3 = {texture_enable, eraser, size, red, green, blue, clear, 1'b0}`
- `byte4 = {4'b0, paper, texture_shape}`
- `byte5 = 0x55`

## WaveDrom Code

```json
{ "signal": [
  { "name": "clk",        "wave": "p.............." },
  { "name": "send_trig",  "wave": "0.10..........." },
  { "name": "tx_start",   "wave": "0....10..10..10..10..10..10" },
  { "name": "golden_byte","wave": "x....=...=...=...=...=...=.", "data": ["AA", "X[8:1]", "Y[7:0]", "CTRL", "SHAPE", "55"] },
  { "name": "rtl_byte",   "wave": "x....=...=...=...=...=...=.", "data": ["AA", "X[8:1]", "Y[7:0]", "CTRL", "SHAPE", "55"] },
  { "name": "busy",       "wave": "0....1==================0" },
  { "name": "tx_done",    "wave": "0.......10..10..10..10..10..10" }
]}
```
