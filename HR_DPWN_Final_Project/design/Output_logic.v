//
// Verilog Module HR_DPWM_lib.Output_logic
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 18:09:33 10/26/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
module Output_logic #( // Parameters
parameter Nde = 64,
parameter DE_bits = 6,
parameter Dc_length = 13,
parameter Count_length = Dc_length-DE_bits
)
( // I/O Signals
input wire [Count_length:0] High_start_counter_p,
input wire [Count_length:0] High_start_counter_n,
input wire [Count_length:0] High_stop_counter_p,
input wire [Count_length:0] High_stop_counter_n,
input wire [Count_length:0] Low_start_counter_p,
input wire [Count_length:0] Low_start_counter_n,
input wire [Count_length:0] Low_stop_counter_p,
input wire [Count_length:0] Low_stop_counter_n,

//////

/////
input wire [Count_length+1:0] High_div,
input wire[Count_length+1:0] Low_div,
input wire [Count_length:0] DT_div,
input rst,
input enable_l,
input enable_h,
output wire DH_DPWM,
output wire DL_DPWM
) ;

// Internal signals


wire[Count_length:0] High_div_2;
wire[Count_length-1:0] DT_div_2;
wire[Count_length:0] Low_div_2;

wire High_div_res;
wire DT_div_res;
wire Low_div_res;

wire HPWM;
wire LPWM;
reg cpH1;
reg cpH2;
reg cpL1;
reg cpL2;

assign High_div_2 = High_div>>1;
assign DT_div_2 = DT_div>>1;
assign Low_div_2 = Low_div>>1;

//assign Low_div_plus = (L_stop_bf_L_start && Low_stop_counter_p>0 &&Low_stop_counter_n>0 ) ? Low_div+1 : Low_div; // in case Low stop counter preliminary to Low start
assign High_div_res = High_div[0] ? 1:0;
assign DT_div_res = DT_div[0] ? 1:0;
assign Low_div_res = Low_div[0] ? 1:0;

always @(High_start_counter_p,High_start_counter_n,rst,enable_h)
begin:high_start
   if (enable_h || rst)
      cpH1=0;
  else begin
  if(DT_div_res)
  begin
       if((High_start_counter_p>=DT_div_2 &&High_start_counter_n>=(DT_div_2+1)) ||(High_start_counter_p>=(DT_div_2+1) &&High_start_counter_n>=DT_div_2) )
       cpH1 = 1;
  end
  else
  begin
    if((High_start_counter_p>=DT_div_2 &&High_start_counter_n>=DT_div_2))
       cpH1 = 1;
      end
end
  end

always @(High_stop_counter_p,High_stop_counter_n,rst,enable_h)
begin:high_stop
   if (enable_h || rst)
      cpH2=0;
  else begin
  if(High_div_res)
  begin
       if((High_stop_counter_p<=High_div_2 &&High_stop_counter_n<(High_div_2+1)) ||(High_stop_counter_p<(High_div_2+1) &&High_stop_counter_n<=High_div_2) )
       cpH2 = 1;
       else
       cpH2 = 0;
  end
  else
  begin
    if((High_stop_counter_p<High_div_2 || High_stop_counter_n<High_div_2))
       cpH2 = 1;
      else
      cpH2 = 0;
      end
end
  end



always @(Low_start_counter_p,Low_start_counter_n,rst,enable_l)
begin:low_start
   if (enable_l || rst)
      cpL1=0;
  else begin
  if(DT_div_res)
  begin
       if((Low_start_counter_p>=DT_div_2 &&Low_start_counter_n>=(DT_div_2+1)) ||(Low_start_counter_p>=(DT_div_2+1) &&Low_start_counter_n>=DT_div_2) )
       cpL1 = 1;
  end
  else
  begin
    if((Low_start_counter_p>=DT_div_2 &&Low_start_counter_n>=DT_div_2))
       cpL1 = 1;
      end
end
  end

always @(Low_stop_counter_p,Low_stop_counter_n,rst,enable_l)
begin:low_stop
   if (enable_l || rst)
      cpL2=0;
  else begin
  if(Low_div_res)
  begin
       if((Low_stop_counter_p<=Low_div_2 &&Low_stop_counter_n<(Low_div_2+1)) ||(Low_stop_counter_p<(Low_div_2+1) &&Low_stop_counter_n<=Low_div_2) )
       cpL2 = 1;
       else
       cpL2 = 0;
  end
  else
  begin
    if((Low_stop_counter_p<Low_div_2 ||Low_stop_counter_n<Low_div_2))
       cpL2 = 1;
       else
       cpL2 = 0;
      end
end
  end


assign HPWM = (cpH1&cpH2); 
assign LPWM = (cpL1&cpL2);

assign DH_DPWM = HPWM;
assign DL_DPWM = LPWM;

endmodule
