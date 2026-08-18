`ifndef BRUSH_DRIVER_SV
`define BRUSH_DRIVER_SV

class brush_driver extends uvm_driver #(brush_seq_item);
    `uvm_component_utils(brush_driver)

    //---------------------------------------------------------
    // Virtual Interface
    //---------------------------------------------------------
    virtual brush_if vif;

    //---------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //---------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual brush_if)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"Cannot get brush_if")

    endfunction

    //---------------------------------------------------------
    task run_phase(uvm_phase phase);

        brush_seq_item item;

        //-----------------------------------------------------
        // Initial Value
        //-----------------------------------------------------
        vif.drv_cb.point_valid     <= 0;

        vif.drv_cb.point_x         <= 0;
        vif.drv_cb.point_y         <= 0;

        vif.drv_cb.color           <= 0;

        vif.drv_cb.radius          <= 2;

        vif.drv_cb.sq_threshold    <= 4;

        vif.drv_cb.texture_enable  <= 0;
        vif.drv_cb.texture_shape   <= 0;

        //-----------------------------------------------------
        // Wait Reset Release
        //-----------------------------------------------------
        wait(vif.rst == 0);

        repeat(3) @(vif.drv_cb);

        forever begin

            //-------------------------------------------------
            // Receive Sequence Item
            //-------------------------------------------------
            seq_item_port.get_next_item(item);

            //-------------------------------------------------
            // Wait DUT Ready
            //-------------------------------------------------
            while(!vif.drv_cb.point_ready)
                @(vif.drv_cb);

            //-------------------------------------------------
            // Drive Brush Point
            //-------------------------------------------------
            @(vif.drv_cb);

            vif.drv_cb.point_x        <= item.point_x;
            vif.drv_cb.point_y        <= item.point_y;

            vif.drv_cb.color          <= item.color;

            vif.drv_cb.radius         <= item.radius;

            vif.drv_cb.sq_threshold   <= item.sq_threshold;

            vif.drv_cb.texture_enable <= item.texture_enable;
            vif.drv_cb.texture_shape  <= item.texture_shape;

            vif.drv_cb.point_valid    <= 1'b1;

            `uvm_info(get_type_name(),
                $sformatf(
                "STAMP START : P=(%0d,%0d) COLOR=%0d R=%0d TH=%0d TEX_EN=%0d SHAPE=%0d",
                item.point_x,
                item.point_y,
                item.color,
                item.radius,
                item.sq_threshold,
                item.texture_enable,
                item.texture_shape),
                UVM_MEDIUM)

            //-------------------------------------------------
            // point_valid : One Cycle Pulse
            //-------------------------------------------------
            @(vif.drv_cb);

            vif.drv_cb.point_valid <= 1'b0;

            //-------------------------------------------------
            // Wait Stamp Complete
            //-------------------------------------------------
            while(!vif.drv_cb.stamp_done)
                @(vif.drv_cb);

            `uvm_info(get_type_name(),
                "STAMP DONE",
                UVM_HIGH)

            //-------------------------------------------------
            // Transaction Complete
            //-------------------------------------------------
            seq_item_port.item_done();

            @(vif.drv_cb);

        end

    endtask

endclass

`endif