`ifndef UARTRXPACKED_AGENT_SV
`define UARTRXPACKED_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartrxpacked_seq_item.sv"

typedef uvm_sequencer #(uartrxpacked_seq_item) uartrxpacked_sequencer;

class uartrxpacked_agent extends uvm_agent;
    `uvm_component_utils(uartrxpacked_agent)

    uartrxpacked_driver    drv;
    uartrxpacked_monitor   mon;
    uartrxpacked_sequencer sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = uartrxpacked_driver::type_id::create("drv", this);
        mon = uartrxpacked_monitor::type_id::create("mon", this);
        sqr = uartrxpacked_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass

`endif
