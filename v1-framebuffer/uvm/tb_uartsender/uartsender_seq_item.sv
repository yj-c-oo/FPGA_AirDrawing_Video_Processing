`ifndef UARTSENDER_SEQ_ITEM_SV
`define UARTSENDER_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum int unsigned {
    SCN_RESET_IDLE,
    SCN_SINGLE_SEND,
    SCN_CONTROL_BITS,
    SCN_TEXTURE_PAPER,
    SCN_COORD_BOUNDARY,
    SCN_TRIGGER_HOLD,
    SCN_BUSY_RETRIGGER,
    SCN_BACK_TO_BACK,
    SCN_CLEAR_BIT,
    SCN_RANDOM_STRESS
} uartsender_scenario_e;

class uartsender_seq_item extends uvm_sequence_item;
    uartsender_scenario_e scenario;
    int unsigned          packet_id;
    bit                   expect_packet;

    int unsigned          trigger_hold_cycles;
    int unsigned          idle_before_cycles;
    int unsigned          idle_after_cycles;
    bit                   retrigger_during_busy;
    int unsigned          retrigger_after_baud_ticks;

    bit [8:0]             X_center;
    bit [8:0]             Y_center;
    bit                   sw_paint_red;
    bit                   sw_paint_green;
    bit                   sw_paint_blue;
    bit                   sw_eraser;
    bit                   sw_size;
    bit                   sw_texture_enable;
    bit [2:0]             texture_shape;
    bit                   paper;
    bit                   clear_btn;

    `uvm_object_utils_begin(uartsender_seq_item)
        `uvm_field_enum(uartsender_scenario_e, scenario, UVM_ALL_ON)
        `uvm_field_int(packet_id, UVM_ALL_ON)
        `uvm_field_int(expect_packet, UVM_ALL_ON)
        `uvm_field_int(trigger_hold_cycles, UVM_ALL_ON)
        `uvm_field_int(idle_before_cycles, UVM_ALL_ON)
        `uvm_field_int(idle_after_cycles, UVM_ALL_ON)
        `uvm_field_int(retrigger_during_busy, UVM_ALL_ON)
        `uvm_field_int(retrigger_after_baud_ticks, UVM_ALL_ON)
        `uvm_field_int(X_center, UVM_ALL_ON)
        `uvm_field_int(Y_center, UVM_ALL_ON)
        `uvm_field_int(sw_paint_red, UVM_ALL_ON)
        `uvm_field_int(sw_paint_green, UVM_ALL_ON)
        `uvm_field_int(sw_paint_blue, UVM_ALL_ON)
        `uvm_field_int(sw_eraser, UVM_ALL_ON)
        `uvm_field_int(sw_size, UVM_ALL_ON)
        `uvm_field_int(sw_texture_enable, UVM_ALL_ON)
        `uvm_field_int(texture_shape, UVM_ALL_ON)
        `uvm_field_int(paper, UVM_ALL_ON)
        `uvm_field_int(clear_btn, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uartsender_seq_item");
        super.new(name);
        scenario = SCN_SINGLE_SEND;
        packet_id = 0;
        expect_packet = 1;
        trigger_hold_cycles = 1;
        idle_before_cycles = 8;
        idle_after_cycles = 8;
        retrigger_during_busy = 0;
        retrigger_after_baud_ticks = 32;
        X_center = 9'd100;
        Y_center = 9'd50;
        sw_paint_red = 1;
        sw_paint_green = 0;
        sw_paint_blue = 0;
        sw_eraser = 0;
        sw_size = 0;
        sw_texture_enable = 0;
        texture_shape = 3'd0;
        paper = 0;
        clear_btn = 0;
    endfunction

    function string scenario_name();
        case (scenario)
            SCN_RESET_IDLE:      return "RESET_IDLE";
            SCN_SINGLE_SEND:     return "SINGLE_SEND";
            SCN_CONTROL_BITS:    return "CONTROL_BITS";
            SCN_TEXTURE_PAPER:   return "TEXTURE_PAPER";
            SCN_COORD_BOUNDARY:  return "COORD_BOUNDARY";
            SCN_TRIGGER_HOLD:    return "TRIGGER_HOLD";
            SCN_BUSY_RETRIGGER:  return "BUSY_RETRIGGER";
            SCN_BACK_TO_BACK:    return "BACK_TO_BACK";
            SCN_CLEAR_BIT:       return "CLEAR_BIT";
            SCN_RANDOM_STRESS:   return "RANDOM_STRESS";
            default:             return "UNKNOWN";
        endcase
    endfunction

    function bit [7:0] expected_control_byte();
        return {
            sw_texture_enable,
            sw_eraser,
            sw_size,
            sw_paint_red,
            sw_paint_green,
            sw_paint_blue,
            clear_btn,
            1'b0
        };
    endfunction

    function bit [7:0] expected_shape_byte();
        return {4'b0, paper, texture_shape};
    endfunction

    function bit [7:0] expected_byte(int unsigned idx);
        case (idx)
            0: return 8'hAA;
            1: return X_center[8:1];
            2: return Y_center[7:0];
            3: return expected_control_byte();
            4: return expected_shape_byte();
            5: return 8'h55;
            default: return 8'h00;
        endcase
    endfunction

    function string convert2string();
        return $sformatf(
            "scenario=%s packet_id=%0d expect=%0b hold=%0d retrigger=%0b x=%0d y=%0d ctrl=[rgb=%0b%0b%0b eraser=%0b size=%0b tex=%0b clear=%0b] shape=%0d paper=%0b",
            scenario_name(), packet_id, expect_packet, trigger_hold_cycles,
            retrigger_during_busy, X_center, Y_center, sw_paint_red, sw_paint_green,
            sw_paint_blue, sw_eraser, sw_size, sw_texture_enable, clear_btn,
            texture_shape, paper
        );
    endfunction
endclass

`endif
