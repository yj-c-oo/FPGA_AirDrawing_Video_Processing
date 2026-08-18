`timescale 1ns / 1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import bresenham_pkg::*;

module tb_bresenham;

    //------------------------------------------
    // Clock / Reset
    //------------------------------------------

    logic clk;
    logic rst;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  //100MHz
    end

    initial begin

        rst = 1;

        repeat (5) @(posedge clk);

        rst = 0;

    end


    //------------------------------------------
    // Interface
    //------------------------------------------

    bresenham_if vif (clk);

    assign vif.rst = rst;


    //------------------------------------------
    // DUT
    //------------------------------------------

    bresenham_interpolator DUT (

        .clk(clk),
        .rst(rst),

        .line_start(vif.line_start),

        .line_x0(vif.line_x0),
        .line_y0(vif.line_y0),

        .line_x1(vif.line_x1),
        .line_y1(vif.line_y1),

        .line_ready(vif.line_ready),

        .point_valid(vif.point_valid),
        .point_ready(vif.point_ready),

        .point_x(vif.point_x),
        .point_y(vif.point_y),

        .stamp_done(vif.stamp_done),

        .line_done(vif.line_done),

        .busy(vif.busy)

    );


    //------------------------------------------
    // UVM Configuration
    //------------------------------------------

    initial begin

        uvm_config_db#(virtual bresenham_if)::set(null, "*", "vif", vif);

        run_test();

    end


    //------------------------------------------
    // Wave Dump
    //------------------------------------------

    initial begin

        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_bresenham);

    end

endmodule
