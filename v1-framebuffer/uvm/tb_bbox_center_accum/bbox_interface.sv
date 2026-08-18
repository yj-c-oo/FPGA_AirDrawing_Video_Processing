`ifndef BBOX_INTERFACE_SV
`define BBOX_INTERFACE_SV

interface bbox_if(input logic pclk);

    logic rst;

    // Camera Input
    logic        vsync;
    logic        we;
    logic        hit;

    // DUT Output
    logic [8:0] cx;
    logic [8:0] cy;
    logic       pen;
    logic       valid;

    // Driver Clocking Block
    clocking drv_cb @(posedge pclk);

        default input #1step output #0;

        output vsync;
        output we;
        output hit;

        input cx;
        input cy;
        input pen;
        input valid;

    endclocking

    // Monitor Clocking Block
    clocking mon_cb @(posedge pclk);

        default input #1step;

        input vsync;
        input we;
        input hit;

        input cx;
        input cy;
        input pen;
        input valid;

    endclocking

endinterface


`endif