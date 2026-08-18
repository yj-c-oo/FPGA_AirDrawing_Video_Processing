# Pencontrol UVM Drive/Monitor Timing

`pencontrol_driver`와 `pencontrol_monitor`의 edge 정렬을 정리한 WaveDrom입니다.

## Timing Rules

- driver 입력 drive: `@(negedge clk)`
- DUT 상태 갱신: 다음 `@(posedge clk)`
- driver expected snapshot: 상태가 바뀐 같은 `posedge clk`
- monitor actual snapshot: 출력 변화가 보이는 같은 `posedge clk`

## WaveDrom Code

```json
{ "signal": [
  { "name": "clk",                "wave": "p................................." },
  { "name": "drv @negedge",       "wave": "x..4...4...4...4...4...4...4...4.x",
    "data": ["drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv"] },
  { "name": "mon @posedge",       "wave": "x.5.5.5.5.5.5.5.5.5.5.5.5.5.5.5.x.",
    "data": ["mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon"] },
  { "name": "i_uart_valid",       "wave": "0....10..........................." },
  { "name": "i_btn_mode",         "wave": "0............10..................." },
  { "name": "i_btn_size",         "wave": "0....................10..........." },
  { "name": "i_uart_clear_pulse", "wave": "0........................10......." },
  { "name": "o_texture_enable",   "wave": "0.....1.......1..................." },
  { "name": "o_texture_shape",    "wave": "x.....=.......=....=..............",
    "data": ["SPRAY0", "DIAG3", "DIAG4"] },
  { "name": "o_eraser",           "wave": "0..............0.................." },
  { "name": "o_clear",            "wave": "0........................1........" },
  { "name": "drv exp snapshot",   "wave": "0.....10......10...10.....10......" },
  { "name": "mon act snapshot",   "wave": "0.....10......10...10.....10......" }
]}
```

## Notes

- driver는 negedge에서 입력을 세팅하고, DUT와 monitor는 다음 posedge를 기준으로 동작합니다.
- `drv exp snapshot`과 `mon act snapshot`은 출력 상태가 변한 posedge에 함께 발생합니다.
- `o_clear`는 clear 요청 이후 stretch 구간을 유지하므로, snapshot은 clear 상승 시점에 찍히고 이후 유지 구간은 level로 확인합니다.
