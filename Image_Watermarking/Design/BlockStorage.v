//
// Verilog Module Image_Watermarking_Project_lib.BlockStorage
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 19:40:31 17/11/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
module BlockStorage #(
   // synopsys template
   parameter amba_addr_depth = 20,
   parameter amba_word       = 16,
   //  parameter M               = 72,
   parameter Max_block_size  = 5184,
   parameter Data_Depth      = 8      // Pixel size

)
( 
   input   wire    [amba_word-1:0]       Data_in, 
   input   wire                           Finish_Calc, 
   output  reg                            LastPrimBlock, 
   output  reg                            LastWaterBlock, 
   output  reg     [Data_Depth-1:0]       Ppixel, 
   output  reg     [amba_addr_depth-1:0]  PixelAddress, 
   output  reg     [Data_Depth-1:0]       Wpixel, 
   output  wire    [6:0]                  alpha_out, 
   output  wire    [5:0]                  beta_out, 
   output  wire    [9:0]                  Block_Size, 
   input   wire                           clk, 
   input   wire                           rst, 
   input   wire                           start, 
   output  reg                            StartCalcIWk
);


// Internal Declarations
reg [Data_Depth-1:0] WhitePixel; // store the white pixel value
reg [9:0] PrimSize; // store the Primary image Size
reg [9:0] WatermarkSize; // Store the Watermark image size
reg [9:0] M; // store the block size
reg [7:0] EdgeThr; // store the edgetreshold
reg [6:0] Amin; // store Alpha Min
reg [6:0] Amax; // store Alpha max
reg [5:0] Bmin; // store Beta min
reg [5:0] Bmax;//Store beta max
reg [Data_Depth-1:0] PrimBlock [Max_block_size-1:0]; // Primary Image Block
reg [Data_Depth-1:0] WatermarkBlock [Max_block_size-1:0]; // Watermark Image block
reg [amba_addr_depth-1:0] WaterCounterAddr ; // counter that indicate the pixel's address in the register file of the watermark image
reg [amba_addr_depth-1:0] PrimCounterAddr ; // counter that indicate the pixel's address in the register file of the Primary image
reg PrimBlockFinishedRead; // flag that indicate if we finished to read a block of the primary image
reg WaterBlockFinishedRead; // flag that indicate if we finished to read a block of the watermark image
wire ena_read_prim; // control signal that enable the block that calculate the address of the Primary image pixel for the current block
wire ena_read_water; // control signal that enable the block that calculate the address of the watermark image pixel for the current block
reg [amba_addr_depth-1:0] PrimBlockCounter; // Counter that count how many Primary image blocks we transfer - max blocks= 720*720(case of block size is 1) so we need 19 bits counter
reg [amba_addr_depth-1:0] WaterBlockCounter; // Counter that count how many Watermark image blocks we transfer - max blocks= 720*720(case of block size is 1) so we need 19 bits counter
reg [7-1:0] PRowBlockCounter; // counter for the rows we finished to read in the block- the max rows in block is M=72 so we need 7 bits counter
reg [7-1:0] PFinishReadRowcounter; // counter for to check if we finished to read all the pixel in a block's row(indicate the column) - the max columns in block is M=72 so we need 7 bits counter
reg [7-1:0] WRowBlockCounter; // counter for the rows we finished to read in the block- the max rows in block is M=72 so we need 7 bits counter
reg [7-1:0] WFinishReadRowcounter; // counter for to check if we finished to read all the pixel in a block's row(indicate the column) - the max columns in block is M=72 so we need 7 bits counter
reg [13-1:0] PrimBlockaddr; // the address in the Primary block - the max size of the Primary block is 72*72=5184, so we need 2^13 bits.
reg [13-1:0] WaterBlockaddr; // the address in the Watermark block - the max size of the Watermark block is 72*72=5184, so we need 2^13 bits.
reg WritetoPrim; // flag that indicate if we write to the Primary image block
reg WritetoWater; // flag that indicate if we write to the Watermark image block
reg [21:0] temp_sum;//temp sum - max value 256*72*72*2 - using to calculate GMuk                
wire [12:0] Divide_Factor;//max value 72*72 - using to calculate GMuk
reg [12:0] CounterG; //counter - using to calculate GMuk, max value = M*M
reg [12:0] GMuk; //to calculate GMuk - using inside always  
reg [Data_Depth-1:0] Arg1; //to calculate GMuk - using inside always, calculate I(x,y)-I(x+1,y) 
reg [Data_Depth-1:0] Arg2; //to calculate GMuk - using inside always, calculate I(x,y)-I(x,y+1)
wire [13:0] sigma_k_out;
wire sigma_ready;
reg StartAlphaBeta;
wire Alpha_Ready;
wire [6:0] Alpha_k_out;
wire Beta_ready;
wire [5:0] Beta_k_out;
reg   Gready; 
reg LetsCompare;
reg [12:0] PixelOutCounter;
reg EnaTrans;
wire Finish_Comp;
reg StartWater;
//My code

