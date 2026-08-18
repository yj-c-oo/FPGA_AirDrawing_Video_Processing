`ifndef STROKE_OUTPUT_MONITOR_SV
`define STROKE_OUTPUT_MONITOR_SV

class stroke_output_monitor extends uvm_monitor;

    `uvm_component_utils(stroke_output_monitor)

    //------------------------------------------
    // Virtual Interface
    //------------------------------------------
    virtual stroke_if vif;

    //------------------------------------------
    // Analysis Port
    //------------------------------------------
    uvm_analysis_port #(stroke_result) ap;

    //------------------------------------------
    // Constructor
    //------------------------------------------
    function new(string name = "stroke_output_monitor",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //------------------------------------------
    // Build Phase
    //------------------------------------------
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual stroke_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Cannot get Virtual Interface");
        end

    endfunction

    //------------------------------------------
    // Run Phase
    //------------------------------------------
    task run_phase(uvm_phase phase);

        stroke_result result;

        static int stroke_id = 0;

        forever begin

            @(vif.mon_cb);

            //--------------------------------------
            // Stroke가 시작될 때만 Capture
            //--------------------------------------

            if (vif.mon_cb.line_start) begin

                result = stroke_result::type_id::create("result");

                result.stroke_id = stroke_id++;

                //----------------------------------
                // DUT Output
                //----------------------------------

                result.line_x0 = vif.mon_cb.line_x0;
                result.line_y0 = vif.mon_cb.line_y0;

                result.line_x1 = vif.mon_cb.line_x1;
                result.line_y1 = vif.mon_cb.line_y1;

                result.line_color = vif.mon_cb.line_color;

                result.line_radius = vif.mon_cb.line_radius;

                result.line_threshold = vif.mon_cb.line_threshold;

                result.busy = vif.mon_cb.busy;

                //----------------------------------
                // Send to Scoreboard
                //----------------------------------

                ap.write(result);

                //----------------------------------
                // Log
                //----------------------------------

                `uvm_info(get_type_name(), $sformatf(
                          "\nOUTPUT STROKE #%0d\nStart Point : (%0d,%0d)\nEnd Point   : (%0d,%0d)\nColor       : %0h\nRadius      : %0d\nThreshold   : %0d\nBusy        : %0d",
                          result.stroke_id,
                          result.line_x0,
                          result.line_y0,
                          result.line_x1,
                          result.line_y1,
                          result.line_color,
                          result.line_radius,
                          result.line_threshold,
                          result.busy
                          ), UVM_MEDIUM);

            end

        end

    endtask

endclass

`endif
