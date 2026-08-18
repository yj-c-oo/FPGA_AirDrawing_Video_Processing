`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uartrxpacked_interface.sv"
`include "uartrxpacked_seq_item.sv"
`include "uartrxpacked_byte_item.sv"
`include "uartrxpacked_packet_item.sv"
`include "uartrxpacked_sequence.sv"
`include "uartrxpacked_driver.sv"
`include "uartrxpacked_monitor.sv"
`include "uartrxpacked_agent.sv"
`include "uartrxpacked_scoreboard.sv"
`include "uartrxpacked_coverage.sv"
`include "uartrxpacked_env.sv"
`include "uartrxpacked_test.sv"

module tb_uartrxpacked;
    logic clk;
    logic rst;

    always #5 clk = ~clk;

    uartrxpacked_if vif (
        .clk(clk),
        .rst(rst)
    );

    uart_packet_decoder #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115_200)
    ) dut (
        .clk             (clk),
        .rst             (rst),
        .rx              (vif.rx),
        .o_pen_color     (vif.o_pen_color),
        .o_eraser        (vif.o_eraser),
        .o_size          (vif.o_size),
        .o_texture_enable(vif.o_texture_enable),
        .o_texture_shape (vif.o_texture_shape),
        .o_paper         (vif.o_paper),
        .o_clear_pulse   (vif.o_clear_pulse),
        .o_packet_valid  (vif.o_packet_valid)
    );

    assign vif.baud_tick_dbg = dut.baud_tick;
    assign vif.rx_done_dbg   = dut.rx_done;
    assign vif.rx_data_dbg   = dut.rx_data;
    assign vif.state_dbg     = dut.state;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual uartrxpacked_if)::set(null, "*", "vif", vif);
        run_test("uartrxpacked_base_test");
    end

    initial begin
        $fsdbDumpfile("novas_uartpacket.fsdb");
        $fsdbDumpvars(0, tb_uartrxpacked, "+all");
    end
endmodule
