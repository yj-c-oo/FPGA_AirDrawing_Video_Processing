`ifndef MEMCTRL_AGENT_SV
`define MEMCTRL_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "memctrl_seq_item.sv"

typedef uvm_sequencer #(memctrl_seq_item) memctrl_sequencer;

class memctrl_agent extends uvm_agent;
    `uvm_component_utils(memctrl_agent)

    memctrl_driver    drv;
    memctrl_monitor   mon;
    memctrl_sequencer sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = memctrl_driver::type_id::create("drv", this);
        mon = memctrl_monitor::type_id::create("mon", this);
        sqr = memctrl_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass

`endif
