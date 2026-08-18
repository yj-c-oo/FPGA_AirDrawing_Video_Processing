`ifndef BRUSH_INPUT_MONITOR_SV
`define BRUSH_INPUT_MONITOR_SV

class brush_input_monitor extends uvm_monitor;
    `uvm_component_utils(brush_input_monitor)

    //---------------------------------------------------------
    // Analysis Port
    //---------------------------------------------------------
    uvm_analysis_port #(brush_seq_item) ap;

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

        ap = new("ap", this);

        if(!uvm_config_db #(virtual brush_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Cannot get brush_if")

    endfunction

    //---------------------------------------------------------
    task run_phase(uvm_phase phase);

        brush_seq_item item;

        forever begin

            @(vif.mon_cb);

            //-------------------------------------------------
            // New Brush Stamp
            //-------------------------------------------------
            if(vif.mon_cb.point_valid && vif.mon_cb.point_ready) begin

                item = brush_seq_item::type_id::create("item", this);

                item.point_x        = vif.mon_cb.point_x;
                item.point_y        = vif.mon_cb.point_y;

                item.color          = vif.mon_cb.color;

                item.radius         = vif.mon_cb.radius;

                item.sq_threshold   = vif.mon_cb.sq_threshold;

                item.texture_enable = vif.mon_cb.texture_enable;
                item.texture_shape  = vif.mon_cb.texture_shape;

                `uvm_info(get_type_name(),
                    $sformatf(
                    "[INPUT] P=(%0d,%0d) COLOR=%0d R=%0d TH=%0d TEX_EN=%0d SHAPE=%0d",
                    item.point_x,
                    item.point_y,
                    item.color,
                    item.radius,
                    item.sq_threshold,
                    item.texture_enable,
                    item.texture_shape),
                    UVM_MEDIUM)

                ap.write(item);

            end

        end

    endtask

endclass

`endif