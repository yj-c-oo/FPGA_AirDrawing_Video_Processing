`ifndef UARTRXPACKED_BYTE_ITEM_SV
`define UARTRXPACKED_BYTE_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartrxpacked_seq_item.sv"

class uartrxpacked_byte_item extends uvm_sequence_item;
    uartrxpacked_scenario_e scenario;
    int unsigned           packet_id;
    int unsigned           byte_index;
    bit [7:0]              byte_value;
    int unsigned           cycle_id;
    longint unsigned       event_time_ns;

    `uvm_object_utils_begin(uartrxpacked_byte_item)
        `uvm_field_enum(uartrxpacked_scenario_e, scenario, UVM_ALL_ON)
        `uvm_field_int(packet_id, UVM_ALL_ON)
        `uvm_field_int(byte_index, UVM_ALL_ON)
        `uvm_field_int(byte_value, UVM_ALL_ON)
        `uvm_field_int(cycle_id, UVM_ALL_ON)
        `uvm_field_int(event_time_ns, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uartrxpacked_byte_item");
        super.new(name);
    endfunction
endclass

`endif
