`ifndef PENCONTROL_SEQUENCE_SV
`define PENCONTROL_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "pencontrol_seq_item.sv"

class pencontrol_base_seq extends uvm_sequence #(pencontrol_seq_item);
    `uvm_object_utils(pencontrol_base_seq)

    int unsigned next_item_id;

    function new(string name = "pencontrol_base_seq");
        super.new(name);
    endfunction

    function pencontrol_seq_item make_item(string name, pencontrol_scenario_e scenario);
        pencontrol_seq_item item;

        item = pencontrol_seq_item::type_id::create(name);
        item.scenario = scenario;
        item.item_id = next_item_id;
        next_item_id++;
        return item;
    endfunction

    task send_item_cfg(pencontrol_seq_item item);
        start_item(item);
        finish_item(item);
        `uvm_info(get_type_name(), $sformatf("Queued %s", item.convert2string()), UVM_MEDIUM)
    endtask

    virtual task body();
        pencontrol_seq_item item;

        item = make_item("reset_idle", SCN_RESET_IDLE);
        item.idle_before_cycles = 2;
        item.post_wait_cycles = 2;
        send_item_cfg(item);

        item = make_item("uart_update", SCN_UART_UPDATE);
        item.uart_valid = 1;
        item.uart_pen_color = 3'b011;
        item.uart_eraser = 0;
        item.uart_size = 1;
        item.uart_texture_enable = 1;
        item.uart_texture_shape = 3'd2;
        item.uart_paper = 1;
        send_item_cfg(item);

        item = make_item("shape_clamp", SCN_SHAPE_CLAMP);
        item.uart_valid = 1;
        item.uart_pen_color = 3'b101;
        item.uart_texture_enable = 1;
        item.uart_texture_shape = 3'd7;
        send_item_cfg(item);

        item = make_item("btn_eraser", SCN_BTN_ERASER);
        item.btn_eraser = 1;
        send_item_cfg(item);

        item = make_item("btn_mode_0", SCN_BTN_MODE);
        item.btn_mode = 1;
        send_item_cfg(item);

        item = make_item("btn_size", SCN_BTN_SIZE);
        item.btn_size = 1;
        send_item_cfg(item);

        item = make_item("btn_mode_1", SCN_BTN_MODE);
        item.btn_mode = 1;
        send_item_cfg(item);

        item = make_item("btn_mode_2", SCN_BTN_MODE);
        item.btn_mode = 1;
        send_item_cfg(item);

        item = make_item("uart_btn_priority", SCN_UART_BTN_PRIORITY);
        item.uart_valid = 1;
        item.uart_pen_color = 3'b001;
        item.uart_eraser = 1;
        item.uart_size = 1;
        item.uart_texture_enable = 1;
        item.uart_texture_shape = 3'd4;
        item.btn_mode = 1;
        send_item_cfg(item);

        item = make_item("clear_stretch", SCN_CLEAR_STRETCH);
        item.uart_clear_pulse = 1;
        item.post_wait_cycles = 260;
        send_item_cfg(item);

        item = make_item("clear_retrigger_a", SCN_CLEAR_RETRIGGER);
        item.uart_clear_pulse = 1;
        item.post_wait_cycles = 40;
        send_item_cfg(item);

        item = make_item("clear_retrigger_b", SCN_CLEAR_RETRIGGER);
        item.uart_clear_pulse = 1;
        item.post_wait_cycles = 260;
        send_item_cfg(item);

        for (int i = 0; i < 8; i++) begin
            item = make_item($sformatf("random_%0d", i), SCN_RANDOM_MIX);
            item.uart_valid = $urandom_range(0, 1);
            item.uart_pen_color = $urandom_range(0, 7);
            item.uart_eraser = $urandom_range(0, 1);
            item.uart_size = $urandom_range(0, 1);
            item.uart_texture_enable = $urandom_range(0, 1);
            item.uart_texture_shape = $urandom_range(0, 7);
            item.uart_paper = $urandom_range(0, 1);
            item.uart_clear_pulse = (i == 2) ? 1'b1 : $urandom_range(0, 1);
            item.btn_eraser = $urandom_range(0, 1);
            item.btn_mode = $urandom_range(0, 1);
            item.btn_size = $urandom_range(0, 1);
            item.idle_before_cycles = $urandom_range(0, 2);
            item.post_wait_cycles = $urandom_range(1, 4);
            send_item_cfg(item);
        end
    endtask
endclass

`endif
