`ifndef UARTSENDER_SCOREBOARD_SV
`define UARTSENDER_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_byte_item.sv"
`include "uartsender_packet_item.sv"
`uvm_analysis_imp_decl(_byte_exp)
`uvm_analysis_imp_decl(_byte_act)
`uvm_analysis_imp_decl(_pkt_exp)
`uvm_analysis_imp_decl(_pkt_act)

class uartsender_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uartsender_scoreboard)

    localparam int TIMING_TOL_CYCLES = 1;
    localparam int TIMING_TOL_NS     = 10;

    uvm_analysis_imp_byte_exp #(uartsender_byte_item, uartsender_scoreboard) byte_exp_imp;
    uvm_analysis_imp_byte_act #(uartsender_byte_item, uartsender_scoreboard) byte_act_imp;
    uvm_analysis_imp_pkt_exp  #(uartsender_packet_item, uartsender_scoreboard) pkt_exp_imp;
    uvm_analysis_imp_pkt_act  #(uartsender_packet_item, uartsender_scoreboard) pkt_act_imp;

    uartsender_byte_item   exp_byte_q[$];
    uartsender_byte_item   act_byte_q[$];
    uartsender_packet_item exp_pkt_q[$];
    uartsender_packet_item act_pkt_q[$];

    int unsigned      pass_byte_events;
    int unsigned      fail_byte_events;
    int unsigned      fail_byte_data_events;
    int unsigned      fail_byte_timing_events;
    int unsigned      pass_packets;
    int unsigned      fail_packets;
    int unsigned      fail_packet_data_events;
    int unsigned      fail_packet_timing_events;
    int               worst_byte_cycle_delta;
    int               worst_packet_cycle_delta;
    longint unsigned  worst_byte_time_delta_ns;
    longint unsigned  worst_packet_time_delta_ns;
    longint unsigned  total_byte_exp_latency_cycles;
    longint unsigned  total_byte_exp_latency_ns;
    longint unsigned  total_byte_act_latency_cycles;
    longint unsigned  total_byte_act_latency_ns;
    int unsigned      total_byte_latency_count;
    longint unsigned  total_packet_exp_latency_cycles;
    longint unsigned  total_packet_exp_latency_ns;
    longint unsigned  total_packet_act_latency_cycles;
    longint unsigned  total_packet_act_latency_ns;
    int unsigned      total_packet_latency_count;
    longint signed    total_packet_cycle_delta;
    longint signed    total_packet_time_delta_ns;
    longint unsigned  total_packet_abs_cycles;
    longint unsigned  total_packet_abs_time_ns;
    int unsigned      total_packet_delta_count;
    int unsigned      total_packet_late_cycles;
    longint unsigned  total_packet_late_ns;
    int unsigned      total_packet_late_count;
    bit               pre_coverage_summary_printed;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        byte_exp_imp = new("byte_exp_imp", this);
        byte_act_imp = new("byte_act_imp", this);
        pkt_exp_imp  = new("pkt_exp_imp", this);
        pkt_act_imp  = new("pkt_act_imp", this);
    endfunction

    function void write_byte_exp(uartsender_byte_item tx);
        exp_byte_q.push_back(tx);
        compare_ready_bytes();
    endfunction

    function void write_byte_act(uartsender_byte_item tx);
        act_byte_q.push_back(tx);
        compare_ready_bytes();
    endfunction

    function void write_pkt_exp(uartsender_packet_item tx);
        exp_pkt_q.push_back(tx);
        compare_ready_packets();
    endfunction

    function void write_pkt_act(uartsender_packet_item tx);
        act_pkt_q.push_back(tx);
        compare_ready_packets();
    endfunction

    function bit timing_out_of_tolerance(
        int              abs_cycle_delta,
        longint unsigned abs_time_delta_ns
    );
        return (abs_cycle_delta > TIMING_TOL_CYCLES) && (abs_time_delta_ns > longint'(TIMING_TOL_NS));
    endfunction

    function void compare_ready_bytes();
        while ((exp_byte_q.size() > 0) && (act_byte_q.size() > 0)) begin
            uartsender_byte_item exp_tx;
            uartsender_byte_item act_tx;
            int                  mismatch_count;
            int                  cycle_delta;
            longint signed       time_delta_ns;
            int                  abs_cycle_delta;
            longint unsigned     abs_time_delta_ns;
            bit                  data_mismatch;
            bit                  timing_mismatch;
            int                  exp_latency_cycle;
            int                  act_latency_cycle;
            longint signed       exp_latency_time_ns;
            longint signed       act_latency_time_ns;

            exp_tx = exp_byte_q.pop_front();
            act_tx = act_byte_q.pop_front();
            mismatch_count = 0;
            data_mismatch = 1'b0;
            timing_mismatch = 1'b0;
            cycle_delta = int'(act_tx.cycle_id) - int'(exp_tx.cycle_id);
            time_delta_ns = longint'(act_tx.event_time_ns) - longint'(exp_tx.event_time_ns);
            abs_cycle_delta = (cycle_delta < 0) ? -cycle_delta : cycle_delta;
            abs_time_delta_ns = (time_delta_ns < 0)
                ? longint'(-time_delta_ns) : longint'(time_delta_ns);
            exp_latency_cycle = int'(exp_tx.cycle_id) - int'(exp_tx.ref_cycle_id);
            act_latency_cycle = int'(act_tx.cycle_id) - int'(exp_tx.ref_cycle_id);
            exp_latency_time_ns = longint'(exp_tx.event_time_ns) - longint'(exp_tx.ref_time_ns);
            act_latency_time_ns = longint'(act_tx.event_time_ns) - longint'(exp_tx.ref_time_ns);

            if (abs_cycle_delta > worst_byte_cycle_delta) begin
                worst_byte_cycle_delta = abs_cycle_delta;
            end
            if (abs_time_delta_ns > worst_byte_time_delta_ns) begin
                worst_byte_time_delta_ns = abs_time_delta_ns;
            end
            if (exp_latency_cycle >= 0) begin
                total_byte_exp_latency_cycles += exp_latency_cycle;
            end
            if (act_latency_cycle >= 0) begin
                total_byte_act_latency_cycles += act_latency_cycle;
            end
            if (exp_latency_time_ns >= 0) begin
                total_byte_exp_latency_ns += longint'(exp_latency_time_ns);
            end
            if (act_latency_time_ns >= 0) begin
                total_byte_act_latency_ns += longint'(act_latency_time_ns);
            end
            total_byte_latency_count++;

            if (exp_tx.byte_value !== act_tx.byte_value) begin
                data_mismatch = 1'b1;
                `uvm_error(get_type_name(),
                    $sformatf("Byte mismatch packet=%0d byte=%0d exp=0x%02h act=0x%02h",
                    exp_tx.packet_id, exp_tx.byte_index, exp_tx.byte_value, act_tx.byte_value))
                mismatch_count++;
            end
            if (timing_out_of_tolerance(abs_cycle_delta, abs_time_delta_ns)) begin
                timing_mismatch = 1'b1;
                `uvm_error(get_type_name(),
                    $sformatf("Byte timing mismatch packet=%0d byte=%0d exp_cycle=%0d act_cycle=%0d delta_cycle=%0d exp_time_ns=%0d act_time_ns=%0d delta_time_ns=%0d tol_cycle=%0d tol_time_ns=%0d",
                    exp_tx.packet_id, exp_tx.byte_index, exp_tx.cycle_id, act_tx.cycle_id,
                    cycle_delta, exp_tx.event_time_ns, act_tx.event_time_ns, time_delta_ns,
                    TIMING_TOL_CYCLES, TIMING_TOL_NS))
                mismatch_count++;
            end
            if (data_mismatch) begin
                fail_byte_data_events++;
            end
            if (timing_mismatch) begin
                fail_byte_timing_events++;
            end

            if (mismatch_count == 0) begin
                pass_byte_events++;
            end else begin
                fail_byte_events++;
            end
        end
    endfunction

    function void compare_ready_packets();
        while ((exp_pkt_q.size() > 0) && (act_pkt_q.size() > 0)) begin
            uartsender_packet_item exp_tx;
            uartsender_packet_item act_tx;
            int                    mismatch_count;
            int                    cycle_delta;
            longint signed         time_delta_ns;
            int                    abs_cycle_delta;
            longint unsigned       abs_time_delta_ns;
            bit                    data_mismatch;
            bit                    timing_mismatch;
            int                    exp_latency_cycle;
            int                    act_latency_cycle;
            longint signed         exp_latency_time_ns;
            longint signed         act_latency_time_ns;

            exp_tx = exp_pkt_q.pop_front();
            act_tx = act_pkt_q.pop_front();
            mismatch_count = 0;
            data_mismatch = 1'b0;
            timing_mismatch = 1'b0;
            cycle_delta = int'(act_tx.cycle_id) - int'(exp_tx.cycle_id);
            time_delta_ns = longint'(act_tx.event_time_ns) - longint'(exp_tx.event_time_ns);
            abs_cycle_delta = (cycle_delta < 0) ? -cycle_delta : cycle_delta;
            abs_time_delta_ns = (time_delta_ns < 0)
                ? longint'(-time_delta_ns) : longint'(time_delta_ns);
            exp_latency_cycle = int'(exp_tx.cycle_id) - int'(exp_tx.ref_cycle_id);
            act_latency_cycle = int'(act_tx.cycle_id) - int'(exp_tx.ref_cycle_id);
            exp_latency_time_ns = longint'(exp_tx.event_time_ns) - longint'(exp_tx.ref_time_ns);
            act_latency_time_ns = longint'(act_tx.event_time_ns) - longint'(exp_tx.ref_time_ns);

            if (abs_cycle_delta > worst_packet_cycle_delta) begin
                worst_packet_cycle_delta = abs_cycle_delta;
            end
            if (abs_time_delta_ns > worst_packet_time_delta_ns) begin
                worst_packet_time_delta_ns = abs_time_delta_ns;
            end
            if (exp_latency_cycle >= 0) begin
                total_packet_exp_latency_cycles += exp_latency_cycle;
            end
            if (act_latency_cycle >= 0) begin
                total_packet_act_latency_cycles += act_latency_cycle;
            end
            if (exp_latency_time_ns >= 0) begin
                total_packet_exp_latency_ns += longint'(exp_latency_time_ns);
            end
            if (act_latency_time_ns >= 0) begin
                total_packet_act_latency_ns += longint'(act_latency_time_ns);
            end
            total_packet_latency_count++;
            total_packet_cycle_delta += cycle_delta;
            total_packet_time_delta_ns += time_delta_ns;
            total_packet_abs_cycles += abs_cycle_delta;
            total_packet_abs_time_ns += abs_time_delta_ns;
            total_packet_delta_count++;
            if (cycle_delta > 0) begin
                total_packet_late_cycles += cycle_delta;
                total_packet_late_count++;
            end
            if (time_delta_ns > 0) begin
                total_packet_late_ns += longint'(time_delta_ns);
            end

            if (exp_tx.byte0 !== act_tx.byte0) mismatch_count++;
            if (exp_tx.byte1 !== act_tx.byte1) mismatch_count++;
            if (exp_tx.byte2 !== act_tx.byte2) mismatch_count++;
            if (exp_tx.byte3 !== act_tx.byte3) mismatch_count++;
            if (exp_tx.byte4 !== act_tx.byte4) mismatch_count++;
            if (exp_tx.byte5 !== act_tx.byte5) mismatch_count++;
            if (timing_out_of_tolerance(abs_cycle_delta, abs_time_delta_ns)) begin
                timing_mismatch = 1'b1;
                `uvm_error(get_type_name(),
                    $sformatf("Packet timing mismatch packet=%0d exp_cycle=%0d act_cycle=%0d delta_cycle=%0d exp_time_ns=%0d act_time_ns=%0d delta_time_ns=%0d tol_cycle=%0d tol_time_ns=%0d",
                    exp_tx.packet_id, exp_tx.cycle_id, act_tx.cycle_id, cycle_delta,
                    exp_tx.event_time_ns, act_tx.event_time_ns, time_delta_ns,
                    TIMING_TOL_CYCLES, TIMING_TOL_NS))
                mismatch_count++;
            end
            if ((exp_tx.byte0 !== act_tx.byte0) || (exp_tx.byte1 !== act_tx.byte1) ||
                (exp_tx.byte2 !== act_tx.byte2) || (exp_tx.byte3 !== act_tx.byte3) ||
                (exp_tx.byte4 !== act_tx.byte4) || (exp_tx.byte5 !== act_tx.byte5)) begin
                data_mismatch = 1'b1;
                `uvm_error(get_type_name(),
                    $sformatf("Packet bytes mismatch packet=%0d exp=[%02h %02h %02h %02h %02h %02h] act=[%02h %02h %02h %02h %02h %02h]",
                    exp_tx.packet_id, exp_tx.byte0, exp_tx.byte1, exp_tx.byte2, exp_tx.byte3,
                    exp_tx.byte4, exp_tx.byte5, act_tx.byte0, act_tx.byte1, act_tx.byte2,
                    act_tx.byte3, act_tx.byte4, act_tx.byte5))
                mismatch_count++;
            end
            if (data_mismatch) begin
                fail_packet_data_events++;
            end
            if (timing_mismatch) begin
                fail_packet_timing_events++;
            end

            `uvm_info(get_type_name(),
                $sformatf("Packet %0d cycle_delta=%0d time_delta_ns=%0d bytes=[%02h %02h %02h %02h %02h %02h]",
                exp_tx.packet_id, cycle_delta, time_delta_ns, exp_tx.byte0, exp_tx.byte1,
                exp_tx.byte2, exp_tx.byte3, exp_tx.byte4, exp_tx.byte5),
                UVM_LOW)

            if (mismatch_count == 0) begin
                pass_packets++;
            end else begin
                fail_packets++;
            end
        end
    endfunction

    function void print_pre_coverage_timing_totals();
        real avg_byte_exp_latency_cycles;
        real avg_byte_exp_latency_ns;
        real avg_byte_act_latency_cycles;
        real avg_byte_act_latency_ns;
        real avg_packet_cycle_delta;
        real avg_packet_time_delta_ns;
        real avg_packet_abs_cycles;
        real avg_packet_abs_time_ns;
        real avg_packet_exp_latency_cycles;
        real avg_packet_exp_latency_ns;
        real avg_packet_act_latency_cycles;
        real avg_packet_act_latency_ns;
        real avg_packet_late_cycles;
        real avg_packet_late_ns;

        if (pre_coverage_summary_printed) begin
            return;
        end
        pre_coverage_summary_printed = 1'b1;
        if (total_byte_latency_count == 0) begin
            avg_byte_exp_latency_cycles = 0.0;
            avg_byte_exp_latency_ns = 0.0;
            avg_byte_act_latency_cycles = 0.0;
            avg_byte_act_latency_ns = 0.0;
        end else begin
            avg_byte_exp_latency_cycles = real'(total_byte_exp_latency_cycles) / real'(total_byte_latency_count);
            avg_byte_exp_latency_ns = real'(total_byte_exp_latency_ns) / real'(total_byte_latency_count);
            avg_byte_act_latency_cycles = real'(total_byte_act_latency_cycles) / real'(total_byte_latency_count);
            avg_byte_act_latency_ns = real'(total_byte_act_latency_ns) / real'(total_byte_latency_count);
        end
        if (total_packet_delta_count == 0) begin
            avg_packet_cycle_delta = 0.0;
            avg_packet_time_delta_ns = 0.0;
            avg_packet_abs_cycles = 0.0;
            avg_packet_abs_time_ns = 0.0;
        end else begin
            avg_packet_cycle_delta = real'(total_packet_cycle_delta) / real'(total_packet_delta_count);
            avg_packet_time_delta_ns = real'(total_packet_time_delta_ns) / real'(total_packet_delta_count);
            avg_packet_abs_cycles = real'(total_packet_abs_cycles) / real'(total_packet_delta_count);
            avg_packet_abs_time_ns = real'(total_packet_abs_time_ns) / real'(total_packet_delta_count);
        end
        if (total_packet_latency_count == 0) begin
            avg_packet_exp_latency_cycles = 0.0;
            avg_packet_exp_latency_ns = 0.0;
            avg_packet_act_latency_cycles = 0.0;
            avg_packet_act_latency_ns = 0.0;
        end else begin
            avg_packet_exp_latency_cycles = real'(total_packet_exp_latency_cycles) / real'(total_packet_latency_count);
            avg_packet_exp_latency_ns = real'(total_packet_exp_latency_ns) / real'(total_packet_latency_count);
            avg_packet_act_latency_cycles = real'(total_packet_act_latency_cycles) / real'(total_packet_latency_count);
            avg_packet_act_latency_ns = real'(total_packet_act_latency_ns) / real'(total_packet_latency_count);
        end
        if (total_packet_late_count == 0) begin
            avg_packet_late_cycles = 0.0;
            avg_packet_late_ns = 0.0;
        end else begin
            avg_packet_late_cycles = real'(total_packet_late_cycles) / real'(total_packet_late_count);
            avg_packet_late_ns = real'(total_packet_late_ns) / real'(total_packet_late_count);
        end

        `uvm_info(get_type_name(), "===== Uartsender Timing Totals (Before Coverage) =====", UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Byte avg golden latency        : cycle=%.3f ns=%.3f evt_cnt=%0d",
            avg_byte_exp_latency_cycles, avg_byte_exp_latency_ns, total_byte_latency_count), UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Byte avg RTL latency           : cycle=%.3f ns=%.3f evt_cnt=%0d",
            avg_byte_act_latency_cycles, avg_byte_act_latency_ns, total_byte_latency_count), UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Packet avg golden latency      : cycle=%.3f ns=%.3f pkt_cnt=%0d",
            avg_packet_exp_latency_cycles, avg_packet_exp_latency_ns, total_packet_latency_count), UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Packet avg RTL latency         : cycle=%.3f ns=%.3f pkt_cnt=%0d",
            avg_packet_act_latency_cycles, avg_packet_act_latency_ns, total_packet_latency_count), UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Final output avg signed delta   : cycle=%.3f ns=%.3f pkt_cnt=%0d",
            avg_packet_cycle_delta, avg_packet_time_delta_ns, total_packet_delta_count), UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Final output avg absolute delta : cycle=%.3f ns=%.3f pkt_cnt=%0d",
            avg_packet_abs_cycles, avg_packet_abs_time_ns, total_packet_delta_count), UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Final output avg RTL-late delay : cycle=%.3f ns=%.3f late_pkt_cnt=%0d",
            avg_packet_late_cycles, avg_packet_late_ns, total_packet_late_count), UVM_LOW)
        `uvm_info(get_type_name(), "======================================================", UVM_LOW)
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if ((exp_byte_q.size() != 0) || (act_byte_q.size() != 0)) begin
            `uvm_error(get_type_name(),
                $sformatf("Unmatched byte events remain exp_q=%0d act_q=%0d", exp_byte_q.size(), act_byte_q.size()))
        end
        if ((exp_pkt_q.size() != 0) || (act_pkt_q.size() != 0)) begin
            `uvm_error(get_type_name(),
                $sformatf("Unmatched packet events remain exp_q=%0d act_q=%0d", exp_pkt_q.size(), act_pkt_q.size()))
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        string result;

        super.report_phase(phase);
        result = ((fail_byte_events == 0) && (fail_packets == 0)) ? "** PASS **" : "** FAIL **";
        `uvm_info(get_type_name(), "******** uartsender summary ********", UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Result                  : %s", result), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Pass byte events        : %0d", pass_byte_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail byte events        : %0d", fail_byte_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail byte data events   : %0d", fail_byte_data_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail byte timing events : %0d", fail_byte_timing_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Pass packets            : %0d", pass_packets), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail packets            : %0d", fail_packets), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail pkt data events    : %0d", fail_packet_data_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail pkt timing events  : %0d", fail_packet_timing_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst byte cycle delta  : %0d", worst_byte_cycle_delta), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst byte time delta   : %0d", worst_byte_time_delta_ns), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst pkt cycle delta   : %0d", worst_packet_cycle_delta), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst pkt time delta    : %0d", worst_packet_time_delta_ns), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Byte timing tolerance   : cycle<=%0d or ns<=%0d",
            TIMING_TOL_CYCLES, TIMING_TOL_NS), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Packet timing tolerance : cycle<=%0d or ns<=%0d",
            TIMING_TOL_CYCLES, TIMING_TOL_NS), UVM_MEDIUM)
        `uvm_info(get_type_name(), "****************************************", UVM_MEDIUM)
    endfunction
endclass

`endif
