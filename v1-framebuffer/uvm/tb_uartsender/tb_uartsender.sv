`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uartsender_interface.sv"
`include "uartsender_seq_item.sv"
`include "uartsender_byte_item.sv"
`include "uartsender_packet_item.sv"
`include "uartsender_sequence.sv"
`include "uartsender_driver.sv"
`include "uartsender_monitor.sv"
`include "uartsender_agent.sv"
`include "uartsender_scoreboard.sv"
`include "uartsender_coverage.sv"
`include "uartsender_env.sv"
`include "uartsender_test.sv"

module tb_uartsender;
    logic clk;
    logic rst;

    always #5 clk = ~clk;

    uartsender_if vif (
        .clk(clk),
        .rst(rst)
    );

    uart_packet_sender #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115_200)
    ) dut (
        .clk              (clk),
        .rst              (rst),
        .send_trigger     (vif.send_trigger),
        .X_center         (vif.X_center),
        .Y_center         (vif.Y_center),
        .sw_paint_red     (vif.sw_paint_red),
        .sw_paint_green   (vif.sw_paint_green),
        .sw_paint_blue    (vif.sw_paint_blue),
        .sw_eraser        (vif.sw_eraser),
        .sw_size          (vif.sw_size),
        .sw_texture_enable(vif.sw_texture_enable),
        .texture_shape    (vif.texture_shape),
        .paper            (vif.paper),
        .clear_btn        (vif.clear_btn),
        .tx               (vif.tx),
        .busy             (vif.busy)
    );

    assign vif.baud_tick_dbg = dut.baud_tick;
    assign vif.tx_start_dbg  = dut.tx_start;
    assign vif.tx_busy_dbg   = dut.tx_busy;
    assign vif.tx_done_dbg   = dut.tx_done;
    assign vif.tx_data_dbg   = dut.tx_data;
    assign vif.state_dbg     = dut.state;
    assign vif.byte_index_dbg = dut.byte_index;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual uartsender_if)::set(null, "*", "vif", vif);
        run_test("uartsender_base_test");
    end

    initial begin
        $fsdbDumpfile("novas_uartsender.fsdb");
        $fsdbDumpvars(0, tb_uartsender, "+all");
    end
endmodule
