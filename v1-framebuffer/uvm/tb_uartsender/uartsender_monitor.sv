`ifndef UARTSENDER_MONITOR_SV
`define UARTSENDER_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_byte_item.sv"
`include "uartsender_packet_item.sv"

class uartsender_monitor extends uvm_monitor;
    `uvm_component_utils(uartsender_monitor)

    uvm_analysis_port #(uartsender_byte_item)   byte_ap;
    uvm_analysis_port #(uartsender_packet_item) packet_ap;
    virtual uartsender_if vif;

    int unsigned observed_packet_count;
    int unsigned observed_byte_count;
    bit [7:0] packet_bytes[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        byte_ap = new("byte_ap", this);
        packet_ap = new("packet_ap", this);
        if (!uvm_config_db#(virtual uartsender_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "monitor failed to get uartsender_if")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        wait (vif.rst == 1'b0);
        `uvm_info(get_type_name(), "Monitoring uart_packet_sender activity", UVM_MEDIUM)

        forever begin
            @(posedge vif.clk);
            sample_cycle();
        end
    endtask

    function void sample_cycle();
        if (vif.tx_start_dbg) begin
            uartsender_byte_item act_tx;

            act_tx = uartsender_byte_item::type_id::create($sformatf("act_b_%0d", observed_byte_count));
            act_tx.packet_id     = observed_packet_count;
            act_tx.byte_index    = packet_bytes.size();
            act_tx.byte_value    = vif.tx_data_dbg;
            act_tx.cycle_id      = vif.cycle_count;
            act_tx.event_time_ns = $time;
            byte_ap.write(act_tx);
            packet_bytes.push_back(vif.tx_data_dbg);
            observed_byte_count++;
        end

        if (vif.tx_done_dbg && (packet_bytes.size() == 6)) begin
            uartsender_packet_item act_pkt;

            act_pkt = uartsender_packet_item::type_id::create($sformatf("act_p_%0d", observed_packet_count));
            act_pkt.packet_id     = observed_packet_count;
            act_pkt.cycle_id      = vif.cycle_count;
            act_pkt.event_time_ns = $time;
            act_pkt.byte0         = packet_bytes[0];
            act_pkt.byte1         = packet_bytes[1];
            act_pkt.byte2         = packet_bytes[2];
            act_pkt.byte3         = packet_bytes[3];
            act_pkt.byte4         = packet_bytes[4];
            act_pkt.byte5         = packet_bytes[5];
            packet_ap.write(act_pkt);
            packet_bytes.delete();
            observed_packet_count++;
        end
    endfunction
endclass

`endif