// check if we can start to transfer a block of the Primary image from the register file
assign ena_read_prim=start&Finish_Calc&(~PrimBlockFinishedRead);

//always @(start,Finish_Calc,PrimBlockFinishedRead) begin :enableReadP_proc
  // ena_read_prim<= start&Finish_Calc&(~PrimBlockFinishedRead); // if start bit=1, we finish to calculate a block and we didn't finish to read a block, we can start to transfer a block of the primary image
 //end

 //check if we can write the data to the Primary image block
 always @(posedge clk) begin : WriteDataPrim_proc // in case that the address is below Block_Size^2 and above 10(9 registers of parameters), and the writetoPrim bit is on:
   if((WritetoPrim)&& (PrimBlockaddr<M*M)&& (PrimCounterAddr>10)) begin
     PrimBlock[PrimBlockaddr]<=Data_in; // write the input Data to the PrimBlockaddr in the PrimBlock
     PrimBlockaddr<=PrimBlockaddr+1; // move the address counter to the next address in the block
   end
     else
      begin
        PrimBlockaddr<=0; // if we can't write-> reset the address counter of the Primary block
      end
    end
        
        
// calculate the address of the next address of the Primary image we should read from the register bank + parameters read
always @ (posedge clk) begin :Primblock_proc
  if (rst)
  begin
    PrimCounterAddr<=0;
    PrimBlockCounter<=0;
    PRowBlockCounter<=0;
    PrimBlockFinishedRead<=0;
    PFinishReadRowcounter<=1;
    WritetoPrim<=0;
    StartWater<=0;
  end
  else if(ena_read_prim)
  begin
    if (PrimCounterAddr<=10) // parameters store
      begin
        if (PrimCounterAddr==10) 
        begin
         WritetoPrim<=1; // indicate that we can write the input data to the Primary image block
         if (M==1) // case of pixel by pixel transmision
         begin
            PrimBlockFinishedRead<=1;
            StartWater<=1;
            PrimBlockCounter<=PrimBlockCounter+1;
          end
         else begin
          PrimBlockFinishedRead<=0;
        end
        end// and if addr==10
        else 
        begin
          WritetoPrim<=0; // indicate that we can write the input data to the Primary image block
        end
      PrimCounterAddr<=PrimCounterAddr+1;
      case(PrimCounterAddr-1)
      1: WhitePixel<=Data_in;
      2: PrimSize<=Data_in;
      3: WatermarkSize<=Data_in;
      4: M<=Data_in;
      5: EdgeThr<=Data_in;
      6: Amin<=Data_in;
      7: Amax<=Data_in;
      8: Bmin<=Data_in;
      9: Bmax<=Data_in;
      endcase
    end
    else // Address>=10
    begin
      WritetoPrim<=1; // indicate that we can write the input data to the Primary image block
      if (PFinishReadRowcounter<M-1) // check if we finished to read a row in the block: if we don't Address+=1, and go to the next pixel in this row
        begin // we didn't finish to read a row in the current block
      PrimCounterAddr<= PrimCounterAddr+1; // Address= Next pixel in this row
      PFinishReadRowcounter<=PFinishReadRowcounter+1; // increase the column indicator by 1
        end
      else // if we finished to read a row
        begin
          PRowBlockCounter<=PRowBlockCounter+1; // counter that indicate the num of the row in the block
          PFinishReadRowcounter<=0; 
          if (PRowBlockCounter==M-1) // check if we finished to read a block
            begin
            PrimBlockCounter<=PrimBlockCounter+1; // Blocks counter
            PRowBlockCounter<=0;
            PFinishReadRowcounter<=0;
            PrimBlockFinishedRead<=1; // indicate that we finished to read a block
            StartWater<=1;
              if(((PrimBlockCounter+1)%(PrimSize/M))!=0) //check if it's the last Block in the strip
                begin
            PrimCounterAddr<=PrimCounterAddr - (PrimSize*(M-1)) +1; //jump to the next base address of the next block in the strip
                end
              else //if it's the last block in the strip
                begin
                PrimCounterAddr<= PrimCounterAddr+1; //    jump to the next block in the next strip
                end
            if(PrimBlockCounter==(((PrimSize*PrimSize)/(M*M)))-1) // check if this is the last Primary image block
            begin
              LastPrimBlock<=1;
              end
              else
              begin
                LastPrimBlock<=0;
                end
            end
            else // if we didn't finished to read a block
            begin
              PrimCounterAddr<=PrimCounterAddr+PrimSize-M+1; // next row in the block
            end
        end
      
    end
  end
  else
  begin
    WritetoPrim<=0;
    if(PixelOutCounter==M*M) begin
        PrimBlockFinishedRead<=0;
        StartWater<=0;
      end
  end
