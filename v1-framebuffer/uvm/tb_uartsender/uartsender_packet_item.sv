`ifndef UARTSENDER_PACKET_ITEM_SV
`define UARTSENDER_PACKET_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_seq_item.sv"

class uartsender_packet_item extends uvm_sequence_item;
    uartsender_scenario_e scenario;
    int unsigned          packet_id;
    int unsigned          ref_cycle_id;
    longint unsigned      ref_time_ns;
    int unsigned          cycle_id;
    longint unsigned      event_time_ns;
    bit [7:0]             byte0;
    bit [7:0]             byte1;
    bit [7:0]             byte2;
    bit [7:0]             byte3;
    bit [7:0]             byte4;
    bit [7:0]             byte5;

    `uvm_object_utils_begin(uartsender_packet_item)
        `uvm_field_enum(uartsender_scenario_e, scenario, UVM_ALL_ON)
        `uvm_field_int(packet_id, UVM_ALL_ON)
        `uvm_field_int(ref_cycle_id, UVM_ALL_ON)
        `uvm_field_int(ref_time_ns, UVM_ALL_ON)
        `uvm_field_int(cycle_id, UVM_ALL_ON)
        `uvm_field_int(event_time_ns, UVM_ALL_ON)
        `uvm_field_int(byte0, UVM_ALL_ON)
        `uvm_field_int(byte1, UVM_ALL_ON)
        `uvm_field_int(byte2, UVM_ALL_ON)
        `uvm_field_int(byte3, UVM_ALL_ON)
        `uvm_field_int(byte4, UVM_ALL_ON)
        `uvm_field_int(byte5, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uartsender_packet_item");
        super.new(name);
    endfunction
endclass

`endif
