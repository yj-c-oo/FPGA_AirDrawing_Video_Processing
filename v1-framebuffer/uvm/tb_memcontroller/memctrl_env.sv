`ifndef MEMCTRL_ENV_SV
`define MEMCTRL_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "memctrl_seq_item.sv"

class memctrl_env extends uvm_env;
    `uvm_component_utils(memctrl_env)

    memctrl_agent      agt;
    memctrl_scoreboard scb;
    memctrl_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = memctrl_agent::type_id::create("agt", this);
        scb = memctrl_scoreboard::type_id::create("scb", this);
        cov = memctrl_coverage::type_id::create("cov", this);
        cov.scb = scb;
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.drv.ap_exp.connect(scb.exp_imp);
        agt.drv.ap_timing_exp.connect(scb.tim_exp_imp);
        agt.drv.ap_exp.connect(cov.analysis_export);
        agt.mon.ap.connect(scb.act_imp);
        agt.mon.timing_ap.connect(scb.tim_act_imp);
    endfunction
endclass

`endif
