`ifndef BBOX_TEST_SV
`define BBOX_TEST_SV


class bbox_base_test extends uvm_test;

    `uvm_component_utils(bbox_base_test)

    bbox_env env;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = bbox_env::type_id::create("env", this);
    endfunction

endclass



class bbox_random_test extends bbox_base_test;

    `uvm_component_utils(bbox_random_test)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        bbox_random_seq seq;
        phase.raise_objection(this);

        seq = bbox_random_seq::type_id::create("seq");

        seq.start(env.agent.sqr);

        phase.drop_objection(this);

    endtask

endclass



class bbox_coverage_test extends bbox_base_test;

    `uvm_component_utils(bbox_coverage_test)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        bbox_directed_seq seq;

        phase.raise_objection(this);

        seq = bbox_directed_seq::type_id::create("seq");

        seq.start(env.agent.sqr);

        phase.drop_objection(this);

    endtask

endclass


class bbox_stress_test extends bbox_base_test;

    `uvm_component_utils(bbox_stress_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bbox_full_stress_seq seq;

        phase.raise_objection(this);

        seq = bbox_full_stress_seq::type_id::create("seq");
        
        seq.start(env.agent.sqr);

        phase.drop_objection(this);
    endtask

endclass

`endif