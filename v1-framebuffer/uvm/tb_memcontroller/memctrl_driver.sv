`ifndef MEMCTRL_DRIVER_SV
`define MEMCTRL_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "memctrl_seq_item.sv"
`include "memctrl_timing_item.sv"

class memctrl_driver extends uvm_driver #(memctrl_seq_item);
    `uvm_component_utils(memctrl_driver)

    localparam int FRAME_WIDTH  = 320;
    localparam int FRAME_HEIGHT = 240;
    localparam int FRAME_PIXELS = FRAME_WIDTH * FRAME_HEIGHT;

    uvm_analysis_port #(memctrl_seq_item) ap_exp;
    uvm_analysis_port #(memctrl_timing_item) ap_timing_exp;
    virtual memctrl_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_exp = new("ap_exp", this);
        ap_timing_exp = new("ap_timing_exp", this);
        if (!uvm_config_db#(virtual memctrl_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "driver failed to get memctrl_if")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        init_bus();
        wait (vif.reset == 1'b0);
        `uvm_info(get_type_name(), "Reset deasserted, starting frame generation", UVM_MEDIUM)

        forever begin
            memctrl_seq_item req;
            seq_item_port.get_next_item(req);
            drive_frame(req);
            seq_item_port.item_done();
        end
    endtask

    task init_bus();
        vif.drv_cb.href  <= 1'b0;
        vif.drv_cb.vsync <= 1'b0;
        vif.drv_cb.pdata <= 8'h00;
    endtask

    function automatic logic [31:0] lcg_next(logic [31:0] state);
        return state * 32'd1664525 + 32'd1013904223;
    endfunction

    function automatic logic [15:0] next_random_pixel(ref logic [31:0] state);
        state = lcg_next(state);
        return state[15:0];
    endfunction

    function automatic logic [15:0] gen_pixel(
        mem_frame_kind_e kind,
        int              pixel_idx,
        ref logic [31:0] rng_state
    );
        logic [15:0] pixel;

        case (kind)
            FRAME_ALL_ZERO: begin
                pixel = 16'h0000;
            end
            FRAME_ALL_ONE: begin
                pixel = 16'hFFFF;
            end
            FRAME_RED_HEAVY: begin
                pixel = {5'h1F, pixel_idx[5:0], pixel_idx[4:0]};
            end
            FRAME_GREEN_HEAVY: begin
                pixel = {pixel_idx[4:0], 6'h3F, pixel_idx[4:0]};
            end
            FRAME_BLUE_HEAVY: begin
                pixel = {pixel_idx[4:0], pixel_idx[5:0], 5'h1F};
            end
            default: begin
                pixel = next_random_pixel(rng_state);
            end
        endcase

        return pixel;
    endfunction

    task drive_idle(int cycles);
        repeat (cycles) begin
            vif.drv_cb.href  <= 1'b0;
            vif.drv_cb.vsync <= 1'b0;
            vif.drv_cb.pdata <= 8'h00;
            @(vif.drv_cb);
        end
    endtask

    task pulse_vsync(int cycles = 2);
        repeat (cycles) begin
            vif.drv_cb.href  <= 1'b0;
            vif.drv_cb.vsync <= 1'b1;
            vif.drv_cb.pdata <= 8'h00;
            @(vif.drv_cb);
        end

        vif.drv_cb.vsync <= 1'b0;
        vif.drv_cb.href  <= 1'b0;
        vif.drv_cb.pdata <= 8'h00;
        @(vif.drv_cb);
    endtask

    task drive_high_byte(logic [7:0] data);
        vif.drv_cb.vsync <= 1'b0;
        vif.drv_cb.href  <= 1'b1;
        vif.drv_cb.pdata <= data;
        @(vif.drv_cb);
    endtask

    task drive_low_byte(logic [7:0] data);
        vif.drv_cb.vsync <= 1'b0;
        vif.drv_cb.href  <= 1'b1;
        vif.drv_cb.pdata <= data;
        @(vif.drv_cb);
    endtask

    task drive_complete_pixel(logic [15:0] pixel);
        drive_high_byte(pixel[15:8]);
        drive_low_byte(pixel[7:0]);
    endtask

    task drive_frame(memctrl_seq_item req);
        memctrl_seq_item exp_frame;
        memctrl_timing_item exp_timing;
        logic [31:0] rng_state;
        logic [15:0] pixel;

        req.pixels.delete();
        req.first_byte_we_errors  = 0;
        req.second_byte_we_errors = 0;
        req.href_low_we_errors    = 0;
        req.vsync_reset_errors    = 0;
        req.addr_errors           = 0;

        rng_state = (req.pixel_seed == 0) ? 32'hCAFE_F00D : req.pixel_seed;

        pulse_vsync();

        for (int pix = 0; pix < FRAME_PIXELS; pix++) begin
            pixel = gen_pixel(req.frame_kind, pix, rng_state);

            if ((req.frame_kind == FRAME_ODD_HREF_DROP) && (pix == FRAME_PIXELS - 1)) begin
                drive_high_byte(pixel[15:8]);
                drive_idle(2);
                break;
            end

            if ((req.frame_kind == FRAME_ODD_VSYNC_DROP) && (pix == FRAME_PIXELS - 1)) begin
                drive_high_byte(pixel[15:8]);
                pulse_vsync(1);
                break;
            end

            drive_complete_pixel(pixel);
            exp_timing = memctrl_timing_item::type_id::create(
                $sformatf("exp_timing_f%0d_p%0d", req.frame_id, pix)
            );
            exp_timing.event_kind  = TIMING_EVT_WRITE;
            exp_timing.frame_id    = req.frame_id;
            exp_timing.pixel_index = pix;
            exp_timing.cycle_id    = vif.cycle_count;
            exp_timing.event_time_ns = $time;
            exp_timing.we          = 1'b1;
            exp_timing.waddr       = pix;
            exp_timing.wdata       = pixel;
            ap_timing_exp.write(exp_timing);
            req.pixels.push_back(pixel);

            if ((req.frame_kind == FRAME_HREF_GAP) && (pix == FRAME_PIXELS / 2)) begin
                drive_idle(4);
            end
        end

        drive_idle(2);

        exp_frame = memctrl_seq_item::type_id::create($sformatf("exp_frame_%0d", req.frame_id));
        exp_frame.copy(req);
        ap_exp.write(exp_frame);

        `uvm_info(get_type_name(), $sformatf("Driven %s", req.convert2string()), UVM_LOW)
    endtask
endclass

`endif
