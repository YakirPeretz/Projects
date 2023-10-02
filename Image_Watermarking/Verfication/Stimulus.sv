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
 parameter Data_Depth= 8,
  parameter amba_word = 16,
  parameter amba_addr_depth=20);

bit [Data_Depth-1:0] WhitePixel; // store the white pixel value
bit [9:0] PrimSize;
bit [9:0] WatermarkSize;
bit [6:0] M; // store the block size
bit [7:0] EdgeThr; // store the edgetreshold
bit [6:0] Amin; // store Alpha Min
bit [6:0] Amax; // store Alpha max
bit [5:0] Bmin; // store Beta min
bit [5:0] Bmax;//Store beta max
endclass

module Stimulus#(
  parameter Data_Depth= 8,
  parameter amba_word = 16,
  parameter amba_addr_depth=20)
( 
   // Port Declarations
   Interface.stimulus stim_bus
);
  
`define NULL 0
// Data Types
integer data_file_0;
integer data_file_1;
integer data_file_2;
integer scan_file_0;
integer scan_file_1;
integer scan_file_2;
integer i;
string  str0 = "D:/DigitalDesignProject/GoldenModel/parameters_random_value_";
string  str1 = "D:/DigitalDesignProject/GoldenModel/primary_image_";
string  str2 = "D:/DigitalDesignProject/GoldenModel/watermark_image_";  
string  val;

ParametersClass Param;


reg [21-1:0] count;
reg [9:0] primsize;
reg [9:0] watersize;
// ### Please start your Verilog code here ### 

always begin : clock_generator_proc
  #10 stim_bus.clk = ~stim_bus.clk;
end

initial 
begin : stim_proc
  
  for(i=1;i<13;i=i+1) begin
    // Initilization
    stim_bus.clk = 1; // start with clock and reset at '1'
    stim_bus.rst = 1;
    // input signal equal 0
    stim_bus.PADDR = 0;
    stim_bus.PWRITE = 0;
    stim_bus.PSEL = 0;
    stim_bus.PENABLE=0;
    stim_bus.PWDATA=0;
    Param = new();
    @(posedge stim_bus.clk); // wait til next rising edge (in other words, wait 20ns)
    stim_bus.rst = 0;
    
    // Starting work by reading the data from external files,
    // then sending it to the device by asserting the values to the appropriate ports.
    
    //// The  parameters file
    //file_name = {str0, i, txt}; // Concatenation: combining number of elements together as one string
    val.itoa(i);
    //$display($sformatf({str0, val, ".txt"}));
    data_file_0 = $fopen($sformatf({str0, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_0 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_0 handle was NULL");
      $finish;
    end
    //// The Primary Image Pixels file
    //file_name = {str1, i, txt}; // Concatenation: combining number of elements together as one string
    val.itoa(i);
  //  $display($sformatf({str1, val, ".jpg"}));
    data_file_1 = $fopen($sformatf({str1,val,".txt"}), "r"); // opening file in reading format
    if (data_file_1 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_1 handle was NULL");
      $finish;
    end // end if
    //// The Watermark Image Pixels file
    //file_name = {str2, i, txt}; // Concatenation: combining number of elements together as one string
//    $display (str2);
    val.itoa(i);
    data_file_2 = $fopen($sformatf({str2,val,".txt"}),"r"); // opening file in reading format
    if (data_file_2 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_2 handle was NULL");
      $finish;
    end//end if
    
    @(posedge stim_bus.clk); // wait til next rising edge (in other words, wait 20ns)
    
    //// Reading First Line of each file
    if ((!$feof(data_file_1)) && (!$feof(data_file_2))) begin
      scan_file_1 = $fscanf(data_file_1, "%d\n",primsize); // Np
      scan_file_2 = $fscanf(data_file_2, "%d\n",watersize); // Nw
    end // end if
    Param.PrimSize=primsize;
    Param.WatermarkSize=watersize;
    Param.WhitePixel=255;
    if ((!$feof(data_file_0))) begin
      scan_file_0 = $fscanf(data_file_0, "%d\n",Param.M); // scan Block size M
      scan_file_0 = $fscanf(data_file_0, "%d\n",Param.EdgeThr); // scan Edgethreshold
      scan_file_0 = $fscanf(data_file_0, "%d\n",Param.Amin); // scan Alpha min
      scan_file_0 = $fscanf(data_file_0, "%d\n",Param.Amax); // scan Alpha max
      scan_file_0 = $fscanf(data_file_0, "%d\n",Param.Bmin); // scan Beta min
      scan_file_0 = $fscanf(data_file_0, "%d\n",Param.Bmax); // scan Beta max
  end
    stim_bus.WhitePixel=Param.WhitePixel;
    stim_bus.M= Param.M;
    stim_bus.EdgeThr=Param.EdgeThr;
    stim_bus.Amin=Param.Amin;
    stim_bus.Amax=Param.Amax;
    stim_bus.Bmin= Param.Bmin;
    stim_bus.Bmax= Param.Bmax;
    stim_bus.ImgSize= primsize;
    
    count=1;
    // implement writing by the AMBA Bus Protocol
    while (count <= Param.PrimSize*Param.PrimSize + Param.WatermarkSize*Param.WatermarkSize +10) begin
      stim_bus.PWRITE=1; // PWrite=1 as long as we in writing mode
      stim_bus.PSEL=1; // Psel=1 always (this is the only peripheral for us)
      if (count<10) begin // we are writing the Parameters to the reg file
             case (count)
               1: stim_bus.PWDATA=Param.WhitePixel;
               2: stim_bus.PWDATA= Param.PrimSize;
               3: stim_bus.PWDATA= Param.WatermarkSize;
               4: stim_bus.PWDATA= Param.M;
               5:stim_bus.PWDATA= Param.EdgeThr;
               6: stim_bus.PWDATA= Param.Amin;
               7: stim_bus.PWDATA= Param.Amax;
               8: stim_bus.PWDATA= Param.Bmin;
               9:stim_bus.PWDATA= Param.Bmax;
           endcase 
      end // end if
      else if (count >9 && count < 10+Param.PrimSize*Param.PrimSize) begin
      scan_file_1 = $fscanf(data_file_1, "%d\n", stim_bus.PWDATA); // read pixel from the primary image
      end //end else if
      else begin
      scan_file_2 = $fscanf(data_file_2, "%d\n", stim_bus.PWDATA);// read pixel from the watermark image
      end // end else 
    stim_bus.PADDR=count;
    @(posedge stim_bus.clk); // wait for 1 clock cycle
    stim_bus.PENABLE=1; // enable writing
    @(posedge stim_bus.clk); // wait 1 clock cycle
    stim_bus.PENABLE=0; // disable writing
    @(posedge stim_bus.clk); // wait 1 clock cycle
    count=count+1;
    end// ena while
    // after we finish to write all the parameter and pixels, ctrl=1;
    stim_bus.PWDATA=1;
    stim_bus.PADDR=0;
    @(posedge stim_bus.clk); // wait for 1 clock cycle
    stim_bus.PENABLE=1; // enable writing
    @(posedge stim_bus.clk); // wait 1 clock cycle
    stim_bus.PENABLE=0; // disable writing
    stim_bus.PWRITE=0; // end of writing mode
    stim_bus.PWDATA=256; // illegal input- for the coverage
    stim_bus.PADDR=(2**20)-1; // value that we never use
     @(posedge stim_bus.Image_Done); // wait until image done and write to the CTRL register 0 (the component is off)
     stim_bus.PWDATA=0;
    stim_bus.PADDR=0;
    stim_bus.PWRITE=1;
    @(posedge stim_bus.clk); // wait for 1 clock cycle
    stim_bus.PENABLE=1; // enable writing
    @(posedge stim_bus.clk); // wait for 1 clock cycle
    stim_bus.PENABLE=0; // disable writing
    stim_bus.PWRITE=0; // end of writing mode
 // $stop;
  end // end for
 
end //end initial
  
endmodule
