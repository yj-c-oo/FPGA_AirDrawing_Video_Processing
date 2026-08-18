`ifndef BBOX_ENV_SV
`define BBOX_ENV_SV


class bbox_env extends uvm_env;
    `uvm_component_utils(bbox_env)

    bbox_agent agent;

    bbox_scoreboard scoreboard;

    bbox_coverage coverage;


    function new(string name, uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent = bbox_agent::type_id::create("agent", this);

        scoreboard = bbox_scoreboard::type_id::create("scoreboard", this);

        coverage = bbox_coverage::type_id::create("coverage", this);

    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.input_mon.ap.connect(scoreboard.input_imp);

        agent.output_mon.ap.connect(scoreboard.output_imp);

        // agent.input_mon.ap.connect(
        //     coverage.analysis_export
        // );

    endfunction

endclass

`endif
