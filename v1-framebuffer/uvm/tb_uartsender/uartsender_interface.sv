interface uartsender_if (
    input logic clk,
    input logic rst
);

    logic       send_trigger;
    logic [8:0] X_center;
    logic [8:0] Y_center;
    logic       sw_paint_red;
    logic       sw_paint_green;
    logic       sw_paint_blue;
    logic       sw_eraser;
    logic       sw_size;
    logic       sw_texture_enable;
    logic [2:0] texture_shape;
    logic       paper;
    logic       clear_btn;

    logic       tx;
    logic       busy;

    logic       baud_tick_dbg;
    logic       tx_start_dbg;
    logic       tx_busy_dbg;
    logic       tx_done_dbg;
    logic [7:0] tx_data_dbg;
    logic [1:0] state_dbg;
    logic [2:0] byte_index_dbg;

    int unsigned cycle_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end
endinterface
