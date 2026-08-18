`ifndef MEMCTRL_TIMING_ITEM_SV
`define MEMCTRL_TIMING_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum int unsigned {
    TIMING_EVT_WRITE
} memctrl_timing_kind_e;

class memctrl_timing_item extends uvm_sequence_item;
    memctrl_timing_kind_e event_kind;
    int unsigned          frame_id;
    int unsigned          pixel_index;
    int unsigned          cycle_id;
    longint unsigned      event_time_ns;
    bit                   we;
    bit [15:0]            wdata;
    int unsigned          waddr;

    `uvm_object_utils_begin(memctrl_timing_item)
        `uvm_field_enum(memctrl_timing_kind_e, event_kind, UVM_ALL_ON)
        `uvm_field_int(frame_id, UVM_ALL_ON)
        `uvm_field_int(pixel_index, UVM_ALL_ON)
        `uvm_field_int(cycle_id, UVM_ALL_ON)
        `uvm_field_int(event_time_ns, UVM_ALL_ON)
        `uvm_field_int(we, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(waddr, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "memctrl_timing_item");
        super.new(name);
    endfunction

    function string kind_name();
        case (event_kind)
            TIMING_EVT_WRITE: return "WRITE";
            default:          return "UNKNOWN";
        endcase
    endfunction

    function string convert2string();
        return $sformatf(
            "kind=%s frame=%0d pixel=%0d cycle=%0d time=%0t we=%0b waddr=%0d wdata=0x%04h",
            kind_name(), frame_id, pixel_index, cycle_id, event_time_ns, we, waddr, wdata
        );
    endfunction
endclass

`endif
