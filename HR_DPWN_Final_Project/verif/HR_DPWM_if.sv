//
// Verilog interface HR_DPWM_lib.HR_DPWM_if
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 19:40:37 12/ 4/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
interface HR_DPWM_if#(
  parameter DE_bits      = 6,
   parameter Dc_length    = 13,
   parameter Count_length = Dc_length-DE_bits
);
logic  [Dc_length-1:0]  DeadTime;
logic  [Dc_length-1:0]  H_on;
logic  [Dc_length-1:0]  L_on; 
logic                   rst;
logic                   H_DPWM; 
logic                   L_DPWM;
logic [Count_length+1:0] Flags_out;
logic clk_base;



endinterface
