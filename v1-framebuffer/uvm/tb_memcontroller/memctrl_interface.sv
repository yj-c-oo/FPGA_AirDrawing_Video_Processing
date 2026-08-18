interface memctrl_if (
    input logic pclk,
    input logic reset
);

    logic                         href;
    logic                         vsync;
    logic [7:0]                   pdata;
    logic                         we;
    logic [$clog2(320 * 240)-1:0] waddr;
    logic [15:0]                  wdata;
    int unsigned                  cycle_count;

    always_ff @(posedge pclk or posedge reset) begin
        if (reset) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end

    clocking drv_cb @(posedge pclk);
        default input #1step output #0;
        output href;
        output vsync;
        output pdata;
        input  we;
        input  waddr;
        input  wdata;
    endclocking

    clocking mon_cb @(posedge pclk);
        // Monitor DUT outputs after the sequential NBA updates settle.
        default input #0 output #0;
        input href;
        input vsync;
        input pdata;
        input we;
        input waddr;
        input wdata;
    endclocking

    modport mod_drv(clocking drv_cb, input pclk, input reset);
    modport mod_mon(clocking mon_cb, input pclk, input reset);
endinterface
