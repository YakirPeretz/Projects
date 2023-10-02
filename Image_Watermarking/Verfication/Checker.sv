//
// Verilog Module Image_Watermarking_Project_lib.Checker
//
// Created:
//          by - Yakir.UNKNOWN (YAKIR-PC)
//          at - 00:19:32 15/12/2020
//
// using Mentor Graphics HDL Designer(TM) 2018.2 (Build 19)
//

`resetall
`timescale 1ns/10ps
module Checker
(
//port declaration
 Interface.checker_coverager checker_bus
 );

property rst_active;
  @ (checker_bus.clk) checker_bus.rst==1 |=> (checker_bus.new_pixel==0)&&(checker_bus.Image_Done==0)&&(checker_bus.PWDATA==0);
				endproperty
				
				assert property (rst_active)
				else $error("error with rst");
				cover property(rst_active); 
				
property APB_stable;
  @ (checker_bus.clk) (checker_bus.PSEL &&!checker_bus.PENABLE) ##1 (checker_bus.PSEL &&checker_bus.PENABLE) |=> ($stable(checker_bus.PWRITE))&&($stable(checker_bus.PADDR))&&($stable(checker_bus.PWDATA));
  				endproperty //APB protocol- stable data from low ena to high ena whill psel is set
				
				assert property (APB_stable)
				else $error("error with stability of APB FSM");
				cover property(APB_stable); 
				
//property APB_stable2;
//  @ (checker_bus.clk) checker_bus.PSEL && checker_bus.PENABLE |=> ($stable(checker_bus.PWRITE))&&($stable(checker_bus.PADDR))&&($stable(checker_bus.PWDATA));
//  				endproperty
//				
//				assert property (APB_stable)
//				else $error("error with stability of APB FSM");
//				cover property(APB_stable); 
				
property PADDR_active0;//start
  @ (checker_bus.PWDATA) (checker_bus.PADDR==0)&&( checker_bus.rst==0) |-> (checker_bus.PWDATA==0)|| (checker_bus.PWDATA==1);
				endproperty
				
				assert property (PADDR_active0)
				else $error("error with PADDR=0 or 1");
				cover property(PADDR_active0); 
				
property PADDR_active1;//white pixel
  @ (checker_bus.PWDATA) (checker_bus.PADDR==1)&&( checker_bus.rst==0) |-> (checker_bus.PWDATA>=1)&&(checker_bus.PWDATA<=255);
				endproperty
				
				assert property (PADDR_active1)
				else $error("error with PADDR=1");
				cover property(PADDR_active1); 
				
property PADDR_active2;//Image size
  @ (checker_bus.PWDATA) ((checker_bus.PADDR==2)||(checker_bus.PADDR==3))&&( checker_bus.rst==0) |-> (checker_bus.PWDATA>=200)&&(checker_bus.PWDATA<=720);
				endproperty
				
				assert property (PADDR_active2)
				else $error("error with PADDR=2 or 3");
				cover property(PADDR_active2); 				
							
property PADDR_active3;//M
  @ (checker_bus.PADDR) (checker_bus.PADDR==4)&&( checker_bus.rst==0) |-> (checker_bus.PWDATA>=1)&&(checker_bus.PWDATA<=72);
				endproperty
				
				assert property (PADDR_active3)
				else $error("error with PADDR=4");
				cover property(PADDR_active3); 	

property PADDR_active4;//Bthr
  @ (checker_bus.PADDR) (checker_bus.PADDR==5)&&( checker_bus.rst==0) |-> (checker_bus.PWDATA>=1)&&(checker_bus.PWDATA<=20);
				endproperty
				
				assert property (PADDR_active4)
				else $error("error with PADDR=5");
				cover property(PADDR_active4); 	

property PADDR_active5;//Amax
  @ (checker_bus.PADDR) (checker_bus.PADDR==7)&&( checker_bus.rst==0) |-> (checker_bus.PWDATA>=90)&&(checker_bus.PWDATA<=99);
				endproperty
				
				assert property (PADDR_active5)
				else $error("error with PADDR=7");
				cover property(PADDR_active5);
				
property PADDR_active6;//Bmax
  @ (checker_bus.PADDR) (checker_bus.PADDR==9)&&( checker_bus.rst==0) |-> (checker_bus.PWDATA>=30)&&(checker_bus.PWDATA<=40);
				endproperty
				
				assert property (PADDR_active6)
				else $error("error with PADDR=9");
				cover property(PADDR_active6); 
				
property PADDR_active7;//Bmin
  @ (checker_bus.PADDR) (checker_bus.PADDR==8)&&( checker_bus.rst==0) |-> (checker_bus.PWDATA>=20)&&(checker_bus.PWDATA<=checker_bus.Bmax);
				endproperty
				
				assert property (PADDR_active7)
				else $error("error with PADDR=8");
				cover property(PADDR_active7); 
				
property PADDR_active8;//Amin
  @ (checker_bus.PADDR) (checker_bus.PADDR==6)&&( checker_bus.rst==0) |-> (checker_bus.PWDATA>=80)&&(checker_bus.PWDATA<=checker_bus.Amax);
				endproperty
				
				assert property (PADDR_active8)
				else $error("error with PADDR=6");
				cover property(PADDR_active8);
				
	property PADDR_active9;//pixel data
  @ (checker_bus.PADDR) (checker_bus.PADDR>=10)&&(checker_bus.PADDR<=9+2*(checker_bus.ImgSize^2))&&( checker_bus.rst==0) |-> (checker_bus.PWDATA>=0)&&(checker_bus.PWDATA<=255);
				endproperty
				
				assert property (PADDR_active9)
				else $error("error with PADDR - Pixels");
				cover property(PADDR_active9);
				
property new_pixel_active;
  @ (checker_bus.new_pixel) (checker_bus.new_pixel==1)|=> (checker_bus.Pixel_Data>=0)&&(checker_bus.Pixel_Data<=255);
				endproperty
				
				assert property (new_pixel_active)
				else $error("error with new_pixel");
				cover property(new_pixel_active);
				
			 					
endmodule
