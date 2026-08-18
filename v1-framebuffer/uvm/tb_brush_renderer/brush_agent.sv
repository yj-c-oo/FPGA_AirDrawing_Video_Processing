`ifndef BRUSH_AGENT_SV
`define BRUSH_AGENT_SV

class brush_sequencer extends uvm_sequencer #(brush_seq_item);
    `uvm_component_utils(brush_sequencer)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
endclass


class brush_agent extends uvm_agent;
    `uvm_component_utils(brush_agent)

    brush_driver          drv;
    brush_sequencer       sqr;
    brush_input_monitor   input_mon;
    brush_output_monitor  output_mon;

    virtual brush_if vif;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual brush_if)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"Cannot get brush_if")

        sqr = brush_sequencer::type_id::create("sqr",this);

        drv = brush_driver::type_id::create("drv",this);

        input_mon = brush_input_monitor::type_id::create("input_mon",this);

        output_mon = brush_output_monitor::type_id::create("output_mon",this);

        uvm_config_db #(virtual brush_if)::set(this,"*","vif",vif);

    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(sqr.seq_item_export);

    endfunction

endclass

`endif