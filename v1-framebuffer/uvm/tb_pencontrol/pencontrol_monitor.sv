`ifndef PENCONTROL_MONITOR_SV
`define PENCONTROL_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "pencontrol_packet_item.sv"

class pencontrol_monitor extends uvm_monitor;
    `uvm_component_utils(pencontrol_monitor)

    uvm_analysis_port #(pencontrol_packet_item) act_ap;
    virtual pencontrol_if vif;

    bit sampled_once;
    bit [2:0] prev_pen_color;
    bit       prev_eraser;
    bit       prev_size;
    bit       prev_texture_enable;
    bit [2:0] prev_texture_shape;
    bit       prev_paper;
    bit       prev_clear;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        act_ap = new("act_ap", this);
        if (!uvm_config_db#(virtual pencontrol_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "monitor failed to get pencontrol_if")
        end
    endfunction

    function void emit_actual_snapshot();
        pencontrol_packet_item act_tx;

        act_tx = pencontrol_packet_item::type_id::create($sformatf("act_%0d", vif.cycle_count));
        act_tx.item_id         = 0;
        act_tx.cycle_id        = vif.cycle_count;
        act_tx.event_time_ns   = $time;
        act_tx.pen_color       = vif.o_pen_color;
        act_tx.eraser          = vif.o_eraser;
        act_tx.size            = vif.o_size;
        act_tx.texture_enable  = vif.o_texture_enable;
        act_tx.texture_shape   = vif.o_texture_shape;
        act_tx.paper           = vif.o_paper;
        act_tx.clear           = vif.o_clear;
        act_ap.write(act_tx);
    endfunction

    virtual task run_phase(uvm_phase phase);
        wait (vif.rst == 1'b0);
        `uvm_info(get_type_name(), "Monitoring pen_config_controller outputs", UVM_MEDIUM)

        forever begin
            @(posedge vif.clk);
            if (!sampled_once) begin
                sampled_once = 1'b1;
                emit_actual_snapshot();
            end else if (
                (prev_pen_color      != vif.o_pen_color)      ||
                (prev_eraser         != vif.o_eraser)         ||
                (prev_size           != vif.o_size)           ||
                (prev_texture_enable != vif.o_texture_enable) ||
                (prev_texture_shape  != vif.o_texture_shape)  ||
                (prev_paper          != vif.o_paper)          ||
                (prev_clear          != vif.o_clear)
            ) begin
                emit_actual_snapshot();
            end

            prev_pen_color      = vif.o_pen_color;
            prev_eraser         = vif.o_eraser;
            prev_size           = vif.o_size;
            prev_texture_enable = vif.o_texture_enable;
            prev_texture_shape  = vif.o_texture_shape;
            prev_paper          = vif.o_paper;
            prev_clear          = vif.o_clear;
        end
    endtask
endclass

`endif
