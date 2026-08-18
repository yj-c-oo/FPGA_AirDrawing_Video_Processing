interface uartrxpacked_if (
    input logic clk,
    input logic rst
);

    logic       rx;

    logic [2:0] o_pen_color;
    logic       o_eraser;
    logic       o_size;
    logic       o_texture_enable;
    logic [2:0] o_texture_shape;
    logic       o_paper;
    logic       o_clear_pulse;
    logic       o_packet_valid;

    logic       baud_tick_dbg;
    logic       rx_done_dbg;
    logic [7:0] rx_data_dbg;
    logic [1:0] state_dbg;

    int unsigned cycle_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output rx;
        input  cycle_count;
        input  baud_tick_dbg;
        input  rx_done_dbg;
        input  rx_data_dbg;
        input  state_dbg;
        input  o_pen_color;
        input  o_eraser;
        input  o_size;
        input  o_texture_enable;
        input  o_texture_shape;
        input  o_paper;
        input  o_clear_pulse;
        input  o_packet_valid;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #0 output #0;
        input rx;
        input cycle_count;
        input baud_tick_dbg;
        input rx_done_dbg;
        input rx_data_dbg;
        input state_dbg;
        input o_pen_color;
        input o_eraser;
        input o_size;
        input o_texture_enable;
        input o_texture_shape;
        input o_paper;
        input o_clear_pulse;
        input o_packet_valid;
    endclocking
endinterface
