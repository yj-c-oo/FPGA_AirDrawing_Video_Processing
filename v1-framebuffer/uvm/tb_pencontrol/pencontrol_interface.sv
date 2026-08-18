interface pencontrol_if (
    input logic clk,
    input logic rst
);

    logic       i_uart_valid;
    logic [2:0] i_uart_pen_color;
    logic       i_uart_eraser;
    logic       i_uart_size;
    logic       i_uart_texture_enable;
    logic [2:0] i_uart_texture_shape;
    logic       i_uart_paper;
    logic       i_uart_clear_pulse;
    logic       i_btn_eraser;
    logic       i_btn_mode;
    logic       i_btn_size;

    logic [2:0] o_pen_color;
    logic       o_eraser;
    logic       o_size;
    logic       o_texture_enable;
    logic [2:0] o_texture_shape;
    logic       o_paper;
    logic       o_clear;

    logic       clear_active_dbg;
    logic [15:0] clear_cnt_dbg;

    int unsigned cycle_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end
endinterface