end


assign Block_Size=M;
// choose the output address - if it's for the primary or watermark block
always @(ena_read_water,ena_read_prim,WaterCounterAddr,PrimCounterAddr) begin:PrimorWater_proc
  if (ena_read_water)
  begin
    PixelAddress<=WaterCounterAddr+PrimSize*PrimSize+10; // watermark pixels start in PrimSize^2 + 10
  end
  else if (ena_read_prim)
  begin
    PixelAddress<=PrimCounterAddr;
  end
  else
  begin
    PixelAddress<=0;
  end
end
 
// check if we can start to transfer a block of the Watermark image from the register file
assign ena_read_water=(StartWater)&(~WaterBlockFinishedRead);

//always@(PrimBlockFinishedRead,WaterBlockFinishedRead,ena_read_prim) begin : enableReadW_proc
//ena_read_water<=(StartWater)&(~WaterBlockFinishedRead); // enable if we finish to read a Primary image block and stop if we finished to read a watermark image block
//end

//check if we can write the data to the Watermark image block
 always @(posedge clk) begin : WriteDataWrim_proc
   if((WritetoWater)&& (WaterBlockaddr<M*M)) begin
     WatermarkBlock[WaterBlockaddr]<=Data_in;
     WaterBlockaddr<=WaterBlockaddr+1;
   end
     else
      begin
        WaterBlockaddr<=0;
      end
    end

