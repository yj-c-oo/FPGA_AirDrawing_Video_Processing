`ifndef STROKE_ENV_SV
`define STROKE_ENV_SV

class stroke_env extends uvm_env;

    `uvm_component_utils(stroke_env)

    //------------------------------------------
    // Components
    //------------------------------------------

    stroke_agent      agent;
    stroke_scoreboard scb;

    //------------------------------------------
    // Constructor
    //------------------------------------------

    function new(string name="stroke_env",
                 uvm_component parent=null);

        super.new(name,parent);

    endfunction

    //------------------------------------------
    // Build Phase
    //------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        //--------------------------------------
        // Agent
        //--------------------------------------

        agent = stroke_agent::type_id::create(
                    "agent",
                    this);

        //--------------------------------------
        // Scoreboard
        //--------------------------------------

        scb = stroke_scoreboard::type_id::create(
                    "scb",
                    this);

    endfunction

    //------------------------------------------
    // Connect Phase
    //------------------------------------------

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        //--------------------------------------
        // Input Monitor -> Scoreboard
        //--------------------------------------

        agent.in_mon.ap.connect(
            scb.input_imp);

        //--------------------------------------
        // Output Monitor -> Scoreboard
        //--------------------------------------

        agent.out_mon.ap.connect(
            scb.output_imp);

    endfunction

endclass

`endif