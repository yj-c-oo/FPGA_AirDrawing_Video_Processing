# Memcontroller UVM Drive/Monitor Timing

`memctrl_driver`와 `memctrl_monitor`의 실제 동작 edge를 기준으로 정리한 WaveDrom입니다.

## Timing Rules

- driver 출력: `drv_cb @(posedge pclk)`, `output #0`
- monitor 샘플: `mon_cb @(posedge pclk)`, `input #0`
- expected write emit: low byte가 들어간 같은 cycle
- actual write capture: DUT의 `we/waddr/wdata`가 유효한 같은 cycle

## WaveDrom Code

```json
{ "signal": [
  { "name": "pclk",             "wave": "p................................." },
  { "name": "reset",            "wave": "10................................" },
  { "name": "drv_cb edge",      "wave": "x.4.4.4.4.4.4.4.4.4.4.4.4.4.4.4.x.",
    "data": ["drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv", "drv"] },
  { "name": "mon_cb edge",      "wave": "x.5.5.5.5.5.5.5.5.5.5.5.5.5.5.5.x.",
    "data": ["mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon", "mon"] },
  { "name": "vsync",            "wave": "0..11.0..........................." },
  { "name": "href",             "wave": "0......1.1.1.1.....0.............." },
  { "name": "pdata",            "wave": "x......=.=.=.=.....x..............",
    "data": ["HI0", "LO0", "HI1", "LO1"] },
  { "name": "we",               "wave": "0........1...1.....0.............." },
  { "name": "waddr",            "wave": "x........=...=.....x..............",
    "data": ["0", "1"] },
  { "name": "wdata",            "wave": "x........=...=.....x..............",
    "data": ["PIX0", "PIX1"] },
  { "name": "drv exp emit",     "wave": "0........1...1.....0.............." },
  { "name": "mon act capture",  "wave": "0........1...1.....0.............." },
  { "name": "frame phase",      "wave": "x..=.=.=.=.=.=.=.=.=.=.=.=.=.=.=.x",
    "data": ["reset", "vsync", "vsync", "idle", "pix0_hi", "pix0_lo", "pix1_hi", "pix1_lo", "idle", "idle", "", "", "", "", "", ""] }
]}
```

## Notes

- high byte cycle에서는 `href=1`, `pdata=HIx`, 아직 `we=0`입니다.
- low byte cycle에서 DUT가 `wdata`를 조립해 `we=1`로 내보내고, driver expected와 monitor actual이 같은 cycle에 발생합니다.
- `vsync`가 올라간 첫 cycle에서 monitor는 새 frame 시작으로 해석합니다.
