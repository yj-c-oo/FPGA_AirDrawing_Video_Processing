`ifndef UARTRXPACKED_COVERAGE_SV
`define UARTRXPACKED_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartrxpacked_seq_item.sv"

typedef class uartrxpacked_scoreboard;

class uartrxpacked_coverage extends uvm_subscriber #(uartrxpacked_seq_item);
    `uvm_component_utils(uartrxpacked_coverage)

    uartrxpacked_scoreboard scb;

    int scenario_s;
    bit expect_valid_s;
    bit texture_enable_s;
    bit eraser_s;
    bit size_s;
    bit clear_s;
    bit [2:0] pen_color_s;
    bit [2:0] shape_s;
    bit paper_s;
    int timeout_after_byte_s;

    covergroup scenario_cg;
        cp_scenario: coverpoint scenario_s {
            bins reset_idle     = {SCN_RESET_IDLE};
            bins valid_packet   = {SCN_VALID_PACKET};
            bins control_decode = {SCN_CONTROL_DECODE};
            bins shape_decode   = {SCN_SHAPE_DECODE};
            bins wrong_start    = {SCN_WRONG_START};
            bins wrong_end      = {SCN_WRONG_END};
            bins timeout        = {SCN_TIMEOUT};
            bins back_to_back   = {SCN_BACK_TO_BACK};
            bins clear_pulse    = {SCN_CLEAR_PULSE};
            bins random_stress  = {SCN_RANDOM_STRESS};
        }

        cp_expect_valid: coverpoint expect_valid_s {
            bins invalid = {0};
            bins valid   = {1};
        }

        cp_texture_enable: coverpoint texture_enable_s {
            bins off = {0};
            bins on  = {1};
        }

        cp_eraser: coverpoint eraser_s {
            bins off = {0};
            bins on  = {1};
        }

        cp_size: coverpoint size_s {
            bins b0 = {0};
            bins b1 = {1};
        }

        cp_clear: coverpoint clear_s {
            bins no  = {0};
            bins yes = {1};
        }

        cp_pen_color: coverpoint pen_color_s {
            bins colors[] = {[0:7]};
        }

        cp_shape: coverpoint shape_s {
            bins valid[]    = {[0:4]};
            bins reserved[] = {[5:7]};
        }

        cp_paper: coverpoint paper_s {
            bins off = {0};
            bins on  = {1};
        }

        cp_timeout_after_byte: coverpoint timeout_after_byte_s {
            bins none          = {-1};
            bins after_start   = {0};
            bins after_control = {1};
            bins after_shape   = {2};
        }

        cx_shape_paper: cross cp_shape, cp_paper;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        scenario_cg = new();
    endfunction

    function void write(uartrxpacked_seq_item t);
        scenario_s = int'(t.scenario);
        expect_valid_s = t.expects_packet_valid();
        texture_enable_s = t.control_byte[7];
        eraser_s = t.control_byte[6];
        size_s = t.control_byte[5];
        clear_s = t.control_byte[1];
        pen_color_s = t.control_byte[4:2];
        shape_s = t.shape_byte[2:0];
        paper_s = t.shape_byte[3];
        timeout_after_byte_s = t.timeout_after_byte;
        scenario_cg.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (scb != null) begin
            scb.print_pre_coverage_timing_totals();
        end
        `uvm_info(get_type_name(), "\n===== UART RX Packed Coverage Summary =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Scenario       : %.1f%%", scenario_cg.cp_scenario.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Expect valid   : %.1f%%", scenario_cg.cp_expect_valid.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Pen color      : %.1f%%", scenario_cg.cp_pen_color.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Shape          : %.1f%%", scenario_cg.cp_shape.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Paper          : %.1f%%", scenario_cg.cp_paper.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Shape x Paper  : %.1f%%", scenario_cg.cx_shape_paper.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Timeout stage  : %.1f%%", scenario_cg.cp_timeout_after_byte.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), "===========================================\n", UVM_LOW)
    endfunction
endclass

`endif
