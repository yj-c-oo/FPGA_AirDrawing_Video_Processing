`ifndef BRESENHAM_SCOREBOARD_SV
`define BRESENHAM_SCOREBOARD_SV

`uvm_analysis_imp_decl(_input)
`uvm_analysis_imp_decl(_output)

class bresenham_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(bresenham_scoreboard)

    //------------------------------------------
    // Analysis Ports
    //------------------------------------------

    uvm_analysis_imp_input #(bresenham_seq_item,
                             bresenham_scoreboard) input_imp;

    uvm_analysis_imp_output #(bresenham_output_item,
                              bresenham_scoreboard) output_imp;

    //------------------------------------------
    // Queue
    //------------------------------------------
    bresenham_seq_item input_q[$];

    int total_cnt;
    int pass_cnt;
    int fail_cnt;

    //------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    //------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        input_imp  = new("input_imp",this);
        output_imp = new("output_imp",this);

        total_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;
    endfunction

    //------------------------------------------------------------
    // Input Monitor
    //------------------------------------------------------------
    function void write_input(bresenham_seq_item item);

        bresenham_seq_item copy;

        copy = bresenham_seq_item::type_id::create("copy");

        copy.copy(item);

        input_q.push_back(copy);

    endfunction


    //------------------------------------------------------------
    // Output Monitor
    //------------------------------------------------------------
    function void write_output(bresenham_output_item out_item);


        bresenham_seq_item in_item;

        logic signed [10:0] dx;
        logic signed [10:0] dy;

        logic signed [10:0] sx;
        logic signed [10:0] sy;

        logic signed [10:0] err;
        logic signed [10:0] e2;

        integer x;
        integer y;

        int idx;

        logic [8:0] exp_x[$];
        logic [8:0] exp_y[$];
        
        total_cnt++;

        if(input_q.size()==0) begin
            `uvm_error(get_type_name(),"No input transaction")
            fail_cnt++;
            return;
        end

        in_item = input_q.pop_front();

        //--------------------------------------
        // Golden Model
        //--------------------------------------

        x = in_item.x0;
        y = in_item.y0;

        dx = (in_item.x1>=in_item.x0) ?
              (in_item.x1-in_item.x0) :
              (in_item.x0-in_item.x1);

        dy = (in_item.y1>=in_item.y0) ?
              (in_item.y0-in_item.y1) :
              (in_item.y1-in_item.y0);

        sx = (in_item.x0<in_item.x1)?1:-1;
        sy = (in_item.y0<in_item.y1)?1:-1;

        err = dx + dy;

        forever begin

            exp_x.push_back(x);
            exp_y.push_back(y);

            if((x==in_item.x1)&&(y==in_item.y1))
                break;

            e2 = err<<<1;

            if(e2>=dy) begin
                err = err + dy;
                x   = x + sx;
            end

            if(e2<=dx) begin
                err = err + dx;
                y   = y + sy;
            end

        end

        //--------------------------------------
        // Compare Count
        //--------------------------------------
        if(exp_x.size()!=out_item.point_x_q.size()) begin

            `uvm_error(get_type_name(),
                $sformatf("Point count mismatch exp=%0d dut=%0d",
                exp_x.size(),
                out_item.point_x_q.size()))

            fail_cnt++;
            return;

        end

        //--------------------------------------
        // Compare Data
        //--------------------------------------
        for(idx=0;idx<exp_x.size();idx++) begin

            if(exp_x[idx]!==out_item.point_x_q[idx] ||
               exp_y[idx]!==out_item.point_y_q[idx]) begin

                `uvm_error(get_type_name(),
                    $sformatf(
                    "Mismatch[%0d] EXP=(%0d,%0d) DUT=(%0d,%0d)",
                    idx,
                    exp_x[idx],
                    exp_y[idx],
                    out_item.point_x_q[idx],
                    out_item.point_y_q[idx]))

                fail_cnt++;

                return;

            end

        end

        pass_cnt++;

        `uvm_info(get_type_name(),
            $sformatf("PASS (%0d points)",exp_x.size()),
            UVM_MEDIUM);

    endfunction


    //------------------------------------------
    function void report_phase(uvm_phase phase);

        `uvm_info(get_type_name(), " ===== Bresenham Scoreboard Report =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Total transactions: %0d", total_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Pass: %0d", pass_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Fail: %0d", fail_cnt), UVM_LOW)

        if(fail_cnt==0)
            `uvm_info(get_type_name(),
                "TEST PASSED",
                UVM_LOW)
        else
            `uvm_error(get_type_name(),
                "TEST FAILED")

    endfunction

endclass

`endif