`ifndef UARTSENDER_SEQUENCE_SV
`define UARTSENDER_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_seq_item.sv"

class uartsender_base_seq extends uvm_sequence #(uartsender_seq_item);
    `uvm_object_utils(uartsender_base_seq)

    int unsigned next_packet_id;

    function new(string name = "uartsender_base_seq");
        super.new(name);
    endfunction

    function uartsender_seq_item make_item(string name, uartsender_scenario_e scenario);
        uartsender_seq_item item;
        item = uartsender_seq_item::type_id::create(name);
        item.scenario = scenario;
        item.packet_id = next_packet_id;
        next_packet_id++;
        return item;
    endfunction

    task send_item_cfg(uartsender_seq_item item);
        start_item(item);
        finish_item(item);
        `uvm_info(get_type_name(), $sformatf("Queued %s", item.convert2string()), UVM_MEDIUM)
    endtask

    virtual task body();
        uartsender_seq_item item;

        item = make_item("reset_idle", SCN_RESET_IDLE);
        item.expect_packet = 0;
        item.idle_after_cycles = 8;
        send_item_cfg(item);

        item = make_item("single_send", SCN_SINGLE_SEND);
        send_item_cfg(item);

        item = make_item("control_bits", SCN_CONTROL_BITS);
        item.sw_paint_red = 0;
        item.sw_paint_green = 1;
        item.sw_paint_blue = 1;
        item.sw_eraser = 1;
        item.sw_size = 1;
        send_item_cfg(item);

        item = make_item("texture_paper", SCN_TEXTURE_PAPER);
        item.sw_texture_enable = 1;
        item.texture_shape = 3'd4;
        item.paper = 1;
        send_item_cfg(item);

        item = make_item("coord_boundary", SCN_COORD_BOUNDARY);
        item.X_center = 9'd511;
        item.Y_center = 9'd239;
        send_item_cfg(item);

        item = make_item("trigger_hold", SCN_TRIGGER_HOLD);
        item.trigger_hold_cycles = 6;
        send_item_cfg(item);

        item = make_item("busy_retrigger", SCN_BUSY_RETRIGGER);
        item.retrigger_during_busy = 1;
        item.retrigger_after_baud_ticks = 32;
        send_item_cfg(item);

        item = make_item("back_to_back_a", SCN_BACK_TO_BACK);
        item.idle_after_cycles = 0;
        item.X_center = 9'd123;
        item.Y_center = 9'd77;
        send_item_cfg(item);

        item = make_item("back_to_back_b", SCN_BACK_TO_BACK);
        item.idle_before_cycles = 0;
        item.X_center = 9'd321;
        item.Y_center = 9'd88;
        send_item_cfg(item);

        item = make_item("clear_bit", SCN_CLEAR_BIT);
        item.clear_btn = 1;
        send_item_cfg(item);

        for (int i = 0; i < 8; i++) begin
            item = make_item($sformatf("random_%0d", i), SCN_RANDOM_STRESS);
            item.X_center = $urandom_range(0, 511);
            item.Y_center = $urandom_range(0, 239);
            item.sw_paint_red = $urandom_range(0, 1);
            item.sw_paint_green = $urandom_range(0, 1);
            item.sw_paint_blue = $urandom_range(0, 1);
            item.sw_eraser = $urandom_range(0, 1);
            item.sw_size = $urandom_range(0, 1);
            item.sw_texture_enable = $urandom_range(0, 1);
            item.texture_shape = $urandom_range(0, 7);
            item.paper = $urandom_range(0, 1);
            item.clear_btn = $urandom_range(0, 1);
            item.trigger_hold_cycles = $urandom_range(1, 6);
            item.retrigger_during_busy = $urandom_range(0, 1);
            item.retrigger_after_baud_ticks = 16 + $urandom_range(0, 48);
            item.idle_before_cycles = $urandom_range(1, 8);
            item.idle_after_cycles = $urandom_range(1, 8);
            send_item_cfg(item);
        end
    endtask
endclass

`endif
