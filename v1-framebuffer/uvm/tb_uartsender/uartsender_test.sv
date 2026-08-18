`ifndef UARTSENDER_TEST_SV
`define UARTSENDER_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_env.sv"
`include "uartsender_sequence.sv"

class uartsender_base_test extends uvm_test;
    `uvm_component_utils(uartsender_base_test)

    uartsender_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uartsender_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        uartsender_base_seq seq;

        phase.raise_objection(this);
        seq = uartsender_base_seq::type_id::create("seq");
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask
endclass

`endif
