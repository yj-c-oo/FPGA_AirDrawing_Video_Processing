`ifndef BBOX_COVERAGE_SV
`define BBOX_COVERAGE_SV


class bbox_coverage extends uvm_subscriber #(bbox_frame_item);

    `uvm_component_utils(bbox_coverage)

    int marker_x;
    int marker_y;

    int marker_width;
    int marker_height;

    int pixel_count;

    int center_x;
    int center_y;


    bit overflow_case;

    bit erosion_test;


    typedef enum int {
        POS_CENTER,
        POS_EDGE,
        POS_CORNER
    } position_t;

    position_t position;


    typedef enum int {
        SMALL,
        MEDIUM,
        LARGE
    } size_t;

    size_t marker_size;


    typedef enum int {
        BELOW_MIN,
        ABOVE_MIN
    } pen_type_t;

    pen_type_t pen_type;


    covergroup cg;

        cp_position: coverpoint position {
            bins pos_center = {POS_CENTER};

            bins pos_edge = {POS_EDGE};

            bins pos_corner = {POS_CORNER};
        }


        cp_size: coverpoint marker_size {
            bins min = {SMALL}; bins mid = {MEDIUM}; bins max = {LARGE};
        }


        cp_width: coverpoint marker_width {
            bins tiny = {[1 : 5]};

            bins min = {[6 : 20]};

            bins mid = {[21 : 60]};

            bins max = {[61 : 120]};
        }


        cp_height: coverpoint marker_height {
            bins tiny = {[1 : 5]};

            bins min = {[6 : 20]};

            bins mid = {[21 : 60]};

            bins max = {[61 : 120]};
        }


        cp_pixel_count: coverpoint pixel_count {
            bins empty = {0};

            bins low = {[1 : 14]};

            bins valid = {[15 : 2000]};

            bins huge = {[2001 : 10000]};
        }


        cp_pen_type: coverpoint pen_type {
            bins below = {BELOW_MIN}; bins above = {ABOVE_MIN};
        }


        cp_overflow: coverpoint overflow_case {
            bins normal = {0}; bins overflow = {1};
        }


        cp_erosion: coverpoint erosion_test {
            bins normal_marker = {0}; bins erosion_case = {1};
        }


        cc_pos_size: cross cp_position, cp_size {
            ignore_bins ignore_corner_small = cc_pos_size with (
                cp_position == POS_CORNER && cp_size == SMALL
            );
        }

        cc_pos_overflow: cross cp_position, cp_overflow {
            ignore_bins ignore_corner_normal = cc_pos_overflow with (
                cp_position == POS_CORNER && cp_overflow == 0
            );
        }

        cc_size_type: cross cp_size, cp_pen_type;

    endgroup


    function new(string name = "bbox_coverage", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction


    function void write(bbox_frame_item t);

        marker_x = t.marker_x;
        marker_y = t.marker_y;
        marker_width = t.marker_width;
        marker_height = t.marker_height;


        if (t.expected_hit_count == 0) begin
            pixel_count = 0;
            for (int y=0; y<240; y++) begin
                for (int x=0; x<320; x++) begin
                    if (t.pixel_map[y][x]) pixel_count++;
                end
            end
        end else begin
            pixel_count = t.expected_hit_count;
        end


        center_x = marker_x + marker_width / 2;
        center_y = marker_y + marker_height / 2;


        if((marker_x<10 ||
            marker_x+marker_width>=310) &&
           (marker_y<10 ||
            marker_y+marker_height>=230))
        begin

            position = POS_CORNER;

        end

        else if(marker_x<10 ||
                marker_x+marker_width>=310 ||
                marker_y<10 ||
                marker_y+marker_height>=230)
        begin

            position = POS_EDGE;

        end else begin

            position = POS_CENTER;

        end


        if (marker_width <= 10 && marker_height <= 10) begin
            marker_size = SMALL;
        end else if (marker_width <= 50 && marker_height <= 50) begin
            marker_size = MEDIUM;
        end else begin
            marker_size = LARGE;
        end



        // PEN_MIN=15
        if (pixel_count >= 15) pen_type = ABOVE_MIN;
        else pen_type = BELOW_MIN;

        // Overflow condition
        overflow_case = ((marker_x + marker_width - 1) + marker_x) > 511;

        // Erosion related
        erosion_test  = (pixel_count == 3);


        cg.sample();

    endfunction

endclass

`endif
