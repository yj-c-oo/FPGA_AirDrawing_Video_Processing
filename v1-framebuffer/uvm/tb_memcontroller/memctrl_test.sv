`ifndef MEMCTRL_TEST_SV
`define MEMCTRL_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class memctrl_base_test extends uvm_test;
    `uvm_component_utils(memctrl_base_test)

    memctrl_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = memctrl_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "==== UVM topology ====", UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        memctrl_base_seq seq;

        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 100_000);

        seq = memctrl_base_seq::type_id::create("seq");
        seq.num_random_frames = 20;
        seq.start(env.agt.sqr);

        phase.drop_objection(this);
    endtask
endclass

`endif
