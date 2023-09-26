//
// Verilog Module HR_DPWM_lib.tb_HRDPWM
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 10:59:47 12/10/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps

import env_pkg::*;

module tb_HRDPWM#(
   // synopsys template
   parameter Nde          = 64,
   parameter DE_bits      = 6,
   parameter Dc_length    = 13,
   parameter Count_length = Dc_length-DE_bits
);

HR_DPWM_if m_if();
HR_DPWM_top u0(.rst(m_if.rst),
                .H_on(m_if.H_on),
                .L_on(m_if.L_on),
                .DeadTime(m_if.DeadTime),
                .H_DPWM(m_if.H_DPWM),
                .L_DPWM(m_if.L_DPWM),
                .clk_base(m_if.clk_base),
                .Flags_out(m_if.Flags_out));
                
int total_er=0;
int num_of_input;
int test_input=100;
int flag_err=0;
int test0,test2,test3,test4,test5,test6,test7;
bit [Count_length+2:0] flags_counter;
bit [Dc_length-1:0] L_on_current;
consmode c0=FREE;
consmode c1=DTZERO;
consmode c2=CLKBASE;
consmode c3= LESSCLKBASE;
consmode c4= HonMax;
consmode c5= MAXV;
consmode c6=SMALL1;
consmode c7=SMALL2;


// coverage 
Coverage cov (.vif(m_if));

test t0,t2,t3,t4,t5,t6,t7;
initial begin
test0=1;
test2=1;
test3=1;
test4=1;
test5=1;
test6=1;
test7=1;
  $display ("Coverage Start............");
  $display ("**************************************************************** Test number 0 ******************************************************************************************** \n \n \n");
  // Rand FREE- Pass 1000!!!!!!! zero errors
  if (test0) begin
  t0=new;
  t0.e0.vif=m_if;
  t0.e0.g0.c=c0;
  t0.e0.g0.num=10000;
  t0.run();
  $display ("Last error at: %0d",t0.e0.s0.er_time);
  $display ("****** Num of Errors= %0d *********",t0.e0.s0.num_error);
  end
  
  /*
  //DeadTime zero test -  DeadTime not good - the catch of the signals in the monitor
  t1=new;
  t1.e0.vif=m_if;
  t1.e0.g0.c=c1;
  t1.e0.g0.num=10;
  t1.run();
  $display ("****** Num of Errors= %0d *********",t1.e0.s0.num_error);
  $display ("Last error at: %0d",t1.e0.s0.er_time);
  */
  
    /// test 2 all pointers on the clk base - Pass 1000! zero errors
    if (test2) begin
    $display ("**************************************************************** Test number 2 ******************************************************************************************** \n \n \n");
  t2=new;
  t2.e0.vif=m_if;
  t2.e0.g0.c=c2;
  t2.e0.g0.num=test_input;
  t2.run();
  $display ("****** Num of Errors= %0d *********",t2.e0.s0.num_error);
  $display ("Last error at: %0d",t2.e0.s0.er_time);
end

  // test 3  - H_on < Nde - Pass 1000! zero errors
  if (test3) begin
    $display ("**************************************************************** Test number 3 ******************************************************************************************** \n \n \n");
  t3=new;
  t3.e0.vif=m_if;
  t3.e0.g0.c=c3;
  t3.e0.g0.num=test_input;
  t3.run();
  $display ("****** Num of Errors= %0d *********",t3.e0.s0.num_error);
  $display ("Last error at: %0d",t3.e0.s0.er_time);
end
  
  if (test4) begin
  $display ("**************************************************************** Test number 4 ******************************************************************************************** \n \n \n");
  t4=new;
  t4.e0.vif=m_if;
  t4.e0.g0.c=c4;
  t4.e0.g0.num=test_input;
  t4.run();
  $display ("Last error at: %0d",t4.e0.s0.er_time);
  $display ("****** Num of Errors= %0d *********",t4.e0.s0.num_error);
  end
  // Test 5 - MAX Value all - pass 1000  - zero Errors
  if (test5) begin
    $display ("**************************************************************** Test number 5 ******************************************************************************************** \n \n \n");
  t5=new;
  t5.e0.vif=m_if;
  t5.e0.g0.c=c5;
  t5.e0.g0.num=500;
  t5.run();
  $display ("****** Num of Errors= %0d *********",t5.e0.s0.num_error);
  $display ("Last error at: %0d",t5.e0.s0.er_time);
