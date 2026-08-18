`ifndef UARTRXPACKED_PACKET_ITEM_SV
`define UARTRXPACKED_PACKET_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartrxpacked_seq_item.sv"

class uartrxpacked_packet_item extends uvm_sequence_item;
    uartrxpacked_scenario_e scenario;
    int unsigned           packet_id;
    int unsigned           cycle_id;
    longint unsigned       event_time_ns;
    bit                    packet_valid;
    bit                    clear_pulse;
    bit [2:0]              pen_color;
    bit                    eraser;
    bit                    size;
    bit                    texture_enable;
    bit [2:0]              texture_shape;
    bit                    paper;

    `uvm_object_utils_begin(uartrxpacked_packet_item)
        `uvm_field_enum(uartrxpacked_scenario_e, scenario, UVM_ALL_ON)
        `uvm_field_int(packet_id, UVM_ALL_ON)
        `uvm_field_int(cycle_id, UVM_ALL_ON)
        `uvm_field_int(event_time_ns, UVM_ALL_ON)
        `uvm_field_int(packet_valid, UVM_ALL_ON)
        `uvm_field_int(clear_pulse, UVM_ALL_ON)
        `uvm_field_int(pen_color, UVM_ALL_ON)
        `uvm_field_int(eraser, UVM_ALL_ON)
        `uvm_field_int(size, UVM_ALL_ON)
        `uvm_field_int(texture_enable, UVM_ALL_ON)
        `uvm_field_int(texture_shape, UVM_ALL_ON)
        `uvm_field_int(paper, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uartrxpacked_packet_item");
        super.new(name);
    endfunction
endclass

`endif
