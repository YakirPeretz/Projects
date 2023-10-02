//
// Verilog Module Image_Watermarking_Project_lib.GoldModel
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 12:28:11 13/12/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//
`resetall
`timescale 1ns/10ps
module GoldModel #(
  parameter Data_Depth= 8)
( 
   // Port Declarations
   Interface.vsgoldenmodel gold_bus
);

`define NULL 0
// Data Types
integer data_file_0;
integer scan_file_0;
integer data_file_1;
integer i = 1;
integer hit;
integer miss;
integer error;
integer col,row,blockC; // column and row indicator. BlockC- block counter
integer M;


string  str0 = "D:/DigitalDesignProject/GoldenModel/watermarked_image(result)_";
string  str1 = "D:/DigitalDesignProject/GoldenModel/hdl_design_watermarked_image(result)_";

string  val;

reg [Data_Depth-1:0] resultpix [2**(20-1)-1:0];
reg [Data_Depth-1:0] resultpix_dut [2**(20-1)-1:0];
reg [Data_Depth-1:0] currentPix;
reg [Data_Depth-1:0] dutpix;
reg [10-1:0] resultsize;
reg [21-1:0] count;
reg [21-1:0] j;

initial
begin : init_proc

    //------------------------------------------------------------------------------------------
    //// The Golden Model Result Image Pixels file
    val.itoa(i);
    data_file_0 = $fopen($sformatf({str0, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_0 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_1 handle was NULL");
      $finish;
    end
    if (!$feof(data_file_0)) begin
      scan_file_0 = $fscanf(data_file_0, "%d\n", resultsize);
    end
    for (count=0;count<resultsize*resultsize;count=count+1) begin
      scan_file_0 = $fscanf(data_file_0, "%d\n", resultpix[count]);
    end
    count = 0;
    //// Our Architectural Model Result Image Pixels file (For Saving)
    val.itoa(i);
    data_file_1 = $fopen($sformatf({str1, val, ".txt"}), "w"); // opening file in writing format
    if (data_file_1 == `NULL) begin
      $display("data_file_1 handle was NULL");
      $finish;
    end
    //------------------------------------------------------------------------------------------
    //// Initilization
    hit = 0;
    miss = 0;
    error = 0;
    count = 0;
    row=0;
    col=0;
    blockC=0;
end


// smapeling the result pixel in every posedge clock and new pixel is 1
  always @(posedge gold_bus.clk)
  begin : res_proc
    if (gold_bus.new_pixel)
    begin
      M = gold_bus.M;
  if ((gold_bus.Pixel_Data >= 0) && (gold_bus.Pixel_Data <= 255)) 
    begin
    resultpix_dut[count]=gold_bus.Pixel_Data;
      if (col<M-1) 
      begin // check if we finished to write to row
      col=col+1;
      count=count +1;
      end // end if - case that we didn't finish to write a row
      else 
      begin // if we finished to write a row
      row=row+1;
      col=0;
        if (row==M) 
        begin // if we finished to write a block
        blockC=blockC +1; // block counter
        row=0;
        col=0;
          if (blockC%(resultsize/M)!=0) 
          begin // check if  we write the last block in the strip
          count=count-(resultsize*(M-1))+1;
          end // end if - case it's not the last block in the strip
          else 
          begin
          count=count+1;
          end // case it's the last block in the strip
        end // end if - case we finish to write a block
        else 
        begin// case we didn't finish write a block
        count= count+resultsize-M+1;
        end // end else - didn't finish to write a block
      end // end else - case that we finish to write a row
    end // end if pixel_data in range
  end // always- posedge clk
end // end if new pixel is 1


always @(posedge gold_bus.Image_Done) 
begin : Imgdone_proc
  for (j=0;j<resultsize*resultsize;j=j+1) begin
    currentPix= resultpix[j]; // for debuging
    dutpix= resultpix_dut[j]; // for debugging
    if(resultpix[j]<15) begin
      if (resultpix_dut[j]<=resultpix[j] +15) begin // check if our result pixel is in the range of +-15 from the golden model result pixel
        hit=hit+1;
        $fwrite(data_file_1, "%d\n", resultpix_dut[j]);
      end
      else begin
      miss=miss+1;
      $fwrite(data_file_1, "%d\n", resultpix_dut[j]);
      end
    end
    else if (resultpix[j]>240)     begin // check if our result pixel is in the range of +-15 from the golden model result pixel
      if (resultpix_dut[j]>=resultpix[j] -15) begin
        hit=hit+1;
        $fwrite(data_file_1, "%d\n", resultpix_dut[j]);
      end
      else begin
          miss=miss+1;
      $fwrite(data_file_1, "%d\n", resultpix_dut[j]);
      end
    end
    else begin
    if ((resultpix_dut[j] <= resultpix[j]+15) && (resultpix_dut[j]>= resultpix[j] -15)) // check if our result pixel is in the range of +-15 from the golden model result pixel
    begin
      hit = hit + 1;
      $fwrite(data_file_1, "%d\n", resultpix_dut[j]);
    end // end if
    else 
    begin
      miss=miss+1;
      $fwrite(data_file_1, "%d\n", resultpix_dut[j]);
    end// end else
  end// end else
  end // end for
  count=0;
  i=i+1;
  if (i==13) 
  begin
    $finish;
  end// end if - last file

  if (!count && i) begin // each beginning except first time
    //------------------------------------------------------------------------------------------
    //// The Golden Model Result Image Pixels file
    val.itoa(i);
    data_file_0 = $fopen($sformatf({str0, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_0 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_1 handle was NULL");
      $finish;
    end
    if (!$feof(data_file_0)) begin
      scan_file_0 = $fscanf(data_file_0, "%d\n", resultsize);
    end
    for (count=0;count<resultsize*resultsize;count=count+1) begin
      scan_file_0 = $fscanf(data_file_0, "%d\n", resultpix[count]);
    end
    count = 0;
    //// Our Architectural Model Result Image Pixels file (For Saving)
    val.itoa(i);
    data_file_1 = $fopen($sformatf({str1, val, ".txt"}), "w"); // opening file in writing format
    if (data_file_1 == `NULL) begin
      $display("data_file_1 handle was NULL");
      $finish;
    end
    //------------------------------------------------------------------------------------------
    //// Initilization
    hit = 0;
    miss = 0;
    error = 0;
    count = 0;
    row=0;
    col=0;
    blockC=0;
  end
  
end // end always

endmodule
