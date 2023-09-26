//
// Verilog Module HR_DPWM_lib.Counters_M1
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 17:46:26 11/19/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
module Counters_M1#( // Parameters
parameter Nde = 64,
parameter DE_bits = 6,
parameter Dc_length = 13,
parameter Count_length = Dc_length-DE_bits
)
( // I/O Signals
input wire L_start_Dclk,
input wire L_stop_Dclk,
input wire rst,
input wire enable_l,
///////////////
output wire [Count_length:0] Low_start_counter_p_m1,
output wire [Count_length:0] Low_start_counter_n_m1,

output wire [Count_length:0] Low_stop_counter_p_m1,
output wire [Count_length:0] Low_stop_counter_n_m1
);


// internal signals
reg [Count_length:0] L_start_counter_m1_p;
reg [Count_length:0] L_stop_counter_m1_p;
reg [Count_length:0] L_start_counter_m1_n;
reg [Count_length:0] L_stop_counter_m1_n;
wire reset_m1;
// My Code
assign Low_start_counter_p_m1 = L_start_counter_m1_p;
assign Low_start_counter_n_m1 = L_start_counter_m1_n;
assign Low_stop_counter_p_m1 = L_stop_counter_m1_p;
assign Low_stop_counter_n_m1 = L_stop_counter_m1_n;
assign reset_m1= rst|enable_l;

///////////////////////////////////////////////////////////
/////////// Low Start Counters ////////////////////////////

always @(posedge L_start_Dclk or posedge reset_m1)
begin: counter_Low_start_posetive
  if (reset_m1)
  begin
    L_start_counter_m1_p <= 0;
  end // end rst
  else 
  begin
        L_start_counter_m1_p <= L_start_counter_m1_p+1;
    end
end // end always

always @(negedge L_start_Dclk or posedge reset_m1)
begin: counter_Low_start_negedge
  if (reset_m1)
  begin
    L_start_counter_m1_n <= 0;
  end // end rst
  else 
  begin
        L_start_counter_m1_n  <= L_start_counter_m1_n+1;
    end
end // end always

////////////////////////////////////////////////////////////////
//////// Low Stop Counters /////////////////////////////////////
always @(posedge L_stop_Dclk or posedge reset_m1)
begin: counter_Low_stop_posedge
  if (reset_m1)
  begin
    L_stop_counter_m1_p <= 0;
  end // end rst
  else 
  begin
        L_stop_counter_m1_p  <= L_stop_counter_m1_p +1;
    end
end // end always

always @(negedge L_stop_Dclk or posedge reset_m1)
begin: counter_Low_stop_negedge
  if (reset_m1)
  begin
    L_stop_counter_m1_n <= 0;
  end // end rst
  else 
  begin
        L_stop_counter_m1_n  <= L_stop_counter_m1_n +1;
    end
end // end always
//////////////////////////////////////////////////////////////////////


endmodule
