`ifndef STROKE_COVERAGE_SV
`define STROKE_COVERAGE_SV

// `uvm_analysis_imp_decl(_INPUT)
// `uvm_analysis_imp_decl(_OUTPUT)

class stroke_coverage extends uvm_component;

    `uvm_component_utils(stroke_coverage)

    //--------------------------------------------
    // Analysis Ports
    //--------------------------------------------

    uvm_analysis_imp_INPUT
    #(stroke_transaction,
      stroke_coverage) input_export;

    uvm_analysis_imp_OUTPUT
    #(stroke_result,
      stroke_coverage) output_export;

    //--------------------------------------------
    // Variables
    //--------------------------------------------

    bit        pen_present;
    bit [2:0]  sw_pen_color;
    bit        sw_eraser;
    bit        sw_size;

    bit [3:0]  line_color;
    bit [4:0]  line_radius;
    bit [10:0] line_threshold;

    //--------------------------------------------
    // Input Covergroup
    //--------------------------------------------
    covergroup input_cg;

        option.per_instance = 1;

        cp_pen_present : coverpoint pen_present;

        // 3비트 입력 sw_pen_color (000 ~ 111) 전범위 8가지 빈 생성
        cp_pen_color : coverpoint sw_pen_color {
            bins col_000_black   = {3'b000};
            bins col_001_red     = {3'b001};
            bins col_010_green   = {3'b010};
            bins col_011_yellow  = {3'b011};
            bins col_100_blue    = {3'b100};
            bins col_101_magenta = {3'b101};
            bins col_110_cyan    = {3'b110};
            bins col_111_white   = {3'b111};
        }

        cp_eraser : coverpoint sw_eraser;

        cp_size : coverpoint sw_size;

        //------------------------------------
        // Cross Coverage
        //------------------------------------
        cross_pen :
            cross cp_pen_color,
                  cp_size;

        cross_eraser :
            cross cp_pen_present,
                  cp_eraser;

    endgroup



    //--------------------------------------------
    // Output Covergroup
    //--------------------------------------------

    covergroup output_cg;

        option.per_instance = 1;

        cp_line_color : coverpoint line_color {
            // 1. 지우개 동작 시 출력 (4'b0000)
            bins color_eraser       = {4'b0000};

            // 2. 일반 브러시 그리기 시 출력 (MSB가 1인 4'b1000 ~ 4'b1111)
            bins black   = {4'b1000};
            bins red     = {4'b1001};
            bins green   = {4'b1010};
            bins yellow  = {4'b1011};
            bins blue    = {4'b1100};
            bins magenta = {4'b1101};
            bins cyan    = {4'b1110};
            bins white   = {4'b1111};

            // // 3. 하드웨어 사양상 절대 나올 수 없는 영역 (0001 ~ 0111) 지정
            // // 이렇게 ignore_bins를 명시해 주면 커버리지 총점 분모에서 제외되어 100% 채우기가 가능해집니다.
            // ignore_bins illegal_colors = { [4'b0001 : 4'b0111] };
        }

        cp_radius : coverpoint line_radius {

            bins low         = {2}; 
            bins mid         = {3}; 
            bins erase_small = {5};
            bins erase_big   = {7};

        }

        cp_threshold : coverpoint line_threshold {

            bins t6  = {6};
            bins t12 = {12};
            bins t25 = {25};
            bins t49 = {49};

        }

        //------------------------------------
        // Cross Coverage
        //------------------------------------
        cross_draw :
            cross cp_line_color,
                  cp_radius {
                      
                // 1. 지우개 컬러(4'b0000)이면서 반경이 low(2), mid(3)인 불가능한 조합 제외
                ignore_bins eraser_with_low_mid = binsof(cp_line_color.color_eraser) && 
                                                  (binsof(cp_radius.low) || binsof(cp_radius.mid));

                // 2. 일반 컬러들(MSB=1)이면서 반경이 지우개 크기(5, 7)인 불가능한 조합 제외
                ignore_bins draw_colors_with_erase_radius = (binsof(cp_line_color.black)   ||
                                                             binsof(cp_line_color.red)     ||
                                                             binsof(cp_line_color.green)   ||
                                                             binsof(cp_line_color.yellow)  ||
                                                             binsof(cp_line_color.blue)    ||
                                                             binsof(cp_line_color.magenta) ||
                                                             binsof(cp_line_color.cyan)    ||
                                                             binsof(cp_line_color.white))  && 
                                                            (binsof(cp_radius.erase_small) || binsof(cp_radius.erase_big));
            }

    endgroup

    //--------------------------------------------
    // Constructor
    //--------------------------------------------

    function new(string name="stroke_coverage",
                 uvm_component parent=null);

        super.new(name,parent);

        input_cg  = new();
        output_cg = new();

    endfunction

    //--------------------------------------------
    // Build Phase
    //--------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        input_export =
            new("input_export",this);

        output_export =
            new("output_export",this);

    endfunction

    //--------------------------------------------
    // Input Sample
    //--------------------------------------------

    function void write_INPUT(
        stroke_transaction tr);

        //----------------------------------------
        // line_done Event는 제외
        //----------------------------------------

        if(tr.event_type != stroke_transaction::FRAME_EVENT)
            return;

        pen_present = tr.pen_present;

        sw_pen_color = tr.sw_pen_color;

        sw_eraser = tr.sw_eraser;

        sw_size = tr.sw_size;

        input_cg.sample();

    endfunction

    //--------------------------------------------
    // Output Sample
    //--------------------------------------------

    function void write_OUTPUT(
        stroke_result tr);

        line_color = tr.line_color;

        line_radius = tr.line_radius;

        line_threshold = tr.line_threshold;

        output_cg.sample();

    endfunction

endclass

`endif