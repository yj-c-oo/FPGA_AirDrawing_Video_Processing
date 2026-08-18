`ifndef BRUSH_TRANSACTION_SV
`define BRUSH_TRANSACTION_SV

//////////////////////////////////////////////////////////////
// Input Transaction
//////////////////////////////////////////////////////////////
class brush_seq_item extends uvm_sequence_item;

    //---------------------------------------------------------
    // Brush Input
    //---------------------------------------------------------
    rand logic [8:0]  point_x;
    rand logic [8:0]  point_y;

    rand logic [3:0]  color;

    rand logic [4:0]  radius;

    rand logic [10:0] sq_threshold;

    rand logic        texture_enable;

    rand logic [2:0]  texture_shape;

    //---------------------------------------------------------
    // Texture Type
    //---------------------------------------------------------
    typedef enum int {
        PLAIN,
        SPRAY_SMALL,
        SPRAY_MEDIUM,
        SPRAY_LARGE,
        DIAGONAL_THIN,
        DIAGONAL_WIDE
    } brush_mode_t;

    rand brush_mode_t brush_mode;

    //---------------------------------------------------------
    // UVM Macro
    //---------------------------------------------------------
    `uvm_object_utils_begin(brush_seq_item)

        `uvm_field_int(point_x        , UVM_ALL_ON)
        `uvm_field_int(point_y        , UVM_ALL_ON)

        `uvm_field_int(color          , UVM_ALL_ON)

        `uvm_field_int(radius         , UVM_ALL_ON)
        `uvm_field_int(sq_threshold   , UVM_ALL_ON)

        `uvm_field_int(texture_enable , UVM_ALL_ON)
        `uvm_field_int(texture_shape  , UVM_ALL_ON)

    `uvm_object_utils_end


    //---------------------------------------------------------
    // Coordinate Constraint
    //---------------------------------------------------------
    constraint c_coordinate {

        point_x inside {[0:319]};
        point_y inside {[0:239]};

    }

    //---------------------------------------------------------
    // Radius Constraint
    //---------------------------------------------------------
    constraint c_radius {

        radius inside {[2:11]};

    }

    //---------------------------------------------------------
    // Color Constraint
    //
    // color[3]==1 이어야 texture가 활성화됨
    //---------------------------------------------------------
    constraint c_color {

        color inside {[0:15]};

    }

    //---------------------------------------------------------
    // Texture Distribution
    //---------------------------------------------------------
    constraint c_mode {

        brush_mode dist {

            PLAIN          := 20,

            SPRAY_SMALL    := 16,
            SPRAY_MEDIUM   := 16,
            SPRAY_LARGE    := 16,

            DIAGONAL_THIN  := 16,
            DIAGONAL_WIDE  := 16

        };

    }

    //---------------------------------------------------------
    // Mode Mapping
    //---------------------------------------------------------
    constraint c_texture {

        if(brush_mode == PLAIN) {

            texture_enable == 0;
            texture_shape  == 0;

        }

        else if(brush_mode == SPRAY_SMALL) {

            texture_enable == 1;
            texture_shape  == 0;

            color[3] == 1;

        }

        else if(brush_mode == SPRAY_MEDIUM) {

            texture_enable == 1;
            texture_shape  == 1;

            color[3] == 1;

        }

        else if(brush_mode == SPRAY_LARGE) {

            texture_enable == 1;
            texture_shape  == 2;

            color[3] == 1;

        }

        else if(brush_mode == DIAGONAL_THIN) {

            texture_enable == 1;
            texture_shape  == 3;

            color[3] == 1;

        }

        else if(brush_mode == DIAGONAL_WIDE) {

            texture_enable == 1;
            texture_shape  == 4;

            color[3] == 1;

        }

    }

    //---------------------------------------------------------
    // Threshold
    //
    // 일반 원형 브러시는 radius²와 비슷한 값을 사용.
    // texture 모드에서는 DUT에서 사용하지 않지만
    // 정상 입력을 위해 함께 생성.
    //---------------------------------------------------------
    constraint c_threshold {

        if(radius==2)
            sq_threshold==4;

        else if(radius==3)
            sq_threshold==9;

        else if(radius==4)
            sq_threshold==16;

        else if(radius==5)
            sq_threshold==25;

        else if(radius==6)
            sq_threshold==36;

        else if(radius==7)
            sq_threshold==49;

        else if(radius==8)
            sq_threshold==64;

        else if(radius==9)
            sq_threshold==81;

        else if(radius==10)
            sq_threshold==100;

        else if(radius==11)
            sq_threshold==121;

    }

    //---------------------------------------------------------
    function new(string name="brush_seq_item");
        super.new(name);
    endfunction

endclass


//////////////////////////////////////////////////////////////
// Output Transaction
//////////////////////////////////////////////////////////////
class brush_output_item extends uvm_sequence_item;

    `uvm_object_utils(brush_output_item)

    //---------------------------------------------------------
    // DUT Write Results
    //---------------------------------------------------------
    logic [$clog2(320*240)-1:0] ram_addr_q[$];

    logic [3:0] ram_data_q[$];

    function new(string name="brush_output_item");
        super.new(name);
    endfunction

endclass

`endif