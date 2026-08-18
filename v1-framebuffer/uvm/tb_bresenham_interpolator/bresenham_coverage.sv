`ifndef BRESENHAM_COVERAGE_SV
`define BRESENHAM_COVERAGE_SV

class bresenham_coverage extends uvm_subscriber #(bresenham_seq_item);
    `uvm_component_utils(bresenham_coverage)

    //---------------------------------------------------------
    // Sampling Variables
    //---------------------------------------------------------
    int x0;
    int y0;
    int x1;
    int y1;

    int dx;
    int dy;

    int line_length;

    typedef enum int {
        HORIZONTAL,
        VERTICAL,
        DIAGONAL,
        GENERAL
    } line_type_t;

    line_type_t line_type;

    typedef enum int {
        Q1,   // +x +y
        Q2,   // -x +y
        Q3,   // -x -y
        Q4,   // +x -y
        HOR_POS,
        HOR_NEG,
        VER_POS,
        VER_NEG
    } direction_t;

    direction_t direction;

    //---------------------------------------------------------
    // Covergroup
    //---------------------------------------------------------
    covergroup cg;

        //-----------------------------------------
        // Start Point
        //-----------------------------------------
        cp_x0 : coverpoint x0 {
            bins left   = {[0:79]};
            bins center = {[80:239]};
            bins right  = {[240:319]};
        }

        cp_y0 : coverpoint y0 {
            bins top    = {[0:59]};
            bins middle = {[60:179]};
            bins bottom = {[180:239]};
        }

        //-----------------------------------------
        // End Point
        //-----------------------------------------
        cp_x1 : coverpoint x1 {
            bins left   = {[0:79]};
            bins center = {[80:239]};
            bins right  = {[240:319]};
        }

        cp_y1 : coverpoint y1 {
            bins top    = {[0:59]};
            bins middle = {[60:179]};
            bins bottom = {[180:239]};
        }

        //-----------------------------------------
        // dx / dy
        //-----------------------------------------
        cp_dx_dy : coverpoint (dx > dy) {
            bins dx_gt_dy = {1};
            bins dx_le_dy = {0};
        }

        cp_equal : coverpoint (dx == dy) {
            bins equal = {1};
            bins other = {0};
        }

        //-----------------------------------------
        // Line Type
        //-----------------------------------------
        cp_line_type : coverpoint line_type {
            bins horizontal = {HORIZONTAL};
            bins vertical   = {VERTICAL};
            bins diagonal   = {DIAGONAL};
            bins general    = {GENERAL};
        }

        //-----------------------------------------
        // Direction
        //-----------------------------------------
        cp_direction : coverpoint direction {
            bins q1      = {Q1};
            bins q2      = {Q2};
            bins q3      = {Q3};
            bins q4      = {Q4};
            bins h_pos   = {HOR_POS};
            bins h_neg   = {HOR_NEG};
            bins v_pos   = {VER_POS};
            bins v_neg   = {VER_NEG};
        }

        //-----------------------------------------
        // Length
        //-----------------------------------------
        cp_length : coverpoint line_length {
            bins short_line  = {[0:10]};
            bins medium_line = {[11:50]};
            bins long_line   = {[51:150]};
            bins very_long   = {[151:320]};
        }

        //-----------------------------------------
        // Cross Coverage
        //-----------------------------------------
        cross cp_line_type, cp_direction {
            
            // 1. 수평선(HORIZONTAL)일 때는 HOR_POS, HOR_NEG만 가능하므로 나머지는 무시
            ignore_bins hor_mismatch = binsof(cp_line_type) intersect {HORIZONTAL} && 
                                    !binsof(cp_direction) intersect {HOR_POS, HOR_NEG};

            // 2. 수직선(VERTICAL)일 때는 VER_POS, VER_NEG만 가능하므로 나머지는 무시
            ignore_bins ver_mismatch = binsof(cp_line_type) intersect {VERTICAL} && 
                                    !binsof(cp_direction) intersect {VER_POS, VER_NEG};

            // 3. 대각선/일반선(DIAGONAL, GENERAL)일 때는 Q1~Q4만 가능하므로 수평/수직 방향은 무시
            ignore_bins slope_mismatch = binsof(cp_line_type) intersect {DIAGONAL, GENERAL} && 
                                        binsof(cp_direction) intersect {HOR_POS, HOR_NEG, VER_POS, VER_NEG};
        }

        cross cp_line_type, cp_length;

    endgroup

    //---------------------------------------------------------
    function new(string name="bresenham_coverage",
                 uvm_component parent);
        super.new(name,parent);

        cg = new();
    endfunction

    //---------------------------------------------------------
    function void write(bresenham_seq_item t);

        x0 = t.x0;
        y0 = t.y0;
        x1 = t.x1;
        y1 = t.y1;

        dx = (x1>x0)?(x1-x0):(x0-x1);
        dy = (y1>y0)?(y1-y0):(y0-y1);

        line_length = (dx>dy)?dx:dy;

        //-----------------------------------------
        // Determine Line Type
        //-----------------------------------------
        if(y0==y1)
            line_type = HORIZONTAL;

        else if(x0==x1)
            line_type = VERTICAL;

        else if(dx==dy)
            line_type = DIAGONAL;

        else
            line_type = GENERAL;

        //-----------------------------------------
        // Determine Direction
        //-----------------------------------------
        if(y0==y1) begin

            if(x1>x0)
                direction = HOR_POS;
            else
                direction = HOR_NEG;

        end

        else if(x0==x1) begin

            if(y1>y0)
                direction = VER_POS;
            else
                direction = VER_NEG;

        end

        else begin

            if(x1>x0 && y1>y0)
                direction = Q1;

            else if(x1<x0 && y1>y0)
                direction = Q2;

            else if(x1<x0 && y1<y0)
                direction = Q3;

            else
                direction = Q4;

        end

        //-----------------------------------------
        cg.sample();

    endfunction

endclass

`endif