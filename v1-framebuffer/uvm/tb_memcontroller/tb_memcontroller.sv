`include "uvm_macros.svh"
import uvm_pkg::*;

`include "memctrl_interface.sv"
`include "memctrl_seq_item.sv"
`include "memctrl_timing_item.sv"
`include "memctrl_sequence.sv"
`include "memctrl_driver.sv"
`include "memctrl_monitor.sv"
`include "memctrl_agent.sv"
`include "memctrl_scoreboard.sv"
`include "memctrl_coverage.sv"
`include "memctrl_env.sv"
`include "memctrl_test.sv"

module tb_ov7670_memcontroller;
    logic pclk;
    logic reset;

    always #5 pclk = ~pclk;

    memctrl_if vif (
        .pclk (pclk),
        .reset(reset)
    );

    ov7670_memcontroller dut (
        .pclk (pclk),
        .reset(reset),
        .href (vif.href),
        .vsync(vif.vsync),
        .pdata(vif.pdata),
        .we   (vif.we),
        .waddr(vif.waddr),
        .wdata(vif.wdata)
    );

    initial begin
        pclk  = 1'b0;
        reset = 1'b1;
        repeat (5) @(posedge pclk);
        reset = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual memctrl_if)::set(null, "*", "vif", vif);
        run_test("memctrl_base_test");
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_ov7670_memcontroller, "+all");
    end
endmodule
