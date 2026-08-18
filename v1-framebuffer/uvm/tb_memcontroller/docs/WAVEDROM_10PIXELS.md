# WaveDrom for 10 Pixels

아래 WaveDrom 코드는 `frame 2 (RED_HEAVY)`의 앞 10픽셀 구간을 기준으로 작성했습니다.

- 입력 기준:
  - `vsync` 2 cycle
  - idle 1 cycle
  - 10 pixels = 20 bytes
- 출력 기준:
  - `WE`는 각 픽셀의 두 번째 byte cycle에서만 `1`
  - `WADDR`, `WDATA`는 이 문서에서는 `WE=1`인 유효 write cycle에서만 표시
- 픽셀 데이터:
  - `P0=0xF800`
  - `P1=0xF821`
  - `P2=0xF842`
  - `P3=0xF863`
  - `P4=0xF884`
  - `P5=0xF8A5`
  - `P6=0xF8C6`
  - `P7=0xF8E7`
  - `P8=0xF908`
  - `P9=0xF929`

```wavedrom
{
  signal: [
    {name: "pclk",           wave: "p......................"},
    {},
    ["Inputs",
      {name: "vsync",        wave: "1.0...................."},
      {name: "href",         wave: "0..1..................."},
      {name: "pdata[7:0]",   wave: "xxx====================",
       data: ["F8","00","F8","21","F8","42","F8","63","F8","84",
              "F8","A5","F8","C6","F8","E7","F9","08","F9","29"]}
    ],
    {},
    ["Golden Output",
      {name: "golden_we",    wave: "0...1010101010101010101"},
      {name: "golden_waddr", wave: "xxxx=x=x=x=x=x=x=x=x=x=",
       data: ["0","1","2","3","4","5","6","7","8","9"]},
      {name: "golden_wdata", wave: "xxxx=x=x=x=x=x=x=x=x=x=",
       data: ["F800","F821","F842","F863","F884",
              "F8A5","F8C6","F8E7","F908","F929"]}
    ],
    {},
    ["RTL Output",
      {name: "rtl_we",       wave: "0...1010101010101010101"},
      {name: "rtl_waddr",    wave: "xxxx=x=x=x=x=x=x=x=x=x=",
       data: ["0","1","2","3","4","5","6","7","8","9"]},
      {name: "rtl_wdata",    wave: "xxxx=x=x=x=x=x=x=x=x=x=",
       data: ["F800","F821","F842","F863","F884",
              "F8A5","F8C6","F8E7","F908","F929"]}
    ]
  ],
  edge: [
    "a~>b pixel0_write",
    "c~>d pixel1_write",
    "e~>f pixel2_write",
    "g~>h pixel3_write",
    "i~>j pixel4_write",
    "k~>l pixel5_write",
    "m~>n pixel6_write",
    "o~>p pixel7_write",
    "q~>r pixel8_write",
    "s~>t pixel9_write"
  ],
  node: ".ab.cd.ef.gh.ij.kl.mn.op.qr.st",
  config: {hscale: 2}
}
```

실제 비교 포인트는 아래처럼 보면 됩니다.

- `pdata`의 두 번째 byte가 들어오는 cycle
- 그 cycle에서 `golden_we`와 `rtl_we`가 동시에 `1`
- 같은 cycle에서 `golden_waddr == rtl_waddr`
- 같은 cycle에서 `golden_wdata == rtl_wdata`

로그/CSV와 같이 맞춰 보려면 `timing_compare_first3frames.csv`의 `frame_id=2` 구간과 함께 확인하면 됩니다.
