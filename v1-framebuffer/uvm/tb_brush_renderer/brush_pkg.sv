`ifndef BRUSH_PKG_SV
`define BRUSH_PKG_SV


package brush_pkg;


import uvm_pkg::*;

`include "uvm_macros.svh"

//------------------------------------------------
// Interface independent files
//------------------------------------------------

`include "brush_seq_item.sv"


//------------------------------------------------
// Sequence
//------------------------------------------------

`include "brush_sequence.sv"


//------------------------------------------------
// Driver / Monitor
//------------------------------------------------

`include "brush_driver.sv"
`include "brush_input_monitor.sv"
`include "brush_output_monitor.sv"


//------------------------------------------------
// Agent / Env
//------------------------------------------------

`include "brush_agent.sv"
`include "brush_scoreboard.sv"
`include "brush_coverage.sv"
`include "brush_env.sv"


//------------------------------------------------
// Test
//------------------------------------------------

`include "brush_test.sv"

endpackage


`endif