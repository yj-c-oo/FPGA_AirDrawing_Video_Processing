`ifndef PENCONTROL_DRIVER_SV
`define PENCONTROL_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "pencontrol_seq_item.sv"
`include "pencontrol_packet_item.sv"

class pencontrol_driver extends uvm_driver #(pencontrol_seq_item);
    `uvm_component_utils(pencontrol_driver)

    localparam int unsigned CLEAR_STRETCH = 256;
    localparam bit [2:0]    SHAPE_MAX     = 3'd4;

    uvm_analysis_port #(pencontrol_packet_item) exp_ap;
    uvm_analysis_port #(pencontrol_seq_item)    cov_ap;
    virtual pencontrol_if vif;

    bit [2:0] model_pen_color;
    bit       model_eraser;
    bit       model_size;
    bit       model_texture_enable;
    bit [2:0] model_texture_shape;
    bit       model_paper;
    bit       model_clear;
    bit       model_clear_active;
    int unsigned model_clear_cnt;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_ap = new("exp_ap", this);
        cov_ap = new("cov_ap", this);
        if (!uvm_config_db#(virtual pencontrol_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "driver failed to get pencontrol_if")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        pencontrol_seq_item req;

        init_inputs();
        wait (vif.rst == 1'b0);
        @(posedge vif.clk);
        reset_model();
        emit_expected_snapshot(SCN_RESET_IDLE, 0);
        `uvm_info(get_type_name(), "Reset deasserted, starting pencontrol driving", UVM_MEDIUM)

        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task init_inputs();
        vif.i_uart_valid          <= 1'b0;
        vif.i_uart_pen_color      <= 3'b000;
        vif.i_uart_eraser         <= 1'b0;
        vif.i_uart_size           <= 1'b0;
        vif.i_uart_texture_enable <= 1'b0;
        vif.i_uart_texture_shape  <= 3'b000;
        vif.i_uart_paper          <= 1'b0;
        vif.i_uart_clear_pulse    <= 1'b0;
        vif.i_btn_eraser          <= 1'b0;
        vif.i_btn_mode            <= 1'b0;
        vif.i_btn_size            <= 1'b0;
    endtask

    function void reset_model();
        model_pen_color      = 3'b100;
        model_eraser         = 1'b0;
        model_size           = 1'b0;
        model_texture_enable = 1'b0;
        model_texture_shape  = 3'd0;
        model_paper          = 1'b0;
        model_clear_active   = 1'b0;
        model_clear_cnt      = 0;
        model_clear          = 1'b0;
    endfunction

    function bit state_changed(
        bit [2:0] prev_pen_color,
        bit       prev_eraser,
        bit       prev_size,
        bit       prev_texture_enable,
        bit [2:0] prev_texture_shape,
        bit       prev_paper,
        bit       prev_clear
    );
        return (prev_pen_color      != model_pen_color)      ||
               (prev_eraser         != model_eraser)         ||
               (prev_size           != model_size)           ||
               (prev_texture_enable != model_texture_enable) ||
               (prev_texture_shape  != model_texture_shape)  ||
               (prev_paper          != model_paper)          ||
               (prev_clear          != model_clear);
    endfunction

    function void model_step(bit active, pencontrol_seq_item req);
        bit [2:0] curr_pen_color;
        bit       curr_eraser;
        bit       curr_size;
        bit       curr_texture_enable;
        bit [2:0] curr_texture_shape;
        bit       curr_paper;
        bit       curr_clear_active;
        int unsigned curr_clear_cnt;

        curr_pen_color      = model_pen_color;
        curr_eraser         = model_eraser;
        curr_size           = model_size;
        curr_texture_enable = model_texture_enable;
        curr_texture_shape  = model_texture_shape;
        curr_paper          = model_paper;
        curr_clear_active   = model_clear_active;
        curr_clear_cnt      = model_clear_cnt;

        if (active && req.uart_valid) begin
            model_pen_color      = req.uart_pen_color;
            model_eraser         = req.uart_eraser;
            model_size           = req.uart_size;
            model_texture_enable = req.uart_texture_enable;
            model_texture_shape  = (req.uart_texture_shape > SHAPE_MAX)
                                  ? SHAPE_MAX : req.uart_texture_shape;
            model_paper          = req.uart_paper;
        end

        if (active && req.btn_eraser) begin
            model_eraser = ~curr_eraser;
        end

        if (active && req.btn_size) begin
            model_size = ~curr_size;
            if (curr_texture_enable) begin
                if (curr_texture_shape <= 3'd2) begin
                    model_texture_shape = (~curr_size) ? 3'd2 : 3'd0;
                end else begin
                    model_texture_shape = (~curr_size) ? 3'd4 : 3'd3;
                end
            end
        end

        if (active && req.btn_mode) begin
            model_eraser = 1'b0;
            if (!curr_texture_enable) begin
                model_texture_enable = 1'b1;
                model_texture_shape  = curr_size ? 3'd2 : 3'd0;
            end else if (curr_texture_shape <= 3'd2) begin
                model_texture_shape = curr_size ? 3'd4 : 3'd3;
            end else begin
                model_texture_enable = 1'b0;
            end
        end

        if (active && req.uart_clear_pulse) begin
            model_clear_active = 1'b1;
            model_clear_cnt    = 0;
        end else if (curr_clear_active) begin
            if (curr_clear_cnt == CLEAR_STRETCH - 1) begin
                model_clear_active = 1'b0;
                model_clear_cnt    = 0;
            end else begin
                model_clear_cnt = curr_clear_cnt + 1;
            end
        end

        model_clear = model_clear_active;
    endfunction

    task emit_expected_snapshot(pencontrol_scenario_e scenario, int unsigned item_id);
        pencontrol_packet_item exp_tx;

        exp_tx = pencontrol_packet_item::type_id::create($sformatf("exp_%0d", item_id));
        exp_tx.scenario        = scenario;
        exp_tx.item_id         = item_id;
        exp_tx.cycle_id        = vif.cycle_count;
        exp_tx.event_time_ns   = $time;
        exp_tx.pen_color       = model_pen_color;
        exp_tx.eraser          = model_eraser;
        exp_tx.size            = model_size;
        exp_tx.texture_enable  = model_texture_enable;
        exp_tx.texture_shape   = model_texture_shape;
        exp_tx.paper           = model_paper;
        exp_tx.clear           = model_clear;
        exp_ap.write(exp_tx);
    endtask

    task drive_cycle(bit active, pencontrol_seq_item req);
        bit [2:0] prev_pen_color;
        bit       prev_eraser;
        bit       prev_size;
        bit       prev_texture_enable;
        bit [2:0] prev_texture_shape;
        bit       prev_paper;
        bit       prev_clear;

        @(negedge vif.clk);
        vif.i_uart_valid          <= active ? req.uart_valid          : 1'b0;
        vif.i_uart_pen_color      <= active ? req.uart_pen_color      : 3'b000;
        vif.i_uart_eraser         <= active ? req.uart_eraser         : 1'b0;
        vif.i_uart_size           <= active ? req.uart_size           : 1'b0;
        vif.i_uart_texture_enable <= active ? req.uart_texture_enable : 1'b0;
        vif.i_uart_texture_shape  <= active ? req.uart_texture_shape  : 3'b000;
        vif.i_uart_paper          <= active ? req.uart_paper          : 1'b0;
        vif.i_uart_clear_pulse    <= active ? req.uart_clear_pulse    : 1'b0;
        vif.i_btn_eraser          <= active ? req.btn_eraser          : 1'b0;
        vif.i_btn_mode            <= active ? req.btn_mode            : 1'b0;
        vif.i_btn_size            <= active ? req.btn_size            : 1'b0;

        prev_pen_color      = model_pen_color;
        prev_eraser         = model_eraser;
        prev_size           = model_size;
        prev_texture_enable = model_texture_enable;
        prev_texture_shape  = model_texture_shape;
        prev_paper          = model_paper;
        prev_clear          = model_clear;

        @(posedge vif.clk);
        model_step(active, req);
        if (state_changed(
            prev_pen_color, prev_eraser, prev_size, prev_texture_enable,
            prev_texture_shape, prev_paper, prev_clear
        )) begin
            emit_expected_snapshot(req.scenario, req.item_id);
        end
    endtask

    task drive_item(pencontrol_seq_item req);
        pencontrol_seq_item cov_item;

        cov_item = pencontrol_seq_item::type_id::create($sformatf("cov_%0d", req.item_id));
        cov_item.copy(req);
        cov_ap.write(cov_item);

        repeat (req.idle_before_cycles) begin
            drive_cycle(1'b0, req);
        end

        drive_cycle(1'b1, req);

        repeat (req.post_wait_cycles) begin
            drive_cycle(1'b0, req);
        end

        `uvm_info(get_type_name(), $sformatf("Driven %s", req.convert2string()), UVM_LOW)
    endtask
endclass

`endif
