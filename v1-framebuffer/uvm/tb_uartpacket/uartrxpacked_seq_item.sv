`ifndef UARTRXPACKED_SEQ_ITEM_SV
`define UARTRXPACKED_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum int unsigned {
    SCN_RESET_IDLE,
    SCN_VALID_PACKET,
    SCN_CONTROL_DECODE,
    SCN_SHAPE_DECODE,
    SCN_WRONG_START,
    SCN_WRONG_END,
    SCN_TIMEOUT,
    SCN_BACK_TO_BACK,
    SCN_CLEAR_PULSE,
    SCN_RANDOM_STRESS
} uartrxpacked_scenario_e;

class uartrxpacked_seq_item extends uvm_sequence_item;
    uartrxpacked_scenario_e scenario;
    int unsigned           packet_id;
    bit [7:0]              start_byte;
    bit [7:0]              control_byte;
    bit [7:0]              shape_byte;
    bit [7:0]              end_byte;
    int unsigned           idle_before_ticks;
    int unsigned           gap_after_byte0_ticks;
    int unsigned           gap_after_byte1_ticks;
    int unsigned           gap_after_byte2_ticks;
    int unsigned           idle_after_ticks;
    int                    timeout_after_byte;
    int unsigned           timeout_gap_ticks;

    `uvm_object_utils_begin(uartrxpacked_seq_item)
        `uvm_field_enum(uartrxpacked_scenario_e, scenario, UVM_ALL_ON)
        `uvm_field_int(packet_id, UVM_ALL_ON)
        `uvm_field_int(start_byte, UVM_ALL_ON)
        `uvm_field_int(control_byte, UVM_ALL_ON)
        `uvm_field_int(shape_byte, UVM_ALL_ON)
        `uvm_field_int(end_byte, UVM_ALL_ON)
        `uvm_field_int(idle_before_ticks, UVM_ALL_ON)
        `uvm_field_int(gap_after_byte0_ticks, UVM_ALL_ON)
        `uvm_field_int(gap_after_byte1_ticks, UVM_ALL_ON)
        `uvm_field_int(gap_after_byte2_ticks, UVM_ALL_ON)
        `uvm_field_int(idle_after_ticks, UVM_ALL_ON)
        `uvm_field_int(timeout_after_byte, UVM_ALL_ON)
        `uvm_field_int(timeout_gap_ticks, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uartrxpacked_seq_item");
        super.new(name);
        scenario = SCN_VALID_PACKET;
        packet_id = 0;
        start_byte = 8'hA5;
        control_byte = 8'h00;
        shape_byte = 8'h00;
        end_byte = 8'h5A;
        idle_before_ticks = 16;
        gap_after_byte0_ticks = 0;
        gap_after_byte1_ticks = 0;
        gap_after_byte2_ticks = 0;
        idle_after_ticks = 16;
        timeout_after_byte = -1;
        timeout_gap_ticks = 0;
    endfunction

    function string scenario_name();
        case (scenario)
            SCN_RESET_IDLE:     return "RESET_IDLE";
            SCN_VALID_PACKET:   return "VALID_PACKET";
            SCN_CONTROL_DECODE: return "CONTROL_DECODE";
            SCN_SHAPE_DECODE:   return "SHAPE_DECODE";
            SCN_WRONG_START:    return "WRONG_START";
            SCN_WRONG_END:      return "WRONG_END";
            SCN_TIMEOUT:        return "TIMEOUT";
            SCN_BACK_TO_BACK:   return "BACK_TO_BACK";
            SCN_CLEAR_PULSE:    return "CLEAR_PULSE";
            SCN_RANDOM_STRESS:  return "RANDOM_STRESS";
            default:            return "UNKNOWN";
        endcase
    endfunction

    function bit is_idle_only();
        return (scenario == SCN_RESET_IDLE);
    endfunction

    function int unsigned sent_byte_count();
        if (is_idle_only()) begin
            return 0;
        end
        if (timeout_after_byte >= 0) begin
            return timeout_after_byte + 1;
        end
        return 4;
    endfunction

    function bit expects_packet_valid();
        if (is_idle_only()) begin
            return 0;
        end
        if (timeout_after_byte >= 0) begin
            return 0;
        end
        return (start_byte == 8'hA5) && (end_byte == 8'h5A);
    endfunction

    function bit [2:0] expected_pen_color();
        return control_byte[4:2];
    endfunction

    function bit expected_eraser();
        return control_byte[6];
    endfunction

    function bit expected_size();
        return control_byte[5];
    endfunction

    function bit expected_texture_enable();
        return control_byte[7];
    endfunction

    function bit [2:0] expected_texture_shape();
        return shape_byte[2:0];
    endfunction

    function bit expected_paper();
        return shape_byte[3];
    endfunction

    function bit expected_clear_pulse();
        return control_byte[1];
    endfunction

    function string convert2string();
        return $sformatf(
            "scenario=%s packet_id=%0d bytes=[0x%02h 0x%02h 0x%02h 0x%02h] sent_bytes=%0d exp_valid=%0b timeout_after=%0d timeout_gap_ticks=%0d",
            scenario_name(), packet_id, start_byte, control_byte, shape_byte,
            end_byte, sent_byte_count(), expects_packet_valid(),
            timeout_after_byte, timeout_gap_ticks
        );
    endfunction
endclass

`endif