end
  
  // Test 6 - Small Changes 1 - Pass 1000 - zero errors
  if (test6) begin
    $display ("**************************************************************** Test number 6 ******************************************************************************************** \n \n \n");

  t6=new;
  t6.e0.vif=m_if;
  t6.e0.g0.c=c6;
  t6.e0.g0.num=test_input;
  t6.run();
  $display ("****** Num of Errors= %0d *********",t6.e0.s0.num_error);
  $display ("Last error at: %0d",t6.e0.s0.er_time);
end
  
  
  // Test 7 - Small Changes 2 - Pass 1000 - zero errors
  if (test7) begin
    $display ("**************************************************************** Test number 7 ******************************************************************************************** \n \n \n");
  t7=new;
  t7.e0.vif=m_if;
  t7.e0.g0.c=c7;
  t7.e0.g0.num=test_input;
  t7.run();
  $display ("****** Num of Errors= %0d *********",t7.e0.s0.num_error);
  $display ("Last error at: %0d",t7.e0.s0.er_time);
end
  if (test0&&test2&&test3&&test4&&test5&&test6&&test7) 
  begin
  total_er=t0.e0.s0.num_error+t2.e0.s0.num_error+t3.e0.s0.num_error+t4.e0.s0.num_error+t5.e0.s0.num_error+t6.e0.s0.num_error+t7.e0.s0.num_error;
  num_of_input=t0.e0.g0.num+t2.e0.g0.num+t3.e0.g0.num+t4.e0.g0.num+t5.e0.g0.num+t6.e0.g0.num+t7.e0.g0.num;
  end
  if (test0) begin
  if (t0.e0.s0.num_error==0)
  $display ("Test 0 Pass with no Error!");
  else begin
  $display ("Test 0 Pass with Errosr!");
  $display ("Last error at Test 0: %d",t0.e0.s0.er_time);
  end
end
if (test2) begin
  if (t2.e0.s0.num_error==0)
  $display ("Test 2 Pass with no Error!");
  else begin
  $display ("Test 2 Pass with Errors!");
  $display ("Last error at Test 2: %d",t2.e0.s0.er_time);
  end
end
if (test3) begin
  if (t3.e0.s0.num_error==0)
  $display ("Test 3 Pass with no Error!");
  else begin
  $display ("Test 3 Pass with Errors!");
  $display ("Last error at Test 3: %d",t3.e0.s0.er_time);
  end
end
if (test4) begin
  if (t4.e0.s0.num_error==0)
  $display ("Test 4 Pass with no Error!");
  else begin
  $display ("Test 4 Pass with Errors!");
  $display ("Last error at Test 4: %d",t4.e0.s0.er_time);
  end
end
if (test5) begin
  if (t5.e0.s0.num_error==0)
  $display ("Test 5 Pass with no Error!");
  else begin
  $display ("Test 5 Pass with Errors!");
  $display ("Last error at Test 5: %d",t5.e0.s0.er_time);
  end
end
if (test6) begin
  if (t6.e0.s0.num_error==0)
  $display ("Test 6 Pass with no Error!");
  else begin
  $display ("Test 6 Pass with Errors!");
  $display ("Last error at Test 6: %d",t6.e0.s0.er_time);
  end
end
if (test7) begin
  if (t7.e0.s0.num_error==0)
  $display ("Test 7 Pass with no Error!");
  else begin
  $display ("Test 7 Pass with Errors!");
  $display ("Last error at Test 7: %d",t7.e0.s0.er_time);
  end
end
  $display ("Number Of Total inputs:%d",num_of_input);
  $display ("Total Flag errors=%0d",flag_err);
  $display ("Total errors=%0d",total_er);
  
  #500
  $stop;
  
end

    always @(posedge m_if.clk_base or negedge m_if.clk_base or posedge m_if.rst)
    begin
      if (m_if.rst)
      flags_counter=0;
      else
      begin
        if ((m_if.Flags_out!= flags_counter)&& L_on_current>Nde) begin
          $error("********\n SimTime=%0t , Flag_counter=%0d while Flag_out=%0d \n",$time,flags_counter,m_if.Flags_out);
          flag_err=flag_err+1;
          end
        flags_counter=flags_counter+1;
      end
    end
    always @(negedge m_if.L_DPWM) begin
      flags_counter=0;
    end
always @(negedge m_if.L_DPWM) begin
      L_on_current = m_if.L_on;
    end
endmodule
