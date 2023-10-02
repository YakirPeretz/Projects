//
// Verilog Module Image_Watermarking_Project_lib.Write_no_wait
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 15:32:10 10/11/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)

`resetall
`timescale 1ns/10ps
module WriteandRead_no_wait #(
   parameter  amba_addr_depth = 20, //Address Size
   parameter  amba_word       = 16   //word size
)
( 
   input   wire                            PSEL, 
   input   wire                            PWRITE,  
   input   wire    [amba_word-1:0]         P_rdata_in, 
   input   wire                            P_enable,  
   output  reg                             Wena,
   output  reg     [amba_word-1:0]         PRDATA
);                          

always @(PWRITE,PSEL,P_enable,P_rdata_in) begin :CheckWrite_proc // if there is change in those signals do:
 if((PWRITE==1)&&(PSEL==1)&&(P_enable==1)) // if P_write and psel and P_enable are high => Wena high( write mode)
 begin
  Wena<=1;
  PRDATA<=0;
 end 
 else if ((PWRITE==0)&&(PSEL==1)&&(P_enable==1)) // if P_write=0 so we are in read mode
 begin
   PRDATA<=P_rdata_in;
   Wena<=0;
 end
 else
 begin
   Wena<=0;
   PRDATA<=0;
   end
end
endmodule
