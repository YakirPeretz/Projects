// Test bench for Frequency Duty Divider module
// Created By : Yakir Peretz
`resetall
`timescale 1ps/1ps

module FDD_tb#(
   // synopsys template
   parameter Nde          = 32,
   parameter Count_bits   = 16

);

reg [Count_bits-1:0] div_count;
reg [Count_bits-1:0] duty_count;
reg rstn;
reg enable;

Freq_Div_Duty_Top  #(.Nde(Nde),.Count_bits(Count_bits)) FDD (
    .i_div_count(div_count),
    .i_duty_count(duty_count),
    .i_rstn(rstn),
    .i_enable(enable),
    .o_div_clk()
);

initial begin
  $deposit(FDD.clk_gen.R_osc,32'hFFFF_FFFE);
  rstn <= 1;
  enable <= 0;
  div_count <= 0;
  duty_count <= 0;
  #100ns;
  rstn <= 0;
  #50ns;
  rstn <= 1;
  #50ns;
  enable <= 1;
  #200ns;
  div_count <= 5;
  duty_count <=2;
  #200ns;
  duty_count <=7;
  #200ns;
  div_count <= 14;
  #200ns;
  duty_count <= 0;
  #200ns;
end
endmodule
