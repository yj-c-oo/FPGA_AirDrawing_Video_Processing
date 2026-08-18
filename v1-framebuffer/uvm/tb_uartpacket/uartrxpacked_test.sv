`ifndef UARTRXPACKED_TEST_SV
`define UARTRXPACKED_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class uartrxpacked_base_test extends uvm_test;
    `uvm_component_utils(uartrxpacked_base_test)

    uartrxpacked_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uartrxpacked_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "==== UVM topology ====", UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        uartrxpacked_base_seq seq;

        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100_000);

        seq = uartrxpacked_base_seq::type_id::create("seq");
        seq.num_random_packets = 20;
        seq.start(env.agt.sqr);

        phase.drop_objection(this);
    endtask
endclass

`endif
