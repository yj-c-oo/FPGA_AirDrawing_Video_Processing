`ifndef PENCONTROL_ENV_SV
`define PENCONTROL_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "pencontrol_agent.sv"
`include "pencontrol_scoreboard.sv"
`include "pencontrol_coverage.sv"

class pencontrol_env extends uvm_env;
    `uvm_component_utils(pencontrol_env)

    pencontrol_agent      agt;
    pencontrol_scoreboard scb;
    pencontrol_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = pencontrol_agent::type_id::create("agt", this);
        scb = pencontrol_scoreboard::type_id::create("scb", this);
        cov = pencontrol_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.drv.exp_ap.connect(scb.exp_imp);
        agt.mon.act_ap.connect(scb.act_imp);
        agt.drv.cov_ap.connect(cov.analysis_export);
        cov.scb = scb;
    endfunction
endclass

`endif
