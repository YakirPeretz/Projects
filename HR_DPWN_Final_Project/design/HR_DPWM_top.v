//
// Verilog Module HR_DPWM_lib.HR_DPWM_top
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 17:33:30 12/ 4/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
module HR_DPWM_top#(
   // synopsys template
   parameter Nde          = 64,
   parameter DE_bits      = 6,
   parameter Dc_length    = 13,
   parameter Count_length = Dc_length-DE_bits
)
( 
   // Port Declarations
   input   wire    [Dc_length-1:0]  DeadTime, 
   input   wire    [Dc_length-1:0]  H_on, 
   input   wire    [Dc_length-1:0]  L_on, 
   input   wire                     rst, 
   output  wire                     H_DPWM, 
   output  wire                     L_DPWM,
   output  wire                     clk_base
);


// Internal Declarations


// Local declarations

// Internal signal declarations
wire  [Count_length:0]     DT_div;
wire  [Nde - 1:0]          Delay;
wire                       H_start_Dclk;
wire  [DE_bits-1:0]        H_start_curr;
wire                       H_stop_Dclk;
wire  [DE_bits-1:0]        H_stop_curr;
wire  [Count_length+1:0]   High_div;
wire [Count_length:0] High_start_counter_p;
wire [Count_length:0] High_start_counter_n;
wire [Count_length:0] High_stop_counter_p;
wire [Count_length:0] High_stop_counter_n;
wire                       L_start_Dclk;
wire  [DE_bits-1:0]        L_start_curr;
wire  [DE_bits-1:0]        L_start_next;
wire                       L_stop_Dclk;
wire  [DE_bits-1:0]        L_stop_curr;
wire  [DE_bits-1:0]        L_stop_next;
wire  [Count_length+1:0]   Low_div;
wire [Count_length:0] Low_start_counter_p;
wire [Count_length:0] Low_start_counter_n;
wire [Count_length:0] Low_stop_counter_p;
wire [Count_length:0] Low_stop_counter_n;
wire                       enable_h;
wire                       enable_l;

assign clk_base = Delay[0];

// Instances 
Clock_choose #(.Nde(Nde),.DE_bits(DE_bits),.Dc_length(Dc_length),.Count_length(Count_length)) U_2( 
   .rst          (rst), 
   .H_on         (H_on), 
   .L_on         (L_on), 
   .DeadTime     (DeadTime), 
   .L_PWM        (L_DPWM), 
   .H_PWM        (H_DPWM), 
   .High_div     (High_div), 
   .Low_div      (Low_div), 
   .DT_div       (DT_div), 
   .H_start_curr (H_start_curr), 
   .H_stop_curr  (H_stop_curr), 
   .L_start_curr (L_start_curr), 
   .L_stop_curr  (L_stop_curr),  
   .enable_h     (enable_h), 
   .enable_l     (enable_l)
); 

Counters_M1 #(.Nde(Nde),.DE_bits(DE_bits),.Dc_length(Dc_length),.Count_length(Count_length)) U_4( 
   .L_start_Dclk      (L_start_Dclk), 
   .L_stop_Dclk       (L_stop_Dclk), 
   .rst                  (rst), 
   .enable_l               (enable_l), 
   .Low_start_counter_p_m1 (Low_start_counter_p), 
   .Low_start_counter_n_m1 (Low_start_counter_n),
   .Low_stop_counter_p_m1  (Low_stop_counter_p),
   .Low_stop_counter_n_m1  (Low_stop_counter_n)

); 

Counters_high #(.Nde(Nde),.DE_bits(DE_bits),.Dc_length(Dc_length),.Count_length(Count_length)) U_3( 
   .H_start_Dclk       (H_start_Dclk), 
   .H_stop_Dclk        (H_stop_Dclk), 
   .rst                (rst), 
   .enable_h           (enable_h), 
   .High_start_counter_p (High_start_counter_p), 
   .High_start_counter_n (High_start_counter_n), 
   .High_stop_counter_p  (High_stop_counter_p),
   .High_stop_counter_n  (High_stop_counter_n)
); 

DL #(.Nde(Nde)) U_0( 
   .Delay    (Delay)
); 

Mux_Array #(.Nde(Nde),.DE_bits(DE_bits),.Dc_length(Dc_length),.Count_length(Count_length)) U_1( 
   .H_start_curr    (H_start_curr), 
   .H_stop_curr     (H_stop_curr), 
   .L_start_curr    (L_start_curr), 
   .L_stop_curr     (L_stop_curr), 
   .Delay           (Delay), 
   .H_start_Dclk    (H_start_Dclk), 
   .H_stop_Dclk     (H_stop_Dclk), 
   .L_start_Dclk    (L_start_Dclk), 
   .L_stop_Dclk     (L_stop_Dclk) 
); 

Output_logic #(.Nde(Nde),.DE_bits(DE_bits),.Dc_length(Dc_length),.Count_length(Count_length)) U_5( 
   .High_start_counter_p (High_start_counter_p), 
   .High_start_counter_n (High_start_counter_n), 
   .High_stop_counter_p  (High_stop_counter_p),
   .High_stop_counter_n  (High_stop_counter_n),
   .Low_start_counter_p (Low_start_counter_p), 
   .Low_start_counter_n (Low_start_counter_n),
   .Low_stop_counter_p  (Low_stop_counter_p),
   .Low_stop_counter_n  (Low_stop_counter_n),
   .High_div             (High_div), 
   .Low_div              (Low_div), 
   .DT_div               (DT_div), 
   .rst                  (rst), 
   .enable_l                (enable_l), 
   .enable_h                (enable_h), 
   .DH_DPWM              (H_DPWM), 
   .DL_DPWM              (L_DPWM)
); 

endmodule
