`timescale 1ns / 1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import bbox_pkg::*;

module tb_bbox_center_accum;

    logic pclk;
    logic rst;

    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk;
    end

    initial begin
        rst = 1;
        repeat (5) @(posedge pclk);
        rst = 0;
    end


    bbox_if vif (pclk);

    assign vif.rst = rst;


    bbox_center_accum #(
        .PEN_MIN(15),
        .ERODE  (1'b1)
    ) DUT (
        .pclk (pclk),
        .vsync(vif.vsync),
        .we   (vif.we),
        .hit  (vif.hit),
        .cx   (vif.cx),
        .cy   (vif.cy),
        .pen  (vif.pen),
        .valid(vif.valid)
    );


    initial begin
        uvm_config_db#(virtual bbox_if)::set(null, "*", "vif", vif);

        run_test();
    end


    initial begin
        $fsdbDumpfile("bbox.fsdb");
        $fsdbDumpvars(0, tb_bbox_center_accum);
    end


endmodule
