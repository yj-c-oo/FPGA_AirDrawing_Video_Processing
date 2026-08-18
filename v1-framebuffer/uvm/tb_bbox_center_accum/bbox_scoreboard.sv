`ifndef BBOX_SCOREBOARD_SV
`define BBOX_SCOREBOARD_SV

`uvm_analysis_imp_decl(_input)
`uvm_analysis_imp_decl(_output)

class bbox_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(bbox_scoreboard)

    bbox_coverage cov;

    localparam int PEN_MIN = 15;
    localparam bit ERODE = 1'b1;

    uvm_analysis_imp_input #(bbox_frame_item, bbox_scoreboard) input_imp;
    uvm_analysis_imp_output #(bbox_output_item, bbox_scoreboard) output_imp;


    bbox_frame_item frame_q[$];

    logic [8:0] last_exp_cx;
    logic [8:0] last_exp_cy;


    int total_cnt;
    int pass_cnt;
    int fail_cnt;


    function new(string name = "bbox_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        cov = bbox_coverage::type_id::create("cov", this);

        input_imp = new("input_imp", this);
        output_imp = new("output_imp", this);

        total_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;

        // 처음 하드웨어 전원 킬때 X 상태 따라함
        last_exp_cx = 9'bX;
        last_exp_cy = 9'bX;

    endfunction


    function void write_input(bbox_frame_item item);

        bbox_frame_item copy;

        copy                    = bbox_frame_item::type_id::create("copy");

        copy.frame_id           = item.frame_id;
        copy.marker_x           = item.marker_x;
        copy.marker_y           = item.marker_y;
        copy.marker_width       = item.marker_width;
        copy.marker_height      = item.marker_height;
        copy.expected_hit_count = item.expected_hit_count;
        copy.add_noise          = item.add_noise;

        copy.pixel_map          = item.pixel_map;


        frame_q.push_back(copy);

        `uvm_info(get_type_name(), $sformatf(
                  "Frame stored. Queue=%0d", frame_q.size()), UVM_HIGH);

    endfunction


    function void write_output(bbox_output_item out_item);

        bbox_frame_item in_item;

        logic [8:0] exp_cx;
        logic [8:0] exp_cy;
        bit exp_pen;

        total_cnt++;

        if (frame_q.size() == 0) begin

            `uvm_error(get_type_name(), "No input frame exists.");

            fail_cnt++;
            return;

        end

        in_item = frame_q.pop_front();


        calculate_bbox(in_item, exp_cx, exp_cy, exp_pen);


        if(out_item.cx  !== exp_cx[8:0] ||
           out_item.cy  !== exp_cy[8:0] ||
           out_item.pen !== exp_pen)
        begin
            fail_cnt++;

            `uvm_error(get_type_name(), $sformatf(
                       "BBOX MISMATCH EXP(cx=%0d cy=%0d pen=%0d) DUT(cx=%0d cy=%0d pen=%0d)",
                       exp_cx,
                       exp_cy,
                       exp_pen,
                       out_item.cx,
                       out_item.cy,
                       out_item.pen
                       ));
        end else begin
            pass_cnt++;

            `uvm_info(get_type_name(), $sformatf(
                      "PASS cx=%0d cy=%0d pen=%0d",
                      out_item.cx,
                      out_item.cy,
                      out_item.pen
                      ), UVM_MEDIUM);
        end
    endfunction


    function void calculate_bbox(input bbox_frame_item item,
                                 output logic [8:0] cx, output logic [8:0] cy,
                                 output bit pen);

        logic [8:0] x;
        logic [8:0] y;

        logic [8:0] minx;
        logic [8:0] maxx;

        logic [8:0] miny;
        logic [8:0] maxy;

        logic [16:0] cnt;

        logic hit_d1;
        logic hit_d2;

        logic hit;
        logic line_end;
        logic eff_hit;

        logic [8:0] eff_x;


        x      = 9'd0;
        y      = 9'd0;

        minx   = 9'd511;
        maxx   = 9'd0;

        miny   = 9'd511;
        maxy   = 9'd0;

        cnt    = 17'd0;

        hit_d1 = 1'b0;
        hit_d2 = 1'b0;


        for (int yy = 0; yy < 240; yy++) begin
            for (int xx = 0; xx < 320; xx++) begin

                hit = item.pixel_map[y][x];

                line_end = (x == 9'd319);

                if (ERODE) eff_hit = hit & hit_d1 & hit_d2;
                else eff_hit = hit;

                if (ERODE) eff_x = x - 9'd1;
                else eff_x = x;

                if (eff_hit) begin
                    cnt = cnt + 17'd1;
                    if (eff_x < minx) minx = eff_x;
                    if (eff_x > maxx) maxx = eff_x;
                    if (y < miny) miny = y;
                    if (y > maxy) maxy = y;
                end


                begin
                    logic old_hit_d1;

                    logic [8:0] next_x;
                    logic [8:0] next_y;

                    old_hit_d1 = hit_d1;

                    hit_d1 = hit & ~line_end;
                    hit_d2 = old_hit_d1 & ~line_end;

                    if (line_end) begin
                        next_x = 9'd0;
                        next_y = y + 9'd1;
                    end else begin
                        next_x = x + 9'd1;
                        next_y = y;
                    end

                    x = next_x;
                    y = next_y;

                end
            end
        end


        if (cnt != 0) begin
            cx = ({1'b0, minx} + {1'b0, maxx}) >> 1;
            cy = ({1'b0, miny} + {1'b0, maxy}) >> 1;
            
            last_exp_cx = cx;
            last_exp_cy = cy;
        end else begin
            cx = last_exp_cx;
            cy = last_exp_cy;
        end

        pen = (cnt >= PEN_MIN);

    endfunction


    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(get_type_name(), "===== BBOX SCOREBOARD REPORT =====", UVM_LOW)

        `uvm_info(get_type_name(), $sformatf("Total Transactions : %0d", total_cnt), UVM_LOW)

        `uvm_info(get_type_name(), $sformatf("Pass  : %0d", pass_cnt), UVM_LOW)

        `uvm_info(get_type_name(), $sformatf("Fail  : %0d", fail_cnt), UVM_LOW)

        if (fail_cnt == 0) begin
            `uvm_info(get_type_name(), "TEST PASSED", UVM_NONE);
        end else begin
            `uvm_error(get_type_name(), $sformatf("TEST FAILED (%0d failures)", fail_cnt));
        end

    endfunction

endclass

`endif
