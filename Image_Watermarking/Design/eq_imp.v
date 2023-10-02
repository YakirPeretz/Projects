//
// Verilog Module Image_Watermarking_Project_lib.eq_imp
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 18:20:45 28/11/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
module eq_imp #(
parameter amba_word = 16,
parameter Data_Depth= 8    // Pixel size
) 
(
input wire   [Data_Depth-1:0]  P_pixel,
input wire   [Data_Depth-1:0]  W_pixel,
input wire  [6:0]   alpha,
input wire  [5:0]    beta,
input   wire                           clk, 
input   wire                           rst, 
input wire   [9:0]        M,
input wire           start_calc_iw_k,
input  wire                           Last_Prim_Block, 
input  wire                            Last_Water_Block, 
output reg    FinishCalc,
output reg   [Data_Depth-1:0]  iwPixel,
output reg    Image_Done,
output reg new_pixel
);

// ### Please start your Verilog code here ### 
// internal dec
reg [12:0] counter;
reg [amba_word-1:0] temp_iwPixel;
always @(posedge clk) begin: calc_iwk_proc
  if (rst)
  begin
    FinishCalc<=1;
    Image_Done<=0;
    new_pixel<=0;
    counter<=0;
  end
  else // rst=0
  begin
    if (start_calc_iw_k)
    begin // begin ena
      if (counter<M*M)
      begin // begin counter <=M*M
       temp_iwPixel<= (alpha*P_pixel + beta*W_pixel)/100;
       new_pixel<=1;
       counter<= counter +1;
       FinishCalc<=0;
     end
    else // if counter > M*M
    begin // begin counter > M*M
      if (Last_Prim_Block&&Last_Water_Block)
      begin
        Image_Done<=1;
        FinishCalc<=1;
        new_pixel<=0;
      end // end if it's the last block
      else // if it's not the last block in the world
      begin
        FinishCalc<=1;
        Image_Done<=0;
        new_pixel<=0;
      end // end else not last block
    end // end else counter >M*M
    end // end ena
    else // is ena=0
    begin
    Image_Done<=0;
    new_pixel<=0;
    counter<=0;
    end
  end // end else of the if rst
end// end always
always @(temp_iwPixel)
begin: checkoverflow_proc
  if (temp_iwPixel>255)
        begin
        iwPixel<=255;
        end
  else
  begin
    iwPixel<= temp_iwPixel[Data_Depth-1:0];
    end
end

endmodule
