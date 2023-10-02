//
// Top module for YakiRouter: 2X4 router
// Created by - Yakir Peretz

`resetall
`timescale 1ps/1ps

module YakiRouter_Top#(
   parameter data_size          = 8
)
( 
   // Port Declarations
   // Inputs
   input logic i_clk,
   input logic i_rstn,
   // channel 0 input
   input logic i_ch_0_en,
   input logic [data_size-1:0] i_data_in_0,
   // channel 1 input
   input logic i_ch_1_en,
   input logic [data_size-1:0] i_data_in_1,
   /// Outputs
   // general outputs
   output logic o_busy,
   output logic o_error,
   // channel 0 outputs
   output logic [data_size-1:0] o_data_out_0,
   output logic o_ch_0_vld,
   // channel 1 outputs
   output logic [data_size-1:0] o_data_out_1,
   output logic o_ch_1_vld,
   // channel 2 outputs
   output logic [data_size-1:0] o_data_out_2,
   output logic o_ch_2_vld,
   // channel 3 outputs
   output logic [data_size-1:0] o_data_out_3,
   output logic o_ch_3_vld,
);




endmodule
