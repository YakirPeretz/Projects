//
// Verilog Module my_project_lib.calc_sigma_k
//
// Created:
//          by - nofar.UNKNOWN (DESKTOP-6H8PMMN)
//          at - 18:39:22 21/11/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//
`resetall
`timescale 1ns/10ps
module calc_sigma_k #(
   parameter Data_Depth = 8,
   parameter block_size = 72

)
( 
   // Port Declarations
   input   wire    [9:0] M, 
   input   wire    clk,
   input   wire    rst,
   input   wire    ena,
   input   wire    [8-1:0]  I_white,
   output  reg    [13:0]  SigmakOut,
   output  reg     SigmaReady,
   input   wire    [8-1:0] pixel
);

// Internal Declarations
//parameter Data_Depth = 8;
//parameter block_size = 72
//parameter I_white = 255

// Local declarations

// Internal signal declarations
wire [8-1:0] SubFromPixel;//temp value
reg [13-1:0] TempSum;//temp sum;
wire [20:0] divide_factor;//max value 72*72*256
reg [12:0] counter;
	
// Instances 
always @(posedge clk) 
begin: sum_proc
	if (rst)
	begin
		counter<=0;
		TempSum<=0;
		SigmaReady<=0;
	end //end if
	else 
	begin
	  if (ena)
	  begin
			if (counter<M*M)
			begin					
				if (pixel>=128) //abs value
				begin
				TempSum<=TempSum+pixel-SubFromPixel;
				end
				else
				begin
				TempSum<=TempSum-pixel+SubFromPixel;
				end
			counter<=counter+1;
			if(counter== M*M-1) begin
			  SigmaReady<=1;
			  end
			  else begin
			    SigmaReady<=0;
			    end
			end	//end if			
			end // end ena
			else begin
			  			TempSum<=0;
				counter<=0;
				end
		end//end else
end //end always

always @(counter)
begin:check_finish_proc
  if (counter == M*M)
  begin
    			
    			SigmakOut<=((TempSum)*10000*2)/divide_factor;

  end
end
assign SubFromPixel=(I_white+1)/2;//constant subtracted

assign divide_factor= M*M*(I_white+1);//divide_factor

// ### Please start your Verilog code here ### 

endmodule

