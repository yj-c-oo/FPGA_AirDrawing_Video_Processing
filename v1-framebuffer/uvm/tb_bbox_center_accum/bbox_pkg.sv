`ifndef BBOX_PKG_SV
`define BBOX_PKG_SV

package bbox_pkg;

    import uvm_pkg::*;

    `include "uvm_macros.svh"

    `include "bbox_seq_item.sv"

    `include "bbox_sequence.sv"
    `include "bbox_coverage.sv"
    `include "bbox_scoreboard.sv"
    `include "bbox_driver.sv"
    `include "bbox_input_monitor.sv"
    `include "bbox_output_monitor.sv"

    `include "bbox_agent.sv"
    `include "bbox_env.sv"

    `include "bbox_test.sv"

endpackage


`endif
