`ifndef UARTRXPACKED_ENV_SV
`define UARTRXPACKED_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class uartrxpacked_env extends uvm_env;
    `uvm_component_utils(uartrxpacked_env)

    uartrxpacked_agent      agt;
    uartrxpacked_scoreboard scb;
    uartrxpacked_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = uartrxpacked_agent::type_id::create("agt", this);
        scb = uartrxpacked_scoreboard::type_id::create("scb", this);
        cov = uartrxpacked_coverage::type_id::create("cov", this);
        cov.scb = scb;
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.drv.byte_exp_ap.connect(scb.byte_exp_imp);
        agt.mon.byte_ap.connect(scb.byte_act_imp);
        agt.drv.packet_exp_ap.connect(scb.pkt_exp_imp);
        agt.mon.packet_ap.connect(scb.pkt_act_imp);
        agt.drv.cov_ap.connect(cov.analysis_export);
    endfunction
endclass

`endif
