`ifndef BRUSH_OUTPUT_MONITOR_SV
`define BRUSH_OUTPUT_MONITOR_SV

class brush_output_monitor extends uvm_monitor;
    `uvm_component_utils(brush_output_monitor)

    //---------------------------------------------------------
    // Analysis Port
    //---------------------------------------------------------
    uvm_analysis_port #(brush_output_item) ap;

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

        if(!uvm_config_db #(virtual brush_if)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"Cannot get brush_if");

    endfunction

    //---------------------------------------------------------
    task run_phase(uvm_phase phase);

        brush_output_item item;

        forever begin

            //-------------------------------------------------
            // Wait until a new stamp starts
            //-------------------------------------------------
            @(vif.mon_cb);

            if(vif.mon_cb.point_valid && vif.mon_cb.point_ready) begin

                item = brush_output_item::type_id::create("item", this);

                //-------------------------------------------------
                // Collect all RAM writes for one stamp
                //-------------------------------------------------
                forever begin

                    @(vif.mon_cb);

                    if(vif.mon_cb.ram_we) begin

                        item.ram_addr_q.push_back(vif.mon_cb.ram_waddr);
                        item.ram_data_q.push_back(vif.mon_cb.ram_wdata);

                        `uvm_info(get_type_name(),
                            $sformatf(
                            "[WRITE] ADDR=%0d DATA=%0h",
                            vif.mon_cb.ram_waddr,
                            vif.mon_cb.ram_wdata),
                            UVM_HIGH)

                    end

                    //-------------------------------------------------
                    // Stamp finished
                    //-------------------------------------------------
                    if(vif.mon_cb.stamp_done) begin

                        `uvm_info(get_type_name(),
                            $sformatf(
                            "STAMP DONE : total write = %0d",
                            item.ram_addr_q.size()),
                            UVM_MEDIUM)

                        ap.write(item);

                        break;

                    end

                end

            end

        end

    endtask

endclass

`endif