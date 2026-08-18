`ifndef STROKE_TEST_SV
`define STROKE_TEST_SV

//============================================================
// Base Test
//============================================================

class stroke_base_test extends uvm_test;

    `uvm_component_utils(stroke_base_test)

    stroke_env env;

    function new(string name="stroke_base_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = stroke_env::type_id::create("env", this);
    endfunction

endclass


//============================================================
// Basic Test
//============================================================

class stroke_basic_test extends stroke_base_test;

    `uvm_component_utils(stroke_basic_test)

    function new(string name="stroke_basic_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        stroke_basic_sequence seq;

        phase.raise_objection(this);

        seq = stroke_basic_sequence::type_id::create("seq");
        seq.start(env.agent.sqr);

        #100ns;

        phase.drop_objection(this);

    endtask

endclass


//============================================================
// Connect Test
//============================================================

class stroke_connect_test extends stroke_base_test;

    `uvm_component_utils(stroke_connect_test)

    function new(string name="stroke_connect_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        stroke_connect_sequence seq;

        phase.raise_objection(this);

        seq = stroke_connect_sequence::type_id::create("seq");
        seq.start(env.agent.sqr);

        #100ns;

        phase.drop_objection(this);

    endtask

endclass


//============================================================
// Pen Up Test
//============================================================

class stroke_penup_test extends stroke_base_test;

    `uvm_component_utils(stroke_penup_test)

    function new(string name="stroke_penup_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        stroke_penup_sequence seq;

        phase.raise_objection(this);

        seq = stroke_penup_sequence::type_id::create("seq");
        seq.start(env.agent.sqr);

        #100ns;

        phase.drop_objection(this);

    endtask

endclass


//============================================================
// Eraser Test
//============================================================

class stroke_eraser_test extends stroke_base_test;

    `uvm_component_utils(stroke_eraser_test)

    function new(string name="stroke_eraser_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        stroke_eraser_sequence seq;

        phase.raise_objection(this);

        seq = stroke_eraser_sequence::type_id::create("seq");
        seq.start(env.agent.sqr);

        #100ns;

        phase.drop_objection(this);

    endtask

endclass


//============================================================
// Size Test
//============================================================

class stroke_size_test extends stroke_base_test;

    `uvm_component_utils(stroke_size_test)

    function new(string name="stroke_size_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        stroke_size_sequence seq;

        phase.raise_objection(this);

        seq = stroke_size_sequence::type_id::create("seq");
        seq.start(env.agent.sqr);

        #100ns;

        phase.drop_objection(this);

    endtask

endclass


//============================================================
// Random Test
//============================================================

class stroke_random_test extends stroke_base_test;

    `uvm_component_utils(stroke_random_test)

    function new(string name="stroke_random_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        stroke_random_sequence seq;

        phase.raise_objection(this);

        seq = stroke_random_sequence::type_id::create("seq");
        seq.start(env.agent.sqr);

        #100ns;

        phase.drop_objection(this);

    endtask

endclass


//============================================================
// Stress Test
//============================================================

class stroke_stress_test extends stroke_base_test;

    `uvm_component_utils(stroke_stress_test)

    function new(string name="stroke_stress_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        stroke_stress_sequence seq;

        phase.raise_objection(this);

        seq = stroke_stress_sequence::type_id::create("seq");
        seq.start(env.agent.sqr);

        #1000ns;

        phase.drop_objection(this);

    endtask

endclass

`endif