//
// Top module for Freq divider and duty change
// Created by - Yakir Peretz

`resetall
`timescale 1ps/1ps

module Freq_Div_Duty_Top#(
   // synopsys template
   parameter Nde          = 32,
   parameter Count_bits   = 16
)
( 
   // Port Declarations
   input [Count_bits-1:0] i_div_count,
   input [Count_bits-1:0] i_duty_count,
   input i_rstn,
   input i_enable,
   output  wire                     o_div_clk
);

wire base_clk;

Rocl #(.Nde(Nde))  clk_gen(
   .o_clk(base_clk)
);

Freq_Duty_div #(.Count_bits(Count_bits)) Freq_Duty_div_m (
.i_clk(base_clk),
.i_div_count(i_div_count),
.i_duty_count(i_duty_count),
.i_rstn(i_rstn),
.i_enable(i_enable),
.o_div_clk(o_div_clk)
);


endmodule
