`ifndef UARTSENDER_DRIVER_SV
`define UARTSENDER_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_seq_item.sv"
`include "uartsender_byte_item.sv"
`include "uartsender_packet_item.sv"

class uartsender_driver extends uvm_driver #(uartsender_seq_item);
    `uvm_component_utils(uartsender_driver)

    localparam int UART_BYTE_TICKS = 160;
    localparam int GM_S_IDLE       = 0;
    localparam int GM_S_START_BYTE = 1;
    localparam int GM_S_WAIT_BYTE  = 2;
    localparam int GM_T_IDLE       = 0;
    localparam int GM_T_START      = 1;
    localparam int GM_T_DATA       = 2;
    localparam int GM_T_STOP       = 3;

    uvm_analysis_port #(uartsender_byte_item)   byte_exp_ap;
    uvm_analysis_port #(uartsender_packet_item) packet_exp_ap;
    uvm_analysis_port #(uartsender_seq_item)    cov_ap;
    virtual uartsender_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        byte_exp_ap   = new("byte_exp_ap", this);
        packet_exp_ap = new("packet_exp_ap", this);
        cov_ap        = new("cov_ap", this);
        if (!uvm_config_db#(virtual uartsender_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "driver failed to get uartsender_if")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        init_inputs();
        wait (vif.rst == 1'b0);
        `uvm_info(get_type_name(), "Reset deasserted, starting uartsender driving", UVM_MEDIUM)

        forever begin
            uartsender_seq_item req;
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task init_inputs();
        vif.send_trigger      <= 1'b0;
        vif.X_center          <= '0;
        vif.Y_center          <= '0;
        vif.sw_paint_red      <= 1'b0;
        vif.sw_paint_green    <= 1'b0;
        vif.sw_paint_blue     <= 1'b0;
        vif.sw_eraser         <= 1'b0;
        vif.sw_size           <= 1'b0;
        vif.sw_texture_enable <= 1'b0;
        vif.texture_shape     <= '0;
        vif.paper             <= 1'b0;
        vif.clear_btn         <= 1'b0;
    endtask

    task set_payload(uartsender_seq_item req);
        vif.X_center          <= req.X_center;
        vif.Y_center          <= req.Y_center;
        vif.sw_paint_red      <= req.sw_paint_red;
        vif.sw_paint_green    <= req.sw_paint_green;
        vif.sw_paint_blue     <= req.sw_paint_blue;
        vif.sw_eraser         <= req.sw_eraser;
        vif.sw_size           <= req.sw_size;
        vif.sw_texture_enable <= req.sw_texture_enable;
        vif.texture_shape     <= req.texture_shape;
        vif.paper             <= req.paper;
        vif.clear_btn         <= req.clear_btn;
    endtask

    task wait_baud_ticks(int unsigned ticks);
        int unsigned count;
        count = 0;
        while (count < ticks) begin
            @(posedge vif.clk);
            if (vif.baud_tick_dbg) begin
                count++;
            end
        end
    endtask

    task idle_cycles(int unsigned cycles);
        repeat (cycles) begin
            @(negedge vif.clk);
            vif.send_trigger <= 1'b0;
            @(posedge vif.clk);
        end
    endtask

    task emit_expected_byte(
        uartsender_seq_item req,
        int unsigned        idx,
        int unsigned        ref_cycle_id,
        longint unsigned    ref_time_ns
    );
        uartsender_byte_item exp_tx;

        exp_tx = uartsender_byte_item::type_id::create($sformatf("exp_b_%0d_%0d", req.packet_id, idx));
        exp_tx.scenario      = req.scenario;
        exp_tx.packet_id     = req.packet_id;
        exp_tx.byte_index    = idx;
        exp_tx.byte_value    = req.expected_byte(idx);
        exp_tx.ref_cycle_id  = ref_cycle_id;
        exp_tx.ref_time_ns   = ref_time_ns;
        exp_tx.cycle_id      = vif.cycle_count;
        exp_tx.event_time_ns = $time;
        byte_exp_ap.write(exp_tx);
    endtask

    task emit_expected_packet(
        uartsender_seq_item req,
        int unsigned        ref_cycle_id,
        longint unsigned    ref_time_ns
    );
        uartsender_packet_item exp_pkt;

        exp_pkt = uartsender_packet_item::type_id::create($sformatf("exp_p_%0d", req.packet_id));
        exp_pkt.scenario      = req.scenario;
        exp_pkt.packet_id     = req.packet_id;
        exp_pkt.ref_cycle_id  = ref_cycle_id;
        exp_pkt.ref_time_ns   = ref_time_ns;
        exp_pkt.cycle_id      = vif.cycle_count;
        exp_pkt.event_time_ns = $time;
        exp_pkt.byte0         = req.expected_byte(0);
        exp_pkt.byte1         = req.expected_byte(1);
        exp_pkt.byte2         = req.expected_byte(2);
        exp_pkt.byte3         = req.expected_byte(3);
        exp_pkt.byte4         = req.expected_byte(4);
        exp_pkt.byte5         = req.expected_byte(5);
        packet_exp_ap.write(exp_pkt);
    endtask

    task pulse_busy_retrigger();
        @(negedge vif.clk);
        vif.send_trigger <= 1'b1;
        @(posedge vif.clk);
        @(negedge vif.clk);
        vif.send_trigger <= 1'b0;
    endtask

    task drive_initial_trigger(uartsender_seq_item req);
        @(negedge vif.clk);
        set_payload(req);
        vif.send_trigger <= 1'b1;
        repeat (req.trigger_hold_cycles) begin
            @(posedge vif.clk);
            if (req.trigger_hold_cycles > 1) begin
                @(negedge vif.clk);
                set_payload(req);
                vif.send_trigger <= 1'b1;
            end
        end
        @(negedge vif.clk);
        vif.send_trigger <= 1'b0;
    endtask

    task run_golden_timing_model(
        uartsender_seq_item req,
        int unsigned        ref_cycle_id,
        longint unsigned    ref_time_ns
    );
        int unsigned      gm_sender_state;
        int unsigned      gm_sender_state_next;
        int unsigned      gm_tx_state;
        int unsigned      gm_tx_state_next;
        bit               gm_trigger_meta;
        bit               gm_trigger_meta_next;
        bit               gm_trigger_sync;
        bit               gm_trigger_sync_next;
        bit               gm_trigger_sync_d;
        bit               gm_trigger_sync_d_next;
        bit               gm_trigger_pulse;
        bit [2:0]         gm_byte_index;
        bit [2:0]         gm_byte_index_next;
        bit               gm_tx_start_reg;
        bit               gm_tx_start_next;
        bit               gm_tx_busy_reg;
        bit               gm_tx_busy_next;
        bit               gm_tx_done_reg;
        bit               gm_tx_done_next;
        bit [3:0]         gm_b_tick_cnt;
        bit [3:0]         gm_b_tick_cnt_next;
        bit [2:0]         gm_bit_cnt;
        bit [2:0]         gm_bit_cnt_next;
        int unsigned      emitted_bytes;

        gm_sender_state = GM_S_IDLE;
        gm_tx_state     = GM_T_IDLE;
        gm_trigger_meta = 1'b0;
        gm_trigger_sync = 1'b0;
        gm_trigger_sync_d = 1'b0;
        gm_byte_index   = 3'd0;
        gm_tx_start_reg = 1'b0;
        gm_tx_busy_reg  = 1'b0;
        gm_tx_done_reg  = 1'b0;
        gm_b_tick_cnt   = 4'd0;
        gm_bit_cnt      = 3'd0;
        emitted_bytes   = 0;

        forever begin
            @(posedge vif.clk);

            // Emit on the same registered events the monitor observes.
            if (gm_tx_start_reg && (emitted_bytes < 6)) begin
                emit_expected_byte(req, emitted_bytes, ref_cycle_id, ref_time_ns);
                emitted_bytes++;
            end
            if (gm_tx_done_reg && (emitted_bytes == 6)) begin
                emit_expected_packet(req, ref_cycle_id, ref_time_ns);
                break;
            end

            gm_trigger_pulse = gm_trigger_sync & ~gm_trigger_sync_d;

            gm_sender_state_next = gm_sender_state;
            gm_byte_index_next   = gm_byte_index;
            gm_tx_start_next     = 1'b0;
            case (gm_sender_state)
                GM_S_IDLE: begin
                    if (gm_trigger_pulse) begin
                        gm_byte_index_next   = 3'd0;
                        gm_sender_state_next = GM_S_START_BYTE;
                    end
                end

                GM_S_START_BYTE: begin
                    if (!gm_tx_busy_reg) begin
                        gm_tx_start_next     = 1'b1;
                        gm_sender_state_next = GM_S_WAIT_BYTE;
                    end
                end

                GM_S_WAIT_BYTE: begin
                    if (gm_tx_done_reg) begin
                        if (gm_byte_index == 3'd5) begin
                            gm_sender_state_next = GM_S_IDLE;
                        end else begin
                            gm_byte_index_next   = gm_byte_index + 3'd1;
                            gm_sender_state_next = GM_S_START_BYTE;
                        end
                    end
                end
            endcase

            gm_tx_state_next  = gm_tx_state;
            gm_tx_busy_next   = gm_tx_busy_reg;
            gm_tx_done_next   = gm_tx_done_reg;
            gm_b_tick_cnt_next = gm_b_tick_cnt;
            gm_bit_cnt_next   = gm_bit_cnt;
            case (gm_tx_state)
                GM_T_IDLE: begin
                    gm_b_tick_cnt_next = 4'd0;
                    gm_bit_cnt_next    = 3'd0;
                    gm_tx_busy_next    = 1'b0;
                    gm_tx_done_next    = 1'b0;
                    if (gm_tx_start_reg) begin
                        gm_tx_state_next = GM_T_START;
                        gm_tx_busy_next  = 1'b1;
                    end
                end

                GM_T_START: begin
                    if (vif.baud_tick_dbg) begin
                        if (gm_b_tick_cnt == 4'd15) begin
                            gm_tx_state_next  = GM_T_DATA;
                            gm_b_tick_cnt_next = 4'd0;
                        end else begin
                            gm_b_tick_cnt_next = gm_b_tick_cnt + 4'd1;
                        end
                    end
                end

                GM_T_DATA: begin
                    if (vif.baud_tick_dbg) begin
                        if (gm_b_tick_cnt == 4'd15) begin
                            gm_b_tick_cnt_next = 4'd0;
                            if (gm_bit_cnt == 3'd7) begin
                                gm_tx_state_next = GM_T_STOP;
                            end else begin
                                gm_bit_cnt_next = gm_bit_cnt + 3'd1;
                            end
                        end else begin
                            gm_b_tick_cnt_next = gm_b_tick_cnt + 4'd1;
                        end
                    end
                end

                GM_T_STOP: begin
                    if (vif.baud_tick_dbg) begin
                        if (gm_b_tick_cnt == 4'd15) begin
                            gm_tx_done_next    = 1'b1;
                            gm_tx_busy_next    = 1'b0;
                            gm_b_tick_cnt_next = 4'd0;
                            gm_tx_state_next   = GM_T_IDLE;
                        end else begin
                            gm_b_tick_cnt_next = gm_b_tick_cnt + 4'd1;
                        end
                    end
                end
            endcase

            gm_trigger_meta_next = vif.send_trigger;
            gm_trigger_sync_next = gm_trigger_meta;
            gm_trigger_sync_d_next = gm_trigger_sync;

            gm_sender_state = gm_sender_state_next;
            gm_tx_state     = gm_tx_state_next;
            gm_trigger_meta = gm_trigger_meta_next;
            gm_trigger_sync = gm_trigger_sync_next;
            gm_trigger_sync_d = gm_trigger_sync_d_next;
            gm_byte_index   = gm_byte_index_next;
            gm_tx_start_reg = gm_tx_start_next;
            gm_tx_busy_reg  = gm_tx_busy_next;
            gm_tx_done_reg  = gm_tx_done_next;
            gm_b_tick_cnt   = gm_b_tick_cnt_next;
            gm_bit_cnt      = gm_bit_cnt_next;
        end
    endtask

    task drive_item(uartsender_seq_item req);
        uartsender_seq_item cov_item;
        int unsigned       ref_cycle_id;
        longint unsigned   ref_time_ns;

        cov_item = uartsender_seq_item::type_id::create($sformatf("cov_%0d", req.packet_id));
        cov_item.copy(req);
        cov_ap.write(cov_item);

        idle_cycles(req.idle_before_cycles);
        ref_cycle_id = vif.cycle_count;
        ref_time_ns  = $time;

        if (!req.expect_packet) begin
            drive_initial_trigger(req);
            idle_cycles(req.idle_after_cycles);
            `uvm_info(get_type_name(), $sformatf("Driven ignored trigger %s", req.convert2string()), UVM_LOW)
            return;
        end

        fork
            run_golden_timing_model(req, ref_cycle_id, ref_time_ns);
            begin
                drive_initial_trigger(req);
                if (req.retrigger_during_busy &&
                    (req.retrigger_after_baud_ticks < UART_BYTE_TICKS)) begin
                    wait (vif.tx_busy_dbg == 1'b1);
                    wait_baud_ticks(req.retrigger_after_baud_ticks);
                    pulse_busy_retrigger();
                end
            end
        join

        idle_cycles(req.idle_after_cycles);
        `uvm_info(get_type_name(), $sformatf("Driven %s", req.convert2string()), UVM_LOW)
    endtask
endclass

`endif
