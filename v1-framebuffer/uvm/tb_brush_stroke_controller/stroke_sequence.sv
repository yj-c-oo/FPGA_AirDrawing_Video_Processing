`ifndef STROKE_BASE_SEQUENCE_SV
`define STROKE_BASE_SEQUENCE_SV

class stroke_base_sequence extends uvm_sequence #(stroke_transaction);

    `uvm_object_utils(stroke_base_sequence)

    function new(string name="stroke_base_sequence");
        super.new(name);
    endfunction

    //--------------------------------------------------
    // Helper Task
    //--------------------------------------------------

    task send_frame(
        bit pen,
        int x,
        int y,
        bit [2:0] color,
        bit eraser,
        bit size
    );

        req = stroke_transaction::type_id::create("req");

        start_item(req);

        req.pen_present  = pen;
        req.X_center     = x;
        req.Y_center     = y;

        req.sw_pen_color = color;

        req.sw_eraser    = eraser;
        req.sw_size      = size;

        req.line_ready   = 1;

        finish_item(req);

    endtask

endclass

class stroke_basic_sequence extends stroke_base_sequence;

    `uvm_object_utils(stroke_basic_sequence)

    function new(string name="stroke_basic_sequence");
        super.new(name);
    endfunction

    task body();

        send_frame(
            1,
            100,
            80,
            3'b001,
            0,
            0
        );

    endtask

endclass

class stroke_connect_sequence extends stroke_base_sequence;

    `uvm_object_utils(stroke_connect_sequence)

    function new(string name="stroke_connect_sequence");
        super.new(name);
    endfunction

    task body();

        send_frame(1,100,100,3'b001,0,0);
        send_frame(1,110,110,3'b001,0,0);
        send_frame(1,120,120,3'b001,0,0);
        send_frame(1,130,130,3'b001,0,0);

    endtask

endclass

class stroke_penup_sequence extends stroke_base_sequence;

    `uvm_object_utils(stroke_penup_sequence)

    function new(string name="stroke_penup_sequence");
        super.new(name);
    endfunction

    task body();

        send_frame(1,100,100,3'b001,0,0);

        send_frame(0,100,100,3'b001,0,0);

        send_frame(1,200,200,3'b001,0,0);

    endtask

endclass

class stroke_eraser_sequence extends stroke_base_sequence;

    `uvm_object_utils(stroke_eraser_sequence)

    function new(string name="stroke_eraser_sequence");
        super.new(name);
    endfunction

    task body();

        send_frame(1,120,120,3'b010,1,0);

        send_frame(1,140,140,3'b010,1,1);

    endtask

endclass

class stroke_size_sequence extends stroke_base_sequence;

    `uvm_object_utils(stroke_size_sequence)

    function new(string name="stroke_size_sequence");
        super.new(name);
    endfunction

    task body();

        send_frame(1,100,100,3'b100,0,0);

        send_frame(1,150,150,3'b100,0,1);

    endtask

endclass

class stroke_random_sequence extends stroke_base_sequence;

    `uvm_object_utils(stroke_random_sequence)

    function new(string name="stroke_random_sequence");
        super.new(name);
    endfunction

    task body();

        repeat(250) begin

            send_frame(

                $urandom_range(0,1),

                $urandom_range(0,319),

                $urandom_range(0,239),

                $urandom_range(0,7),

                $urandom_range(0,1),

                $urandom_range(0,1)

            );

        end

    endtask

endclass

class stroke_stress_sequence extends stroke_base_sequence;

    `uvm_object_utils(stroke_stress_sequence)

    function new(string name="stroke_stress_sequence");
        super.new(name);
    endfunction

    task body();

        repeat(10000) begin

            send_frame(

                1,

                $urandom_range(0,319),

                $urandom_range(0,239),

                3'b001,

                0,

                $urandom_range(0,1)

            );

        end

    endtask

endclass



`endif