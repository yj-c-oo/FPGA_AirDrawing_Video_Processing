# Uartsender UVM Drive/Monitor Timing

`uartsender_driver`와 `uartsender_monitor`의 실제 timing 기준을 정리한 WaveDrom입니다.

## Timing Rules

- driver payload/set trigger: `@(negedge clk)`
- trigger sync: DUT 내부 2FF 동기화 후 `trigger_pulse`
- expected byte emit: golden timing model의 `gm_tx_start_reg`가 1인 `@(posedge clk)`
- monitor actual byte capture: `tx_start_dbg`가 1인 `@(posedge clk)`
- expected/actual packet emit: `tx_done_dbg` 정렬 cycle

## WaveDrom Code

```json
{ "signal": [
  { "name": "clk",               "wave": "p................................." },
  { "name": "drv @negedge",      "wave": "x..4...4...4...4...4...4...4...4.x",
    "data": ["drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv"] },
  { "name": "mon @posedge",      "wave": "x.5.5.5.5.5.5.5.5.5.5.5.5.5.5.5.x.",
    "data": ["mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon"] },
  { "name": "send_trigger",      "wave": "0....10..........................." },
  { "name": "state_dbg",         "wave": "x......=.=.......................x",
    "data": ["IDLE", "START_BYTE", "WAIT_BYTE"] },
  { "name": "busy",              "wave": "0........1.....................0.." },
  { "name": "tx_start_dbg",      "wave": "0.........10....10....10.........." },
  { "name": "tx_data_dbg",       "wave": "x.........=.....=.....=..........x",
    "data": ["AA", "X", "Y"] },
  { "name": "drv exp byte",      "wave": "0.........10....10....10.........." },
  { "name": "mon act byte",      "wave": "0.........10....10....10.........." },
  { "name": "tx_done_dbg",       "wave": "0............................10..." },
  { "name": "drv exp packet",    "wave": "0............................10..." },
  { "name": "mon act packet",    "wave": "0............................10..." }
]}
```

## Notes

- driver는 negedge에서 `send_trigger`와 payload를 넣고, monitor는 posedge에서 `tx_start_dbg/tx_done_dbg`를 샘플합니다.
- byte timing 비교는 `drv exp byte`와 `mon act byte`의 같은 posedge 정렬을 기준으로 합니다.
- packet timing 비교는 마지막 `tx_done_dbg` cycle에서 `drv exp packet`과 `mon act packet`이 같이 발생하는 구조입니다.
