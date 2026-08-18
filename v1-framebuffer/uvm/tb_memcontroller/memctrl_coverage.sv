`ifndef MEMCTRL_COVERAGE_SV
`define MEMCTRL_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "memctrl_seq_item.sv"
`include "memctrl_scoreboard.sv"

class memctrl_coverage extends uvm_subscriber #(memctrl_seq_item);
    `uvm_component_utils(memctrl_coverage)

    memctrl_scoreboard scb;
    logic [4:0] r_s;
    logic [5:0] g_s;
    logic [4:0] b_s;
    int unsigned sampled_frames;
    int unsigned sampled_pixels;

    covergroup rgb565_cg;
        cp_r: coverpoint r_s {
            bins low  = {[5'd0  : 5'd10]};
            bins mid  = {[5'd11 : 5'd20]};
            bins high = {[5'd21 : 5'd31]};
        }

        cp_g: coverpoint g_s {
            bins low  = {[6'd0  : 6'd21]};
            bins mid  = {[6'd22 : 6'd42]};
            bins high = {[6'd43 : 6'd63]};
        }

        cp_b: coverpoint b_s {
            bins low  = {[5'd0  : 5'd10]};
            bins mid  = {[5'd11 : 5'd20]};
            bins high = {[5'd21 : 5'd31]};
        }

        cx_rg  : cross cp_r, cp_g;
        cx_gb  : cross cp_g, cp_b;
        cx_br  : cross cp_b, cp_r;
        cx_rgb : cross cp_r, cp_g, cp_b;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        rgb565_cg = new();
    endfunction

    function void sample_pixel(bit [15:0] pixel);
        r_s = pixel[15:11];
        g_s = pixel[10:5];
        b_s = pixel[4:0];
        rgb565_cg.sample();
        sampled_pixels++;
    endfunction

    function void write(memctrl_seq_item t);
        sampled_frames++;
        foreach (t.pixels[i]) begin
            sample_pixel(t.pixels[i]);
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (scb != null) begin
            scb.print_pre_coverage_timing_totals();
        end
        `uvm_info(get_type_name(), "\n===== RGB565 Coverage Summary =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Frames sampled : %0d", sampled_frames), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Pixels sampled : %0d", sampled_pixels), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Overall        : %.1f%%", rgb565_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("R bins         : %.1f%%", rgb565_cg.cp_r.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("G bins         : %.1f%%", rgb565_cg.cp_g.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("B bins         : %.1f%%", rgb565_cg.cp_b.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), "==================================\n", UVM_LOW)
    endfunction
endclass

`endif