// calculate the address of the next address of the Watermark image we should read from the register bank         
always @ (posedge clk) begin :Waterblock_proc
  if (rst)
  begin
    WaterBlockFinishedRead<=0;
    WaterCounterAddr<=0;
    WaterBlockCounter<=0;
    WRowBlockCounter<=0;
     WFinishReadRowcounter<=0;
  end
  else if(ena_read_water)
    begin
      WritetoWater<=1;
      if (WFinishReadRowcounter<M-1) // check if we finished to read a row in the block: if we don't Address+=1, and go to the next pixel in this row
        begin // we didn't finish to read a row in the current block
      WaterCounterAddr<= WaterCounterAddr+1; // Address= Next pixel in this row
      WFinishReadRowcounter<=WFinishReadRowcounter+1;
        end
      else // if we finished to read a row
        begin
          WRowBlockCounter<=WRowBlockCounter+1; // counter that indicate the num of the row in the block
          WFinishReadRowcounter<=0;
          if (WRowBlockCounter==M-1) // check if we finished to read a block
            begin
            WaterBlockCounter<=WaterBlockCounter+1; // Blocks counter
            WRowBlockCounter<=0;
            WFinishReadRowcounter<=0;
              if(((WaterBlockCounter+1)%(WatermarkSize/M))!=0) //check if it's the last Block in the strip
                begin
            WaterCounterAddr<=WaterCounterAddr - (WatermarkSize*(M-1)) +1; //jump to the next base address of the next block in the strip
                end
              else
                begin
                WaterCounterAddr<= WaterCounterAddr+1; // maybe a problem     jump to the next block in the next strip
                end
            WaterBlockFinishedRead<=1; // indicate that we finished to read a block
            if(WaterBlockCounter==(((WatermarkSize*WatermarkSize)/(M*M))-1))
            begin
              LastWaterBlock<=1;
              end
              else
              begin
                LastWaterBlock<=0;
                end
            end
            else // if we didn't finished to read a block
            begin
              WaterCounterAddr<=WaterCounterAddr+WatermarkSize-M+1; // next row in the block
            end
        end  
    end
     else
  begin
    WritetoWater<=0;
    if(PixelOutCounter==M*M) begin
        WaterBlockFinishedRead<=0;
      end
  end
  end
  
always @(posedge clk) 
begin: sum_G_proc
	if (rst)
	begin
		CounterG<=0;
		temp_sum<=0;
		Gready<=1; // for the first block transmission
		Arg1<=0;
		Arg2<=0;
	end //end if
	else 
	begin
	  if ((CounterG<=M*M+1)&&(PrimBlockFinishedRead)&&(!WritetoPrim))
		begin
		  if (CounterG==M*M+1)//last itteration - calc G, reset parameters
		    begin
		    		temp_sum<=temp_sum+Arg1+Arg2;
				  GMuk<=temp_sum/Divide_Factor;
				  Gready<=1;
				  temp_sum<=0;
					Arg1<=0;
	       	Arg2<=0;
				end
			else
			begin
			  Gready<=0;
			if ((CounterG)%M==(M-1))//right edge
			begin
				if((CounterG)==(M*M-1))//right corner
				begin
				  Arg1<=PrimBlock[CounterG];//I(x,y)-I(x+1,y)=I(x,y)-0
				  Arg2<=PrimBlock[CounterG];//I(x,y)-I(x,y+1)=I(x,y)-0
				end
				else
				begin
				  Arg2<=PrimBlock[CounterG];//I(x,y)-I(x,y+1)=I(x,y)-0
				  if(PrimBlock[CounterG]>PrimBlock[CounterG+M])
				    Arg1<=PrimBlock[CounterG]-PrimBlock[CounterG+M];//I(x,y)-I(x+1,y)
				  else
				    Arg1<=PrimBlock[CounterG+M]-PrimBlock[CounterG];//I(x+1,y)-I(x,y)
				end
			end
			else //CounterG%M=!M-1 
			begin
				if (((CounterG)>=M*(M-1))&&((CounterG)<=(M*M)-2))//last row of the block, buttom edge
				begin
				  Arg1<=PrimBlock[CounterG];//I(x,y)-I(x+1,y)=I(x,y)-0
			   	if(PrimBlock[CounterG]>PrimBlock[CounterG+1])
				    Arg2<=PrimBlock[CounterG]-PrimBlock[CounterG+1];//I(x,y)-I(x,y+1)
				  else
				   Arg2<=PrimBlock[CounterG+1]-PrimBlock[CounterG];//I(x,y)-I(x,y+1)
				end
				else //not buttom edge, regular pixel
				begin
				  if(PrimBlock[CounterG]>PrimBlock[CounterG+M])
				    Arg1<=PrimBlock[CounterG]-PrimBlock[CounterG+M];//I(x,y)-I(x+1,y)
			   	else
				    Arg1<=PrimBlock[CounterG+M]-PrimBlock[CounterG];//I(x+1,y)-I(x,y)
          if(PrimBlock[CounterG]>PrimBlock[CounterG+1])
				    Arg2<=PrimBlock[CounterG]-PrimBlock[CounterG+1];//I(x,y)-I(x,y+1)
				  else
				    Arg2<=PrimBlock[CounterG+1]-PrimBlock[CounterG];//I(x,y+1)-I(x,y)
				end
			end //end else couter%M=!M-1 
				temp_sum<=temp_sum+Arg1+Arg2;//sum up
				CounterG<=CounterG+1;//increase counter
		  end //end else M*M+1
	 end //end if counter <M*M+1
	 else
	 begin
	   Arg1<=0;
	   Arg2<=0;
	   temp_sum<=0;
     CounterG<=0;
	   end
	end //end else
