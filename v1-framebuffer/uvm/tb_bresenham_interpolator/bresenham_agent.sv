`ifndef BRESENHAM_AGENT_SV
`define BRESENHAM_AGENT_SV

class bresenham_agent extends uvm_agent;
    `uvm_component_utils(bresenham_agent)

    uvm_sequencer #(bresenham_seq_item) sqr;

    bresenham_driver         drv;
    bresenham_input_monitor  in_mon;
    bresenham_output_monitor out_mon;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sqr     = uvm_sequencer#(bresenham_seq_item)::type_id::create("sqr",this);

        drv     = bresenham_driver::type_id::create("drv",this);

        in_mon  = bresenham_input_monitor::type_id::create("in_mon",this);

        out_mon = bresenham_output_monitor::type_id::create("out_mon",this);

    endfunction

    function void connect_phase(uvm_phase phase);

        drv.seq_item_port.connect(sqr.seq_item_export);

    endfunction

endclass

`endif