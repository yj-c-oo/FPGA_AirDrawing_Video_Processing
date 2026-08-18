`ifndef UARTSENDER_AGENT_SV
`define UARTSENDER_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_driver.sv"
`include "uartsender_monitor.sv"

class uartsender_agent extends uvm_agent;
    `uvm_component_utils(uartsender_agent)

    uvm_sequencer #(uartsender_seq_item) sqr;
    uartsender_driver                    drv;
    uartsender_monitor                   mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer#(uartsender_seq_item)::type_id::create("sqr", this);
        drv = uartsender_driver::type_id::create("drv", this);
        mon = uartsender_monitor::type_id::create("mon", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass

`endif
