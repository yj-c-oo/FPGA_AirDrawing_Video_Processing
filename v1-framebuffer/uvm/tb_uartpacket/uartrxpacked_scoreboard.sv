`ifndef UARTRXPACKED_SCOREBOARD_SV
`define UARTRXPACKED_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartrxpacked_byte_item.sv"
`include "uartrxpacked_packet_item.sv"
`uvm_analysis_imp_decl(_byte_exp)
`uvm_analysis_imp_decl(_byte_act)
`uvm_analysis_imp_decl(_pkt_exp)
`uvm_analysis_imp_decl(_pkt_act)

class uartrxpacked_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uartrxpacked_scoreboard)

    localparam int BYTE_TIMING_TOL_CYCLES   = 55;
    localparam int BYTE_TIMING_TOL_NS       = 550;
    localparam int PACKET_TIMING_TOL_CYCLES = 60;
    localparam int PACKET_TIMING_TOL_NS     = 600;

    uvm_analysis_imp_byte_exp #(uartrxpacked_byte_item, uartrxpacked_scoreboard) byte_exp_imp;
    uvm_analysis_imp_byte_act #(uartrxpacked_byte_item, uartrxpacked_scoreboard) byte_act_imp;
    uvm_analysis_imp_pkt_exp #(uartrxpacked_packet_item, uartrxpacked_scoreboard) pkt_exp_imp;
    uvm_analysis_imp_pkt_act #(uartrxpacked_packet_item, uartrxpacked_scoreboard) pkt_act_imp;

    uartrxpacked_byte_item   exp_byte_q[$];
    uartrxpacked_byte_item   act_byte_q[$];
    uartrxpacked_packet_item exp_pkt_q[$];
    uartrxpacked_packet_item act_pkt_q[$];

    int unsigned      pass_byte_events;
    int unsigned      fail_byte_events;
    int unsigned      pass_packets;
    int unsigned      fail_packets;
    int               worst_byte_cycle_delta;
    int               worst_packet_cycle_delta;
    longint unsigned  worst_byte_time_delta_ns;
    longint unsigned  worst_packet_time_delta_ns;
    bit               pre_coverage_summary_printed;

    int unsigned      byte_count_by_packet[int unsigned];
    longint signed    byte_cycle_sum_by_packet[int unsigned];
    longint signed    byte_time_sum_by_packet_ns[int unsigned];
    int unsigned      byte_max_abs_cycle_by_packet[int unsigned];
    longint unsigned  byte_max_abs_time_by_packet_ns[int unsigned];
    int unsigned      total_byte_late_cycles;
    longint unsigned  total_byte_late_ns;
    int unsigned      total_packet_late_cycles;
    longint unsigned  total_packet_late_ns;
    int unsigned      total_packet_late_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        pass_byte_events = 0;
        fail_byte_events = 0;
        pass_packets = 0;
        fail_packets = 0;
        worst_byte_cycle_delta = 0;
        worst_packet_cycle_delta = 0;
        worst_byte_time_delta_ns = 0;
        worst_packet_time_delta_ns = 0;
        pre_coverage_summary_printed = 0;
        total_byte_late_cycles = 0;
        total_byte_late_ns = 0;
        total_packet_late_cycles = 0;
        total_packet_late_ns = 0;
        total_packet_late_count = 0;
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        byte_exp_imp = new("byte_exp_imp", this);
        byte_act_imp = new("byte_act_imp", this);
        pkt_exp_imp  = new("pkt_exp_imp", this);
        pkt_act_imp  = new("pkt_act_imp", this);
    endfunction

    function string scenario_name(uartrxpacked_scenario_e scenario);
        case (scenario)
            SCN_RESET_IDLE:     return "RESET_IDLE";
            SCN_VALID_PACKET:   return "VALID_PACKET";
            SCN_CONTROL_DECODE: return "CONTROL_DECODE";
            SCN_SHAPE_DECODE:   return "SHAPE_DECODE";
            SCN_WRONG_START:    return "WRONG_START";
            SCN_WRONG_END:      return "WRONG_END";
            SCN_TIMEOUT:        return "TIMEOUT";
            SCN_BACK_TO_BACK:   return "BACK_TO_BACK";
            SCN_CLEAR_PULSE:    return "CLEAR_PULSE";
            SCN_RANDOM_STRESS:  return "RANDOM_STRESS";
            default:            return "UNKNOWN";
        endcase
    endfunction

    function void write_byte_exp(uartrxpacked_byte_item tx);
        exp_byte_q.push_back(tx);
        compare_ready_bytes();
    endfunction

    function void write_byte_act(uartrxpacked_byte_item tx);
        act_byte_q.push_back(tx);
        compare_ready_bytes();
    endfunction

    function void write_pkt_exp(uartrxpacked_packet_item tx);
        exp_pkt_q.push_back(tx);
        compare_ready_packets();
    endfunction

    function void write_pkt_act(uartrxpacked_packet_item tx);
        act_pkt_q.push_back(tx);
        compare_ready_packets();
    endfunction

    function bit timing_out_of_tolerance(
        int              abs_cycle_delta,
        longint unsigned abs_time_delta_ns,
        int              tol_cycles,
        int              tol_ns
    );
        return (abs_cycle_delta > tol_cycles) && (abs_time_delta_ns > longint'(tol_ns));
    endfunction

    function void compare_ready_bytes();
        while ((exp_byte_q.size() > 0) && (act_byte_q.size() > 0)) begin
            uartrxpacked_byte_item exp_tx;
            uartrxpacked_byte_item act_tx;
            int                    mismatch_count;
            int                    cycle_delta;
            int                    abs_cycle_delta;
            longint signed         time_delta_ns;
            longint unsigned       abs_time_delta_ns;

            exp_tx = exp_byte_q.pop_front();
            act_tx = act_byte_q.pop_front();
            mismatch_count = 0;
            cycle_delta = int'(act_tx.cycle_id) - int'(exp_tx.cycle_id);
            abs_cycle_delta = (cycle_delta < 0) ? -cycle_delta : cycle_delta;
            time_delta_ns = longint'(act_tx.event_time_ns) - longint'(exp_tx.event_time_ns);
            abs_time_delta_ns = (time_delta_ns < 0)
                ? longint'(-time_delta_ns) : longint'(time_delta_ns);

            byte_count_by_packet[exp_tx.packet_id]++;
            byte_cycle_sum_by_packet[exp_tx.packet_id] += cycle_delta;
            byte_time_sum_by_packet_ns[exp_tx.packet_id] += time_delta_ns;

            if (abs_cycle_delta > byte_max_abs_cycle_by_packet[exp_tx.packet_id]) begin
                byte_max_abs_cycle_by_packet[exp_tx.packet_id] = abs_cycle_delta;
            end
            if (abs_time_delta_ns > byte_max_abs_time_by_packet_ns[exp_tx.packet_id]) begin
                byte_max_abs_time_by_packet_ns[exp_tx.packet_id] = abs_time_delta_ns;
            end
            if (abs_cycle_delta > worst_byte_cycle_delta) begin
                worst_byte_cycle_delta = abs_cycle_delta;
            end
            if (abs_time_delta_ns > worst_byte_time_delta_ns) begin
                worst_byte_time_delta_ns = abs_time_delta_ns;
            end
            if (cycle_delta > 0) begin
                total_byte_late_cycles += cycle_delta;
            end
            if (time_delta_ns > 0) begin
                total_byte_late_ns += longint'(time_delta_ns);
            end

            if (exp_tx.byte_value !== act_tx.byte_value) begin
                `uvm_error(get_type_name(),
                    $sformatf("Byte mismatch packet=%0d byte=%0d exp=0x%02h act=0x%02h",
                    exp_tx.packet_id, exp_tx.byte_index, exp_tx.byte_value, act_tx.byte_value))
                mismatch_count++;
            end
            if (timing_out_of_tolerance(
                abs_cycle_delta,
                abs_time_delta_ns,
                BYTE_TIMING_TOL_CYCLES,
                BYTE_TIMING_TOL_NS
            )) begin
                `uvm_error(get_type_name(),
                    $sformatf("Byte timing mismatch packet=%0d byte=%0d exp_cycle=%0d act_cycle=%0d delta_cycle=%0d exp_time_ns=%0d act_time_ns=%0d delta_time_ns=%0d tol_cycle=%0d tol_time_ns=%0d",
                    exp_tx.packet_id, exp_tx.byte_index, exp_tx.cycle_id, act_tx.cycle_id,
                    cycle_delta, exp_tx.event_time_ns, act_tx.event_time_ns, time_delta_ns,
                    BYTE_TIMING_TOL_CYCLES, BYTE_TIMING_TOL_NS))
                mismatch_count++;
            end
            if (mismatch_count == 0) begin
                pass_byte_events++;
            end else begin
                fail_byte_events++;
            end
        end
    endfunction

    function void print_packet_timing_summary(
        uartrxpacked_packet_item exp_tx,
        int                      cycle_delta,
        longint signed           time_delta_ns
    );
        int unsigned byte_count;
        real         avg_byte_cycle_delta;
        real         avg_byte_time_delta_ns;

        byte_count = byte_count_by_packet.exists(exp_tx.packet_id) ? byte_count_by_packet[exp_tx.packet_id] : 0;
        if (byte_count == 0) begin
            avg_byte_cycle_delta = 0.0;
            avg_byte_time_delta_ns = 0.0;
        end else begin
            avg_byte_cycle_delta =
                real'(byte_cycle_sum_by_packet[exp_tx.packet_id]) / real'(byte_count);
            avg_byte_time_delta_ns =
                real'(byte_time_sum_by_packet_ns[exp_tx.packet_id]) / real'(byte_count);
        end

        `uvm_info(get_type_name(),
            $sformatf("Packet %0d scenario=%s byte_cnt=%0d byte_avg_cycle_delta=%.3f byte_avg_time_delta_ns=%.3f byte_max_abs_cycle_delta=%0d byte_max_abs_time_delta_ns=%0d final_cycle_delta=%0d final_time_delta_ns=%0d",
            exp_tx.packet_id, scenario_name(exp_tx.scenario), byte_count,
            avg_byte_cycle_delta, avg_byte_time_delta_ns,
            byte_max_abs_cycle_by_packet[exp_tx.packet_id],
            byte_max_abs_time_by_packet_ns[exp_tx.packet_id],
            cycle_delta, time_delta_ns),
            UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("  outputs: valid=%0b clear=%0b pen_color=%03b eraser=%0b size=%0b texture_en=%0b shape=%0d paper=%0b",
            exp_tx.packet_valid, exp_tx.clear_pulse, exp_tx.pen_color, exp_tx.eraser,
            exp_tx.size, exp_tx.texture_enable, exp_tx.texture_shape, exp_tx.paper),
            UVM_LOW)
    endfunction

    function void compare_ready_packets();
        while ((exp_pkt_q.size() > 0) && (act_pkt_q.size() > 0)) begin
            uartrxpacked_packet_item exp_tx;
            uartrxpacked_packet_item act_tx;
            int                      mismatch_count;
            int                      cycle_delta;
            int                      abs_cycle_delta;
            longint signed           time_delta_ns;
            longint unsigned         abs_time_delta_ns;

            exp_tx = exp_pkt_q.pop_front();
            act_tx = act_pkt_q.pop_front();
            mismatch_count = 0;
            cycle_delta = int'(act_tx.cycle_id) - int'(exp_tx.cycle_id);
            abs_cycle_delta = (cycle_delta < 0) ? -cycle_delta : cycle_delta;
            time_delta_ns = longint'(act_tx.event_time_ns) - longint'(exp_tx.event_time_ns);
            abs_time_delta_ns = (time_delta_ns < 0)
                ? longint'(-time_delta_ns) : longint'(time_delta_ns);

            if (abs_cycle_delta > worst_packet_cycle_delta) begin
                worst_packet_cycle_delta = abs_cycle_delta;
            end
            if (abs_time_delta_ns > worst_packet_time_delta_ns) begin
                worst_packet_time_delta_ns = abs_time_delta_ns;
            end
            if (cycle_delta > 0) begin
                total_packet_late_cycles += cycle_delta;
                total_packet_late_count++;
            end
            if (time_delta_ns > 0) begin
                total_packet_late_ns += longint'(time_delta_ns);
            end

            if (exp_tx.packet_valid !== act_tx.packet_valid) begin
                `uvm_error(get_type_name(),
                    $sformatf("Packet valid mismatch packet=%0d exp=%0b act=%0b",
                    exp_tx.packet_id, exp_tx.packet_valid, act_tx.packet_valid))
                mismatch_count++;
            end
            if (exp_tx.clear_pulse !== act_tx.clear_pulse) begin
                `uvm_error(get_type_name(),
                    $sformatf("Clear pulse mismatch packet=%0d exp=%0b act=%0b",
                    exp_tx.packet_id, exp_tx.clear_pulse, act_tx.clear_pulse))
                mismatch_count++;
            end
            if (exp_tx.pen_color !== act_tx.pen_color) begin
                `uvm_error(get_type_name(),
                    $sformatf("Pen color mismatch packet=%0d exp=%03b act=%03b",
                    exp_tx.packet_id, exp_tx.pen_color, act_tx.pen_color))
                mismatch_count++;
            end
            if (exp_tx.eraser !== act_tx.eraser) begin
                `uvm_error(get_type_name(),
                    $sformatf("Eraser mismatch packet=%0d exp=%0b act=%0b",
                    exp_tx.packet_id, exp_tx.eraser, act_tx.eraser))
                mismatch_count++;
            end
            if (exp_tx.size !== act_tx.size) begin
                `uvm_error(get_type_name(),
                    $sformatf("Size mismatch packet=%0d exp=%0b act=%0b",
                    exp_tx.packet_id, exp_tx.size, act_tx.size))
                mismatch_count++;
            end
            if (exp_tx.texture_enable !== act_tx.texture_enable) begin
                `uvm_error(get_type_name(),
                    $sformatf("Texture enable mismatch packet=%0d exp=%0b act=%0b",
                    exp_tx.packet_id, exp_tx.texture_enable, act_tx.texture_enable))
                mismatch_count++;
            end
            if (exp_tx.texture_shape !== act_tx.texture_shape) begin
                `uvm_error(get_type_name(),
                    $sformatf("Texture shape mismatch packet=%0d exp=%0d act=%0d",
                    exp_tx.packet_id, exp_tx.texture_shape, act_tx.texture_shape))
                mismatch_count++;
            end
            if (exp_tx.paper !== act_tx.paper) begin
                `uvm_error(get_type_name(),
                    $sformatf("Paper mismatch packet=%0d exp=%0b act=%0b",
                    exp_tx.packet_id, exp_tx.paper, act_tx.paper))
                mismatch_count++;
            end
            if (timing_out_of_tolerance(
                abs_cycle_delta,
                abs_time_delta_ns,
                PACKET_TIMING_TOL_CYCLES,
                PACKET_TIMING_TOL_NS
            )) begin
                `uvm_error(get_type_name(),
                    $sformatf("Packet timing mismatch packet=%0d exp_cycle=%0d act_cycle=%0d delta_cycle=%0d exp_time_ns=%0d act_time_ns=%0d delta_time_ns=%0d tol_cycle=%0d tol_time_ns=%0d",
                    exp_tx.packet_id, exp_tx.cycle_id, act_tx.cycle_id, cycle_delta,
                    exp_tx.event_time_ns, act_tx.event_time_ns, time_delta_ns,
                    PACKET_TIMING_TOL_CYCLES, PACKET_TIMING_TOL_NS))
                mismatch_count++;
            end

            print_packet_timing_summary(exp_tx, cycle_delta, time_delta_ns);

            if (mismatch_count == 0) begin
                pass_packets++;
            end else begin
                fail_packets++;
            end
        end
    endfunction

    function void print_pre_coverage_timing_totals();
        real avg_packet_late_cycles;
        real avg_packet_late_ns;

        if (pre_coverage_summary_printed) begin
            return;
        end

        pre_coverage_summary_printed = 1'b1;
        if (total_packet_late_count == 0) begin
            avg_packet_late_cycles = 0.0;
            avg_packet_late_ns = 0.0;
        end else begin
            avg_packet_late_cycles =
                real'(total_packet_late_cycles) / real'(total_packet_late_count);
            avg_packet_late_ns =
                real'(total_packet_late_ns) / real'(total_packet_late_count);
        end

        `uvm_info(get_type_name(), "===== UART RX Packed Timing Totals (Before Coverage) =====", UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Byte event total RTL-late delay   : cycle=%0d ns=%0d",
            total_byte_late_cycles, total_byte_late_ns),
            UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("Final output avg RTL-late delay   : cycle=%.3f ns=%.3f late_pkt_cnt=%0d",
            avg_packet_late_cycles, avg_packet_late_ns, total_packet_late_count),
            UVM_LOW)
        `uvm_info(get_type_name(), "=========================================================", UVM_LOW)
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if ((exp_byte_q.size() != 0) || (act_byte_q.size() != 0)) begin
            `uvm_error(get_type_name(),
                $sformatf("Unmatched byte events remain exp_q=%0d act_q=%0d",
                exp_byte_q.size(), act_byte_q.size()))
        end
        if ((exp_pkt_q.size() != 0) || (act_pkt_q.size() != 0)) begin
            `uvm_error(get_type_name(),
                $sformatf("Unmatched packet events remain exp_q=%0d act_q=%0d",
                exp_pkt_q.size(), act_pkt_q.size()))
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        string result;

        super.report_phase(phase);
        result = ((fail_byte_events == 0) && (fail_packets == 0)) ? "** PASS **" : "** FAIL **";

        `uvm_info(get_type_name(), "******** uartrxpacked summary ********", UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Result                  : %s", result), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Pass byte events        : %0d", pass_byte_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail byte events        : %0d", fail_byte_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Pass packets            : %0d", pass_packets), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail packets            : %0d", fail_packets), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst byte cycle delta  : %0d", worst_byte_cycle_delta), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst byte time delta   : %0d", worst_byte_time_delta_ns), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst pkt cycle delta   : %0d", worst_packet_cycle_delta), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst pkt time delta    : %0d", worst_packet_time_delta_ns), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Byte timing tolerance   : cycle<=%0d or ns<=%0d",
            BYTE_TIMING_TOL_CYCLES, BYTE_TIMING_TOL_NS), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Packet timing tolerance : cycle<=%0d or ns<=%0d",
            PACKET_TIMING_TOL_CYCLES, PACKET_TIMING_TOL_NS), UVM_MEDIUM)
        `uvm_info(get_type_name(), "****************************************", UVM_MEDIUM)
    endfunction
endclass

`endif
