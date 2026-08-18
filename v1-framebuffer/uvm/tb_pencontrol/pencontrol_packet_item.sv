`ifndef PENCONTROL_PACKET_ITEM_SV
`define PENCONTROL_PACKET_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "pencontrol_seq_item.sv"

class pencontrol_packet_item extends uvm_sequence_item;
    pencontrol_scenario_e scenario;
    int unsigned          item_id;
    int unsigned          cycle_id;
    longint unsigned      event_time_ns;

    bit [2:0]             pen_color;
    bit                   eraser;
    bit                   size;
    bit                   texture_enable;
    bit [2:0]             texture_shape;
    bit                   paper;
    bit                   clear;

    `uvm_object_utils_begin(pencontrol_packet_item)
        `uvm_field_enum(pencontrol_scenario_e, scenario, UVM_ALL_ON)
        `uvm_field_int(item_id, UVM_ALL_ON)
        `uvm_field_int(cycle_id, UVM_ALL_ON)
        `uvm_field_int(event_time_ns, UVM_ALL_ON)
        `uvm_field_int(pen_color, UVM_ALL_ON)
        `uvm_field_int(eraser, UVM_ALL_ON)
        `uvm_field_int(size, UVM_ALL_ON)
        `uvm_field_int(texture_enable, UVM_ALL_ON)
        `uvm_field_int(texture_shape, UVM_ALL_ON)
        `uvm_field_int(paper, UVM_ALL_ON)
        `uvm_field_int(clear, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "pencontrol_packet_item");
        super.new(name);
    endfunction
endclass

`endif
