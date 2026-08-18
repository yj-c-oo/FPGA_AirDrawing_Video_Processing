`include "uvm_macros.svh"
import uvm_pkg::*;

`include "pencontrol_interface.sv"
`include "pencontrol_seq_item.sv"
`include "pencontrol_packet_item.sv"
`include "pencontrol_sequence.sv"
`include "pencontrol_driver.sv"
`include "pencontrol_monitor.sv"
`include "pencontrol_agent.sv"
`include "pencontrol_scoreboard.sv"
`include "pencontrol_coverage.sv"
`include "pencontrol_env.sv"
`include "pencontrol_test.sv"

module tb_pencontrol;
    logic clk;
    logic rst;

    always #5 clk = ~clk;

    pencontrol_if vif (
        .clk(clk),
        .rst(rst)
    );

    pen_config_controller dut (
        .clk                 (clk),
        .rst                 (rst),
        .i_uart_valid        (vif.i_uart_valid),
        .i_uart_pen_color    (vif.i_uart_pen_color),
        .i_uart_eraser       (vif.i_uart_eraser),
        .i_uart_size         (vif.i_uart_size),
        .i_uart_texture_enable(vif.i_uart_texture_enable),
        .i_uart_texture_shape(vif.i_uart_texture_shape),
        .i_uart_paper        (vif.i_uart_paper),
        .i_uart_clear_pulse  (vif.i_uart_clear_pulse),
        .i_btn_eraser        (vif.i_btn_eraser),
        .i_btn_mode          (vif.i_btn_mode),
        .i_btn_size          (vif.i_btn_size),
        .o_pen_color         (vif.o_pen_color),
        .o_eraser            (vif.o_eraser),
        .o_size              (vif.o_size),
        .o_texture_enable    (vif.o_texture_enable),
        .o_texture_shape     (vif.o_texture_shape),
        .o_paper             (vif.o_paper),
        .o_clear             (vif.o_clear)
    );

    assign vif.clear_active_dbg = dut.clear_active;
    assign vif.clear_cnt_dbg = dut.clear_cnt;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual pencontrol_if)::set(null, "*", "vif", vif);
        run_test("pencontrol_base_test");
    end

    initial begin
        $fsdbDumpfile("novas_pencontrol.fsdb");
        $fsdbDumpvars(0, tb_pencontrol, "+all");
    end
endmodule
