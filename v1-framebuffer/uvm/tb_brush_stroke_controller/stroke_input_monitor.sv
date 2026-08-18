`ifndef STROKE_INPUT_MONITOR_SV
`define STROKE_INPUT_MONITOR_SV

class stroke_input_monitor extends uvm_monitor;

    `uvm_component_utils(stroke_input_monitor)

    //--------------------------------------------
    // Virtual Interface
    //--------------------------------------------
    virtual stroke_if vif;

    //--------------------------------------------
    // Analysis Port
    //--------------------------------------------
    uvm_analysis_port #(stroke_transaction) ap;

    //--------------------------------------------
    // Constructor
    //--------------------------------------------
    function new(string name = "stroke_input_monitor",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //--------------------------------------------
    // Build Phase
    //--------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual stroke_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Failed to get virtual interface")
        end
    endfunction

    //--------------------------------------------
    // Run Phase
    //--------------------------------------------
    task run_phase(uvm_phase phase);
        stroke_transaction tr;

        forever begin
            // 1. 매 클록마다 이벤트를 대기합니다. (무한 루프 방지 보장)
            @(vif.mon_cb);

            //--------------------------------------------------
            // Frame Event
            //--------------------------------------------------
            if(vif.mon_cb.frame_done) begin
                tr = stroke_transaction::type_id::create("tr");
                tr.event_type = stroke_transaction::FRAME_EVENT; // Enum 스코프 적용
                tr.pen_present  = vif.mon_cb.pen_present;
                tr.X_center     = vif.mon_cb.X_center;
                tr.Y_center     = vif.mon_cb.Y_center;
                tr.sw_pen_color = vif.mon_cb.sw_pen_color;
                tr.sw_eraser    = vif.mon_cb.sw_eraser;
                tr.sw_size      = vif.mon_cb.sw_size;

                ap.write(tr);

                `uvm_info(get_type_name(),
                    $sformatf("[FRAME]\npen=%0d\ncenter=(%0d,%0d)\ncolor=%0d\neraser=%0d\nsize=%0d",
                    tr.pen_present,
                    tr.X_center,
                    tr.Y_center,
                    tr.sw_pen_color,
                    tr.sw_eraser,
                    tr.sw_size),
                    UVM_MEDIUM);
            end

            //--------------------------------------------------
            // Line Done Event (원래 if문이었던 것을 else if로 묶어 처리 안전성 확보)
            //--------------------------------------------------
            if(vif.mon_cb.line_done) begin
                tr = stroke_transaction::type_id::create("tr");
                tr.event_type = stroke_transaction::DONE_EVENT; // Enum 스코프 적용
                ap.write(tr);

                `uvm_info(get_type_name(), "[LINE DONE]", UVM_HIGH);
            end
        end
    endtask

endclass

`endif








// `ifndef STROKE_MONITOR_SV
// `define STROKE_MONITOR_SV

// class stroke_monitor extends uvm_monitor;

//     `uvm_component_utils(stroke_monitor)

//     //--------------------------------------------
//     // Virtual Interface
//     //--------------------------------------------
//     virtual stroke_if vif;

//     //--------------------------------------------
//     // Analysis Port
//     //--------------------------------------------
//     uvm_analysis_port #(stroke_transaction) ap;

//     //--------------------------------------------
//     // Constructor
//     //--------------------------------------------
//     function new(string name = "stroke_monitor",
//                  uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     //--------------------------------------------
//     // Build Phase
//     //--------------------------------------------
//     function void build_phase(uvm_phase phase);

//         super.build_phase(phase);

//         ap = new("ap", this);

//         if(!uvm_config_db#(virtual stroke_if)::get(
//             this,
//             "",
//             "vif",
//             vif
//         )) begin
//             `uvm_fatal(get_type_name(),
//                        "Failed to get virtual interface")
//         end

//     endfunction


//     //--------------------------------------------
//     // Run Phase
//     //--------------------------------------------
//     task run_phase(uvm_phase phase);

//         stroke_transaction tr;
//         static int stroke_cnt = 0;

//         forever begin

//             @(vif.mon_cb);

//             //----------------------------------------------------
//             // Stroke가 실제 시작될 때만 Transaction 생성
//             //----------------------------------------------------

//             if(vif.mon_cb.line_start) begin

//                 tr = stroke_transaction::type_id::create("tr", this);
//                 tr.stroke_id = stroke_cnt++;

//                 //----------------------------------------
//                 // Inputs
//                 //----------------------------------------

//                 tr.frame_done   = vif.mon_cb.frame_done;
//                 tr.pen_present  = vif.mon_cb.pen_present;

//                 tr.X_center     = vif.mon_cb.X_center;
//                 tr.Y_center     = vif.mon_cb.Y_center;

//                 tr.sw_pen_color = vif.mon_cb.sw_pen_color;
//                 tr.sw_eraser    = vif.mon_cb.sw_eraser;
//                 tr.sw_size      = vif.mon_cb.sw_size;

//                 tr.line_ready   = vif.mon_cb.line_ready;

//                 //----------------------------------------
//                 // Outputs
//                 //----------------------------------------

//                 tr.line_start     = vif.mon_cb.line_start;

//                 tr.line_x0        = vif.mon_cb.line_x0;
//                 tr.line_y0        = vif.mon_cb.line_y0;

//                 tr.line_x1        = vif.mon_cb.line_x1;
//                 tr.line_y1        = vif.mon_cb.line_y1;

//                 tr.line_color     = vif.mon_cb.line_color;

//                 tr.line_radius    = vif.mon_cb.line_radius;

//                 tr.line_threshold = vif.mon_cb.line_threshold;

//                 tr.busy           = vif.mon_cb.busy;

//                 //----------------------------------------
//                 // Scoreboard 전달
//                 //----------------------------------------

//                 ap.write(tr);

//                 //----------------------------------------
//                 // Log
//                 //----------------------------------------

//                 `uvm_info(get_type_name(),

//                     $sformatf(
//                     "\nStroke Start"
//                     "\nStart Point : (%0d,%0d)"
//                     "\nEnd Point   : (%0d,%0d)"
//                     "\nColor       : %0h"
//                     "\nRadius      : %0d"
//                     "\nThreshold   : %0d"
//                     "\nBusy        : %0b",

//                     tr.line_x0,
//                     tr.line_y0,

//                     tr.line_x1,
//                     tr.line_y1,

//                     tr.line_color,

//                     tr.line_radius,

//                     tr.line_threshold,

//                     tr.busy),

//                     UVM_MEDIUM);

//             end

//         end

//     endtask

// endclass

// `endif
