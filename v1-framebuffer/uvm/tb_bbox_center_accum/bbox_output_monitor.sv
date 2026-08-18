`ifndef BBOX_OUTPUT_MONITOR_SV
`define BBOX_OUTPUT_MONITOR_SV


class bbox_output_monitor extends uvm_monitor;

    `uvm_component_utils(bbox_output_monitor)

    uvm_analysis_port #(bbox_output_item) ap;

    virtual bbox_if vif;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual bbox_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Cannot get bbox_if")
        end
    endfunction


    task run_phase(uvm_phase phase);

        bbox_output_item item;

        forever begin
            @(vif.mon_cb);

            if (vif.mon_cb.valid) begin

                item = bbox_output_item::type_id::create("item");

                item.cx = vif.mon_cb.cx;

                item.cy = vif.mon_cb.cy;

                item.pen = vif.mon_cb.pen;


                `uvm_info(get_type_name(),
                          $sformatf("[OUTPUT] CENTER=(%0d,%0d) PEN=%0d",
                                    item.cx, item.cy, item.pen), UVM_MEDIUM)


                ap.write(item);

            end
        end
    endtask

endclass

`endif
