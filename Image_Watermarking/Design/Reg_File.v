//
// Verilog Module Image_Watermarking_Project_lib.Reg_File
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 19:27:17 10/11/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
module Reg_File #(
   // synopsys template
   parameter amba_addr_depth = 20, // Address size
   parameter amba_word       = 16,
   parameter Data_Depth     = 8   //word size
   //word size
)
( 
   input   wire    [amba_addr_depth-1:0]  PADDR, 
   input   wire                           clk, 
   output  reg     [amba_word-1:0]        DataOut, 
   input   wire    [amba_word-1:0]        input_data, 
   input   wire    [amba_addr_depth-1:0]  read_pixel_addr, 
   input   wire                           rst, 
   output  wire                           start, 
   input   wire                           w_ena
);


// Internal Declarations
reg [amba_word-1:0] regfile [2**(amba_addr_depth)-1:0];

always @(posedge clk) begin :RegisterFile_proc
  if (rst) 
  begin 
  regfile[0]<= 0; //CTRL reg
  DataOut<=0;
  end 
  if (w_ena)  // if we are in write mode-> write the data to the reg file in address place
  begin
      regfile[PADDR]<=input_data;
  end
  else // if we are in read mode
  begin
        DataOut<=regfile[read_pixel_addr]; // read the data from the reg file from address place
  end
end
assign start=regfile[0][0]; // in case that CTRL register=1 we can start our Visible Watermarking calculation

endmodule
