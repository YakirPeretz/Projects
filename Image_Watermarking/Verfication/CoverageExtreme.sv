//
// Verilog Module ImageWatermarkingProject_lib.CoverageExtreme
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 17:23:53 17/12/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
module CoverageExtreme#(
  parameter Data_Depth= 8,
  parameter amba_word = 16,
  parameter amba_addr_depth=20)
( 
   // Port Declarations
   Interface.checker_coverager coverage_bus
);

// Coverage Group
covergroup extreme_test @(posedge coverage_bus.clk);
				// checking if the reset signal get all the values in the range
       	
        // checking if the pixels that we write get all the values in the range
         WritePixel : coverpoint coverage_bus.PWDATA{
         bins Black = {[0:50]};
         bins DarkGray  = {[51:100]};
         bins Gray = {[101:150]};
         bins LightGray = {[151:200]};
         bins White = {[201:255]};
          }
        // checking if the block size get all the values in the range
        BlockSize : coverpoint coverage_bus.M{
         bins PixByPix = {1};
         bins Blocks = {[2:72]};
          }
        // checking if the Edgetreshold get all the values in the range
        EdgeThreshold : coverpoint coverage_bus.EdgeThr{
         bins EdgeThr = {[1:20]};
          }
          // checking if the Alpha_Min get all the values in the range
        AlphaMin : coverpoint coverage_bus.Amin{
         bins AlphaMin = {[80:99]};
          }
          // checking if the Alpha_Max get all the values in the range
        AlphaMax : coverpoint coverage_bus.Amax{
         bins AlphaMax = {[90:99]};
          }
          // checking if the Beta_Min get all the values in the range
        BetaMin : coverpoint coverage_bus.Bmin{
         bins BetaMin = {[20:40]};
          }
          // checking if the Beta_Max get all the values in the range
        BetaMax : coverpoint coverage_bus.Bmax{
         bins BetaMax = {[30:40]};
          }

           // checking if the Result Pixel signal get all the values in the range
         ResultPixel : coverpoint coverage_bus.Pixel_Data{
         bins res = {[0:255]};
          }
           // checking if the newPixel signal get all the values in the range
         NewPixel : coverpoint coverage_bus.new_pixel{
         bins low = {0};
         bins high = {1};
          }  
      				endgroup 
// Instance of covergroup regular_test
extreme_test etst = new();


endmodule
