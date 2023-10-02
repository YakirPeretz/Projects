//
// Verilog interface Image_Watermarking_Project_lib.Interface
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 11:57:32 12/12/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
interface Interface#(
  parameter Data_Depth= 8,
  parameter amba_word = 16,
  parameter amba_addr_depth=20)();

//signals declaration
logic [amba_addr_depth-1:0] PADDR;
logic PENABLE;
logic PSEL;
logic [amba_word-1:0] PWDATA;
logic PWRITE;
logic clk;
logic rst;
logic  [amba_word-1:0] PRDATA;
logic Image_Done;
logic  [Data_Depth-1:0] Pixel_Data; 
logic new_pixel;
logic [Data_Depth-1:0] WhitePixel; // store the white pixel value
logic [6:0] M; // store the block size
logic [9:0] ImgSize; // store the block size
logic [7:0] EdgeThr; // store the edgetreshold
logic [6:0] Amin; // store Alpha Min
logic [6:0] Amax; // store Alpha max
logic [5:0] Bmin; // store Beta min
logic [5:0] Bmax;//Store beta max

//modports declaration
modport stimulus (input Image_Done,output PADDR,PENABLE,PSEL,PWDATA,PWRITE,rst,clk,WhitePixel,M,EdgeThr,Amin,Amax,Bmin,Bmax,ImgSize);
modport checker_coverager (input clk,rst,PENABLE,PSEL,PWRITE,PADDR,PWDATA,PRDATA,Image_Done,Pixel_Data,new_pixel,M,EdgeThr,Amin,Amax,Bmin,Bmax,ImgSize);
modport vsgoldenmodel (input Image_Done,Pixel_Data,new_pixel,clk,M);

endinterface
