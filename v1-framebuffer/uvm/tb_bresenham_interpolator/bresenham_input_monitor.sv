`ifndef BRESENHAM_INPUT_MONITOR_SV
`define BRESENHAM_INPUT_MONITOR_SV

class bresenham_input_monitor extends uvm_monitor;
    `uvm_component_utils(bresenham_input_monitor)

    // Scoreboard로 전달
    uvm_analysis_port #(bresenham_seq_item) ap;

    virtual bresenham_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if(!uvm_config_db #(virtual bresenham_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Cannot get bresenham_if")
    endfunction


    task run_phase(uvm_phase phase);

        bresenham_seq_item item;

        forever begin

            @(vif.mon_cb);

            if(vif.mon_cb.line_start) begin

                item = bresenham_seq_item::type_id::create("item", this);

                item.x0 = vif.mon_cb.line_x0;
                item.y0 = vif.mon_cb.line_y0;
                item.x1 = vif.mon_cb.line_x1;
                item.y1 = vif.mon_cb.line_y1;

                `uvm_info(get_type_name(),
                    $sformatf("[INPUT] (%0d,%0d) -> (%0d,%0d)",
                        item.x0,
                        item.y0,
                        item.x1,
                        item.y1),
                    UVM_MEDIUM)

                ap.write(item);

            end

        end

    endtask

endclass

`endif