interface bresenham_if(input logic clk);

    logic rst;

    logic line_start;
    logic [8:0] line_x0;
    logic [8:0] line_y0;
    logic [8:0] line_x1;
    logic [8:0] line_y1;

    logic line_ready;
    logic line_done;

    logic point_valid;
    logic point_ready;
    logic [8:0] point_x;
    logic [8:0] point_y;

    logic stamp_done;
    logic busy;

    clocking drv_cb @(posedge clk);

        default input #1step output #0;

        output line_start;
        output line_x0;
        output line_y0;
        output line_x1;
        output line_y1;

        output point_ready;
        output stamp_done;

        input line_ready;
        input line_done;
        input point_valid;
        input point_x;
        input point_y;
        input busy;

    endclocking


    clocking mon_cb @(posedge clk);

        default input #1step;

        input line_start;
        input line_x0;
        input line_y0;
        input line_x1;
        input line_y1;

        input point_valid;
        input point_ready;
        input point_x;
        input point_y;

        input line_done;
        input busy;

    endclocking

endinterface