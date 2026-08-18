`ifndef STROKE_TRANSACTION_SV
`define STROKE_TRANSACTION_SV

class stroke_transaction extends uvm_sequence_item;

    `uvm_object_utils(stroke_transaction)

    //------------------------------------------
    // Stroke Number
    //------------------------------------------
    int stroke_id;

    //------------------------------------------
    // Input Information
    //------------------------------------------
    bit        pen_present;

    bit [8:0]  X_center;
    bit [8:0]  Y_center;

    bit [2:0]  sw_pen_color;

    bit        sw_eraser;
    bit        sw_size;

    bit        line_ready;

    //------------------------------------------
    // Output Information
    //------------------------------------------
    bit        line_start;

    bit [8:0]  line_x0;
    bit [8:0]  line_y0;

    bit [8:0]  line_x1;
    bit [8:0]  line_y1;

    bit [3:0]  line_color;

    bit [4:0]  line_radius;

    bit [10:0] line_threshold;

    bit        busy;


    typedef enum bit[1:0] {

    FRAME_EVENT,
    DONE_EVENT

} stroke_event_e;

stroke_event_e event_type;

    //------------------------------------------
    // Constructor
    //------------------------------------------
    function new(string name="stroke_transaction");
        super.new(name);
    endfunction

    //------------------------------------------
    // Print
    //------------------------------------------
    function void do_print(uvm_printer printer);

        super.do_print(printer);

        printer.print_int("stroke_id", stroke_id, 32, UVM_DEC);

        printer.print_field("pen_present", pen_present, 1, UVM_BIN);

        printer.print_int("X_center", X_center, 9, UVM_DEC);
        printer.print_int("Y_center", Y_center, 9, UVM_DEC);

        printer.print_field("sw_pen_color", sw_pen_color, 3, UVM_BIN);
        printer.print_field("sw_eraser", sw_eraser, 1, UVM_BIN);
        printer.print_field("sw_size", sw_size, 1, UVM_BIN);

        printer.print_field("line_start", line_start, 1, UVM_BIN);

        printer.print_int("line_x0", line_x0, 9, UVM_DEC);
        printer.print_int("line_y0", line_y0, 9, UVM_DEC);

        printer.print_int("line_x1", line_x1, 9, UVM_DEC);
        printer.print_int("line_y1", line_y1, 9, UVM_DEC);

        printer.print_field("line_color", line_color, 4, UVM_BIN);

        printer.print_int("line_radius", line_radius, 5, UVM_DEC);

        printer.print_int("line_threshold", line_threshold, 11, UVM_DEC);

        printer.print_field("busy", busy, 1, UVM_BIN);

    endfunction

endclass

//////////////////// Output Transaction(stroke_result) ////////////////////////
class stroke_result extends uvm_sequence_item;

    `uvm_object_utils(stroke_result)

    int stroke_id;

    bit [8:0] line_x0;
    bit [8:0] line_y0;

    bit [8:0] line_x1;
    bit [8:0] line_y1;

    bit [3:0] line_color;

    bit [4:0] line_radius;

    bit [10:0] line_threshold;

    bit busy;

    function new(string name="stroke_result");
        super.new(name);
    endfunction

endclass

`endif

