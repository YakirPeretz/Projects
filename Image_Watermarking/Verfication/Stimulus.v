//
// Verilog Module Image_Watermarking_Project_lib.Stimulus
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 12:37:53 12/12/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps

class ParametersClass #(
parameter Data_Depth=8);

bit [Data_Depth-1:0] WhitePixel; // store the white pixel value
bit [9:0] PrimSize;
bit [9:0] WatermarkSize;
bit [9:0] M; // store the block size
bit [7:0] EdgeThr; // store the edgetreshold
bit [6:0] Amin; // store Alpha Min
bit [6:0] Amax; // store Alpha max
bit [5:0] Bmin; // store Beta min
bit [5:0] Bmax;//Store beta max
endclass


