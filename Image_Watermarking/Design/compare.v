//
// Verilog Module Image_Watermarking_Project_lib.compare
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 17:41:38 28/11/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
module compare (
  input   wire    [12:0]   G_mu_k, 
   input   wire    [5:0]   beta_min, 
   input   wire    [6:0]  alpha_max, 
   input   wire   [6:0] alpha_k,
   input  wire    [5:0]   beta_k,
   input  wire            start_comp,
   input  wire [7:0]      edge_thr,
   output reg  [6:0]   AlphaOut,
   output reg  [5:0]    BetaOut,
   output reg      FinishComp
);


always @(start_comp) 
begin :comp_G_thr_proc
if (start_comp)
begin
  if ((G_mu_k <  edge_thr))
  begin
    AlphaOut=alpha_k;
    BetaOut=beta_k;
  end
  else
  begin
    AlphaOut=alpha_max;
    BetaOut=beta_min;
  end
  FinishComp=1;
end
  else
  begin
    FinishComp=0;
    AlphaOut=0;
    BetaOut=0;
  end
  
end// end always

endmodule
