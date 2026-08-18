`ifndef BRESENHAM_TEST_SV
`define BRESENHAM_TEST_SV

class bresenham_base_test extends uvm_test;
    `uvm_component_utils(bresenham_base_test)

    bresenham_env env;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = bresenham_env::type_id::create("env",this);

    endfunction

endclass


class bresenham_random_test extends bresenham_base_test;
    `uvm_component_utils(bresenham_random_test)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        bresenham_random_seq seq;

        phase.raise_objection(this);

        seq = bresenham_random_seq::type_id::create("seq");

        seq.start(env.agent.sqr);

        phase.drop_objection(this);

    endtask

endclass


class bresenham_boundary_test extends bresenham_base_test;
    `uvm_component_utils(bresenham_boundary_test)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        bresenham_boundary_seq seq;

        phase.raise_objection(this);

        seq = bresenham_boundary_seq::type_id::create("seq");

        seq.start(env.agent.sqr);

        phase.drop_objection(this);

    endtask

endclass


class bresenham_regression_test extends bresenham_base_test;
    `uvm_component_utils(bresenham_regression_test)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        bresenham_regression_seq seq;

        phase.raise_objection(this);

        seq = bresenham_regression_seq::type_id::create("seq");

        seq.start(env.agent.sqr);

        phase.drop_objection(this);

    endtask

endclass

`endif