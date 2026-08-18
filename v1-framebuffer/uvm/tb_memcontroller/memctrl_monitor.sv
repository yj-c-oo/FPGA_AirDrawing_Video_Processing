`ifndef MEMCTRL_MONITOR_SV
`define MEMCTRL_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "memctrl_seq_item.sv"
`include "memctrl_timing_item.sv"

class memctrl_monitor extends uvm_monitor;
    `uvm_component_utils(memctrl_monitor)

    uvm_analysis_port #(memctrl_seq_item) ap;
    uvm_analysis_port #(memctrl_timing_item) timing_ap;
    virtual memctrl_if vif;

    memctrl_seq_item current_frame;
    int unsigned     frame_index;
    bit              byte_phase;
    logic [7:0]      high_byte;
    bit              seen_frame_start;
    bit              prev_vsync;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        timing_ap = new("timing_ap", this);
        if (!uvm_config_db#(virtual memctrl_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "monitor failed to get memctrl_if")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        wait (vif.reset == 1'b0);
        `uvm_info(get_type_name(), "Monitoring memcontroller frames", UVM_MEDIUM)

        forever begin
            @(vif.mon_cb);
            sample_cycle();
        end
    endtask

    function void start_new_frame();
        current_frame = memctrl_seq_item::type_id::create($sformatf("act_frame_%0d", frame_index));
        current_frame.frame_id   = frame_index;
        current_frame.frame_kind = FRAME_RANDOM;
        current_frame.pixel_seed = 32'd0;
        frame_index++;
        byte_phase       = 1'b0;
        seen_frame_start = 1'b1;
    endfunction

    function void flush_current_frame();
        if ((current_frame != null) && (current_frame.pixel_count() > 0 ||
            current_frame.first_byte_we_errors  > 0 ||
            current_frame.second_byte_we_errors > 0 ||
            current_frame.href_low_we_errors    > 0 ||
            current_frame.vsync_reset_errors    > 0 ||
            current_frame.addr_errors           > 0)) begin
            ap.write(current_frame);
            `uvm_info(get_type_name(), $sformatf("Captured %s", current_frame.convert2string()), UVM_LOW)
        end
    endfunction

    function void sample_cycle();
        if (vif.mon_cb.vsync) begin
            if (!prev_vsync) begin
                if (current_frame != null) begin
                    flush_current_frame();
                end
                start_new_frame();
            end

            if (current_frame != null) begin
                if (vif.mon_cb.we !== 1'b0) begin
                    current_frame.vsync_reset_errors++;
                end
                if (vif.mon_cb.waddr !== '0) begin
                    current_frame.vsync_reset_errors++;
                end
            end

            prev_vsync = 1'b1;
            return;
        end

        prev_vsync = 1'b0;

        if (!seen_frame_start || (current_frame == null)) begin
            return;
        end

        if (vif.mon_cb.href) begin
            if (!byte_phase) begin
                high_byte = vif.mon_cb.pdata;
                if (vif.mon_cb.we !== 1'b0) begin
                    current_frame.first_byte_we_errors++;
                end
                byte_phase = 1'b1;
            end else begin
                if (vif.mon_cb.we !== 1'b1) begin
                    current_frame.second_byte_we_errors++;
                end else begin
                    memctrl_timing_item act_timing;

                    if (vif.mon_cb.waddr !== current_frame.pixel_count()) begin
                        current_frame.addr_errors++;
                    end
                    act_timing = memctrl_timing_item::type_id::create(
                        $sformatf("act_timing_f%0d_p%0d",
                        current_frame.frame_id, current_frame.pixel_count())
                    );
                    act_timing.event_kind  = TIMING_EVT_WRITE;
                    act_timing.frame_id    = current_frame.frame_id;
                    act_timing.pixel_index = current_frame.pixel_count();
                    act_timing.cycle_id    = vif.cycle_count;
                    act_timing.event_time_ns = $time;
                    act_timing.we          = vif.mon_cb.we;
                    act_timing.waddr       = vif.mon_cb.waddr;
                    act_timing.wdata       = vif.mon_cb.wdata;
                    timing_ap.write(act_timing);
                    current_frame.pixels.push_back(vif.mon_cb.wdata);
                end
                byte_phase = 1'b0;
            end
        end else begin
            if (vif.mon_cb.we !== 1'b0) begin
                current_frame.href_low_we_errors++;
            end
            byte_phase = 1'b0;
        end
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if ((current_frame != null) && !vif.vsync) begin
            flush_current_frame();
        end
    endfunction
endclass

`endif
