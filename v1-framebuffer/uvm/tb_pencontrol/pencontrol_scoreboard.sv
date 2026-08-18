`ifndef PENCONTROL_SCOREBOARD_SV
`define PENCONTROL_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "pencontrol_packet_item.sv"
`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)

class pencontrol_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(pencontrol_scoreboard)

    localparam int TIMING_TOL_CYCLES = 1;
    localparam int TIMING_TOL_NS     = 10;

    uvm_analysis_imp_exp #(pencontrol_packet_item, pencontrol_scoreboard) exp_imp;
    uvm_analysis_imp_act #(pencontrol_packet_item, pencontrol_scoreboard) act_imp;

    pencontrol_packet_item exp_q[$];
    pencontrol_packet_item act_q[$];

    int unsigned      pass_events;
    int unsigned      fail_events;
    int               worst_cycle_delta;
    longint unsigned  worst_time_delta_ns;
    int unsigned      total_late_cycles;
    longint unsigned  total_late_ns;
    int unsigned      late_event_count;
    bit               pre_coverage_summary_printed;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_imp = new("exp_imp", this);
        act_imp = new("act_imp", this);
    endfunction

    function void write_exp(pencontrol_packet_item tx);
        exp_q.push_back(tx);
        compare_ready();
    endfunction

    function void write_act(pencontrol_packet_item tx);
        act_q.push_back(tx);
        compare_ready();
    endfunction

    function bit timing_out_of_tolerance(
        int              abs_cycle_delta,
        longint unsigned abs_time_delta_ns
    );
        return (abs_cycle_delta > TIMING_TOL_CYCLES) && (abs_time_delta_ns > longint'(TIMING_TOL_NS));
    endfunction

    function void compare_ready();
        while ((exp_q.size() > 0) && (act_q.size() > 0)) begin
            pencontrol_packet_item exp_tx;
            pencontrol_packet_item act_tx;
            int                    mismatch_count;
            int                    cycle_delta;
            int                    abs_cycle_delta;
            longint signed         time_delta_ns;
            longint unsigned       abs_time_delta_ns;

            exp_tx = exp_q.pop_front();
            act_tx = act_q.pop_front();
            mismatch_count = 0;
            cycle_delta = int'(act_tx.cycle_id) - int'(exp_tx.cycle_id);
            abs_cycle_delta = (cycle_delta < 0) ? -cycle_delta : cycle_delta;
            time_delta_ns = longint'(act_tx.event_time_ns) - longint'(exp_tx.event_time_ns);
            abs_time_delta_ns = (time_delta_ns < 0)
                ? longint'(-time_delta_ns) : longint'(time_delta_ns);

            if (abs_cycle_delta > worst_cycle_delta) begin
                worst_cycle_delta = abs_cycle_delta;
            end
            if (abs_time_delta_ns > worst_time_delta_ns) begin
                worst_time_delta_ns = abs_time_delta_ns;
            end
            if (cycle_delta > 0) begin
                total_late_cycles += cycle_delta;
                late_event_count++;
            end
            if (time_delta_ns > 0) begin
                total_late_ns += longint'(time_delta_ns);
            end

            if (exp_tx.pen_color !== act_tx.pen_color) begin
                `uvm_error(get_type_name(), $sformatf("Pen color mismatch exp=%03b act=%03b",
                    exp_tx.pen_color, act_tx.pen_color))
                mismatch_count++;
            end
            if (exp_tx.eraser !== act_tx.eraser) begin
                `uvm_error(get_type_name(), $sformatf("Eraser mismatch exp=%0b act=%0b",
                    exp_tx.eraser, act_tx.eraser))
                mismatch_count++;
            end
            if (exp_tx.size !== act_tx.size) begin
                `uvm_error(get_type_name(), $sformatf("Size mismatch exp=%0b act=%0b",
                    exp_tx.size, act_tx.size))
                mismatch_count++;
            end
            if (exp_tx.texture_enable !== act_tx.texture_enable) begin
                `uvm_error(get_type_name(), $sformatf("Texture enable mismatch exp=%0b act=%0b",
                    exp_tx.texture_enable, act_tx.texture_enable))
                mismatch_count++;
            end
            if (exp_tx.texture_shape !== act_tx.texture_shape) begin
                `uvm_error(get_type_name(), $sformatf("Texture shape mismatch exp=%0d act=%0d",
                    exp_tx.texture_shape, act_tx.texture_shape))
                mismatch_count++;
            end
            if (exp_tx.paper !== act_tx.paper) begin
                `uvm_error(get_type_name(), $sformatf("Paper mismatch exp=%0b act=%0b",
                    exp_tx.paper, act_tx.paper))
                mismatch_count++;
            end
            if (exp_tx.clear !== act_tx.clear) begin
                `uvm_error(get_type_name(), $sformatf("Clear mismatch exp=%0b act=%0b",
                    exp_tx.clear, act_tx.clear))
                mismatch_count++;
            end
            if (timing_out_of_tolerance(abs_cycle_delta, abs_time_delta_ns)) begin
                `uvm_error(get_type_name(),
                    $sformatf("Timing mismatch scenario=%0d exp_cycle=%0d act_cycle=%0d delta_cycle=%0d exp_time_ns=%0d act_time_ns=%0d delta_time_ns=%0d tol_cycle=%0d tol_time_ns=%0d",
                    exp_tx.scenario, exp_tx.cycle_id, act_tx.cycle_id,
                    cycle_delta, exp_tx.event_time_ns, act_tx.event_time_ns, time_delta_ns,
                    TIMING_TOL_CYCLES, TIMING_TOL_NS))
                mismatch_count++;
            end

            `uvm_info(get_type_name(),
                $sformatf("State event scenario=%0d cycle_delta=%0d time_delta_ns=%0d outputs=[color=%03b eraser=%0b size=%0b tex_en=%0b shape=%0d paper=%0b clear=%0b]",
                exp_tx.scenario, cycle_delta, time_delta_ns, exp_tx.pen_color, exp_tx.eraser,
                exp_tx.size, exp_tx.texture_enable, exp_tx.texture_shape, exp_tx.paper, exp_tx.clear),
                UVM_LOW)

            if (mismatch_count == 0) begin
                pass_events++;
            end else begin
                fail_events++;
            end
        end
    endfunction

    function void print_pre_coverage_timing_totals();
        real avg_late_cycles;
        real avg_late_ns;

        if (pre_coverage_summary_printed) begin
            return;
        end
        pre_coverage_summary_printed = 1'b1;
        if (late_event_count == 0) begin
            avg_late_cycles = 0.0;
            avg_late_ns = 0.0;
        end else begin
            avg_late_cycles = real'(total_late_cycles) / real'(late_event_count);
            avg_late_ns = real'(total_late_ns) / real'(late_event_count);
        end

        `uvm_info(get_type_name(), "===== Pencontrol Timing Totals (Before Coverage) =====", UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Avg RTL-late delay : cycle=%.3f ns=%.3f late_evt_cnt=%0d",
            avg_late_cycles, avg_late_ns, late_event_count), UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Total RTL-late delay : cycle=%0d ns=%0d", total_late_cycles, total_late_ns),
            UVM_LOW)
        `uvm_info(get_type_name(), "=====================================================", UVM_LOW)
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if ((exp_q.size() != 0) || (act_q.size() != 0)) begin
            `uvm_error(get_type_name(),
                $sformatf("Unmatched state events remain exp_q=%0d act_q=%0d", exp_q.size(), act_q.size()))
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        string result;

        super.report_phase(phase);
        result = (fail_events == 0) ? "** PASS **" : "** FAIL **";
        `uvm_info(get_type_name(), "******** pencontrol summary ********", UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Result            : %s", result), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Pass events       : %0d", pass_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail events       : %0d", fail_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst cycle delta : %0d", worst_cycle_delta), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst time delta  : %0d", worst_time_delta_ns), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Timing tolerance  : cycle<=%0d or ns<=%0d",
            TIMING_TOL_CYCLES, TIMING_TOL_NS), UVM_MEDIUM)
        `uvm_info(get_type_name(), "************************************", UVM_MEDIUM)
    endfunction
endclass

`endif
