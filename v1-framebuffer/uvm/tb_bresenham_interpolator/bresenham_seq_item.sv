`ifndef BRESENHAM_TRANSACTION_SV
`define BRESENHAM_TRANSACTION_SV

class bresenham_seq_item extends uvm_sequence_item;

    rand logic [8:0] x0;
    rand logic [8:0] y0;
    rand logic [8:0] x1;
    rand logic [8:0] y1;

    // 0 Hit 극복을 위한 내부 제약용 변수 추가
    typedef enum { HOR, VER, DIAG, GEN } mode_t;
    rand mode_t line_mode;
    
    rand bit sign_x; // 1이면 x1 > x0, 0이면 x1 < x0
    rand bit sign_y; // 1이면 y1 > y0, 0이면 y1 < y0
    
    // medium_line(11~50)을 강제하기 위한 가중치 변수
    rand bit is_medium;

    `uvm_object_utils_begin(bresenham_seq_item)
        `uvm_field_int(x0,UVM_ALL_ON)
        `uvm_field_int(y0,UVM_ALL_ON)
        `uvm_field_int(x1,UVM_ALL_ON)
        `uvm_field_int(y1,UVM_ALL_ON)
    `uvm_object_utils_end

    constraint c_xy{
        x0 inside {[0:319]};
        x1 inside {[0:319]};

        y0 inside {[0:239]};
        y1 inside {[0:239]};
    }

    // 각 모드(수평, 수직, 사선)가 골고루 나오도록 확률 분배
    constraint c_mode_dist {
        line_mode dist { HOR := 25, VER := 25, DIAG := 25, GEN := 25 };
        is_medium dist { 1 := 30, 0 := 70 }; // 30% 확률로 medium_line 저격
    }

    // 모드 및 방향에 따른 상세 제약
    constraint c_line_generation {
        // 1. 수평선 (y가 같음) -> h_pos, h_neg 유도
        if (line_mode == HOR) {
            y1 == y0;
            if (is_medium) {
                (sign_x) ? (x1 == x0 + 30) : (x0 == x1 + 30);
            } else {
                x0 != x1;
            }
        }
        // 2. 수직선 (x가 같음) -> v_pos, v_neg 유도
        else if (line_mode == VER) {
            x1 == x0;
            if (is_medium) {
                (sign_y) ? (y1 == y0 + 30) : (y0 == y1 + 30);
            } else {
                y0 != y1;
            }
        }
        // 3. 대각선 (dx == dy) -> diagonal, equal 유도
        else if (line_mode == DIAG) {
            if (is_medium) {
                (sign_x) ? (x1 == x0 + 30) : (x0 == x1 + 30);
                (sign_y) ? (y1 == y0 + 30) : (y0 == y1 + 30);
            } else {
                // 일반적인 대각선 거리는 랜덤하게 생성하되 dx==dy 유지
                int'(x1 > x0 ? x1 - x0 : x0 - x1) == int'(y1 > y0 ? y1 - y0 : y0 - y1);
                x0 != x1;
                y0 != y1;
            }
        }
        // 4. 일반 선형 중 medium_line 보장
        else if (line_mode == GEN && is_medium) {
            int'(x1 > x0 ? x1 - x0 : x0 - x1) inside {[11:50]};
            int'(y1 > y0 ? y1 - y0 : y0 - y1) inside {[11:50]};
        }
    }

    // 방향성(부호) 제약
    constraint c_signs {
        if (sign_x) x1 >= x0; else x1 <= x0;
        if (sign_y) y1 >= y0; else y1 <= y0;
    }

    function new(string name="bresenham_seq_item");
        super.new(name);
    endfunction

endclass


/////////////////////// 출력 전용 transaction ////////////////
class bresenham_output_item extends uvm_sequence_item;
    `uvm_object_utils(bresenham_output_item)

    logic [8:0] point_x_q[$];
    logic [8:0] point_y_q[$];

    function new(string name="bresenham_output_item");
        super.new(name);
    endfunction

endclass

`endif