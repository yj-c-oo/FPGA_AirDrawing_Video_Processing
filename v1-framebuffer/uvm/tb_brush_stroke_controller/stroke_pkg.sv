`ifndef STROKE_PKG_SV
`define STROKE_PKG_SV

package stroke_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `uvm_analysis_imp_decl(_INPUT)
    `uvm_analysis_imp_decl(_OUTPUT)

    // 1. Sequence Item / Transaction
    `include "stroke_seq_item.sv"

    // 2. Sequencer 정의 (agent에서 사용하므로 미리 정의)
    // typedef uvm_sequencer #(stroke_transaction) stroke_sequencer;

    // 3. Sequences
    `include "stroke_sequence.sv"

    // 4. 하위 컴포넌트들
    `include "stroke_driver.sv"
    `include "stroke_input_monitor.sv"
    `include "stroke_output_monitor.sv"
    `include "stroke_coverage.sv"

    // 5. 상위 컴포넌트들 (Env가 Agent와 Scoreboard를 품음)
    `include "stroke_scoreboard.sv"
    `include "stroke_agent.sv"

    // 6. 환경 및 테스트 케이스들
    `include "stroke_env.sv"
    `include "stroke_test.sv"

endpackage

`endif