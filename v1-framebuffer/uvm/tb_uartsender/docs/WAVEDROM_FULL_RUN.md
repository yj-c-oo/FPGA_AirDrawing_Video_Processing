# UART Packet Sender Full-Run WaveDrom

## Recommended Verdi Windows

- Full run: `0 ps ~ 20000000000 ps`
- Single packet window: `0 ps ~ 1200000000 ps`
- Trigger hold window: `4500000000 ps ~ 6500000000 ps`
- Busy retrigger window: `6500000000 ps ~ 9000000000 ps`
- Back-to-back window: `9000000000 ps ~ 11500000000 ps`

## WaveDrom Code

```json
{ "signal": [
  { "name": "phase", "wave": "x.=.=.=.=.=.=.=.=.=.x",
    "data": [
      "RESET",
      "SINGLE_SEND",
      "CONTROL_BITS",
      "TEXTURE_PAPER",
      "COORD_BOUNDARY",
      "TRIGGER_HOLD",
      "BUSY_RETRIGGER",
      "BACK_TO_BACK",
      "CLEAR_BIT",
      "RANDOM_STRESS"
    ]
  },
  { "name": "send_trigger", "wave": "0.1.1.1.1.1.1.11.1.1" },
  { "name": "golden_busy",  "wave": "0.1.1.1.1.1.1.11.1.1" },
  { "name": "rtl_busy",     "wave": "0.1.1.1.1.1.1.11.1.1" },
  { "name": "tx_start_dbg", "wave": "0.p.p.p.p.p.p.pp.p.p" },
  { "name": "tx_done_dbg",  "wave": "0.p.p.p.p.p.p.pp.p.p" }
]}
```

## Notes

- `busy` should rise once per accepted packet and stay high across all 6 UART bytes.
- `TRIGGER_HOLD` keeps `send_trigger` high for multiple clocks but must still emit one packet.
- `BUSY_RETRIGGER` injects an extra trigger during transmission and it must be ignored.
