`ifndef MEMCTRL_SEQUENCE_SV
`define MEMCTRL_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "memctrl_seq_item.sv"

class memctrl_base_seq extends uvm_sequence #(memctrl_seq_item);
    `uvm_object_utils(memctrl_base_seq)

    int unsigned num_random_frames = 150;

    function new(string name = "memctrl_base_seq");
        super.new(name);
    endfunction

    task send_frame(mem_frame_kind_e kind, int unsigned frame_id);
        memctrl_seq_item item;

        item = memctrl_seq_item::type_id::create($sformatf("frame_%0d", frame_id));
        start_item(item);
        item.frame_kind = kind;
        item.frame_id   = frame_id;

        if (kind == FRAME_RANDOM) begin
            if (!item.randomize() with { pixel_seed != 32'd0; }) begin
                `uvm_fatal(get_type_name(), "Random frame randomize() failed")
            end
        end else begin
            item.pixel_seed = 32'h1ACE_0000 | frame_id;
        end

        finish_item(item);
        `uvm_info(get_type_name(), $sformatf("Queued frame %0d (%s)", frame_id, item.kind_name()), UVM_MEDIUM)
    endtask

    virtual task body();
        int unsigned frame_id;

        frame_id = 0;
        send_frame(FRAME_ALL_ZERO, frame_id++);
        send_frame(FRAME_ALL_ONE, frame_id++);
        send_frame(FRAME_RED_HEAVY, frame_id++);
        send_frame(FRAME_GREEN_HEAVY, frame_id++);
        send_frame(FRAME_BLUE_HEAVY, frame_id++);
        send_frame(FRAME_HREF_GAP, frame_id++);
        send_frame(FRAME_ODD_HREF_DROP, frame_id++);

        for (int i = 0; i < num_random_frames; i++) begin
            send_frame(FRAME_RANDOM, frame_id++);
        end

        send_frame(FRAME_ODD_VSYNC_DROP, frame_id++);
    endtask
endclass

`endif 