end //end always

assign Divide_Factor= M*M;//Divide_Factor



calc_sigma_k U_2( 
   .M     (M), 
   .I_white          (WhitePixel), 
   .clk            (clk), 
   .rst            (rst), 
   .ena          (WritetoPrim), 
   .SigmakOut     (sigma_k_out), 
   .pixel  (Data_in[8-1:0]), 
   .SigmaReady (sigma_ready)
); 

always @( sigma_ready)
begin : StartAlphaBeta_proc
  if (sigma_ready)
  StartAlphaBeta<=1;
  else
  StartAlphaBeta<=0;
end


calc_alpha_k U_3( 
   .alpha_max     (Amax), 
   .alpha_min          (Amin), 
   .sigma_k            (sigma_k_out), 
   .start_calc_alpha            (StartAlphaBeta), 
   .AlphakOut     (Alpha_k_out), 
   .AlphaReady (Alpha_Ready)
); 

calc_beta_k U_4( 
   .beta_max     (Bmax), 
   .beta_min          (Bmin), 
   .sigma_k            (sigma_k_out), 
   .start_calc_beta            (StartAlphaBeta), 
   .BetakOut     (Beta_k_out), 
   .BetaReady (Beta_ready)
); 

always @(Beta_ready,Alpha_Ready,WaterBlockFinishedRead,Gready) begin: enable_compare_proc
  if ((Alpha_Ready)&&(Beta_ready)&& (Gready)&& (WaterBlockFinishedRead))
    LetsCompare<=1;
    else
    LetsCompare<=0;
end

compare U_10(
  .G_mu_k    (GMuk),
   .beta_min (Bmin),
   .alpha_max (Amax),
   .alpha_k   (Alpha_k_out),
  .beta_k   (Beta_k_out),
   .start_comp (LetsCompare),
  .edge_thr (EdgeThr),
   .AlphaOut (alpha_out),
   .BetaOut (beta_out),
   .FinishComp (Finish_Comp)
); 
always @(Finish_Comp,WritetoWater,Finish_Calc,ena_read_prim)
begin : check_begin_trans
  if ((Finish_Comp)&& (!WritetoWater)&& (!ena_read_prim))
  begin
    EnaTrans<=1;
  end
  else
  begin
    EnaTrans<=0;
  end
end

always @(posedge clk) begin : pixel_trans_proc
  if (rst) begin
    PixelOutCounter<=0;
  end
  else if (EnaTrans)
  begin
    if (PixelOutCounter<=M*M)
    begin
    Ppixel<=PrimBlock[PixelOutCounter];
    Wpixel<=WatermarkBlock[PixelOutCounter];
    PixelOutCounter<=PixelOutCounter+1;
    StartCalcIWk<=1;
   end// if counter < M*M
  else // counter == M*M
  begin
    PixelOutCounter<=0;
 //   PrimBlockFinishedRead<=0;
    StartCalcIWk<=0;
    
  end // end else counter == Block_Size^2
  end // end ena
  else
  begin
    PixelOutCounter<=0;
    StartCalcIWk<=0;
  end
end// end always

endmodule
