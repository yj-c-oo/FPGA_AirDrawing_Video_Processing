`timescale 1ns / 1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import brush_pkg::*;


module tb_brush;

    //----------------------------------------------------
    // Clock / Reset
    //----------------------------------------------------

    logic clk;
    logic rst;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        repeat (5) @(posedge clk);
        rst = 0;
    end


    //----------------------------------------------------
    // Interface
    //----------------------------------------------------

    brush_if vif (clk);

    assign vif.rst = rst;


    //----------------------------------------------------
    // DUT
    //----------------------------------------------------

    circular_brush_renderer DUT (

        .clk(clk),
        .rst(rst),

        .point_valid(vif.point_valid),
        .point_ready(vif.point_ready),

        .point_x(vif.point_x),
        .point_y(vif.point_y),

        .color(vif.color),
        .radius(vif.radius),

        .sq_threshold(vif.sq_threshold),

        .texture_enable(vif.texture_enable),
        .texture_shape(vif.texture_shape),

        .stamp_done(vif.stamp_done),

        .ram_we(vif.ram_we),
        .ram_waddr(vif.ram_waddr),
        .ram_wdata(vif.ram_wdata),

        .busy(vif.busy)
    );


    //----------------------------------------------------
    // UVM Config
    //----------------------------------------------------

    initial begin
        uvm_config_db#(virtual brush_if)::set(null, "*", "vif", vif);

        run_test();
    end


    //----------------------------------------------------
    // FSDB Dump
    //----------------------------------------------------

    initial begin
        $fsdbDumpfile("brush.fsdb");
        $fsdbDumpvars(0, tb_brush);
    end


endmodule
