`ifndef PENCONTROL_COVERAGE_SV
`define PENCONTROL_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "pencontrol_seq_item.sv"

typedef class pencontrol_scoreboard;

class pencontrol_coverage extends uvm_subscriber #(pencontrol_seq_item);
    `uvm_component_utils(pencontrol_coverage)

    pencontrol_scoreboard scb;

    int scenario_s;
    bit uart_valid_s;
    bit btn_eraser_s;
    bit btn_mode_s;
    bit btn_size_s;
    bit clear_s;
    bit [2:0] shape_s;

    covergroup cg;
        cp_scenario: coverpoint scenario_s {
            bins all[] = {[SCN_RESET_IDLE:SCN_RANDOM_MIX]};
        }
        cp_uart_valid: coverpoint uart_valid_s { bins no = {0}; bins yes = {1}; }
        cp_btn_eraser: coverpoint btn_eraser_s { bins no = {0}; bins yes = {1}; }
        cp_btn_mode:   coverpoint btn_mode_s   { bins no = {0}; bins yes = {1}; }
        cp_btn_size:   coverpoint btn_size_s   { bins no = {0}; bins yes = {1}; }
        cp_clear:      coverpoint clear_s      { bins no = {0}; bins yes = {1}; }
        cp_shape: coverpoint shape_s {
            bins valid[]    = {[0:4]};
            bins clamped[]  = {[5:7]};
        }
        cx_uart_button: cross cp_uart_valid, cp_btn_eraser, cp_btn_mode, cp_btn_size;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    function void write(pencontrol_seq_item t);
        scenario_s = int'(t.scenario);
        uart_valid_s = t.uart_valid;
        btn_eraser_s = t.btn_eraser;
        btn_mode_s = t.btn_mode;
        btn_size_s = t.btn_size;
        clear_s = t.uart_clear_pulse;
        shape_s = t.uart_texture_shape;
        cg.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (scb != null) begin
            scb.print_pre_coverage_timing_totals();
        end
        `uvm_info(get_type_name(), "\n===== Pencontrol Coverage Summary =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Scenario        : %.1f%%", cg.cp_scenario.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("UART valid      : %.1f%%", cg.cp_uart_valid.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Button mix      : %.1f%%", cg.cx_uart_button.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Shape bins      : %.1f%%", cg.cp_shape.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), "=======================================\n", UVM_LOW)
    endfunction
endclass

`endif
