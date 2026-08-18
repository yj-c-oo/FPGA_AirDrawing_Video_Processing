`ifndef BRUSH_IF_SV
`define BRUSH_IF_SV

interface brush_if(input logic clk);

    //---------------------------------------------------------
    // Global
    //---------------------------------------------------------
    logic rst;

    //---------------------------------------------------------
    // Input Signals
    //---------------------------------------------------------
    logic        point_valid;
    logic        point_ready;

    logic [8:0]  point_x;
    logic [8:0]  point_y;

    logic [3:0]  color;

    logic [4:0]  radius;

    logic [10:0] sq_threshold;

    logic        texture_enable;
    logic [2:0]  texture_shape;

    //---------------------------------------------------------
    // Output Signals
    //---------------------------------------------------------
    logic        stamp_done;

    logic        ram_we;
    logic [$clog2(320*240)-1:0] ram_waddr;
    logic [3:0]  ram_wdata;

    logic        busy;

    //---------------------------------------------------------
    // Driver Clocking Block
    //---------------------------------------------------------
    clocking drv_cb @(posedge clk);

        default input #1step output #0;

        //-----------------------------
        // DUT Inputs
        //-----------------------------
        output point_valid;

        output point_x;
        output point_y;

        output color;

        output radius;

        output sq_threshold;

        output texture_enable;
        output texture_shape;

        //-----------------------------
        // DUT Outputs
        //-----------------------------
        input point_ready;

        input stamp_done;

        input ram_we;
        input ram_waddr;
        input ram_wdata;

        input busy;

    endclocking

    //---------------------------------------------------------
    // Monitor Clocking Block
    //---------------------------------------------------------
    clocking mon_cb @(posedge clk);

        default input #1step;

        //-----------------------------
        // Inputs
        //-----------------------------
        input point_valid;

        input point_ready;

        input point_x;
        input point_y;

        input color;

        input radius;

        input sq_threshold;

        input texture_enable;
        input texture_shape;

        //-----------------------------
        // Outputs
        //-----------------------------
        input stamp_done;

        input ram_we;
        input ram_waddr;
        input ram_wdata;

        input busy;

    endclocking

endinterface

`endif
