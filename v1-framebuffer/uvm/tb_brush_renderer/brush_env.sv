`ifndef BRUSH_ENV_SV
`define BRUSH_ENV_SV

class brush_env extends uvm_env;
    `uvm_component_utils(brush_env)

    brush_agent      agent;

    brush_scoreboard scoreboard;

    brush_coverage   coverage;


    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = brush_agent::type_id::create("agent",this);

        scoreboard =
            brush_scoreboard::type_id::create("scoreboard",this);

        coverage =
            brush_coverage::type_id::create("coverage",this);

    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        //------------------------------------------
        // Input transaction
        //------------------------------------------
        agent.input_mon.ap.connect(
            scoreboard.input_imp
        );


        //------------------------------------------
        // Output transaction
        //------------------------------------------
        agent.output_mon.ap.connect(
            scoreboard.output_imp
        );


        //------------------------------------------
        // Coverage
        //------------------------------------------
        agent.input_mon.ap.connect(
            coverage.analysis_export
        );

    endfunction


endclass

`endif