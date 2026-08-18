`ifndef STROKE_SCOREBOARD_SV
`define STROKE_SCOREBOARD_SV

// `uvm_analysis_imp_decl(_INPUT)
// `uvm_analysis_imp_decl(_OUTPUT)

class stroke_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(stroke_scoreboard)

    //--------------------------------------------
    // Analysis Imports
    //--------------------------------------------
    uvm_analysis_imp_INPUT #(stroke_transaction, stroke_scoreboard) input_imp;

    uvm_analysis_imp_OUTPUT #(stroke_result, stroke_scoreboard) output_imp;

    //--------------------------------------------
    // Queues
    //--------------------------------------------
    stroke_transaction input_q[$];

    stroke_result output_q[$];

    //--------------------------------------------
    // Reference Model
    //--------------------------------------------
    bit prev_valid;

    bit [8:0] prev_x;
    bit [8:0] prev_y;

    //--------------------------------------------
    // Last completed stroke
    //--------------------------------------------
    stroke_transaction last_completed_tr;

    //--------------------------------------------
    // Statistics
    //--------------------------------------------
    int total_cnt;
    int pass_cnt;
    int fail_cnt;

    //--------------------------------------------
    // Constructor
    //--------------------------------------------
    function new(string name = "stroke_scoreboard",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction

    //--------------------------------------------
    // Build Phase
    //--------------------------------------------
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        input_imp = new("input_imp", this);

        output_imp = new("output_imp", this);

        prev_valid = 0;

        prev_x = 0;
        prev_y = 0;

        total_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;

        last_completed_tr = null;

    endfunction

    //--------------------------------------------
    // Input Monitor
    //--------------------------------------------
    function void write_INPUT(stroke_transaction tr);

        case (tr.event_type)
            //------------------------------------
            // frame_done
            //------------------------------------
            stroke_transaction::FRAME_EVENT: begin
                if (tr.pen_present) begin
                    input_q.push_back(tr);
                end
                else begin
                    // 펜을 떼는 순간, 레퍼런스 모델의 상태를 즉각 무효화합니다.
                    prev_valid = 1'b0;
                    prev_x     = '0;
                    prev_y     = '0;
                    // 진행 중이던 이전 동작과의 연결을 끊기 위해 완료 대기 객체도 즉시 비워줍니다.
                    last_completed_tr = null; 
                end
            end
            //------------------------------------
            // line_done
            //------------------------------------
            stroke_transaction::DONE_EVENT: begin
                update_reference();
            end

        endcase

    endfunction




    //--------------------------------------------
    // Output Monitor
    //--------------------------------------------
    function void write_OUTPUT(stroke_result tr);

        output_q.push_back(tr);

        compare();

    endfunction

    //--------------------------------------------
    // Compare DUT Output with Reference Model
    //--------------------------------------------
    function void compare();

        stroke_transaction        in_tr;
        stroke_result             out_tr;

        bit                [ 8:0] exp_x0;
        bit                [ 8:0] exp_y0;

        bit                [ 8:0] exp_x1;
        bit                [ 8:0] exp_y1;

        bit                [ 3:0] exp_color;
        bit                [ 4:0] exp_radius;
        bit                [10:0] exp_threshold;

        //----------------------------------------
        // Wait until both queues have data
        //----------------------------------------
        if (input_q.size() == 0) return;

        if (output_q.size() == 0) return;

        //----------------------------------------
        // Pop Queue
        //----------------------------------------
        in_tr  = input_q.pop_front();
        out_tr = output_q.pop_front();

        total_cnt++;

        //----------------------------------------
        // Expected Coordinate 계산 로직
        //----------------------------------------
        if(prev_valid) begin
            exp_x0 = prev_x;
            exp_y0 = prev_y;
        end
        else begin
            exp_x0 = in_tr.X_center;
            exp_y0 = in_tr.Y_center;
        end

        exp_x1 = in_tr.X_center;
        exp_y1 = in_tr.Y_center;


        //----------------------------------------
        // Expected Color
        //----------------------------------------
        if (in_tr.sw_eraser) exp_color = 4'b0000;
        else exp_color = {1'b1, in_tr.sw_pen_color};

        //----------------------------------------
        // Expected Radius / Threshold
        //----------------------------------------
        case ({
            in_tr.sw_eraser, in_tr.sw_size
        })

            2'b00: begin
                exp_radius    = 5'd2;
                exp_threshold = 11'd6;
            end

            2'b01: begin
                exp_radius    = 5'd3;
                exp_threshold = 11'd12;
            end

            2'b10: begin
                exp_radius    = 5'd5;
                exp_threshold = 11'd25;
            end

            2'b11: begin
                exp_radius    = 5'd7;
                exp_threshold = 11'd49;
            end

        endcase

        //----------------------------------------
        // Compare
        //----------------------------------------
        if(

            out_tr.line_x0        == exp_x0 &&
            out_tr.line_y0        == exp_y0 &&
            out_tr.line_x1        == exp_x1 &&
            out_tr.line_y1        == exp_y1 &&
            out_tr.line_color     == exp_color &&
            out_tr.line_radius    == exp_radius &&
            out_tr.line_threshold == exp_threshold

        )
        begin

            pass_cnt++;

            `uvm_info(
                get_type_name(), $sformatf(

                "PASS (%0d,%0d)->(%0d,%0d)", exp_x0, exp_y0, exp_x1, exp_y1),

                UVM_LOW);

        end else begin

            fail_cnt++;

            `uvm_error(get_type_name(), $sformatf(
                       "\nExpected\n(%0d,%0d)->(%0d,%0d)\ncolor=%0h\nradius=%0d\nthreshold=%0d\nActual\n(%0d,%0d)->(%0d,%0d)\ncolor=%0h\nradius=%0d\nthreshold=%0d",
                       exp_x0,
                       exp_y0,
                       exp_x1,
                       exp_y1,
                       exp_color,
                       exp_radius,
                       exp_threshold,
                       out_tr.line_x0,
                       out_tr.line_y0,
                       out_tr.line_x1,
                       out_tr.line_y1,
                       out_tr.line_color,
                       out_tr.line_radius,
                       out_tr.line_threshold
                       ));
        end

        //----------------------------------------
        // Save completed stroke
        //----------------------------------------
        last_completed_tr = in_tr;

    endfunction


    //--------------------------------------------
    // Update Reference Model
    //--------------------------------------------
    function void update_reference();
        
        // !prev_valid 조건을 제거하여 첫 그리기 완료 시 좌표가 저장되게 합니다.
        // pen=0에 의해 취소된 트랜잭션은 last_completed_tr이 null이 되므로 안전합니다.
        if(last_completed_tr == null) begin
            prev_valid = 1'b0;
            return;
        end

        if(last_completed_tr.pen_present) begin
            prev_valid = 1'b1;
            prev_x = last_completed_tr.X_center;
            prev_y = last_completed_tr.Y_center;
        end
        else begin
            prev_valid = 1'b0;
        end

        last_completed_tr = null;
    endfunction

    

    //--------------------------------------------
    // Report
    //--------------------------------------------
    function void report_phase(uvm_phase phase);

        `uvm_info(get_type_name(), " ===== Stroke Scoreboard Report =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Total transactions: %0d", total_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Pass: %0d", pass_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Fail: %0d", fail_cnt), UVM_LOW)

    endfunction

endclass

`endif
