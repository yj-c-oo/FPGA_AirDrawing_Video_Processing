`ifndef PENCONTROL_SEQ_ITEM_SV
`define PENCONTROL_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum int unsigned {
    SCN_RESET_IDLE,
    SCN_UART_UPDATE,
    SCN_SHAPE_CLAMP,
    SCN_BTN_ERASER,
    SCN_BTN_SIZE,
    SCN_BTN_MODE,
    SCN_UART_BTN_PRIORITY,
    SCN_CLEAR_STRETCH,
    SCN_CLEAR_RETRIGGER,
    SCN_RANDOM_MIX
} pencontrol_scenario_e;

class pencontrol_seq_item extends uvm_sequence_item;
    pencontrol_scenario_e scenario;
    int unsigned          item_id;

    bit                   uart_valid;
    bit [2:0]             uart_pen_color;
    bit                   uart_eraser;
    bit                   uart_size;
    bit                   uart_texture_enable;
    bit [2:0]             uart_texture_shape;
    bit                   uart_paper;
    bit                   uart_clear_pulse;

    bit                   btn_eraser;
    bit                   btn_mode;
    bit                   btn_size;

    int unsigned          idle_before_cycles;
    int unsigned          post_wait_cycles;

    `uvm_object_utils_begin(pencontrol_seq_item)
        `uvm_field_enum(pencontrol_scenario_e, scenario, UVM_ALL_ON)
        `uvm_field_int(item_id, UVM_ALL_ON)
        `uvm_field_int(uart_valid, UVM_ALL_ON)
        `uvm_field_int(uart_pen_color, UVM_ALL_ON)
        `uvm_field_int(uart_eraser, UVM_ALL_ON)
        `uvm_field_int(uart_size, UVM_ALL_ON)
        `uvm_field_int(uart_texture_enable, UVM_ALL_ON)
        `uvm_field_int(uart_texture_shape, UVM_ALL_ON)
        `uvm_field_int(uart_paper, UVM_ALL_ON)
        `uvm_field_int(uart_clear_pulse, UVM_ALL_ON)
        `uvm_field_int(btn_eraser, UVM_ALL_ON)
        `uvm_field_int(btn_mode, UVM_ALL_ON)
        `uvm_field_int(btn_size, UVM_ALL_ON)
        `uvm_field_int(idle_before_cycles, UVM_ALL_ON)
        `uvm_field_int(post_wait_cycles, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "pencontrol_seq_item");
        super.new(name);
        scenario = SCN_RESET_IDLE;
        item_id = 0;
        uart_valid = 0;
        uart_pen_color = 3'b100;
        uart_eraser = 0;
        uart_size = 0;
        uart_texture_enable = 0;
        uart_texture_shape = 0;
        uart_paper = 0;
        uart_clear_pulse = 0;
        btn_eraser = 0;
        btn_mode = 0;
        btn_size = 0;
        idle_before_cycles = 1;
        post_wait_cycles = 2;
    endfunction

    function string scenario_name();
        case (scenario)
            SCN_RESET_IDLE:        return "RESET_IDLE";
            SCN_UART_UPDATE:       return "UART_UPDATE";
            SCN_SHAPE_CLAMP:       return "SHAPE_CLAMP";
            SCN_BTN_ERASER:        return "BTN_ERASER";
            SCN_BTN_SIZE:          return "BTN_SIZE";
            SCN_BTN_MODE:          return "BTN_MODE";
            SCN_UART_BTN_PRIORITY: return "UART_BTN_PRIORITY";
            SCN_CLEAR_STRETCH:     return "CLEAR_STRETCH";
            SCN_CLEAR_RETRIGGER:   return "CLEAR_RETRIGGER";
            SCN_RANDOM_MIX:        return "RANDOM_MIX";
            default:               return "UNKNOWN";
        endcase
    endfunction

    function string convert2string();
        return $sformatf(
            "scenario=%s item_id=%0d uart_valid=%0b uart_cfg=[color=%03b eraser=%0b size=%0b tex_en=%0b shape=%0d paper=%0b clear=%0b] btn=[e=%0b m=%0b s=%0b] idle=%0d wait=%0d",
            scenario_name(), item_id, uart_valid, uart_pen_color, uart_eraser, uart_size,
            uart_texture_enable, uart_texture_shape, uart_paper, uart_clear_pulse,
            btn_eraser, btn_mode, btn_size, idle_before_cycles, post_wait_cycles
        );
    endfunction
endclass

`endif
