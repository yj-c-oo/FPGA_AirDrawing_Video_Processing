`ifndef UARTRXPACKED_SEQUENCE_SV
`define UARTRXPACKED_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartrxpacked_seq_item.sv"

class uartrxpacked_base_seq extends uvm_sequence #(uartrxpacked_seq_item);
    `uvm_object_utils(uartrxpacked_base_seq)

    int unsigned num_random_packets = 12;
    int unsigned next_packet_id;

    function new(string name = "uartrxpacked_base_seq");
        super.new(name);
        next_packet_id = 0;
    endfunction

    task send_item_cfg(uartrxpacked_seq_item item);
        start_item(item);
        finish_item(item);
        `uvm_info(get_type_name(), $sformatf("Queued %s", item.convert2string()), UVM_MEDIUM)
    endtask

    function uartrxpacked_seq_item make_item(
        string                 name,
        uartrxpacked_scenario_e scenario
    );
        uartrxpacked_seq_item item;

        item = uartrxpacked_seq_item::type_id::create(name);
        item.scenario = scenario;
        item.packet_id = next_packet_id;
        next_packet_id++;
        return item;
    endfunction

    task send_idle_scenario();
        uartrxpacked_seq_item item;

        item = make_item("reset_idle", SCN_RESET_IDLE);
        item.idle_before_ticks = 32;
        item.idle_after_ticks = 64;
        send_item_cfg(item);
    endtask

    task send_valid_packet(
        uartrxpacked_scenario_e scenario,
        bit [7:0]              control_byte,
        bit [7:0]              shape_byte,
        int unsigned           idle_before_ticks = 16,
        int unsigned           idle_after_ticks = 16
    );
        uartrxpacked_seq_item item;

        item = make_item($sformatf("%s_pkt_%0d", item_name(scenario), next_packet_id), scenario);
        item.control_byte = control_byte;
        item.shape_byte = shape_byte;
        item.idle_before_ticks = idle_before_ticks;
        item.idle_after_ticks = idle_after_ticks;
        send_item_cfg(item);
    endtask

    function string item_name(uartrxpacked_scenario_e scenario);
        case (scenario)
            SCN_RESET_IDLE:     return "reset_idle";
            SCN_VALID_PACKET:   return "valid";
            SCN_CONTROL_DECODE: return "control";
            SCN_SHAPE_DECODE:   return "shape";
            SCN_WRONG_START:    return "wrong_start";
            SCN_WRONG_END:      return "wrong_end";
            SCN_TIMEOUT:        return "timeout";
            SCN_BACK_TO_BACK:   return "back_to_back";
            SCN_CLEAR_PULSE:    return "clear";
            SCN_RANDOM_STRESS:  return "random";
            default:            return "unknown";
        endcase
    endfunction

    task send_wrong_start_packet();
        uartrxpacked_seq_item item;

        item = make_item("wrong_start", SCN_WRONG_START);
        item.start_byte = 8'h33;
        item.control_byte = 8'h94;
        item.shape_byte = 8'h02;
        send_item_cfg(item);
    endtask

    task send_wrong_end_packet();
        uartrxpacked_seq_item item;

        item = make_item("wrong_end", SCN_WRONG_END);
        item.control_byte = 8'h54;
        item.shape_byte = 8'h04;
        item.end_byte = 8'h00;
        send_item_cfg(item);
    endtask

    task send_timeout_packet();
        uartrxpacked_seq_item item;

        item = make_item("timeout", SCN_TIMEOUT);
        item.control_byte = 8'h84;
        item.shape_byte = 8'h03;
        item.timeout_after_byte = 1;
        item.timeout_gap_ticks = 600;
        item.idle_after_ticks = 64;
        send_item_cfg(item);
    endtask

    task send_back_to_back_packets();
        send_valid_packet(SCN_BACK_TO_BACK, 8'hA4, 8'h01, 16, 0);
        send_valid_packet(SCN_BACK_TO_BACK, 8'h64, 8'h09, 0, 16);
    endtask

    task send_shape_decode_packets();
        for (int paper = 0; paper < 2; paper++) begin
            for (int shape = 0; shape < 5; shape++) begin
                bit [7:0] shape_byte;

                shape_byte = {4'b0, paper[0], shape[2:0]};
                send_valid_packet(SCN_SHAPE_DECODE, 8'h80, shape_byte);
            end
        end
    endtask

    task send_control_decode_packets();
        send_valid_packet(SCN_CONTROL_DECODE, 8'b1001_0100, 8'h01);
        send_valid_packet(SCN_CONTROL_DECODE, 8'b0110_1000, 8'h02);
        send_valid_packet(SCN_CONTROL_DECODE, 8'b0011_1100, 8'h03);
    endtask

    task send_random_stress_packets();
        for (int i = 0; i < num_random_packets; i++) begin
            uartrxpacked_seq_item item;
            int choice;

            item = make_item($sformatf("random_%0d", i), SCN_RANDOM_STRESS);
            item.control_byte = $urandom();
            item.shape_byte = $urandom();
            item.idle_before_ticks = $urandom_range(0, 32);
            item.idle_after_ticks = $urandom_range(0, 32);
            choice = $urandom_range(0, 3);

            case (choice)
                0: begin
                    item.start_byte = 8'hA5;
                    item.end_byte = 8'h5A;
                end
                1: begin
                    item.start_byte = $urandom_range(0, 255);
                    if (item.start_byte == 8'hA5) item.start_byte = 8'h34;
                end
                2: begin
                    item.end_byte = $urandom_range(0, 255);
                    if (item.end_byte == 8'h5A) item.end_byte = 8'h00;
                end
                default: begin
                    item.timeout_after_byte = $urandom_range(0, 2);
                    item.timeout_gap_ticks = 560 + $urandom_range(0, 120);
                end
            endcase

            send_item_cfg(item);
        end
    endtask

    virtual task body();
        send_idle_scenario();
        send_valid_packet(SCN_VALID_PACKET, 8'h94, 8'h02);
        send_control_decode_packets();
        send_shape_decode_packets();
        send_wrong_start_packet();
        send_wrong_end_packet();
        send_timeout_packet();
        send_valid_packet(SCN_VALID_PACKET, 8'h84, 8'h04, 16, 16);
        send_back_to_back_packets();
        send_valid_packet(SCN_CLEAR_PULSE, 8'b1000_0010, 8'h0A);
        send_random_stress_packets();
    endtask
endclass

`endif
