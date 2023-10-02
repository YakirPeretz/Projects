//
// Verilog Module Image_Watermarking_Project_lib.tb_overall
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 16:06:21 12/12/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
module tb_overall #(
  parameter Data_Depth= 8,
  parameter amba_word = 16,
  parameter amba_addr_depth=20);

Interface tb();

Stimulus gen(
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

Coverage cov(
   .coverage_bus(tb)
    );

Checker check(
    .checker_bus(tb)
    );

GoldModel res_test(
    .gold_bus(tb)
    );

endmodule
