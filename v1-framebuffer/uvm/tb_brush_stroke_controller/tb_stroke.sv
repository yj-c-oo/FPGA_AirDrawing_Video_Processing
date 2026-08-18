`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import stroke_pkg::*;

module tb_stroke;

    //------------------------------------------
    // Clock / Reset
    //------------------------------------------

    logic clk;
    logic rst;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;

        repeat(5) @(posedge clk);

        rst = 0;
    end

    //------------------------------------------
    // Interface
    //------------------------------------------

    stroke_if vif(
        .clk(clk),
        .rst(rst)
    );

    //------------------------------------------
    // DUT
    //------------------------------------------

    brush_stroke_controller dut(

        .clk            (clk),
        .rst            (rst),

        .frame_done     (vif.frame_done),
        .pen_present    (vif.pen_present),

        .X_center       (vif.X_center),
        .Y_center       (vif.Y_center),

        .sw_pen_color   (vif.sw_pen_color),
        .sw_eraser      (vif.sw_eraser),
        .sw_size        (vif.sw_size),

        .line_ready     (vif.line_ready),
        .line_done      (vif.line_done),

        .line_start     (vif.line_start),

        .line_x0        (vif.line_x0),
        .line_y0        (vif.line_y0),

        .line_x1        (vif.line_x1),
        .line_y1        (vif.line_y1),

        .line_color     (vif.line_color),

        .line_radius    (vif.line_radius),

        .line_threshold (vif.line_threshold),

        .busy           (vif.busy)

    );

    //------------------------------------------
    // Line Engine Stub
    //------------------------------------------

    line_engine_stub line_stub(

        .clk        (clk),
        .rst        (rst),

        .line_start (vif.line_start),

        .line_done  (vif.line_done)

    );

    //------------------------------------------
    // UVM Configuration
    //------------------------------------------

    initial begin

        uvm_config_db#(virtual stroke_if)::set(null, "*", "vif", vif);

    end

    //------------------------------------------
    // Dump Waveform (FSDB)
    //------------------------------------------
    
    initial begin
    
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_stroke);
    
    end

    //------------------------------------------
    // Start Test
    //------------------------------------------

    initial begin

        run_test();

    end

endmodule



module line_engine_stub
(
    input  logic clk,
    input  logic rst,

    input  logic line_start,
    output logic line_done
);

    int delay_cnt;
    bit busy;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            delay_cnt <= 0;
            busy      <= 0;
            line_done <= 0;
        end
        else begin

            line_done <= 0;

            //------------------------------------------
            // line_start 수신
            //------------------------------------------

            if (!busy && line_start) begin
                busy <= 1;

                // 2~6 Cycle 랜덤 지연
                delay_cnt <= $urandom_range(2,6);
            end

            //------------------------------------------
            // 작업 진행
            //------------------------------------------

            else if (busy) begin

                if (delay_cnt == 0) begin
                    line_done <= 1;
                    busy      <= 0;
                end
                else begin
                    delay_cnt <= delay_cnt - 1;
                end

            end

        end
    end

endmodule



// task drive(stroke_transaction tr);

//     @(vif.drv_cb);

//     vif.drv_cb.frame_done       <= tr.frame_done;
//     vif.drv_cb.pen_present      <= tr.pen_present;

//     vif.drv_cb.X_center         <= tr.X_center;
//     vif.drv_cb.Y_center         <= tr.Y_center;

//     vif.drv_cb.sw_pen_color     <= tr.sw_pen_color;

//     vif.drv_cb.sw_eraser        <= tr.sw_eraser;
//     vif.drv_cb.sw_size          <= tr.sw_size;

//     vif.drv_cb.line_ready       <= tr.line_ready;

// endtask



// brush_stroke_controller DUT
// (
//     .clk(clk),
//     .rst(rst),

//     .frame_done(vif.frame_done),
//     .pen_present(vif.pen_present),

//     .X_center(vif.X_center),
//     .Y_center(vif.Y_center),

//     .sw_pen_color(vif.sw_pen_color),

//     .sw_eraser(vif.sw_eraser),
//     .sw_size(vif.sw_size),

//     .line_ready(vif.line_ready),

//     .line_done(vif.line_done),

//     .line_start(vif.line_start),

//     .line_x0(vif.line_x0),
//     .line_y0(vif.line_y0),

//     .line_x1(vif.line_x1),
//     .line_y1(vif.line_y1),

//     .line_color(vif.line_color),

//     .line_radius(vif.line_radius),

//     .line_threshold(vif.line_threshold),

//     .busy(vif.busy)
// );

// line_engine_stub stub
// (
//     .clk(clk),
//     .rst(rst),

//     .line_start(vif.line_start),

//     .line_done(vif.line_done)
// );




