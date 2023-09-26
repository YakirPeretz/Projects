//
// Verilog Module HR_DPWM_lib.DL
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 10:57:40 10/25/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
module DL #( // Parameters
parameter Nde = 64
)
( // I/O Signals
output wire[Nde-1:0] Delay
);
// internal signals

wire [Nde-1:0] R_osc; // Ring oscilator
genvar i;
// my code

assign #(20) R_osc[0] = ~R_osc[Nde-1]; // delay of 200 ps - last element connected to not gate
generate // generate the delay line
  for(i=1;i<Nde;i=i+1)
  begin: Ring_oscillator
    buf #(20)(R_osc[i],R_osc[i-1]); // each delay element has tpd=200ps
  end
endgenerate
assign Delay = R_osc[Nde-1:0]; // Delay elements signals
endmodule
