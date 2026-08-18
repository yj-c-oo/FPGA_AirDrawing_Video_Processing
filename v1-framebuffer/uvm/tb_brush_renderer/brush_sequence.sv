`ifndef BRUSH_SEQUENCE_SV
`define BRUSH_SEQUENCE_SV

//------------------------------------------------------------
// Random Brush Sequence
//------------------------------------------------------------
class brush_random_seq extends uvm_sequence #(brush_seq_item);
    `uvm_object_utils(brush_random_seq)

    function new(string name = "brush_random_seq");
        super.new(name);
    endfunction

    virtual task body();

        brush_seq_item item;

        repeat (300) begin

            item = brush_seq_item::type_id::create("item");

            start_item(item);

            assert (item.randomize());

            finish_item(item);

        end

    endtask

endclass



//------------------------------------------------------------
// Boundary / Clipping Sequence
//------------------------------------------------------------
class brush_boundary_seq extends uvm_sequence #(brush_seq_item);
    `uvm_object_utils(brush_boundary_seq)

    function new(string name = "brush_boundary_seq");
        super.new(name);
    endfunction


    task send_stamp(input int x, input int y, input int color, input int radius,
                    input int threshold, input bit texture_enable,
                    input int texture_shape);

        brush_seq_item item;

        item = brush_seq_item::type_id::create("item");


        start_item(item);


        item.point_x = x;
        item.point_y = y;

        item.color = color[3:0];

        item.radius = radius[4:0];

        item.sq_threshold = threshold[10:0];

        item.texture_enable = texture_enable;

        item.texture_shape = texture_shape[2:0];


        finish_item(item);

    endtask



    virtual task body();

    //----------------------------------------------------
    // Four corners (radius=10 이므로 LARGE 만족)
    //----------------------------------------------------
    send_stamp(0, 0, 4'hF, 10, 200, 0, 0);
    send_stamp(319, 0, 4'hF, 10, 200, 0, 0);
    send_stamp(0, 239, 4'hF, 10, 200, 0, 0);
    send_stamp(319, 239, 4'hF, 10, 200, 0, 0);

    //----------------------------------------------------
    // 코너 위치(corner_pos)에서 작은 반지름(min) 조합 채우기
    //----------------------------------------------------
    // 좌상단 코너(0,0)에 반지름 3(SMALL)으로 스탬프 주입
    send_stamp(0, 0, 4'hF, 3, 9, 0, 0); 

    //----------------------------------------------------
    // texture_enable은 ON(1)이지만 color가 7 이하인 조합 채우기
    //----------------------------------------------------
    // 텍스처를 켜고(1) 컬러를 4(low)로 설정하여 강제 주입
    // (참고: DUT는 texture_enable과 color[3]이 둘 다 1이어야 실제 텍스처 연산을 하지만,
    //  입력 프로토콜 자체는 7 이하의 컬러와 enable=1이 들어올 수 있으므로 매칭 가능.)
    send_stamp(160, 120, 4'h4, 6, 36, 1, 0);

    //----------------------------------------------------
    // texture_enable은 ON(1)이면서 color가 transparent(0)인 조합
    //----------------------------------------------------
    send_stamp(160, 120, 4'h0, 6, 36, 1, 0); // color를 4'h0으로 강제 주입

    //----------------------------------------------------
    // Edge clipping 및 Center 로직
    //----------------------------------------------------
    send_stamp(0, 120, 4'hA, 11, 121, 0, 0); // 하드웨어 스펙 최대치 11, 121로 수정.
    send_stamp(319, 120, 4'hA, 11, 121, 0, 0);
    send_stamp(160, 0, 4'h5, 11, 121, 0, 0);
    send_stamp(160, 239, 4'h5, 11, 121, 0, 0);

    send_stamp(160, 120, 4'hF, 11, 121, 0, 0);

endtask

endclass



//------------------------------------------------------------
// Texture Shape Sequence
//------------------------------------------------------------
class brush_texture_seq extends uvm_sequence #(brush_seq_item);

    `uvm_object_utils(brush_texture_seq)


    function new(string name = "brush_texture_seq");
        super.new(name);
    endfunction


    task send_texture(input int shape);

        brush_seq_item item;


        item = brush_seq_item::type_id::create("item");


        start_item(item);


        item.point_x = 160;

        item.point_y = 120;

        item.color = 4'h8 | 4'h3;

        item.radius = 12;

        item.sq_threshold = 300;


        item.texture_enable = 1'b1;

        item.texture_shape = shape[2:0];


        finish_item(item);


    endtask



    virtual task body();


        //----------------------------------------------------
        // Spray small
        //----------------------------------------------------

        send_texture(0);


        //----------------------------------------------------
        // Spray medium
        //----------------------------------------------------

        send_texture(1);


        //----------------------------------------------------
        // Spray large
        //----------------------------------------------------

        send_texture(2);


        //----------------------------------------------------
        // Diagonal thin
        //----------------------------------------------------

        send_texture(3);


        //----------------------------------------------------
        // Diagonal wide
        //----------------------------------------------------

        send_texture(4);


    endtask

endclass



//------------------------------------------------------------
// Stress Sequence
//------------------------------------------------------------
class brush_stress_seq extends uvm_sequence #(brush_seq_item);

    `uvm_object_utils(brush_stress_seq)


    function new(string name = "brush_stress_seq");
        super.new(name);
    endfunction



    virtual task body();

        brush_seq_item item;


        repeat (10000) begin


            item = brush_seq_item::type_id::create("item");


            start_item(item);


            assert (item.randomize() with {
                point_x inside {[0 : 319]};
                point_y inside {[0 : 239]};

                radius inside {[0 : 31]};

                sq_threshold inside {[0 : 2047]};

                texture_shape inside {[0 : 4]};

            });


            finish_item(item);


        end


    endtask


endclass




`endif
