`ifndef BBOX_DRIVER_SV
`define BBOX_DRIVER_SV


class bbox_driver extends uvm_driver #(bbox_frame_item);

    `uvm_component_utils(bbox_driver)

    virtual bbox_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual bbox_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Cannot get bbox_if")
        end
    endfunction


    task run_phase(uvm_phase phase);

        bbox_frame_item item;

        bbox_scoreboard sb;


        vif.drv_cb.vsync <= 1'b0;
        vif.drv_cb.we    <= 1'b0;
        vif.drv_cb.hit   <= 1'b0;


        wait (vif.rst == 0);

        repeat (3) @(vif.drv_cb);

        if (!$cast(sb, uvm_top.find("uvm_test_top.env.scoreboard"))) begin
            `uvm_fatal(get_type_name(), "Cannot find scoreboard instance")
        end

        forever begin
            seq_item_port.get_next_item(item);

            `uvm_info(get_type_name(), "START FRAME", UVM_MEDIUM)

            if (sb.cov != null) begin
                sb.cov.write(item);
            end

            // Pixel scan
            for (int y = 0; y < 240; y++) begin
                for (int x = 0; x < 320; x++) begin
                    @(vif.drv_cb);

                    vif.drv_cb.vsync <= 1'b0;
                    vif.drv_cb.we <= 1'b1;

                    vif.drv_cb.hit <= item.pixel_map[y][x];
                end
            end

            // Write disable
            @(vif.drv_cb);
            vif.drv_cb.we  <= 1'b0;
            vif.drv_cb.hit <= 1'b0;


            // VSYNC pulse
            // Frame 종료
            @(vif.drv_cb);
            vif.drv_cb.vsync <= 1'b1;

            @(vif.drv_cb);
            vif.drv_cb.vsync <= 1'b0;


            while (!vif.drv_cb.valid) begin
                @(vif.drv_cb);
            end

            `uvm_info(get_type_name(), $sformatf(
                      "FRAME DONE CX=%0d CY=%0d PEN=%0d",
                      vif.drv_cb.cx,
                      vif.drv_cb.cy,
                      vif.drv_cb.pen
                      ), UVM_MEDIUM)

            seq_item_port.item_done();

        end

    endtask

endclass

`endif
