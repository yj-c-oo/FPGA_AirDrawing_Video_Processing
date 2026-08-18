`ifndef BRESENHAM_OUTPUT_MONITOR_SV
`define BRESENHAM_OUTPUT_MONITOR_SV

class bresenham_output_monitor extends uvm_monitor;
    `uvm_component_utils(bresenham_output_monitor)

    uvm_analysis_port #(bresenham_output_item) ap;

    virtual bresenham_if vif;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap",this);

        if(!uvm_config_db #(virtual bresenham_if)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"Cannot get bresenham_if");
    endfunction


    task run_phase(uvm_phase phase);

        bresenham_output_item item;

        forever begin

            item = bresenham_output_item::type_id::create("item");

            //--------------------------------------------------
            // line_done 전까지 point들을 계속 저장
            //--------------------------------------------------
            forever begin

                @(vif.mon_cb);

                if(vif.mon_cb.point_valid && vif.mon_cb.point_ready) begin

                    item.point_x_q.push_back(vif.mon_cb.point_x);
                    item.point_y_q.push_back(vif.mon_cb.point_y);

                    `uvm_info(get_type_name(),
                        $sformatf("[POINT] (%0d,%0d)",
                        vif.mon_cb.point_x,
                        vif.mon_cb.point_y),
                        UVM_HIGH)

                end

                //--------------------------------------------------
                // 한 Line 종료
                //--------------------------------------------------
                if(vif.mon_cb.line_done) begin

                    `uvm_info(get_type_name(),
                        $sformatf("LINE DONE : total point = %0d",
                        item.point_x_q.size()),
                        UVM_MEDIUM)

                    ap.write(item);

                    break;

                end

            end

        end

    endtask

endclass

`endif