`ifndef MEMCTRL_SEQ_ITEM_SV
`define MEMCTRL_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum int unsigned {
    FRAME_ALL_ZERO,
    FRAME_ALL_ONE,
    FRAME_RED_HEAVY,
    FRAME_GREEN_HEAVY,
    FRAME_BLUE_HEAVY,
    FRAME_HREF_GAP,
    FRAME_ODD_HREF_DROP,
    FRAME_ODD_VSYNC_DROP,
    FRAME_RANDOM
} mem_frame_kind_e;

class memctrl_seq_item extends uvm_sequence_item;
    rand int unsigned pixel_seed;
    mem_frame_kind_e  frame_kind;
    int unsigned      frame_id;
    bit [15:0]        pixels[$];

    int unsigned first_byte_we_errors;
    int unsigned second_byte_we_errors;
    int unsigned href_low_we_errors;
    int unsigned vsync_reset_errors;
    int unsigned addr_errors;

    `uvm_object_utils_begin(memctrl_seq_item)
        `uvm_field_int(pixel_seed, UVM_ALL_ON)
        `uvm_field_enum(mem_frame_kind_e, frame_kind, UVM_ALL_ON)
        `uvm_field_int(frame_id, UVM_ALL_ON)
        `uvm_field_queue_int(pixels, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(first_byte_we_errors, UVM_ALL_ON)
        `uvm_field_int(second_byte_we_errors, UVM_ALL_ON)
        `uvm_field_int(href_low_we_errors, UVM_ALL_ON)
        `uvm_field_int(vsync_reset_errors, UVM_ALL_ON)
        `uvm_field_int(addr_errors, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "memctrl_seq_item");
        super.new(name);
    endfunction

    function int unsigned pixel_count();
        return pixels.size();
    endfunction

    function string kind_name();
        case (frame_kind)
            FRAME_ALL_ZERO:       return "ALL_ZERO";
            FRAME_ALL_ONE:        return "ALL_ONE";
            FRAME_RED_HEAVY:      return "RED_HEAVY";
            FRAME_GREEN_HEAVY:    return "GREEN_HEAVY";
            FRAME_BLUE_HEAVY:     return "BLUE_HEAVY";
            FRAME_HREF_GAP:       return "HREF_GAP";
            FRAME_ODD_HREF_DROP:  return "ODD_HREF_DROP";
            FRAME_ODD_VSYNC_DROP: return "ODD_VSYNC_DROP";
            FRAME_RANDOM:         return "RANDOM";
            default:              return "UNKNOWN";
        endcase
    endfunction

    function string convert2string();
        return $sformatf(
            "frame_id=%0d kind=%s seed=0x%08x pixels=%0d err(first=%0d second=%0d href_low=%0d vsync=%0d addr=%0d)",
            frame_id, kind_name(), pixel_seed, pixel_count(),
            first_byte_we_errors, second_byte_we_errors,
            href_low_we_errors, vsync_reset_errors, addr_errors
        );
    endfunction
endclass

`endif
