//
// Verilog Module HR_DPWM_lib.Mux_Array
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 11:17:41 12/ 6/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
module Mux_Array#( // Parameters
parameter Nde = 64,
parameter DE_bits = 6,
parameter Dc_length = 13,
parameter Count_length = Dc_length-DE_bits
)
(// I/O 
input wire [DE_bits-1:0]  H_start_curr,
input wire [DE_bits-1:0]  H_stop_curr,
input wire [DE_bits-1:0]  L_start_curr,
input wire [DE_bits-1:0]  L_stop_curr,
input wire [Nde-1:0] Delay,
output wire H_start_Dclk,
output wire H_stop_Dclk,
output wire L_start_Dclk,
output wire L_stop_Dclk
);


assign H_start_Dclk  =  Delay[H_start_curr];
assign H_stop_Dclk   =  Delay[H_stop_curr];
assign L_start_Dclk  = Delay[L_start_curr];
assign L_stop_Dclk  = Delay[L_stop_curr];


endmodule
