//
// Verilog Module HR_DPWM_lib.Clock_choose
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 15:29:16 11/ 5/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//
`resetall
`timescale 10ps/1ps
module Clock_choose#( // Parameters
parameter Nde = 64,
parameter DE_bits = 6,
parameter Dc_length = 13,
parameter Count_length = Dc_length-DE_bits
)
( // I/O Signals
input rst,
input wire [Dc_length-1:0] H_on,
input wire [Dc_length-1:0] L_on,
input wire [Dc_length-1:0] DeadTime,
input wire L_PWM,
input wire H_PWM,
output wire [Count_length+1:0] High_div,
output wire [Count_length+1:0] Low_div, 
output wire [Count_length:0] DT_div,
output wire [DE_bits-1:0]  H_start_curr,
output wire [DE_bits-1:0]  H_stop_curr,
output wire [DE_bits-1:0]  L_start_curr,
output wire [DE_bits-1:0]  L_stop_curr,
output wire enable_h,
output wire enable_l
);
// Internal signals
wire [DE_bits-1:0]  H_start_next;
wire [DE_bits-1:0]  H_stop_next;
wire [DE_bits-1:0]  L_start_next;
wire [DE_bits-1:0]  L_stop_next;
reg [Count_length+1:0] H_div_curr_reg;
reg [Count_length+1:0] L_div_curr_reg;
reg [Count_length:0] DT_div_curr_reg;
reg [DE_bits-1:0]  H_start_curr_reg;
reg [DE_bits-1:0]  H_stop_curr_reg;
reg [DE_bits-1:0]  L_start_curr_reg;
reg [DE_bits-1:0]  L_stop_curr_reg;
wire [Count_length+1:0] High_div_next;
wire [Count_length+1:0] Low_div_next;
wire [Count_length:0] DT_div_next;
wire reminder_flag_DT;
wire reminder_flag_DTLOW;
wire reminder_flag_DTHIGH;
reg p_sel_l1;
reg p_sel_l2;
reg p_sel_h1;
reg p_sel_h2;
wire [Dc_length:0] L_DT_sum;
wire [Dc_length:0] H_DT_sum;
wire [Count_length:0] H_DT_sum_sf;
wire [Count_length:0] L_DT_sum_sf;
wire [Count_length-1:0] DeadTime_sf;

// calculate counters limit
assign L_DT_sum = DeadTime+L_on; 
assign H_DT_sum = H_on+DeadTime;
assign reminder_flag_DTHIGH = |H_DT_sum[DE_bits-1:0];
assign reminder_flag_DTLOW = |L_DT_sum[DE_bits-1:0]; // or LSB DE_BITS - check if the period time is mult of 64
assign reminder_flag_DT = |DeadTime[DE_bits-1:0]; // or LSB DE_BITS -> check for reminder

assign H_DT_sum_sf = H_DT_sum>>DE_bits;
assign L_DT_sum_sf = L_DT_sum >>DE_bits;
assign DeadTime_sf = DeadTime>>DE_bits;
assign  High_div_next = (reminder_flag_DTHIGH)  ? (H_DT_sum_sf+1):(H_DT_sum_sf); // high counters limit for output logic
assign  Low_div_next = (reminder_flag_DTLOW) ? (L_DT_sum_sf+1):(L_DT_sum_sf);  // Low counters limit for logic output
assign  DT_div_next  = reminder_flag_DT? (DeadTime_sf+1):(DeadTime_sf); // DeadTime limit for logic output

/// delay H_div,L_div and DT_div for the current period ///
always @(negedge L_PWM or posedge rst)
begin: Delay_Hdiv_Ldiv_DTdiv
  if (rst) begin
  H_div_curr_reg<= 64;
  L_div_curr_reg<=64;
  DT_div_curr_reg <=32;
  end
  else begin
  H_div_curr_reg<= High_div_next;
  L_div_curr_reg<=Low_div_next;
  DT_div_curr_reg <= DT_div_next;
end
end

assign High_div = H_div_curr_reg; // current H_div out
assign Low_div = L_div_curr_reg;  // current L_div out
assign DT_div = DT_div_curr_reg; // current DT_div out

//////////////////////////////////////////////////////
//// pointer for the next period  ///////////////////
assign H_start_next = L_stop_curr_reg+DeadTime; // H_start pointer calculation
assign H_stop_next = H_start_next+H_on; // H_stop pointer calculation
assign L_start_next = H_stop_next+DeadTime; // L_start pointer calculation
assign L_stop_next = L_start_next+L_on; // L_stop pointer calculation

//// Delay Low pointers for period //////
always @(negedge L_PWM or posedge rst)
begin: Delay_LOW_pointers
  if (rst)
  begin
    L_start_curr_reg<=16;
    L_stop_curr_reg<=32;
  end
  else
  begin
    L_start_curr_reg<=L_start_next;
    L_stop_curr_reg<=L_stop_next;
  end
end
//// Delay High pointers for High On time  //////
always @(negedge H_PWM or posedge rst)
begin: Delay_HIGH_pointers
  if (rst)
  begin
    H_start_curr_reg<=0;
    H_stop_curr_reg<=8;
  end
  else
  begin
    H_start_curr_reg<= H_start_next;
    H_stop_curr_reg<=H_stop_next;
  end
end

assign  H_start_curr=H_start_curr_reg;
assign  H_stop_curr=H_stop_curr_reg;
assign  L_start_curr=L_start_curr_reg;
assign  L_stop_curr=L_stop_curr_reg;

/////////////////////////////////////////////////////////
/// LOW Pointers select - choosing two set of pointers - M1 and M2 changing period by period

always @(negedge L_PWM or posedge rst)
begin:Sel_period_changing_end
  if(rst)
  p_sel_l1<=1;
  else
  p_sel_l1<= ~p_sel_l1;
end

always @(negedge H_PWM or posedge rst)
begin:Sel_period_changing
  if(rst)
  p_sel_l2<=0;
  else
  p_sel_l2<= ~p_sel_l2;
end
 ///  High Pointers select - indicates the end of High On and for choosing the next pointers
 /// this bit is the enable bit for the high counters
always @(negedge H_PWM or posedge rst)
begin:Sel_High_changing_negedge
  if(rst)
  p_sel_h1<=0;
  else
  p_sel_h1<= ~p_sel_h1;
end

/// enable high counters for the next period cycle

always @(negedge L_PWM or posedge rst)
begin:Sel_High_changing_period_end
  if(rst)
  p_sel_h2<=0;
  else
  p_sel_h2<= ~p_sel_h2;
end


// two enable bits for the counters 
assign enable_h = p_sel_h1^p_sel_h2;
assign enable_l = p_sel_l1^p_sel_l2;




endmodule
