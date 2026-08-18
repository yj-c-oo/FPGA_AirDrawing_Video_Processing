`ifndef UARTSENDER_COVERAGE_SV
`define UARTSENDER_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_seq_item.sv"

typedef class uartsender_scoreboard;

class uartsender_coverage extends uvm_subscriber #(uartsender_seq_item);
    `uvm_component_utils(uartsender_coverage)

    uartsender_scoreboard scb;

    int scenario_s;
    bit expect_packet_s;
    int trigger_hold_s;
    bit clear_s;
    bit texture_enable_s;
    bit paper_s;
    bit retrigger_s;

    covergroup cg;
        cp_scenario: coverpoint scenario_s {
            bins all[] = {[SCN_RESET_IDLE:SCN_RANDOM_STRESS]};
        }
        cp_expect_packet: coverpoint expect_packet_s { bins no = {0}; bins yes = {1}; }
        cp_trigger_hold: coverpoint trigger_hold_s {
            bins single = {1};
            bins short_hold = {[2:4]};
            bins long_hold = {[5:8]};
        }
        cp_clear: coverpoint clear_s { bins no = {0}; bins yes = {1}; }
        cp_texture_enable: coverpoint texture_enable_s { bins no = {0}; bins yes = {1}; }
        cp_paper: coverpoint paper_s { bins no = {0}; bins yes = {1}; }
        cp_retrigger: coverpoint retrigger_s { bins no = {0}; bins yes = {1}; }
        cx_texture_paper: cross cp_texture_enable, cp_paper;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    function void write(uartsender_seq_item t);
        scenario_s = int'(t.scenario);
        expect_packet_s = t.expect_packet;
        trigger_hold_s = t.trigger_hold_cycles;
        clear_s = t.clear_btn;
        texture_enable_s = t.sw_texture_enable;
        paper_s = t.paper;
        retrigger_s = t.retrigger_during_busy;
        cg.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (scb != null) begin
            scb.print_pre_coverage_timing_totals();
        end
        `uvm_info(get_type_name(), "\n===== Uartsender Coverage Summary =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Scenario        : %.1f%%", cg.cp_scenario.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Trigger hold    : %.1f%%", cg.cp_trigger_hold.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Texture x Paper : %.1f%%", cg.cx_texture_paper.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Retrigger       : %.1f%%", cg.cp_retrigger.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), "=======================================\n", UVM_LOW)
    endfunction
endclass

`endif
