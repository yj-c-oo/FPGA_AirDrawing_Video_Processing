interface stroke_if (
    input logic clk,
    input logic rst
);

    logic        frame_done;
    logic        pen_present;
    logic [8:0]  X_center;
    logic [8:0]  Y_center;
    logic [2:0]  sw_pen_color;
    logic        sw_eraser;
    logic        sw_size;

    logic        line_ready;
    logic        line_done;

    logic        line_start;
    logic [8:0]  line_x0;
    logic [8:0]  line_y0;
    logic [8:0]  line_x1;
    logic [8:0]  line_y1;
    logic [3:0]  line_color;
    logic [4:0]  line_radius;
    logic [10:0] line_threshold;
    logic        busy;


    //--------------------------------------------------
    // Driver Clocking Block
    //--------------------------------------------------

    clocking drv_cb @(posedge clk);

        default input #1step output #0;

        output frame_done;
        output pen_present;
        output X_center;
        output Y_center;
        output sw_pen_color;
        output sw_eraser;
        output sw_size;

        output line_ready;

        input line_done;
        input line_start;
        input line_x0;
        input line_y0;
        input line_x1;
        input line_y1;
        input line_color;
        input line_radius;
        input line_threshold;
        input busy;

    endclocking


    //--------------------------------------------------
    // Monitor Clocking Block
    //--------------------------------------------------

    clocking mon_cb @(posedge clk);

        default input #1step;

        input frame_done;
        input pen_present;
        input X_center;
        input Y_center;
        input sw_pen_color;
        input sw_eraser;
        input sw_size;

        input line_ready;
        input line_done;

        input line_start;
        input line_x0;
        input line_y0;
        input line_x1;
        input line_y1;
        input line_color;
        input line_radius;
        input line_threshold;
        input busy;

    endclocking

endinterface
