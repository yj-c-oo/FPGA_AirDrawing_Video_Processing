`ifndef UARTSENDER_BYTE_ITEM_SV
`define UARTSENDER_BYTE_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_seq_item.sv"

class uartsender_byte_item extends uvm_sequence_item;
    uartsender_scenario_e scenario;
    int unsigned          packet_id;
    int unsigned          byte_index;
    bit [7:0]             byte_value;
    int unsigned          ref_cycle_id;
    longint unsigned      ref_time_ns;
    int unsigned          cycle_id;
    longint unsigned      event_time_ns;

    `uvm_object_utils_begin(uartsender_byte_item)
        `uvm_field_enum(uartsender_scenario_e, scenario, UVM_ALL_ON)
        `uvm_field_int(packet_id, UVM_ALL_ON)
        `uvm_field_int(byte_index, UVM_ALL_ON)
        `uvm_field_int(byte_value, UVM_ALL_ON)
        `uvm_field_int(ref_cycle_id, UVM_ALL_ON)
        `uvm_field_int(ref_time_ns, UVM_ALL_ON)
        `uvm_field_int(cycle_id, UVM_ALL_ON)
        `uvm_field_int(event_time_ns, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uartsender_byte_item");
        super.new(name);
    endfunction
endclass

`endif
