`ifndef UARTRXPACKED_DRIVER_SV
`define UARTRXPACKED_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartrxpacked_seq_item.sv"
`include "uartrxpacked_byte_item.sv"
`include "uartrxpacked_packet_item.sv"

class uartrxpacked_driver extends uvm_driver #(uartrxpacked_seq_item);
    `uvm_component_utils(uartrxpacked_driver)

    localparam int UART_BIT_TICKS = 16;
    localparam int UART_FRAME_BITS = 10;
    localparam int UART_BYTE_TICKS = UART_BIT_TICKS * UART_FRAME_BITS;
    localparam int DEFAULT_TIMEOUT_GAP_TICKS = 512;
    localparam int RX_DONE_ALIGN_TICKS = 8;

    uvm_analysis_port #(uartrxpacked_byte_item)   byte_exp_ap;
    uvm_analysis_port #(uartrxpacked_packet_item) packet_exp_ap;
    uvm_analysis_port #(uartrxpacked_seq_item)    cov_ap;
    virtual uartrxpacked_if vif;
    int unsigned last_exp_cycle_id;
    time         last_exp_event_time_ns;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        byte_exp_ap   = new("byte_exp_ap", this);
        packet_exp_ap = new("packet_exp_ap", this);
        cov_ap        = new("cov_ap", this);
        if (!uvm_config_db#(virtual uartrxpacked_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "driver failed to get uartrxpacked_if")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        init_line();
        wait (vif.rst == 1'b0);
        `uvm_info(get_type_name(), "Reset deasserted, starting UART RX packet driving", UVM_MEDIUM)

        forever begin
            uartrxpacked_seq_item req;

            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task init_line();
        vif.drv_cb.rx <= 1'b1;
    endtask

    task wait_baud_ticks(int unsigned ticks);
        int unsigned count;

        count = 0;
        while (count < ticks) begin
            @(vif.drv_cb);
            if (vif.drv_cb.baud_tick_dbg) begin
                count++;
            end
        end
    endtask

    task drive_idle_ticks(int unsigned ticks);
        vif.drv_cb.rx <= 1'b1;
        wait_baud_ticks(ticks);
    endtask

    task emit_expected_byte(
        uartrxpacked_seq_item req,
        int unsigned          byte_index,
        bit [7:0]             byte_value
    );
        uartrxpacked_byte_item exp_byte;

        exp_byte = uartrxpacked_byte_item::type_id::create(
            $sformatf("exp_byte_p%0d_b%0d", req.packet_id, byte_index)
        );
        exp_byte.scenario      = req.scenario;
        exp_byte.packet_id     = req.packet_id;
        exp_byte.byte_index    = byte_index;
        exp_byte.byte_value    = byte_value;
        exp_byte.cycle_id      = vif.cycle_count;
        exp_byte.event_time_ns = $time;
        last_exp_cycle_id      = exp_byte.cycle_id;
        last_exp_event_time_ns = exp_byte.event_time_ns;
        byte_exp_ap.write(exp_byte);
    endtask

    task emit_expected_packet(uartrxpacked_seq_item req);
        uartrxpacked_packet_item exp_pkt;

        exp_pkt = uartrxpacked_packet_item::type_id::create(
            $sformatf("exp_pkt_%0d", req.packet_id)
        );
        exp_pkt.scenario        = req.scenario;
        exp_pkt.packet_id       = req.packet_id;
        exp_pkt.cycle_id        = last_exp_cycle_id;
        exp_pkt.event_time_ns   = last_exp_event_time_ns;
        exp_pkt.packet_valid    = req.expects_packet_valid();
        exp_pkt.clear_pulse     = req.expected_clear_pulse();
        exp_pkt.pen_color       = req.expected_pen_color();
        exp_pkt.eraser          = req.expected_eraser();
        exp_pkt.size            = req.expected_size();
        exp_pkt.texture_enable  = req.expected_texture_enable();
        exp_pkt.texture_shape   = req.expected_texture_shape();
        exp_pkt.paper           = req.expected_paper();
        packet_exp_ap.write(exp_pkt);
    endtask

    task send_uart_byte(
        uartrxpacked_seq_item req,
        int unsigned          byte_index,
        bit [7:0]             byte_value
    );
        vif.drv_cb.rx <= 1'b0;
        wait_baud_ticks(UART_BIT_TICKS);

        for (int bit_idx = 0; bit_idx < 8; bit_idx++) begin
            vif.drv_cb.rx <= byte_value[bit_idx];
            wait_baud_ticks(UART_BIT_TICKS);
        end

        vif.drv_cb.rx <= 1'b1;
        wait_baud_ticks(RX_DONE_ALIGN_TICKS);
        emit_expected_byte(req, byte_index, byte_value);
        wait_baud_ticks(UART_BIT_TICKS - RX_DONE_ALIGN_TICKS);
    endtask

    task drive_item(uartrxpacked_seq_item req);
        uartrxpacked_seq_item cov_item;
        bit [7:0]             packet_bytes[4];
        int unsigned          bytes_to_send;

        cov_item = uartrxpacked_seq_item::type_id::create(
            $sformatf("cov_item_%0d", req.packet_id)
        );
        cov_item.copy(req);
        cov_ap.write(cov_item);

        drive_idle_ticks(req.idle_before_ticks);

        if (req.is_idle_only()) begin
            drive_idle_ticks(req.idle_after_ticks);
            `uvm_info(get_type_name(),
                $sformatf("Driven idle-only scenario %s", req.scenario_name()),
                UVM_LOW)
            return;
        end

        packet_bytes[0] = req.start_byte;
        packet_bytes[1] = req.control_byte;
        packet_bytes[2] = req.shape_byte;
        packet_bytes[3] = req.end_byte;
        bytes_to_send = req.sent_byte_count();

        for (int idx = 0; idx < bytes_to_send; idx++) begin
            send_uart_byte(req, idx, packet_bytes[idx]);
            case (idx)
                0: if (req.gap_after_byte0_ticks != 0) drive_idle_ticks(req.gap_after_byte0_ticks);
                1: if (req.gap_after_byte1_ticks != 0) drive_idle_ticks(req.gap_after_byte1_ticks);
                2: if (req.gap_after_byte2_ticks != 0) drive_idle_ticks(req.gap_after_byte2_ticks);
                default: ;
            endcase
        end

        if (req.timeout_after_byte >= 0) begin
            drive_idle_ticks(
                (req.timeout_gap_ticks == 0) ? DEFAULT_TIMEOUT_GAP_TICKS : req.timeout_gap_ticks
            );
        end else if (req.expects_packet_valid()) begin
            emit_expected_packet(req);
        end

        drive_idle_ticks(req.idle_after_ticks);

        `uvm_info(get_type_name(),
            $sformatf("Driven %s", req.convert2string()),
            UVM_LOW)
    endtask
endclass

`endif
