`ifndef BRESENHAM_ENV_SV
`define BRESENHAM_ENV_SV

class bresenham_env extends uvm_env;
    `uvm_component_utils(bresenham_env)

    bresenham_agent      agent;
    bresenham_scoreboard sb;
    bresenham_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent = bresenham_agent::type_id::create("agent",this);

        sb    = bresenham_scoreboard::type_id::create("sb",this);

        cov   = bresenham_coverage::type_id::create("cov",this);

    endfunction


    function void connect_phase(uvm_phase phase);

        //-----------------------------------
        // Input Monitor
        //-----------------------------------
        agent.in_mon.ap.connect(sb.input_imp);

        //-----------------------------------
        // Output Monitor
        //-----------------------------------
        agent.out_mon.ap.connect(sb.output_imp);

        //-----------------------------------
        // Coverage
        //-----------------------------------
        agent.in_mon.ap.connect(cov.analysis_export);

    endfunction

endclass

`endif