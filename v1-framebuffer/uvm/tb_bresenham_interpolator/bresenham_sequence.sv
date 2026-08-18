`ifndef BRESENHAM_BASE_SEQUENCE_SV
`define BRESENHAM_BASE_SEQUENCE_SV

class bresenham_random_seq extends uvm_sequence #(bresenham_seq_item);
    `uvm_object_utils(bresenham_random_seq)

    function new(string name="bresenham_random_seq");
        super.new(name);
    endfunction

    virtual task body();

        bresenham_seq_item item;

        repeat(200) begin

            item = bresenham_seq_item::type_id::create("item");

            start_item(item);
            assert(item.randomize());
            finish_item(item);

        end

    endtask

endclass


class bresenham_boundary_seq extends uvm_sequence #(bresenham_seq_item);
    `uvm_object_utils(bresenham_boundary_seq)

    function new(string name="bresenham_boundary_seq");
        super.new(name);
    endfunction

    //--------------------------------------------
    // Local Task
    //--------------------------------------------
    task send_line(
        input int x0,
        input int y0,
        input int x1,
        input int y1
    );
        bresenham_seq_item item;

        item = bresenham_seq_item::type_id::create("item");

        start_item(item);

        item.x0 = x0;
        item.y0 = y0;
        item.x1 = x1;
        item.y1 = y1;

        finish_item(item);
    endtask

    virtual task body();

        //--------------------------------------------
        // Corner
        //--------------------------------------------
        send_line(0,0,319,239);
        send_line(319,239,0,0);
        send_line(0,239,319,0);
        send_line(319,0,0,239);

        //--------------------------------------------
        // Horizontal
        //--------------------------------------------
        send_line(0,120,319,120);
        send_line(319,120,0,120);

        //--------------------------------------------
        // Vertical
        //--------------------------------------------
        send_line(160,0,160,239);
        send_line(160,239,160,0);

        //--------------------------------------------
        // 45 Degree
        //--------------------------------------------
        send_line(20,20,100,100);
        send_line(100,100,20,20);

        //--------------------------------------------
        // dx > dy
        //--------------------------------------------
        send_line(10,10,250,60);

        //--------------------------------------------
        // dy > dx
        //--------------------------------------------
        send_line(30,30,80,220);

        //--------------------------------------------
        // Zero-length line
        //--------------------------------------------
        send_line(100,100,100,100);

    endtask

endclass


class bresenham_regression_seq extends uvm_sequence #(bresenham_seq_item);
    `uvm_object_utils(bresenham_regression_seq)

    function new(string name="bresenham_regression_seq");
        super.new(name);
    endfunction

    virtual task body();

        bresenham_boundary_seq boundary_seq;
        bresenham_random_seq random_seq;

        boundary_seq = bresenham_boundary_seq::type_id::create("boundary_seq");
        random_seq   = bresenham_random_seq::type_id::create("random_seq");

        //--------------------------------
        // Boundary
        //--------------------------------
        boundary_seq.start(m_sequencer);

        //--------------------------------
        // Random 100개
        //--------------------------------
        repeat(5)
            random_seq.start(m_sequencer);

    endtask

endclass

`endif