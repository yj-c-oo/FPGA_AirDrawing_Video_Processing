# UART Packet Decoder Full-Run WaveDrom

## Full Simulation Time Range

- Full simulation: `0 ps ~ 16142255000 ps`
- Full simulation: `0 ns ~ 16142255 ns`

## Extracted Output Event Times

### `o_packet_valid` pulse times

- `404255000 ps`
- `768845000 ps`
- `1133425000 ps`
- `1498005000 ps`
- `1862585000 ps`
- `2227175000 ps`
- `2591755000 ps`
- `2956335000 ps`
- `3320925000 ps`
- `3685505000 ps`
- `4050085000 ps`
- `4414665000 ps`
- `4779255000 ps`
- `5143835000 ps`
- `6780115000 ps`
- `7144705000 ps`
- `7491925000 ps`
- `7856505000 ps`
- `8605745000 ps`
- `8973045000 ps`
- `10507325000 ps`

### `o_clear_pulse` pulse times

- `7856505000 ps`
- `8605745000 ps`
- `8973045000 ps`
- `10507325000 ps`

## Scenario Group Time Ranges

### Recommended Verdi windows

- Startup + reset/idle: `0 ps ~ 450000000 ps`
- First valid packet: `350000000 ps ~ 450000000 ps`
- Control decode block: `700000000 ps ~ 1550000000 ps`
- Shape decode block: `1800000000 ps ~ 5200000000 ps`
- Wrong start / wrong end / timeout block: `5200000000 ps ~ 6781000000 ps`
- Recovery valid packet: `6700000000 ps ~ 6850000000 ps`
- Back-to-back packets: `7100000000 ps ~ 7520000000 ps`
- Clear-pulse packet: `7800000000 ps ~ 7900000000 ps`
- Random stress block: `8500000000 ps ~ 10600000000 ps`
- Last valid packet full 4-byte window: `10246905000 ps ~ 10507325000 ps`

## Scenario Mapping

- `RESET_IDLE`
  - no valid output pulse
- `VALID_PACKET`
  - valid pulse count: `1`
  - first pulse: `404255000 ps`
- `CONTROL_DECODE`
  - valid pulse count: `3`
  - pulse range: `768845000 ps ~ 1498005000 ps`
- `SHAPE_DECODE`
  - valid pulse count: `10`
  - pulse range: `1862585000 ps ~ 5143835000 ps`
- `WRONG_START`, `WRONG_END`, `TIMEOUT`
  - valid pulse count: `0`
  - observation gap before next valid pulse: `5143835000 ps ~ 6780115000 ps`
- `VALID_PACKET` recovery
  - valid pulse count: `1`
  - pulse time: `6780115000 ps`
- `BACK_TO_BACK`
  - valid pulse count: `2`
  - pulse times: `7144705000 ps`, `7491925000 ps`
- `CLEAR_PULSE`
  - valid pulse count: `1`
  - clear pulse count: `1`
  - pulse time: `7856505000 ps`
- `RANDOM_STRESS`
  - valid pulse count observed: `3`
  - clear pulse count observed: `3`
  - valid pulse times: `8605745000 ps`, `8973045000 ps`, `10507325000 ps`

## WaveDrom Code

```json
{ "signal": [
  { "name": "phase", "wave": "x.=.=.=.=.=.=.=.=.x",
    "data": [
      "RESET/IDLE",
      "VALID_PACKET",
      "CONTROL_DECODE x3",
      "SHAPE_DECODE x10",
      "WRONG/WRONG/TIMEOUT",
      "VALID_RECOVERY",
      "BACK_TO_BACK x2",
      "CLEAR_PULSE",
      "RANDOM_STRESS"
    ]
  },
  { "name": "golden_valid_cnt", "wave": "x.=.=.=.=.=.=.=.=.x",
    "data": ["0", "1", "3", "10", "0", "1", "2", "1", "3"]
  },
  { "name": "rtl_packet_valid", "wave": "0.1.1.1.0.1.1.1.1.0" },
  { "name": "golden_clear_cnt", "wave": "x.=.=.=.=.=.=.=.=.x",
    "data": ["0", "0", "0", "0", "0", "0", "0", "1", "3"]
  },
  { "name": "rtl_clear_pulse", "wave": "0.0.0.0.0.0.0.1.1.0" },
  { "name": "result", "wave": "x.=.=.=.=.=.=.=.=.x",
    "data": [
      "idle only",
      "1 valid output",
      "3 control decodes",
      "10 shape decodes",
      "no valid output",
      "recovered",
      "2 consecutive valid outputs",
      "valid + clear pulse",
      "mixed random valid/invalid"
    ]
  }
],
"edge": [
  "a~>b startup to first valid",
  "b~>c control decode region",
  "c~>d shape decode region",
  "d~>e invalid/timeout gap",
  "e~>f recovery valid",
  "f~>g back-to-back valid",
  "g~>h clear pulse packet",
  "h~>i random stress region"
],
"node": "ab.c.d.e.f.g.h.i"
}
```

## Last Packet Range

- Last valid packet detailed window:
  - `10246905000 ps ~ 10507325000 ps`
- Last 4 captured bytes:
  - `10246905000 ps` : `0xA5`
  - `10333705000 ps` : `0x5B`
  - `10420515000 ps` : `0xE3`
  - `10507315000 ps` : `0x5A`
- Final output pulse:
  - `10507325000 ps`

## Korean Notes

- 이 문서는 전체 UART UVM 동작을 상위 레벨에서 보려는 용도입니다.
- `o_packet_valid` 펄스가 실제로 발생한 절대 시간과, 각 시나리오 블럭을 Verdi에서 보기 좋은 시간 범위를 같이 정리했습니다.
- `WRONG_START`, `WRONG_END`, `TIMEOUT` 구간은 정상적으로 `o_packet_valid` 가 나오지 않아야 하므로, 그 구간은 valid pulse 공백으로 확인합니다.
- `CLEAR_PULSE` 와 일부 `RANDOM_STRESS` 패킷에서는 `o_packet_valid` 와 `o_clear_pulse` 가 같은 출력 시점에 1클럭 펄스로 발생합니다.
- 마지막 valid 패킷의 자세한 골든/RTL 비교는 [WAVEDROM_LAST_PACKET.md](/home/hedu23/Hedu23/20260715_UVM_DrawModule/tb_uartpacket/WAVEDROM_LAST_PACKET.md) 에 정리되어 있습니다.

## Useful Verdi Signals

- `/tb_uartrxpacked/vif/rx`
- `/tb_uartrxpacked/vif/baud_tick_dbg`
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
