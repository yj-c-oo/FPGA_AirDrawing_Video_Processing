`ifndef BBOX_SEQUENCE_SV
`define BBOX_SEQUENCE_SV

class bbox_random_seq extends uvm_sequence #(bbox_frame_item);

    `uvm_object_utils(bbox_random_seq)

    function new(string name="bbox_random_seq");
        super.new(name);
    endfunction

    virtual task body();

        bbox_frame_item item;

        repeat(200) begin
            item = bbox_frame_item::type_id::create("item");
            start_item(item);

            if(!item.randomize()) `uvm_fatal(get_type_name(), "Random failed")

            if ($urandom_range(0, 99) < 5) begin
                item.clear_frame(); 
            end
            else if ($urandom_range(0, 99) < 10) begin
                item.clear_frame();
                item.add_three_pixel_hit(100, 100); 
            end
            else begin
                item.create_rectangle_marker();
                if(item.add_noise) begin
                    item.add_single_noise($urandom_range(0,319), $urandom_range(0,239));
                end
            end

            finish_item(item);
        end
    endtask

endclass


class bbox_directed_seq extends uvm_sequence #(bbox_frame_item);

    `uvm_object_utils(bbox_directed_seq)

    function new(string name="bbox_directed_seq");
        super.new(name);
    endfunction


    task send_rectangle(
        input int x,
        input int y,
        input int w,
        input int h
    );

        bbox_frame_item item;

        item = bbox_frame_item::type_id::create("rect");

        start_item(item);

        item.marker_x      = x;
        item.marker_y      = y;
        item.marker_width  = w;
        item.marker_height = h;

        item.create_rectangle_marker();

        finish_item(item);
    endtask

    task send_empty();
        bbox_frame_item item;
        item = bbox_frame_item::type_id::create("empty");
        start_item(item);
        item.clear_frame();
        finish_item(item);
    endtask


    task send_single_noise();
        bbox_frame_item item;
        item = bbox_frame_item::type_id::create("noise");
        start_item(item);
        item.clear_frame();
        item.add_single_noise(160,120);
        finish_item(item);
    endtask

    task send_three_pixel();
        bbox_frame_item item;
        item = bbox_frame_item::type_id::create("three");
        start_item(item);
        item.clear_frame();
        item.add_three_pixel_hit(160,120);
        finish_item(item);
    endtask


    task send_pen15();
        bbox_frame_item item;
        item = bbox_frame_item::type_id::create("pen15");
        start_item(item);

        item.clear_frame();
        for(int i=0;i<5;i++)
            item.add_three_pixel_hit(100+i*3,100);

        finish_item(item);
    endtask


    task send_pen14();
        bbox_frame_item item;
        item = bbox_frame_item::type_id::create("pen14");
        start_item(item);

        item.clear_frame();
        for(int i=0;i<4;i++)
            item.add_three_pixel_hit(100+i*3,100);
        item.add_single_noise(112,100);
        item.add_single_noise(113,100);

        finish_item(item);
    endtask


    virtual task body();

        send_empty();

        send_single_noise();

        send_three_pixel();

        send_pen14();
        send_pen15();

        // Small
        send_rectangle(150,110,10,10);
        
        // Medium
        send_rectangle(120,80,40,40);
        
        // Large
        send_rectangle(80,50,100,100);
        
        // Left edge
        send_rectangle(0,100,30,30);
        
        // Right edge
        send_rectangle(290,100,30,30);

        // Top edge
        send_rectangle(150,0,30,30);
        
        // Bottom edge        
        send_rectangle(150,210,30,30);

        // Four corners        
        send_rectangle(0,0,30,30);
        send_rectangle(290,0,30,30);
        send_rectangle(0,210,30,30);
        send_rectangle(290,210,30,30);

        // Right overflow        
        send_rectangle(300,100,20,30);
        
        // Wide horizontal
        send_rectangle(20,120,250,10);
        
        // Tall vertical
        send_rectangle(150,20,10,200);

    endtask

endclass


class bbox_full_stress_seq extends uvm_sequence #(bbox_frame_item);

    `uvm_object_utils(bbox_full_stress_seq)

    function new(string name="bbox_full_stress_seq");
        super.new(name);
    endfunction

    virtual task body();
        bbox_frame_item item;

        repeat(20) begin
            item = bbox_frame_item::type_id::create("item");

            start_item(item);

            // 기존 item의 c_marker 제약조건을 강제로 끔
            // 그래야 width=320, height=240 조건과 충돌하지 않는다.
            item.c_marker.constraint_mode(0);
            
            if (!item.randomize() with {
                marker_x      == 0;
                marker_y      == 0;
                marker_width  == 320;
                marker_height == 240;
            }) begin
                `uvm_fatal(get_type_name(), "Randomization failed")
            end

            case ($urandom_range(0, 2))
                
                // 패턴 0: 화면 전체를 100% 1로 채움 (카운터 최대치 테스트)
                0: begin
                    for (int y = 0; y < 240; y++) begin
                        for (int x = 0; x < 320; x++) begin
                            item.pixel_map[y][x] = 1'b1;
                        end
                    end
                end

                // 패턴 1: 3픽셀 히트 + 1픽셀 공백이 가로로 무한 반복되는 패턴
                // Erosion 필터(eff_hit)가 매번 켜졌다 꺼졌다를 반복하며 토글 스트레스
                1: begin
                    for (int y = 0; y < 240; y++) begin
                        for (int x = 0; x < 320; x++) begin
                            // x 인덱스가 4로 나눈 나머지가 0,1,2일 때만 1 (연속 3개 ON, 1개 OFF)
                            item.pixel_map[y][x] = ((x % 4) != 3);
                        end
                    end
                end

                // 패턴 2: 체커보드(Checkerboard) 노이즈 플러딩 패턴
                // 연속 3픽셀 조건을 단 1개 차이로 통과하지 못하게 2픽셀씩 쪼개어 배치
                // 하드웨어가 카운트(cnt)는 안 올리면서 필터 파이프라인 레지스터만 바쁘게 만드는 스트레스
                2: begin
                    for (int y = 0; y < 240; y++) begin
                        for (int x = 0; x < 320; x++) begin
                            // 2개 ON, 2개 OFF 무한 반복 (Erosion 필터를 절대 통과 못함)
                            item.pixel_map[y][x] = ((x % 4) < 2);
                        end
                    end
                end

            endcase

            finish_item(item);
        end
    endtask

endclass

`endif