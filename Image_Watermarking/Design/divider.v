//
// Verilog Module Image_Watermarking_Project_lib.divider
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 18:37:30 10/11/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
module divider( 
  input   wire    [10:0]  dividend, //alpha_max-alpha_min 
  input   wire    [13:0]  sigma_k, //divisor
  output  wire    [10:0]  res
);


// Internal Declarations
reg [10:0] temp1;

// Instances 
always @(dividend or sigma_k) begin: al_proc
  temp1 = dividend / sigma_k;
  //temp1 <= dividend / sigma_k;
end

assign res = temp1;

endmodule
