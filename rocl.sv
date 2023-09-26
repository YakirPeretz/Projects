// Rocl module
// Clock generator
// Create By: Yakir Peretz

`resetall
`timescale 1ps/1ps
module Rocl #( // Parameters
parameter Nde = 32
)
( // I/O Signals
output wire o_clk
);
// internal signals

wire [Nde-1:0] R_osc; // Ring oscilator


assign #(10) R_osc[0] = ~R_osc[Nde-1]; // delay of 10 ps

genvar i;
generate // generate the delay line
  for(i=1;i<Nde;i=i+1)
  begin: Ring_oscillator
    assign #(10) R_osc[i] = R_osc[i-1];
  end
endgenerate

assign o_clk = R_osc[0]; // clk - freq = 1.5625GHz

endmodule