`ifndef BRUSH_COVERAGE_SV
`define BRUSH_COVERAGE_SV

class brush_coverage extends uvm_subscriber #(brush_seq_item);

    `uvm_component_utils(brush_coverage)

    //---------------------------------------------------------
    // Sampling Variables
    //---------------------------------------------------------
    int point_x;
    int point_y;
    int radius;
    int sq_threshold;
    bit texture_enable;
    bit texture_active;
    int texture_shape;
    int color;

    //---------------------------------------------------------
    // Derived Variables
    //---------------------------------------------------------
    typedef enum int {
        CENTER_POS,
        BORDER_POS,
        CORNER_POS
    } position_t;

    position_t position;

    typedef enum int {
        SMALL,
        MEDIUM,
        LARGE
    } radius_type_t;

    radius_type_t radius_type;

    typedef enum int {
        NO_TEXTURE,
        SPRAY,
        DIAGONAL
    } texture_type_t;

    texture_type_t texture_type;

    typedef enum int {
        LOW_THRESHOLD,
        NORMAL_THRESHOLD,
        HIGH_THRESHOLD
    } threshold_type_t;

    threshold_type_t threshold_type;

    //---------------------------------------------------------
    // Covergroup
    //---------------------------------------------------------
    covergroup cg;

        //-----------------------------------------------------
        // Canvas X
        //-----------------------------------------------------
        cp_x: coverpoint point_x {
            bins left   = {[0 : 79]};
            bins center = {[80 : 239]};
            bins right  = {[240 : 319]};
        }

        //-----------------------------------------------------
        // Canvas Y
        //-----------------------------------------------------
        cp_y: coverpoint point_y {
            bins top    = {[0 : 59]};
            bins middle = {[60 : 179]};
            bins bottom = {[180 : 239]};
        }

        //-----------------------------------------------------
        // Position
        //-----------------------------------------------------
        cp_position: coverpoint position {
            bins center_pos = {CENTER_POS};
            bins border_pos = {BORDER_POS};
            bins corner_pos = {CORNER_POS};
        }

        //-----------------------------------------------------
        // Radius (Hardware Spec: 2 to 11)[cite: 3, 11]
        //-----------------------------------------------------
        cp_radius: coverpoint radius {
            bins min = {[2 : 4]};
            bins mid = {[5 : 8]};
            bins max = {[9 : 11]}; 
        }

        //-----------------------------------------------------
        // Radius Classification
        //-----------------------------------------------------
        cp_radius_type: coverpoint radius_type {
            bins min = {SMALL}; 
            bins mid = {MEDIUM}; 
            bins max = {LARGE};
        }

        //-----------------------------------------------------
        // Threshold (Hardware Spec Max: 121)[cite: 3]
        //-----------------------------------------------------
        cp_threshold: coverpoint sq_threshold {
            bins low    = {[0 : 25]};
            bins normal = {[26 : 81]};
            bins high   = {[82 : 121]};
        }

        //-----------------------------------------------------
        // Threshold Classification
        //-----------------------------------------------------
        cp_threshold_type: coverpoint threshold_type {
            bins low    = {LOW_THRESHOLD};
            bins normal = {NORMAL_THRESHOLD};
            bins high   = {HIGH_THRESHOLD};
        }

        //-----------------------------------------------------
        // Texture Enable
        //-----------------------------------------------------
        cp_texture_enable: coverpoint texture_enable {
            bins off = {0}; 
            bins on  = {1};
        }

        //-----------------------------------------------------
        // Texture Shape (Valid: 0 to 4)[cite: 3, 11]
        //-----------------------------------------------------
        cp_texture_shape: coverpoint texture_shape {
            bins spray_small   = {0};
            bins spray_medium  = {1};
            bins spray_large   = {2};
            bins diagonal_thin = {3};
            bins diagonal_wide = {4};
            ignore_bins invalid = {[5 : 7]}; // 스펙 아웃 범위 제외[cite: 8]
        }

        //-----------------------------------------------------
        // Texture Type
        //-----------------------------------------------------
        cp_texture_type: coverpoint texture_type {
            bins none     = {NO_TEXTURE};
            bins spray    = {SPRAY};
            bins diagonal = {DIAGONAL};
        }

        //-----------------------------------------------------
        // Color
        //-----------------------------------------------------
        cp_color: coverpoint color {
            bins transparent   = {0};
            bins low           = {[1 : 7]};
            bins texture_color = {[8 : 15]};
        }

        //-----------------------------------------------------
        // Cross Coverage
        //-----------------------------------------------------
        cross cp_texture_enable, cp_texture_shape {
            ignore_bins shape_without_texture =
                binsof(cp_texture_enable) intersect {0}
                &&
                binsof(cp_texture_shape) intersect {[0 : 7]};
        }

        cross cp_texture_type, cp_radius_type;
        cross cp_position, cp_radius_type;
        cross cp_texture_shape, cp_radius;
        cross cp_texture_enable, cp_color;

    endgroup

    //---------------------------------------------------------
    // Constructor
    //---------------------------------------------------------
    function new(string name = "brush_coverage", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    //---------------------------------------------------------
    // Sampling
    //---------------------------------------------------------
    function void write(brush_seq_item t);

        // Copy input
        point_x        = t.point_x;
        point_y        = t.point_y;
        radius         = t.radius;
        sq_threshold   = t.sq_threshold;
        texture_enable = t.texture_enable;
        texture_shape  = t.texture_shape;
        color          = t.color;

        // Texture Active Control Logic
        texture_active = texture_enable && color[3];

        // Position classification
        if(((point_x==0)||(point_x==319)) && ((point_y==0)||(point_y==239))) begin
            position = CORNER_POS;
        end
        else if((point_x<32) || (point_x>287) || (point_y<24) || (point_y>215)) begin
            position = BORDER_POS;
        end else begin
            position = CENTER_POS;
        end

        // Radius classification (Spec-matched 2~11 Scale)[cite: 3]
        if (radius <= 4)       radius_type = SMALL;
        else if (radius <= 8)  radius_type = MEDIUM;
        else                   radius_type = LARGE;

        // Threshold classification (Spec-matched 0~121 Scale)[cite: 3]
        if (sq_threshold <= 25)      threshold_type = LOW_THRESHOLD;
        else if (sq_threshold <= 81) threshold_type = NORMAL_THRESHOLD;
        else                         threshold_type = HIGH_THRESHOLD;

        // Texture classification
        if (!texture_active) begin
            texture_type = NO_TEXTURE;
        end else begin
            case (texture_shape)
                3'd0, 3'd1, 3'd2: texture_type = SPRAY;
                3'd3, 3'd4:       texture_type = DIAGONAL;
                default:          texture_type = NO_TEXTURE;
            endcase
        end

        // Sample Trigger
        cg.sample();

    endfunction

endclass

`endif