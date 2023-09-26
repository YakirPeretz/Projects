//
// Verilog Module HR_DPWM_lib.Counters_high
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 20:53:44 11/28/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
module Counters_high#( // Parameters
parameter Nde = 64,
parameter DE_bits = 6,
parameter Dc_length = 13,
parameter Count_length = Dc_length-DE_bits
)
( // I/O Signals
input wire H_start_Dclk,
input wire H_stop_Dclk,
input wire rst,
input wire enable_h,
///////////////
output wire [Count_length:0] High_start_counter_p,
output wire [Count_length:0] High_start_counter_n,

output wire [Count_length:0] High_stop_counter_p,
output wire [Count_length:0] High_stop_counter_n

);
// internal signals
reg [Count_length:0] H_start_counter_p;
reg [Count_length:0] H_stop_counter_p;
reg [Count_length:0] H_start_counter_n;
reg [Count_length:0] H_stop_counter_n;
wire reset;

// My Code
assign High_start_counter_p = H_start_counter_p;
assign High_start_counter_n = H_start_counter_n;
assign High_stop_counter_p = H_stop_counter_p;
assign High_stop_counter_n = H_stop_counter_n;
assign reset = rst|enable_h; // reset =1 when rst=1 or enable_h=1

//////// High start counters //////////////////////
always @(posedge H_start_Dclk or posedge reset)
begin: counter_High_start_positive
  if (reset)
  begin
    H_start_counter_p <= 0;
  end // end rst
  else 
  begin //begin else
        H_start_counter_p <= H_start_counter_p+1;
      end // else
end // end always

always @(negedge H_start_Dclk or posedge reset)
begin: counter_High_start_negetive
  if (reset)
  begin
    H_start_counter_n <= 0;
  end // end rst
  else 
  begin
        H_start_counter_n <= H_start_counter_n+1;
      end
end // end always
////////////////////////////////////////////////////
///////// High Stop Counters ///////////////
always @(posedge H_stop_Dclk or posedge reset)
begin: counter_High_stop_posetive
  if (reset)
  begin
    H_stop_counter_p <= 0;
  end // end rst
  else 
  begin
        H_stop_counter_p <= H_stop_counter_p+1;
      end
end // end always

always @(negedge H_stop_Dclk or posedge reset)
begin: counter_High_stop_negedge
  if (reset)
  begin
    H_stop_counter_n <= 0;
  end // end rst
  else 
  begin
        H_stop_counter_n <= H_stop_counter_n+1;
      end
end // end always




endmodule
