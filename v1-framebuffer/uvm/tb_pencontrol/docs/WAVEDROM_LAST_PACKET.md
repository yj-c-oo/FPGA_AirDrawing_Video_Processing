# Pen Config Controller Key Timing Window

## Focus Window

- Clear retrigger focus: `5000000000 ps ~ 7600000000 ps`

## Expected Behavior

- First clear request raises `o_clear`.
- Second clear request while `o_clear` is already active restarts the stretch counter.
- `o_clear` falls exactly `CLEAR_STRETCH` clocks after the second request.

## WaveDrom Code

```json
{ "signal": [
  { "name": "clk",          "wave": "p............." },
  { "name": "i_uart_clear", "wave": "0..10.....10.." },
  { "name": "golden_clear", "wave": "0..1=======0.." },
  { "name": "rtl_clear",    "wave": "0..1=======0.." },
  { "name": "clear_cnt_dbg","wave": "x..=.=.=.=.=x", "data": ["0", "64", "128", "192", "255"] }
],
"edge": [
  "a~>b first clear request",
  "c~>d retrigger restarts stretch",
  "d~>e clear deassert"
],
"node": "a..bc....de.."
}
```
