//
// Verilog Module my_project1_lib.Flags
//
// Created:
//          by - topay.UNKNOWN (L330W528)
//          at - 19:04:19 12/12/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
module Flags #( // Parameters
parameter DE_bits = 6,
parameter Dc_length = 13,
parameter Count_length = Dc_length-DE_bits
)
( // I/O Signals
input   wire  clk_base,
input   wire  rst,
input   wire  L_DPWM,
output  wire  [Count_length+2:0] Flags_out
);

wire L_DPWM_delay;
reg [Count_length+1:0] reg_Flags_p;
reg [Count_length+1:0] reg_Flags_n;
reg L_DPWM_rst,L_DPWM_delay_p,L_DPWM_delay_n;
assign reset_Flags = rst|L_DPWM_rst;
assign Flags_out = reg_Flags_p+reg_Flags_n;
assign L_DPWM_delay = L_DPWM_delay_p&L_DPWM_delay_n;
always @(posedge clk_base or posedge reset_Flags)
begin: counter_Clock_base_posetive
  if (reset_Flags)
  begin
    reg_Flags_p <= 0;
  end // end rst
  else 
  begin
        reg_Flags_p <= reg_Flags_p + 1'b1;
    end
    L_DPWM_delay_p <= L_DPWM;
end // end always

always @(negedge clk_base or posedge reset_Flags)
begin: counter_Clock_base_negedge
  if (reset_Flags)
  begin
    reg_Flags_n <= 0;
  end // end rst
  else 
  begin
        reg_Flags_n  <= reg_Flags_n + 1'b1;
    end
     L_DPWM_delay_n <= L_DPWM;
end // end always

always @(L_DPWM,L_DPWM_delay) 
begin:check_for_neg_LPWM_for_rst
  if (L_DPWM_delay==1 &&L_DPWM==0)
    L_DPWM_rst=1;
  else
  L_DPWM_rst=0;
  
end



endmodule

