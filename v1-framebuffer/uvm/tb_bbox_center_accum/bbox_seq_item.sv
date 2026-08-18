`ifndef BBOX_TRANSACTION_SV
`define BBOX_TRANSACTION_SV


class bbox_frame_item extends uvm_sequence_item;

    `uvm_object_utils_begin(bbox_frame_item)

        `uvm_field_int(frame_id, UVM_ALL_ON)
        `uvm_field_int(expected_hit_count, UVM_ALL_ON)
        `uvm_field_int(expected_min_x, UVM_ALL_ON)
        `uvm_field_int(expected_max_x, UVM_ALL_ON)
        `uvm_field_int(expected_min_y, UVM_ALL_ON)
        `uvm_field_int(expected_max_y, UVM_ALL_ON)

    `uvm_object_utils_end


    rand int frame_id;

    bit pixel_map[0:239][0:319];


    int expected_hit_count;

    int expected_min_x;
    int expected_max_x;

    int expected_min_y;
    int expected_max_y;

    rand int marker_x;
    rand int marker_y;

    rand int marker_width;
    rand int marker_height;

    rand bit add_noise;

    int expected_eff_hit_count;

    int expected_eff_min_x;
    int expected_eff_max_x;

    int expected_eff_min_y;
    int expected_eff_max_y;


    constraint c_frame_id {frame_id inside {[0 : 100000]};}


    constraint c_marker {
        marker_x inside {[0 : 319]};
        marker_y inside {[0 : 239]};

        marker_width inside {[1 : 100]};
        marker_height inside {[1 : 100]};
    }


    function new(string name = "bbox_frame_item");
        super.new(name);
    endfunction


    function void clear_frame();

        for (int y = 0; y < 240; y++) begin
            for (int x = 0; x < 320; x++) begin

                pixel_map[y][x] = 1'b0;

            end
        end
    endfunction


    function void create_rectangle_marker();

        clear_frame();

        expected_min_x = 319;
        expected_max_x = 0;

        expected_min_y = 239;
        expected_max_y = 0;

        expected_hit_count = 0;

        for (int y = marker_y; y < marker_y + marker_height; y++) begin

            if (y >= 240) continue;

            for (int x = marker_x; x < marker_x + marker_width; x++) begin

                if (x >= 320) continue;

                pixel_map[y][x] = 1'b1;

                expected_hit_count++;

                if (x < expected_min_x) expected_min_x = x;
                if (x > expected_max_x) expected_max_x = x;
                if (y < expected_min_y) expected_min_y = y;
                if (y > expected_max_y) expected_max_y = y;
            end
        end

    endfunction


    function void add_single_noise(input int x, input int y);
        if ((x < 320) && (y < 240)) pixel_map[y][x] = 1'b1;
    endfunction


    function void add_three_pixel_hit(input int x, input int y);

        if (x + 2 < 320 && y < 240) begin

            pixel_map[y][x]   = 1'b1;
            pixel_map[y][x+1] = 1'b1;
            pixel_map[y][x+2] = 1'b1;
        end

    endfunction


    function void calculate_eroded_expected();

        expected_eff_hit_count = 0;

        expected_eff_min_x = 319;
        expected_eff_max_x = 0;

        expected_eff_min_y = 239;
        expected_eff_max_y = 0;

        for (int y = 0; y < 240; y++) begin
            for (int x = 0; x < 320; x++) begin
                if (x >= 2) begin
                    if(pixel_map[y][x] && pixel_map[y][x-1] && pixel_map[y][x-2]) begin

                        expected_eff_hit_count++;

                        if (x - 1 < expected_eff_min_x) expected_eff_min_x = x - 1;

                        if (x - 1 > expected_eff_max_x) expected_eff_max_x = x - 1;

                        if (y < expected_eff_min_y) expected_eff_min_y = y;

                        if (y > expected_eff_max_y) expected_eff_max_y = y;

                    end
                end
            end
        end

    endfunction

endclass



class bbox_output_item extends uvm_sequence_item;

    `uvm_object_utils_begin(bbox_output_item)

        `uvm_field_int(cx, UVM_ALL_ON)
        `uvm_field_int(cy, UVM_ALL_ON)
        `uvm_field_int(pen, UVM_ALL_ON)
        `uvm_field_int(valid, UVM_ALL_ON)

    `uvm_object_utils_end


    logic [8:0] cx;
    logic [8:0] cy;

    logic pen;

    logic valid;

    function new(string name = "bbox_output_item");
        super.new(name);
    endfunction

endclass

`endif
