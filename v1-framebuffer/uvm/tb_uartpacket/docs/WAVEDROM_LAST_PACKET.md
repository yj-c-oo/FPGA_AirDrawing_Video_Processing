# UART Packet Decoder Last Valid Packet WaveDrom

## Sim Result Summary

- Existing FSDB: `novas_uartpacket.fsdb`
- Existing sim end time: `16142255000 ps`
- Last observed valid output pulse time: `10507325000 ps`
- Last packet byte capture times from `rx_done_dbg`:
  - `10246905000 ps` : `0xA5` start
  - `10333705000 ps` : `0x5B` control
  - `10420515000 ps` : `0xE3` shape
  - `10507315000 ps` : `0x5A` end

## Decoded Last Packet

- Packet bytes: `A5 5B E3 5A`
- Golden decode:
  - `o_packet_valid = 1`
  - `o_clear_pulse = 1`
  - `o_pen_color = 3'b110`
  - `o_eraser = 1`
  - `o_size = 0`
  - `o_texture_enable = 0`
  - `o_texture_shape = 3'b011`
  - `o_paper = 0`
- RTL decode from FSDB:
  - `o_packet_valid = 1`
  - `o_clear_pulse = 1`
  - `o_pen_color = 3'b110`
  - `o_eraser = 1`
  - `o_size = 0`
  - `o_texture_enable = 0`
  - `o_texture_shape = 3'b011`
  - `o_paper = 0`

## WaveDrom Code

```json
{ "signal": [
  { "name": "clk",               "wave": "p............." },
  { "name": "rx_done_dbg",       "wave": "0..10..10..10..10." },
  { "name": "rx_data_dbg",       "wave": "x..=...=...=...=..x", "data": ["A5", "5B", "E3", "5A"] },

  { "name": "golden_packet_valid","wave": "0..............10" },
  { "name": "rtl_packet_valid",   "wave": "0..............10" },
  { "name": "golden_clear_pulse", "wave": "0..............10" },
  { "name": "rtl_clear_pulse",    "wave": "0..............10" },

  { "name": "golden_pen_color",   "wave": "x..............=.", "data": ["110"] },
  { "name": "rtl_pen_color",      "wave": "x..............=.", "data": ["110"] },
  { "name": "golden_eraser",      "wave": "0..............1." },
  { "name": "rtl_eraser",         "wave": "0..............1." },
  { "name": "golden_size",        "wave": "0..............0." },
  { "name": "rtl_size",           "wave": "0..............0." },
  { "name": "golden_texture_en",  "wave": "0..............0." },
  { "name": "rtl_texture_en",     "wave": "0..............0." },
  { "name": "golden_shape",       "wave": "x..............=.", "data": ["011"] },
  { "name": "rtl_shape",          "wave": "x..............=.", "data": ["011"] },
  { "name": "golden_paper",       "wave": "0..............0." },
  { "name": "rtl_paper",          "wave": "0..............0." }
],
"edge": [
  "a<->b byte0:0xA5",
  "b<->c byte1:0x5B",
  "c<->d byte2:0xE3",
  "d<->e byte3:0x5A",
  "e~>f 1clk later output pulse"
],
"node": "a..b...c...d...ef"
}
```

## 한글 설명

- 마지막 valid 패킷은 `A5 5B E3 5A` 입니다.
- `rx_done_dbg` 기준으로 4바이트가 순서대로 수신된 뒤, 마지막 `0x5A` 수신 완료 다음 클럭에 `o_packet_valid` 와 `o_clear_pulse` 가 1클럭 펄스로 올라갑니다.
- 이 패킷의 골든 출력과 RTL 출력은 동일합니다.
- 최종 디코드 결과는 다음과 같습니다.
  - `pen_color = 110`
  - `eraser = 1`
  - `size = 0`
  - `texture_enable = 0`
  - `texture_shape = 011`
  - `paper = 0`
  - `clear_pulse = 1`

## Useful Signals In Verdi

- `/tb_uartrxpacked/vif/rx`
- `/tb_uartrxpacked/vif/rx_done_dbg`
- `/tb_uartrxpacked/vif/rx_data_dbg`
- `/tb_uartrxpacked/vif/o_packet_valid`
- `/tb_uartrxpacked/vif/o_clear_pulse`
- `/tb_uartrxpacked/vif/o_pen_color`
- `/tb_uartrxpacked/vif/o_eraser`
- `/tb_uartrxpacked/vif/o_size`
- `/tb_uartrxpacked/vif/o_texture_enable`
- `/tb_uartrxpacked/vif/o_texture_shape`
- `/tb_uartrxpacked/vif/o_paper`
