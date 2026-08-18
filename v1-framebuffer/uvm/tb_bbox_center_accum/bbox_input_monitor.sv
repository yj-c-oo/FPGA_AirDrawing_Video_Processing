`ifndef BBOX_INPUT_MONITOR_SV
`define BBOX_INPUT_MONITOR_SV


class bbox_input_monitor extends uvm_monitor;

    `uvm_component_utils(bbox_input_monitor)

    uvm_analysis_port #(bbox_frame_item) ap;


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
        bbox_frame_item item;

        int x_cnt;
        int y_cnt;

        forever begin
            @(vif.mon_cb);
            if(vif.mon_cb.we) begin
                item = bbox_frame_item::type_id::create("item");
                item.clear_frame();
                x_cnt = 0;
                y_cnt = 0;

                forever begin
                    if(vif.mon_cb.we) begin
                        item.pixel_map[y_cnt][x_cnt] = vif.mon_cb.hit;

                        if(x_cnt==319) begin
                            x_cnt = 0;
                            y_cnt++;
                        end
                        else begin
                            x_cnt++;
                        end
                    end

                    if(vif.mon_cb.vsync) begin
                        `uvm_info(
                            get_type_name(),
                            $sformatf("[INPUT MON] Frame captured pixels=%0d", x_cnt + y_cnt*320),
                            UVM_MEDIUM
                        )
                        ap.write(item);
                        break;
                    end

                    @(vif.mon_cb);
                end
            end
        end

    endtask

endclass

`endif
