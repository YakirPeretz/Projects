//
// Verilog Module ImageWatermarkingProject_lib.tb_overall_ext
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 17:30:28 17/12/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
module tb_overall_ext #(
  parameter Data_Depth= 8,
  parameter amba_word = 16,
  parameter amba_addr_depth=20);

Interface tb();

StimulusExtreme gen(
    .stim_bus(tb)
    );

Visible_Watermarking dut(
    //.dut_bus(tb)
    .clk(tb.clk),
    .rst(tb.rst),
    .PSEL(tb.PSEL),
    .PENABLE(tb.PENABLE),
    .PWRITE (tb.PWRITE),
    .PWDATA(tb.PWDATA),
    .PADDR(tb.PADDR),
    .Image_Done(tb.Image_Done),
    .PRDATA(tb.PRDATA),
    .Pixel_Data(tb.Pixel_Data),
    .new_pixel(tb.new_pixel)
    );

CoverageExtreme cov(
   .coverage_bus(tb)
    );

CheckerExtreme check(
    .checker_bus(tb)
    );

GoldModelExtreme res_test(
    .gold_bus(tb)
    );

endmodule
