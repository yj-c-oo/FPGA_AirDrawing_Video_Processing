`ifndef STROKE_AGENT_SV
`define STROKE_AGENT_SV

class stroke_agent extends uvm_agent;

    `uvm_component_utils(stroke_agent)

    //------------------------------------------
    // Components
    //------------------------------------------
    stroke_driver                      drv;
    uvm_sequencer #(stroke_transaction) sqr; // sqr로 선언

    stroke_input_monitor  in_mon;
    stroke_output_monitor out_mon;

    stroke_coverage       cov;

    //------------------------------------------
    // Constructor
    //------------------------------------------
    function new(string name = "stroke_agent",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //------------------------------------------
    // Build Phase
    //------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (is_active == UVM_ACTIVE) begin
            drv = stroke_driver::type_id::create("drv", this);
            
            // 선언부와 매칭되도록 sqr로 생성
            sqr = uvm_sequencer#(stroke_transaction)::type_id::create("sqr", this);
        end

        in_mon = stroke_input_monitor::type_id::create("in_mon", this);
        out_mon = stroke_output_monitor::type_id::create("out_mon", this);
        cov = stroke_coverage::type_id::create("cov", this);
    endfunction

    //------------------------------------------
    // Connect Phase
    //------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        //--------------------------------------
        // Driver <-> Sequencer
        //--------------------------------------
        if (is_active == UVM_ACTIVE) begin
            // 드라이버와 일치된 이름인 sqr 연결
            drv.seq_item_port.connect(sqr.seq_item_export);
        end

        //--------------------------------------
        // Coverage
        //--------------------------------------
        in_mon.ap.connect(cov.input_export);
        out_mon.ap.connect(cov.output_export);
    endfunction

endclass

`endif