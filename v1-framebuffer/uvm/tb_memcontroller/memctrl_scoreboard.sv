`ifndef MEMCTRL_SCOREBOARD_SV
`define MEMCTRL_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "memctrl_seq_item.sv"
`include "memctrl_timing_item.sv"
`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)
`uvm_analysis_imp_decl(_tim_exp)
`uvm_analysis_imp_decl(_tim_act)

class memctrl_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(memctrl_scoreboard)

    localparam int DETAIL_FRAME_COUNT = 3;

    uvm_analysis_imp_exp #(memctrl_seq_item, memctrl_scoreboard) exp_imp;
    uvm_analysis_imp_act #(memctrl_seq_item, memctrl_scoreboard) act_imp;
    uvm_analysis_imp_tim_exp #(memctrl_timing_item, memctrl_scoreboard) tim_exp_imp;
    uvm_analysis_imp_tim_act #(memctrl_timing_item, memctrl_scoreboard) tim_act_imp;

    memctrl_seq_item expected_q[$];
    memctrl_seq_item actual_q[$];
    memctrl_timing_item expected_timing_q[$];
    memctrl_timing_item actual_timing_q[$];

    int unsigned pass_frames;
    int unsigned fail_frames;
    int unsigned total_pixel_mismatches;
    int unsigned pass_timing_events;
    int unsigned fail_timing_events;
    int          worst_cycle_delta;
    longint unsigned worst_time_delta;
    bit              pre_coverage_summary_printed;

    int unsigned      frame_timing_event_count[int unsigned];
    longint signed    frame_cycle_delta_sum[int unsigned];
    longint signed    frame_time_delta_sum_ns[int unsigned];
    int unsigned      frame_max_abs_cycle_delta[int unsigned];
    longint unsigned  frame_max_abs_time_delta_ns[int unsigned];
    int unsigned      frame_we_total_late_cycles[int unsigned];
    longint unsigned  frame_we_total_late_ns[int unsigned];
    int unsigned      frame_waddr_total_late_cycles[int unsigned];
    longint unsigned  frame_waddr_total_late_ns[int unsigned];
    int unsigned      frame_wdata_total_late_cycles[int unsigned];
    longint unsigned  frame_wdata_total_late_ns[int unsigned];

    int unsigned      total_we_late_cycles;
    longint unsigned  total_we_late_ns;
    int unsigned      total_waddr_late_cycles;
    longint unsigned  total_waddr_late_ns;
    int unsigned      total_wdata_late_cycles;
    longint unsigned  total_wdata_late_ns;
    int               detail_fd;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        pass_frames = 0;
        fail_frames = 0;
        total_pixel_mismatches = 0;
        pass_timing_events = 0;
        fail_timing_events = 0;
        worst_cycle_delta = 0;
        worst_time_delta = 0;
        pre_coverage_summary_printed = 0;
        total_we_late_cycles = 0;
        total_we_late_ns = 0;
        total_waddr_late_cycles = 0;
        total_waddr_late_ns = 0;
        total_wdata_late_cycles = 0;
        total_wdata_late_ns = 0;
        detail_fd = 0;
    endfunction
    

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_imp = new("exp_imp", this);
        act_imp = new("act_imp", this);
        tim_exp_imp = new("tim_exp_imp", this);
        tim_act_imp = new("tim_act_imp", this);
        detail_fd = $fopen("timing_compare_first3frames.csv", "w");
        if (detail_fd == 0) begin
            `uvm_warning(get_type_name(), "Failed to open timing_compare_first3frames.csv")
        end else begin
            $fdisplay(detail_fd,
                "frame_id,pixel_index,exp_cycle,act_cycle,delta_cycle,exp_time_ns,act_time_ns,delta_time_ns,exp_we,act_we,exp_waddr,act_waddr,exp_wdata,act_wdata,status");
        end
    endfunction

    function void write_exp(memctrl_seq_item tx);
        expected_q.push_back(tx);
        compare_ready_frames();
    endfunction

    function void write_act(memctrl_seq_item tx);
        actual_q.push_back(tx);
        compare_ready_frames();
    endfunction

    function void write_tim_exp(memctrl_timing_item tx);
        expected_timing_q.push_back(tx);
        compare_ready_timing_events();
    endfunction

    function void write_tim_act(memctrl_timing_item tx);
        actual_timing_q.push_back(tx);
        compare_ready_timing_events();
    endfunction

    function void compare_ready_frames();
        while ((expected_q.size() > 0) && (actual_q.size() > 0)) begin
            memctrl_seq_item exp_tx;
            memctrl_seq_item act_tx;
            int              mismatch_count;

            exp_tx = expected_q.pop_front();
            act_tx = actual_q.pop_front();
            mismatch_count = 0;

            if (exp_tx.frame_id != act_tx.frame_id) begin
                `uvm_error(get_type_name(),
                    $sformatf("Frame ordering mismatch exp=%0d act=%0d", exp_tx.frame_id, act_tx.frame_id))
                mismatch_count++;
            end

            if (exp_tx.pixel_count() != act_tx.pixel_count()) begin
                `uvm_error(get_type_name(),
                    $sformatf("Frame %0d pixel count mismatch exp=%0d act=%0d",
                    exp_tx.frame_id, exp_tx.pixel_count(), act_tx.pixel_count()))
                mismatch_count++;
            end

            if (act_tx.first_byte_we_errors != 0 ||
                act_tx.second_byte_we_errors != 0 ||
                act_tx.href_low_we_errors != 0 ||
                act_tx.vsync_reset_errors != 0 ||
                act_tx.addr_errors != 0) begin
                `uvm_error(get_type_name(),
                    $sformatf("Frame %0d protocol errors first=%0d second=%0d href_low=%0d vsync=%0d addr=%0d",
                    act_tx.frame_id, act_tx.first_byte_we_errors, act_tx.second_byte_we_errors,
                    act_tx.href_low_we_errors, act_tx.vsync_reset_errors, act_tx.addr_errors))
                mismatch_count++;
            end

            for (int i = 0; i < exp_tx.pixel_count() && i < act_tx.pixel_count(); i++) begin
                if (exp_tx.pixels[i] !== act_tx.pixels[i]) begin
                    mismatch_count++;
                    total_pixel_mismatches++;
                    if (mismatch_count <= 10) begin
                        `uvm_error(get_type_name(),
                            $sformatf("Frame %0d pixel[%0d] mismatch exp=0x%04h act=0x%04h",
                            exp_tx.frame_id, i, exp_tx.pixels[i], act_tx.pixels[i]))
                    end
                end
            end

            report_frame_timing_summary(exp_tx);

            if (mismatch_count == 0) begin
                pass_frames++;
                `uvm_info(get_type_name(),
                    $sformatf("PASS frame %0d kind=%s pixels=%0d",
                    exp_tx.frame_id, exp_tx.kind_name(), exp_tx.pixel_count()),
                    UVM_LOW)
            end else begin
                fail_frames++;
                `uvm_error(get_type_name(),
                    $sformatf("FAIL frame %0d kind=%s mismatches=%0d",
                    exp_tx.frame_id, exp_tx.kind_name(), mismatch_count))
            end
        end
    endfunction

    function void compare_ready_timing_events();
        while ((expected_timing_q.size() > 0) && (actual_timing_q.size() > 0)) begin
            memctrl_timing_item exp_tx;
            memctrl_timing_item act_tx;
            int                 mismatch_count;
            int                 cycle_delta;
            int                 abs_cycle_delta;
            longint signed      time_delta;
            longint unsigned    abs_time_delta;

            exp_tx = expected_timing_q.pop_front();
            act_tx = actual_timing_q.pop_front();
            mismatch_count = 0;
            cycle_delta = int'(act_tx.cycle_id) - int'(exp_tx.cycle_id);
            abs_cycle_delta = (cycle_delta < 0) ? -cycle_delta : cycle_delta;
            time_delta = longint'(act_tx.event_time_ns) - longint'(exp_tx.event_time_ns);
            abs_time_delta = (time_delta < 0) ? longint'(-time_delta) : longint'(time_delta);

            if (abs_cycle_delta > worst_cycle_delta) begin
                worst_cycle_delta = abs_cycle_delta;
            end
            if (abs_time_delta > worst_time_delta) begin
                worst_time_delta = abs_time_delta;
            end

            frame_timing_event_count[exp_tx.frame_id]++;
            frame_cycle_delta_sum[exp_tx.frame_id] += cycle_delta;
            frame_time_delta_sum_ns[exp_tx.frame_id] += time_delta;
            if (abs_cycle_delta > frame_max_abs_cycle_delta[exp_tx.frame_id]) begin
                frame_max_abs_cycle_delta[exp_tx.frame_id] = abs_cycle_delta;
            end
            if (abs_time_delta > frame_max_abs_time_delta_ns[exp_tx.frame_id]) begin
                frame_max_abs_time_delta_ns[exp_tx.frame_id] = abs_time_delta;
            end
            if (cycle_delta > 0) begin
                frame_we_total_late_cycles[exp_tx.frame_id] += cycle_delta;
                frame_waddr_total_late_cycles[exp_tx.frame_id] += cycle_delta;
                frame_wdata_total_late_cycles[exp_tx.frame_id] += cycle_delta;
                total_we_late_cycles += cycle_delta;
                total_waddr_late_cycles += cycle_delta;
                total_wdata_late_cycles += cycle_delta;
            end
            if (time_delta > 0) begin
                frame_we_total_late_ns[exp_tx.frame_id] += longint'(time_delta);
                frame_waddr_total_late_ns[exp_tx.frame_id] += longint'(time_delta);
                frame_wdata_total_late_ns[exp_tx.frame_id] += longint'(time_delta);
                total_we_late_ns += longint'(time_delta);
                total_waddr_late_ns += longint'(time_delta);
                total_wdata_late_ns += longint'(time_delta);
            end

            if (exp_tx.event_kind != act_tx.event_kind) begin
                `uvm_error(get_type_name(),
                    $sformatf("Timing event kind mismatch exp=%s act=%s",
                    exp_tx.kind_name(), act_tx.kind_name()))
                mismatch_count++;
            end

            if (exp_tx.frame_id != act_tx.frame_id ||
                exp_tx.pixel_index != act_tx.pixel_index) begin
                `uvm_error(get_type_name(),
                    $sformatf("Timing event ordering mismatch exp(frame=%0d pixel=%0d) act(frame=%0d pixel=%0d)",
                    exp_tx.frame_id, exp_tx.pixel_index, act_tx.frame_id, act_tx.pixel_index))
                mismatch_count++;
            end

            if (cycle_delta != 0) begin
                `uvm_error(get_type_name(),
                    $sformatf("Timing cycle mismatch frame=%0d pixel=%0d exp_cycle=%0d act_cycle=%0d delta_cycle=%0d exp_time=%0t act_time=%0t delta_time=%0t",
                    exp_tx.frame_id, exp_tx.pixel_index, exp_tx.cycle_id, act_tx.cycle_id, cycle_delta,
                    exp_tx.event_time_ns, act_tx.event_time_ns, time_delta))
                mismatch_count++;
            end

            if (time_delta != 0) begin
                `uvm_error(get_type_name(),
                    $sformatf("Timing time mismatch frame=%0d pixel=%0d exp_time=%0t act_time=%0t delta_time=%0t",
                    exp_tx.frame_id, exp_tx.pixel_index, exp_tx.event_time_ns, act_tx.event_time_ns, time_delta))
                mismatch_count++;
            end

            if (exp_tx.we !== act_tx.we) begin
                `uvm_error(get_type_name(),
                    $sformatf("Timing WE mismatch frame=%0d pixel=%0d exp=%0b act=%0b",
                    exp_tx.frame_id, exp_tx.pixel_index, exp_tx.we, act_tx.we))
                mismatch_count++;
            end

            if (exp_tx.waddr != act_tx.waddr) begin
                `uvm_error(get_type_name(),
                    $sformatf("Timing WADDR mismatch frame=%0d pixel=%0d exp=%0d act=%0d",
                    exp_tx.frame_id, exp_tx.pixel_index, exp_tx.waddr, act_tx.waddr))
                mismatch_count++;
            end

            if (exp_tx.wdata !== act_tx.wdata) begin
                `uvm_error(get_type_name(),
                    $sformatf("Timing WDATA mismatch frame=%0d pixel=%0d exp=0x%04h act=0x%04h",
                    exp_tx.frame_id, exp_tx.pixel_index, exp_tx.wdata, act_tx.wdata))
                mismatch_count++;
            end

            if ((detail_fd != 0) && (exp_tx.frame_id < DETAIL_FRAME_COUNT)) begin
                string detail_status;

                detail_status = (mismatch_count == 0) ? "PASS" : "FAIL";
                $fdisplay(detail_fd,
                    "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0b,%0b,%0d,%0d,0x%04h,0x%04h,%s",
                    exp_tx.frame_id,
                    exp_tx.pixel_index,
                    exp_tx.cycle_id,
                    act_tx.cycle_id,
                    cycle_delta,
                    exp_tx.event_time_ns,
                    act_tx.event_time_ns,
                    time_delta,
                    exp_tx.we,
                    act_tx.we,
                    exp_tx.waddr,
                    act_tx.waddr,
                    exp_tx.wdata,
                    act_tx.wdata,
                    detail_status);
            end

            if (mismatch_count == 0) begin
                pass_timing_events++;
            end else begin
                fail_timing_events++;
            end
        end
    endfunction

    function void report_frame_timing_summary(memctrl_seq_item frame_tx);
        int unsigned   event_count;
        real           avg_cycle_delta;
        real           avg_time_delta_ns;
        int unsigned   frame_id;

        frame_id = frame_tx.frame_id;
        event_count = frame_timing_event_count.exists(frame_id) ? frame_timing_event_count[frame_id] : 0;

        if (event_count == 0) begin
            `uvm_info(get_type_name(),
                $sformatf("Timing frame %0d kind=%s has no write timing events",
                frame_id, frame_tx.kind_name()),
                UVM_LOW)
            return;
        end

        avg_cycle_delta = real'(frame_cycle_delta_sum[frame_id]) / real'(event_count);
        avg_time_delta_ns = real'(frame_time_delta_sum_ns[frame_id]) / real'(event_count);

        `uvm_info(get_type_name(),
            $sformatf("Timing frame %0d kind=%s events=%0d avg_cycle_delta=%.3f avg_time_delta_ns=%.3f max_abs_cycle_delta=%0d max_abs_time_delta_ns=%0d",
            frame_id, frame_tx.kind_name(), event_count, avg_cycle_delta, avg_time_delta_ns,
            frame_max_abs_cycle_delta[frame_id], frame_max_abs_time_delta_ns[frame_id]),
            UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("  WE    late_vs_golden : total_cycle=%0d total_ns=%0d",
            frame_we_total_late_cycles[frame_id], frame_we_total_late_ns[frame_id]),
            UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("  WADDR late_vs_golden : total_cycle=%0d total_ns=%0d",
            frame_waddr_total_late_cycles[frame_id], frame_waddr_total_late_ns[frame_id]),
            UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("  WDATA late_vs_golden : total_cycle=%0d total_ns=%0d",
            frame_wdata_total_late_cycles[frame_id], frame_wdata_total_late_ns[frame_id]),
            UVM_LOW)
    endfunction

    function void print_pre_coverage_timing_totals();
        if (pre_coverage_summary_printed) begin
            return;
        end

        pre_coverage_summary_printed = 1'b1;
        `uvm_info(get_type_name(), "===== RTL Delay vs Golden (Before Coverage) =====", UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("WE total RTL-late delay    : cycle=%0d ns=%0d",
            total_we_late_cycles, total_we_late_ns),
            UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("WADDR total RTL-late delay : cycle=%0d ns=%0d",
            total_waddr_late_cycles, total_waddr_late_ns),
            UVM_LOW)
        `uvm_info(get_type_name(),
            $sformatf("WDATA total RTL-late delay : cycle=%0d ns=%0d",
            total_wdata_late_cycles, total_wdata_late_ns),
            UVM_LOW)
        `uvm_info(get_type_name(), "===============================================", UVM_LOW)
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if ((expected_q.size() != 0) || (actual_q.size() != 0)) begin
            `uvm_error(get_type_name(),
                $sformatf("Unmatched frames remain exp_q=%0d act_q=%0d", expected_q.size(), actual_q.size()))
        end
        if ((expected_timing_q.size() != 0) || (actual_timing_q.size() != 0)) begin
            `uvm_error(get_type_name(),
                $sformatf("Unmatched timing events remain exp_q=%0d act_q=%0d",
                expected_timing_q.size(), actual_timing_q.size()))
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        string result;

        super.report_phase(phase);
        result = ((fail_frames == 0) && (fail_timing_events == 0)) ? "** PASS **" : "** FAIL **";

        `uvm_info(get_type_name(), "******** memcontroller summary ********", UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Result              : %s", result), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Pass frames         : %0d", pass_frames), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail frames         : %0d", fail_frames), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Pixel mismatches    : %0d", total_pixel_mismatches), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Pass timing events  : %0d", pass_timing_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Fail timing events  : %0d", fail_timing_events), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst cycle delta   : %0d", worst_cycle_delta), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Worst time delta    : %0d", worst_time_delta), UVM_MEDIUM)
        `uvm_info(get_type_name(),
            $sformatf("Detail compare CSV  : timing_compare_first3frames.csv (frames 0 to %0d)",
            DETAIL_FRAME_COUNT - 1),
            UVM_MEDIUM)
        `uvm_info(get_type_name(), "****************************************", UVM_MEDIUM)

        if (detail_fd != 0) begin
            $fclose(detail_fd);
            detail_fd = 0;
        end
    endfunction
endclass

`endif
