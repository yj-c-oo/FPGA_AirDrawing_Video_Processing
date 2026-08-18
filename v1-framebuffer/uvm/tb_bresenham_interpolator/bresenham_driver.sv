`ifndef BRESENHAM_DRIVER_SV
`define BRESENHAM_DRIVER_SV

class bresenham_driver extends uvm_driver #(bresenham_seq_item);
    `uvm_component_utils(bresenham_driver)

    virtual bresenham_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual bresenham_if)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"Cannot get bresenham_if")
    endfunction


    task run_phase(uvm_phase phase);

        bresenham_seq_item item;

        //-------------------------------------------------
        // 초기값
        //-------------------------------------------------
        vif.drv_cb.line_start  <= 0;
        vif.drv_cb.line_x0     <= 0;
        vif.drv_cb.line_y0     <= 0;
        vif.drv_cb.line_x1     <= 0;
        vif.drv_cb.line_y1     <= 0;

        vif.drv_cb.point_ready <= 0;
        vif.drv_cb.stamp_done  <= 0;

        //-------------------------------------------------
        // reset 해제 대기
        //-------------------------------------------------
        wait(vif.rst==0);

        repeat(3) @(vif.drv_cb);

        forever begin

            //-------------------------------------------------
            // Sequence Item 수신
            //-------------------------------------------------
            seq_item_port.get_next_item(item);

            //-------------------------------------------------
            // DUT가 Idle이 될 때까지 대기
            //-------------------------------------------------
            while(!vif.drv_cb.line_ready)
                @(vif.drv_cb);

            //-------------------------------------------------
            // Line 정보 전달
            //-------------------------------------------------
            @(vif.drv_cb);

            vif.drv_cb.line_x0 <= item.x0;
            vif.drv_cb.line_y0 <= item.y0;
            vif.drv_cb.line_x1 <= item.x1;
            vif.drv_cb.line_y1 <= item.y1;

            vif.drv_cb.line_start <= 1'b1;

            `uvm_info(get_type_name(),
                $sformatf("START LINE (%0d,%0d) -> (%0d,%0d)",
                item.x0,item.y0,item.x1,item.y1),
                UVM_MEDIUM)

            //-------------------------------------------------
            // line_start는 1cycle pulse
            //-------------------------------------------------
            @(vif.drv_cb);
            vif.drv_cb.line_start <= 0;

            //-------------------------------------------------
            // Point 하나씩 처리
            //-------------------------------------------------
            forever begin

                //-------------------------------------------------
                // point_valid 대기
                //-------------------------------------------------
                while(!vif.drv_cb.point_valid &&
                      !vif.drv_cb.line_done)
                    @(vif.drv_cb);

                //-------------------------------------------------
                // line 종료
                //-------------------------------------------------
                if(vif.drv_cb.line_done)
                    break;

                //-------------------------------------------------
                // point 수신
                //-------------------------------------------------
                `uvm_info(get_type_name(),
                    $sformatf("POINT (%0d,%0d)",
                    vif.drv_cb.point_x,
                    vif.drv_cb.point_y),
                    UVM_HIGH)

                //-------------------------------------------------
                // Renderer가 point를 받았다고 응답
                //-------------------------------------------------
                @(vif.drv_cb);

                vif.drv_cb.point_ready <= 1'b1;

                @(vif.drv_cb);

                vif.drv_cb.point_ready <= 1'b0;

                //-------------------------------------------------
                // Stamp 완료 신호
                //-------------------------------------------------
                repeat(2) @(vif.drv_cb);

                vif.drv_cb.stamp_done <= 1'b1;

                @(vif.drv_cb);

                vif.drv_cb.stamp_done <= 1'b0;

            end

            //-------------------------------------------------
            // line_done 확인
            //-------------------------------------------------
            `uvm_info(get_type_name(),
                "LINE DONE",
                UVM_MEDIUM)

            seq_item_port.item_done();

            @(vif.drv_cb);

        end

    endtask

endclass

`endif