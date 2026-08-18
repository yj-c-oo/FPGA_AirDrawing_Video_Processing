`ifndef BRUSH_TEST_SV
`define BRUSH_TEST_SV


class brush_base_test extends uvm_test;

    `uvm_component_utils(brush_base_test)

    brush_env env;


    function new(string name, uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = brush_env::type_id::create("env", this);

    endfunction


endclass



//------------------------------------------------------------
// Random Test
//------------------------------------------------------------

class brush_random_test extends brush_base_test;

    `uvm_component_utils(brush_random_test)


    function new(string name, uvm_component parent);

        super.new(name, parent);

    endfunction



    task run_phase(uvm_phase phase);

        brush_random_seq seq;


        phase.raise_objection(this);


        seq = brush_random_seq::type_id::create("seq");


        seq.start(env.agent.sqr);



        phase.drop_objection(this);


    endtask


endclass




//------------------------------------------------------------
// Boundary Test
//------------------------------------------------------------

class brush_boundary_test extends brush_base_test;

    `uvm_component_utils(brush_boundary_test)



    function new(string name, uvm_component parent);

        super.new(name, parent);

    endfunction



    task run_phase(uvm_phase phase);

        brush_boundary_seq seq;


        phase.raise_objection(this);



        seq = brush_boundary_seq::type_id::create("seq");


        seq.start(env.agent.sqr);



        phase.drop_objection(this);


    endtask


endclass




//------------------------------------------------------------
// Texture Test
//------------------------------------------------------------

class brush_texture_test extends brush_base_test;

    `uvm_component_utils(brush_texture_test)



    function new(string name, uvm_component parent);

        super.new(name, parent);

    endfunction



    task run_phase(uvm_phase phase);

        brush_texture_seq seq;


        phase.raise_objection(this);



        seq = brush_texture_seq::type_id::create("seq");


        seq.start(env.agent.sqr);



        phase.drop_objection(this);


    endtask


endclass




//------------------------------------------------------------
// Stress Test
//------------------------------------------------------------

class brush_stress_test extends brush_base_test;
    `uvm_component_utils(brush_stress_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        brush_boundary_seq boundary_seq; // 추가
        brush_stress_seq   stress_seq;

        phase.raise_objection(this);

        // 1. 코너 케이스를 확실하게 채워줄 시퀀스 먼저 실행
        boundary_seq = brush_boundary_seq::type_id::create("boundary_seq");
        boundary_seq.start(env.agent.sqr);

        // 2. 이어서 10,000번의 정상 범위 스트레스 테스트 실행
        stress_seq = brush_stress_seq::type_id::create("stress_seq");
        stress_seq.start(env.agent.sqr);

        phase.drop_objection(this);
    endtask
endclass



`endif
