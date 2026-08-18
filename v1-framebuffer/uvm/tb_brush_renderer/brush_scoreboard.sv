`ifndef BRUSH_SCOREBOARD_SV
`define BRUSH_SCOREBOARD_SV

`uvm_analysis_imp_decl(_input)
`uvm_analysis_imp_decl(_output)


class brush_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(brush_scoreboard)


    //------------------------------------------------------------
    // Analysis Ports
    //------------------------------------------------------------

    uvm_analysis_imp_input #(brush_seq_item,
                             brush_scoreboard) input_imp;


    uvm_analysis_imp_output #(brush_output_item,
                              brush_scoreboard) output_imp;


    //------------------------------------------------------------
    // Input Queue
    //------------------------------------------------------------

    brush_seq_item input_q[$];


    //------------------------------------------------------------
    // Statistics
    //------------------------------------------------------------

    int total_cnt;
    int pass_cnt;
    int fail_cnt;


    //------------------------------------------------------------
    // RTL identical variables
    //------------------------------------------------------------

    logic signed [5:0] offset_x;
    logic signed [5:0] offset_y;


    logic signed [11:0] canvas_x;
    logic signed [11:0] canvas_y;


    logic [6:0] abs_offset_x;
    logic [6:0] abs_offset_y;


    logic [14:0] offset_x_sq;
    logic [14:0] offset_y_sq;


    logic [14:0] distance_sq;

    logic [14:0] radius_sq;


    logic [7:0] spray_hash;


    logic signed [6:0] diagonal_delta;

    logic [6:0] abs_diagonal_delta;



    //------------------------------------------------------------
    function new(string name,
                 uvm_component parent);

        super.new(name,parent);

    endfunction



    //------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        input_imp  = new("input_imp",this);

        output_imp = new("output_imp",this);


        total_cnt = 0;
        pass_cnt  = 0;
        fail_cnt  = 0;


    endfunction



    //------------------------------------------------------------
    // Input Monitor Receive
    //------------------------------------------------------------

    function void write_input(brush_seq_item item);


        brush_seq_item copy;


        copy =
        brush_seq_item::type_id::create("copy");


        copy.copy(item);


        input_q.push_back(copy);


    endfunction



    //------------------------------------------------------------
    // RTL identical abs_s7()
    //------------------------------------------------------------

    function automatic logic [6:0] abs_s7
    (
        input logic signed [6:0] value
    );

        logic signed [6:0] neg_value;


        begin

            neg_value = -value;


            if(value < 0)

                abs_s7 = neg_value[6:0];

            else

                abs_s7 = value[6:0];


        end


    endfunction




    //------------------------------------------------------------
    // RTL identical texture_radius()
    //------------------------------------------------------------

    function automatic logic [4:0] texture_radius
    (
        input logic [4:0] base_radius,

        input logic [4:0] add_radius,

        input logic [4:0] min_radius
    );


        logic [5:0] sum_radius;


        begin


            sum_radius =
                {1'b0,base_radius} +
                {1'b0,add_radius};



            if(sum_radius < {1'b0,min_radius})


                texture_radius = min_radius;



            else if(sum_radius > 6'd11)


                texture_radius = 5'd11;



            else


                texture_radius =
                    sum_radius[4:0];


        end


    endfunction




    //------------------------------------------------------------
    // Output Monitor Receive
    //------------------------------------------------------------

    function void write_output
    (
        brush_output_item out_item
    );


        brush_seq_item in_item;



        //--------------------------------------------------------
        // RTL registers
        //--------------------------------------------------------

        logic [8:0] center_x;

        logic [8:0] center_y;


        logic [3:0] color;


        logic [4:0] radius_reg;


        logic [10:0] threshold_reg;



        logic texture_on_reg;

        logic texture_kind_reg;


        logic [2:0] spray_density_reg;

        logic [2:0] diagonal_half_width_reg;



        //--------------------------------------------------------
        // Golden output queue
        //--------------------------------------------------------

        logic [$clog2(320*240)-1:0] exp_addr_q[$];

        logic [3:0] exp_data_q[$];



        //--------------------------------------------------------
        // Local variables
        //--------------------------------------------------------

        logic plain_circle_mask;

        logic texture_circle_mask;

        logic spray_mask;

        logic diagonal_rect_mask;


        logic draw_pixel;


        int idx;
        



        total_cnt++;



        //--------------------------------------------------------
        // Input transaction check
        //--------------------------------------------------------

        if(input_q.size()==0) begin


            `uvm_error(get_type_name(),
                "No input transaction")


            fail_cnt++;

            return;


        end



        in_item =
            input_q.pop_front();




        //--------------------------------------------------------
        // Latch input exactly like DUT
        //--------------------------------------------------------

        center_x = in_item.point_x;

        center_y = in_item.point_y;


        color = in_item.color;


        threshold_reg =
            in_item.sq_threshold;




        //--------------------------------------------------------
        // Texture profile generation
        // Same as start_texture_* logic
        //--------------------------------------------------------

        texture_on_reg =
            in_item.texture_enable &&
            in_item.color[3];



        texture_kind_reg = 1'b0;


        radius_reg =
            in_item.radius;


        spray_density_reg = 3'd2;


        diagonal_half_width_reg = 3'd1;



        if(texture_on_reg) begin


            case(in_item.texture_shape)


                3'd0: begin

                    texture_kind_reg = 1'b0;


                    radius_reg =
                        texture_radius(
                            in_item.radius,
                            5'd2,
                            5'd5);


                    spray_density_reg = 3'd1;


                end



                3'd1: begin


                    texture_kind_reg = 1'b0;


                    radius_reg =
                        texture_radius(
                            in_item.radius,
                            5'd4,
                            5'd7);


                    spray_density_reg = 3'd2;


                end



                3'd2: begin


                    texture_kind_reg = 1'b0;


                    radius_reg =
                        texture_radius(
                            in_item.radius,
                            5'd6,
                            5'd9);


                    spray_density_reg = 3'd3;


                end



                3'd3: begin


                    texture_kind_reg = 1'b1;


                    radius_reg =
                        texture_radius(
                            in_item.radius,
                            5'd2,
                            5'd5);


                    diagonal_half_width_reg = 3'd1;


                end



                3'd4: begin


                    texture_kind_reg = 1'b1;


                    radius_reg =
                        texture_radius(
                            in_item.radius,
                            5'd4,
                            5'd7);


                    diagonal_half_width_reg = 3'd2;


                end



                default: begin


                    texture_kind_reg = 1'b0;


                    radius_reg =
                        texture_radius(
                            in_item.radius,
                            5'd2,
                            5'd5);


                    spray_density_reg = 3'd1;


                end


            endcase


        end



        //--------------------------------------------------------
        // Raster scan initialization
        // Same as DUT:
        //
        // offset_y = -radius
        // offset_x = -radius
        //--------------------------------------------------------

        offset_y =
            -$signed({1'b0,radius_reg});
        offset_x =
            -$signed({1'b0,radius_reg});

        //--------------------------------------------------------
        // Raster Scan
        // Same order as DUT:
        //
        // offset_y fixed
        // offset_x : -radius -> +radius
        //--------------------------------------------------------

        for(offset_y = -$signed({1'b0,radius_reg});
            offset_y <=  $signed({1'b0,radius_reg});
            offset_y++) begin


            for(offset_x = -$signed({1'b0,radius_reg});
                offset_x <=  $signed({1'b0,radius_reg});
                offset_x++) begin



                //------------------------------------------------
                // canvas coordinate
                // RTL:
                //
                // canvas_x =
                // $signed({1'b0,center_x}) + offset_x;
                //------------------------------------------------

                canvas_x =
                    $signed({1'b0,center_x}) +
                    offset_x;


                canvas_y =
                    $signed({1'b0,center_y}) +
                    offset_y;




                //------------------------------------------------
                // abs offset
                //------------------------------------------------

                abs_offset_x =
                    abs_s7(
                    $signed(
                    {offset_x[5],offset_x}));


                abs_offset_y =
                    abs_s7(
                    $signed(
                    {offset_y[5],offset_y}));




                //------------------------------------------------
                // square calculation
                // RTL width identical
                //------------------------------------------------

                offset_x_sq =
                    {8'd0,abs_offset_x} *
                    {8'd0,abs_offset_x};


                offset_y_sq =
                    {8'd0,abs_offset_y} *
                    {8'd0,abs_offset_y};



                distance_sq =
                    offset_x_sq +
                    offset_y_sq;



                radius_sq =
                    {10'd0,radius_reg} *
                    {10'd0,radius_reg};




                //------------------------------------------------
                // Masks
                //------------------------------------------------

                plain_circle_mask =
                    (distance_sq <=
                    {4'd0,threshold_reg});



                texture_circle_mask =
                    (distance_sq <=
                    radius_sq);



                //------------------------------------------------
                // Boundary check
                //------------------------------------------------

                if((canvas_x >= 0) &&
                   (canvas_x < 320) &&
                   (canvas_y >= 0) &&
                   (canvas_y < 240)) begin




                    //------------------------------------------------
                    // Texture calculation
                    //------------------------------------------------

                    spray_mask = 1'b0;

                    diagonal_rect_mask = 1'b0;



                    //------------------------------------------------
                    // Spray
                    //------------------------------------------------

                    spray_hash =
                        {3'b000,canvas_x[4:0]} ^
                        ({3'b000,canvas_y[4:0]} << 1) ^
                        {2'b00,center_x[5:0]} ^
                        ({2'b00,center_y[5:0]} << 2) ^
                        {2'b00,
                         offset_x[2:0],
                         offset_y[2:0]};



                    spray_mask =
                        texture_circle_mask &&
                        (spray_hash[2:0]
                         <=
                         spray_density_reg);




                    //------------------------------------------------
                    // Diagonal
                    //------------------------------------------------

                    diagonal_delta =
                        $signed(
                        {offset_y[5],offset_y})
                        -
                        $signed(
                        {offset_x[5],offset_x});



                    abs_diagonal_delta =
                        abs_s7(diagonal_delta);



                    diagonal_rect_mask =
                        (abs_diagonal_delta <=
                         {4'd0,
                          diagonal_half_width_reg})
                        &&
                        (abs_offset_x <=
                         {2'd0,radius_reg})
                        &&
                        (abs_offset_y <=
                         {2'd0,radius_reg});




                    //------------------------------------------------
                    // Final draw_pixel
                    //------------------------------------------------

                    draw_pixel =
                        plain_circle_mask;



                    if(texture_on_reg) begin


                        case(texture_kind_reg)


                            1'b0:
                                draw_pixel =
                                    spray_mask;


                            1'b1:
                                draw_pixel =
                                    diagonal_rect_mask;


                        endcase

                    end




                    //------------------------------------------------
                    // Expected RAM Write
                    //
                    // Same as DUT:
                    //
                    // ram_waddr <= canvas_y*320 + canvas_x
                    //------------------------------------------------

                    if(draw_pixel) begin


                        exp_addr_q.push_back(
                            canvas_y*320 +
                            canvas_x);



                        exp_data_q.push_back(
                            color);


                    end



                end



            end

        end




        //--------------------------------------------------------
        // Compare count
        //--------------------------------------------------------

        if(exp_addr_q.size()
           !=
           out_item.ram_addr_q.size()) begin


            `uvm_error(get_type_name(),
                $sformatf(
                "WRITE COUNT ERROR EXP=%0d DUT=%0d",
                exp_addr_q.size(),
                out_item.ram_addr_q.size()))


            fail_cnt++;

            return;


        end




        //--------------------------------------------------------
        // Compare RAM Write Sequence
        //--------------------------------------------------------

        for(idx=0;
            idx<exp_addr_q.size();
            idx++) begin



            if(exp_addr_q[idx]
               !==
               out_item.ram_addr_q[idx]) begin



                `uvm_error(get_type_name(),
                    $sformatf(
                    "ADDR ERROR [%0d] EXP=%0d DUT=%0d",
                    idx,
                    exp_addr_q[idx],
                    out_item.ram_addr_q[idx]))



                fail_cnt++;

                return;


            end




            if(exp_data_q[idx]
               !==
               out_item.ram_data_q[idx]) begin



                `uvm_error(get_type_name(),
                    $sformatf(
                    "DATA ERROR [%0d] EXP=%0h DUT=%0h",
                    idx,
                    exp_data_q[idx],
                    out_item.ram_data_q[idx]))



                fail_cnt++;

                return;


            end


        end




        //--------------------------------------------------------
        // PASS
        //--------------------------------------------------------

        pass_cnt++;


        `uvm_info(get_type_name(),
            $sformatf(
            "PASS : %0d writes",
            exp_addr_q.size()),
            UVM_MEDIUM)



    endfunction



    //------------------------------------------------------------
    // Report Phase
    //------------------------------------------------------------

    function void report_phase(uvm_phase phase);



        `uvm_info(get_type_name(),
            "===== Brush Renderer Scoreboard Report =====",
            UVM_LOW)



        `uvm_info(get_type_name(),
            $sformatf(
            "Total Transactions : %0d",
            total_cnt),
            UVM_LOW)



        `uvm_info(get_type_name(),
            $sformatf(
            "Pass               : %0d",
            pass_cnt),
            UVM_LOW)



        `uvm_info(get_type_name(),
            $sformatf(
            "Fail               : %0d",
            fail_cnt),
            UVM_LOW)



        if(fail_cnt==0)

            `uvm_info(get_type_name(),
                "TEST PASSED",
                UVM_LOW)

        else

            `uvm_error(get_type_name(),
                "TEST FAILED")



    endfunction


endclass


`endif