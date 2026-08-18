`ifndef BBOX_AGENT_SV
`define BBOX_AGENT_SV


class bbox_agent extends uvm_agent;

    `uvm_component_utils(bbox_agent)

    bbox_driver                      drv;
    bbox_input_monitor               input_mon;
    bbox_output_monitor              output_mon;

    uvm_sequencer #(bbox_frame_item) sqr;

    function new(string name, uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        sqr = uvm_sequencer#(bbox_frame_item)::type_id::create("sqr", this);

        drv = bbox_driver::type_id::create("drv", this);

        input_mon = bbox_input_monitor::type_id::create("input_mon", this);

        output_mon = bbox_output_monitor::type_id::create("output_mon", this);

    endfunction



    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        drv.seq_item_port.connect(sqr.seq_item_export);

    endfunction

endclass

`endif
