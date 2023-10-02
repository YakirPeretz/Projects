//
// Verilog Module my_project_lib.divider1
//
// Created:
//          by - nofar.UNKNOWN (DESKTOP-6H8PMMN)
//          at - 13:32:34 20/11/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//


`resetall
`timescale 1ns/10ps
module divider1
( 
   // Port Declarations
   input   wire    [21:0]  prod1, 
   output  wire    [1:0]  prod2
);

// Internal Declarations
// Local declarations

// Internal signal declarations
reg [1:0] temp1;
//reg [21:0] temp1;


// Instances 
always @(prod1) begin: al_proc
  temp1 = prod1 / 1000000;
  //temp1 <= prod1 / 1000000;
end

assign prod2 = temp1;

// ### Please start your Verilog code here ### 

endmodule

