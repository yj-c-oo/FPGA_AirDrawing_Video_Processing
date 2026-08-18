`ifndef UARTRXPACKED_MONITOR_SV
`define UARTRXPACKED_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartrxpacked_byte_item.sv"
`include "uartrxpacked_packet_item.sv"

class uartrxpacked_monitor extends uvm_monitor;
    `uvm_component_utils(uartrxpacked_monitor)

    uvm_analysis_port #(uartrxpacked_byte_item)   byte_ap;
    uvm_analysis_port #(uartrxpacked_packet_item) packet_ap;
    virtual uartrxpacked_if vif;

    int unsigned observed_byte_count;
    int unsigned observed_packet_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        byte_ap   = new("byte_ap", this);
        packet_ap = new("packet_ap", this);
        if (!uvm_config_db#(virtual uartrxpacked_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "monitor failed to get uartrxpacked_if")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        wait (vif.rst == 1'b0);
        `uvm_info(get_type_name(), "Monitoring UART RX packet decoder activity", UVM_MEDIUM)

        forever begin
            @(vif.mon_cb);
            sample_cycle();
        end
    endtask

    function void sample_cycle();
        if (vif.mon_cb.rx_done_dbg) begin
            uartrxpacked_byte_item act_byte;

            act_byte = uartrxpacked_byte_item::type_id::create(
                $sformatf("act_byte_%0d", observed_byte_count)
            );
            act_byte.packet_id     = 0;
            act_byte.byte_index    = observed_byte_count;
            act_byte.byte_value    = vif.mon_cb.rx_data_dbg;
            act_byte.cycle_id      = vif.mon_cb.cycle_count;
            act_byte.event_time_ns = $time;
            byte_ap.write(act_byte);
            observed_byte_count++;
        end

        if (vif.mon_cb.o_packet_valid || vif.mon_cb.o_clear_pulse) begin
            uartrxpacked_packet_item act_pkt;

            act_pkt = uartrxpacked_packet_item::type_id::create(
                $sformatf("act_pkt_%0d", observed_packet_count)
            );
            act_pkt.packet_id       = observed_packet_count;
            act_pkt.cycle_id        = vif.mon_cb.cycle_count;
            act_pkt.event_time_ns   = $time;
            act_pkt.packet_valid    = vif.mon_cb.o_packet_valid;
            act_pkt.clear_pulse     = vif.mon_cb.o_clear_pulse;
            act_pkt.pen_color       = vif.mon_cb.o_pen_color;
            act_pkt.eraser          = vif.mon_cb.o_eraser;
            act_pkt.size            = vif.mon_cb.o_size;
            act_pkt.texture_enable  = vif.mon_cb.o_texture_enable;
            act_pkt.texture_shape   = vif.mon_cb.o_texture_shape;
            act_pkt.paper           = vif.mon_cb.o_paper;
            packet_ap.write(act_pkt);
            observed_packet_count++;
        end
    endfunction
endclass

`endif
