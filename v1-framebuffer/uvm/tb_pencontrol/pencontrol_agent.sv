`ifndef PENCONTROL_AGENT_SV
`define PENCONTROL_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "pencontrol_driver.sv"
`include "pencontrol_monitor.sv"

class pencontrol_agent extends uvm_agent;
    `uvm_component_utils(pencontrol_agent)

    uvm_sequencer #(pencontrol_seq_item) sqr;
    pencontrol_driver                    drv;
    pencontrol_monitor                   mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer#(pencontrol_seq_item)::type_id::create("sqr", this);
        drv = pencontrol_driver::type_id::create("drv", this);
        mon = pencontrol_monitor::type_id::create("mon", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass

`endif
