`ifndef PENCONTROL_TEST_SV
`define PENCONTROL_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "pencontrol_env.sv"
`include "pencontrol_sequence.sv"

class pencontrol_base_test extends uvm_test;
    `uvm_component_utils(pencontrol_base_test)

    pencontrol_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = pencontrol_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        pencontrol_base_seq seq;

        phase.raise_objection(this);
        seq = pencontrol_base_seq::type_id::create("seq");
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask
endclass

`endif
