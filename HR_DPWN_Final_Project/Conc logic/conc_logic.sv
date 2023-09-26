//
// Verilog Module SAR_Controller_lib.conc_logic
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 17:28:27 05/14/2022
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
module conc_logic #(
parameter ADC_width = 8,
parameter Dc_length = 13
)
(
input logic [ADC_width -1:0] ADC_res,
input logic clk,
input logic valid,
input logic [2:0] op,
input logic [1:0] switch,
input logic rst,
output reg [Dc_length-1:0] H_on,
output reg [Dc_length-1:0] L_on,
output reg [Dc_length-1:0] DeadTime
) ;
parameter FAIL = 3'b111,
          OP0 = 3'b000,
          OP1 = 3'b001,
          OP2 = 3'b010,
          OP3 = 3'b011,
          OP4 = 3'b100,
          OP5 = 3'b101,
          OP6 = 3'b110;


logic [Dc_length-1:0] conc_res;
logic enable_Hon,enable_Lon,enable_DT;
logic valid_d,reset;

always_ff @(posedge clk)
begin: VALID_FF
  valid_d<=valid;
end
assign reset = rst|op===FAIL;
assign enable_Hon = (switch==2'b00) & valid_d & (op!=FAIL);
assign enable_Lon = (switch==2'b01) & valid_d & (op!=FAIL);
assign enable_DT = (switch==2'b10) & valid_d & (op!=FAIL);

always @(ADC_res)
begin: OP_STATE
  unique case (op)
  FAIL: begin
        conc_res = {5'b00000,ADC_res};
      end
   OP0: begin
    conc_res = {5'b10000,ADC_res};
    end
   OP1: begin
    conc_res = {5'b01000,ADC_res};
    end
   OP2: begin
    conc_res = {5'b00100,ADC_res};
    end
   OP3: begin
    conc_res = {5'b00010,ADC_res};
    end
   OP4: begin
    conc_res = {5'b00001,ADC_res};
    end
    OP5: begin
      conc_res = {ADC_res,5'b10101};
    end
    OP6: begin
      conc_res = {ADC_res,5'b01010};
    end
  
endcase
end
  
always_ff @(posedge clk or posedge reset)
begin: HON_FF
    if (reset) begin
      H_on <= 13'd2000;
    end
    else begin
      if (enable_Hon)
          H_on<=conc_res;
    end
  
end
  
  
always_ff @(posedge clk or posedge reset)
begin: LON_FF
    if (reset) begin
      L_on <= 13'd1500;
    end
    else begin
      if (enable_Lon)
          L_on<=conc_res;
    end
  
end
  
    
always_ff @(posedge clk or posedge reset)
begin:DEADTIME_FF
    if (reset) begin
      DeadTime<= 13'd500;
    end
    else begin
      if (enable_DT)
          DeadTime<=conc_res;
    end
  
end
  



endmodule
