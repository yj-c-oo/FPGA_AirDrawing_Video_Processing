`ifndef UARTSENDER_ENV_SV
`define UARTSENDER_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uartsender_agent.sv"
`include "uartsender_scoreboard.sv"
`include "uartsender_coverage.sv"

class uartsender_env extends uvm_env;
    `uvm_component_utils(uartsender_env)

    uartsender_agent      agt;
    uartsender_scoreboard scb;
    uartsender_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = uartsender_agent::type_id::create("agt", this);
        scb = uartsender_scoreboard::type_id::create("scb", this);
        cov = uartsender_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.drv.byte_exp_ap.connect(scb.byte_exp_imp);
        agt.mon.byte_ap.connect(scb.byte_act_imp);
        agt.drv.packet_exp_ap.connect(scb.pkt_exp_imp);
        agt.mon.packet_ap.connect(scb.pkt_act_imp);
        agt.drv.cov_ap.connect(cov.analysis_export);
        cov.scb = scb;
    endfunction
endclass

`endif
