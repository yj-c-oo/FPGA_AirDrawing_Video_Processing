`ifndef STROKE_DRIVER_SV
`define STROKE_DRIVER_SV

class stroke_driver extends uvm_driver #(stroke_transaction);

    `uvm_component_utils(stroke_driver)

    //------------------------------------------
    // Virtual Interface
    //------------------------------------------
    virtual stroke_if vif;

    //------------------------------------------
    // Constructor
    //------------------------------------------
    function new(string name = "stroke_driver", uvm_component parent = null);

        super.new(name, parent);

    endfunction

    //------------------------------------------
    // Build Phase
    //------------------------------------------
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual stroke_if)::get(this, "", "vif", vif)) begin

            `uvm_fatal(get_type_name(), "Failed to get virtual interface")

        end

    endfunction

    //------------------------------------------
    // Run Phase
    //------------------------------------------
    task run_phase(uvm_phase phase);
        // [추가] 리셋이 해제될 때까지(rst == 0) 안전하게 대기
        wait (vif.rst === 1'b0);
        // 혹시 모를 메타스테이블 방지를 위해 리셋 해제 후 2~3클록 더 대기
        repeat (3) @(vif.drv_cb);

        forever begin

            seq_item_port.get_next_item(req);

            drive(req);

            seq_item_port.item_done();

        end

    endtask

    //------------------------------------------
    // Drive Task
    //------------------------------------------
    task drive(stroke_transaction tr);
        // 기본 입력 처리
        vif.drv_cb.pen_present  <= tr.pen_present;
        vif.drv_cb.X_center     <= tr.X_center;
        vif.drv_cb.Y_center     <= tr.Y_center;
        vif.drv_cb.sw_pen_color <= tr.sw_pen_color;
        vif.drv_cb.sw_eraser    <= tr.sw_eraser;
        vif.drv_cb.sw_size      <= tr.sw_size;
        vif.drv_cb.line_ready   <= tr.line_ready;

        // frame_done Pulse (1 Cycle)
        @(vif.drv_cb);
        vif.drv_cb.frame_done <= 1'b1;

        @(vif.drv_cb);
        vif.drv_cb.frame_done <= 1'b0;

    
        // --------------------------------------------------
        // 펜이 눌려있을 때(1)만 하드웨어 시퀀스(line_start/done)를 대기함
        // --------------------------------------------------
        if (tr.pen_present) begin
            // line_start 발생 대기
            fork
                begin
                    @(posedge vif.line_start);
                end
                begin
                    repeat(10000) @(vif.drv_cb);
                    `uvm_error(get_type_name(), "TIMEOUT: line_start did not assert after 10000 cycles!")
                end
            join_any
            disable fork;

            `uvm_info(get_type_name(),
                $sformatf("line_start detected (%0d,%0d) -> (%0d,%0d)",
                vif.line_x0, vif.line_y0, vif.line_x1, vif.line_y1),
                UVM_MEDIUM);

            // line_done 대기
            fork
                begin
                    @(posedge vif.line_done);
                end
                begin
                    repeat(10000) @(vif.drv_cb);
                    `uvm_error(get_type_name(), "TIMEOUT: line_done did not assert after 10000 cycles!")
                end
            join_any
            disable fork;

            `uvm_info(get_type_name(), "line_done detected", UVM_MEDIUM);
        end
        else begin
            // 펜을 뗐을 때는 하드웨어가 동작하지 않으므로 대기 없이 즉시 종료하여 다음 아이템 진행
            `uvm_info(get_type_name(), "Pen is UP. Skipping line wait.", UVM_HIGH);
        end

    endtask

endclass

`endif
