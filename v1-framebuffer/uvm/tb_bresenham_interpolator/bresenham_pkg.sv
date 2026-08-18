`ifndef BRESENHAM_PKG_SV
`define BRESENHAM_PKG_SV

package bresenham_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `uvm_analysis_imp_decl(_INPUT)
    `uvm_analysis_imp_decl(_OUTPUT)

    // 1. Sequence Item / Transaction
    `include "bresenham_seq_item.sv"


    // 3. Sequences
    `include "bresenham_sequence.sv"

    // 4. 하위 컴포넌트들
    `include "bresenham_driver.sv"
    `include "bresenham_input_monitor.sv"
    `include "bresenham_output_monitor.sv"
    `include "bresenham_coverage.sv"

    // 5. 상위 컴포넌트들 (Env가 Agent와 Scoreboard를 품음)
    `include "bresenham_scoreboard.sv"
    `include "bresenham_agent.sv"

    // 6. 환경 및 테스트 케이스들
    `include "bresenham_env.sv"
    `include "bresenham_test.sv"

endpackage

`endif