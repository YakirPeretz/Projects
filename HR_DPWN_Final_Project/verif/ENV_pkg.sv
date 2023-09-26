//
// Verilog package HR_DPWM_lib.env_pkg
//
// Created:
//          by - pyakir.UNKNOWN (SHOHAM)
//          at - 13:19:36 12/10/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 10ps/1ps
`include "HR_DPWM_if.sv"

package env_pkg;


class HRDPWM_item#(
Dc_length = 13,
Nde = 64);

rand bit   [Dc_length-1:0]  DeadTime;
rand bit   [Dc_length-1:0]  H_on;
rand bit   [Dc_length-1:0]  L_on; 
bit                   rst=0;


constraint valid_Hon{H_on inside {[1:(2**Dc_length)-1]};}
constraint Valid_Lon {L_on inside {[1:H_on]}; solve H_on before L_on; }
constraint Valid_DT {DeadTime inside {[1:L_on]};solve L_on before DeadTime;}
constraint DT_zero{DeadTime==0;} // no Deadtime
constraint clk_base{(H_on%Nde)==0;(L_on%Nde)==0;(DeadTime%Nde)==0;}
constraint Less_clkbase {H_on<Nde;}
constraint H_onMax {H_on==(2**Dc_length)-1;}
constraint Max_val {H_on==(2**Dc_length)-1;L_on==(2**Dc_length)-1;DeadTime==(2**Dc_length)-1;}
constraint small_change1 {H_on inside {[127:129]};L_on inside {[63:65]};DeadTime inside {[31:33]};}
constraint small_change2 {H_on inside {[1023:1025]};L_on inside {[900:902]};DeadTime inside {[522:524]};}

function void print(string tag="");
  $display("SimTime=%0t [%s] H_on=%0d, L_on=%0d, DeadTime=%0d \n",$time,tag,H_on,L_on,DeadTime);
endfunction

endclass

class HRPWM_calc;

integer H_start;
integer H_stop;
integer L_start;
integer L_stop;
integer DT_start;
integer DT_stop;


function void print(string tag="");
  $display("SimTime=%0t [%s] H_start=%0d, H_stop=%0d, L_start=%0d ,L_stop=%0d ,DT_start=%0d ,DT_stop=%0d \n",$time,tag,H_start,H_stop,L_start,L_stop,DT_start,DT_stop);
endfunction

endclass

typedef enum int {FREE,DTZERO,CLKBASE,LESSCLKBASE,HonMax,MAXV,SMALL1,SMALL2} consmode;

class Generator #(
  Dc_length = 13,
Nde = 64);
int num = 10;
event drv_done;
event mon_negL;
mailbox drv_mbx;
consmode c;

task run();
  for (int i=0; i<num;i++) 
  begin
    HRDPWM_item #(.Dc_length(Dc_length),.Nde(Nde)) item=new;
    item=constoff(item);
    case (c)
      DTZERO: begin 
              item.DT_zero.constraint_mode(1);
              $display("DeadTime=0 constraint enable");
            end
      CLKBASE:  begin 
              item.clk_base.constraint_mode(1);
              $display("All Pointers are on the Clock Base constraint enable");
              end
      LESSCLKBASE: begin 
                   item.Less_clkbase.constraint_mode(1);
                   $display("H_on is less then Nde constraint enable");
                 end
      HonMax:  begin
                   item.H_onMax.constraint_mode(1);
                   $display("H_on in max value constraint enable");
                 end
      MAXV: begin
            item.Max_val.constraint_mode(1);
            $display("MAX_values constraint enable");
          end
      SMALL1: begin
               item.small_change1.constraint_mode(1);
               $display("Small changes1 constraint enable");
             end
      SMALL2:   begin
               item.small_change2.constraint_mode(1);
               $display("Small changes2 constraint enable");
             end
    endcase
    if (i==0)
    begin
      item.H_on=1000;
      item.L_on=800;
      item.DeadTime=500;
      item.rst=1;
      $display ("SimTime=%0t [Generator] Loop:%0d/%0d create item",$time,i+1,num);
      drv_mbx.put(item);
      $display ("SimTime=%0t [Generator] Wait for driver to be done",$time);
      @(drv_done);
       #(20*Nde);
       item.rst=0;
       drv_mbx.put(item);
       $display ("SimTime=%0t [Generator] Wait for driver to be done",$time);
       @(drv_done);
       @(mon_negL);
       drv_mbx.put(item);
      $display ("SimTime=%0t [Generator] Wait for driver to be done",$time);
      @(drv_done);
    end
    else begin
    item.randomize();
    $display ("SimTime=%0t [Generator] Loop:%0d/%0d create item",$time,i+1,num);
    drv_mbx.put(item);
    $display ("SimTime=%0t [Generator] Wait for driver to be done",$time);
    @(drv_done);
    end
  end
endtask

function HRDPWM_item constoff(HRDPWM_item item);
  item.DT_zero.constraint_mode(0);
  item.clk_base.constraint_mode(0);
  item.Less_clkbase.constraint_mode(0);
  item.H_onMax.constraint_mode(0);
  item.Max_val.constraint_mode(0);
  item.small_change1.constraint_mode(0);
  item.small_change2.constraint_mode(0);
  $display("All Constraints off except Valids");
  return item;
endfunction

endclass

class driver#(
Dc_length = 13,
Nde = 64);
virtual HR_DPWM_if #(.Dc_length(Dc_length)) vif;
event drv_done;
mailbox drv_mbx;
HRDPWM_item #(.Dc_length(Dc_length),.Nde(Nde)) Dc_item_pre;
HRDPWM_item #(.Dc_length(Dc_length),.Nde(Nde))  Dc_item_curr;
task run();
  $display ("SimTime= %0t [Driver] start...",$time);
  forever begin
    $display("SimTime= %0t [Driver] waiting for item...",$time);
    drv_mbx.get(Dc_item_curr);
    if (Dc_item_curr.rst==1) begin
      Dc_item_pre=Dc_item_curr;
      Dc_item_curr.print("Driver");
      vif.H_on <= Dc_item_curr.H_on;
      vif.L_on <= Dc_item_curr.L_on;
      vif.DeadTime <= Dc_item_curr.DeadTime;
      vif.rst <= Dc_item_curr.rst; 
      ->drv_done;
      drv_mbx.get(Dc_item_curr);
      Dc_item_curr.print("Driver");
      vif.H_on <= Dc_item_curr.H_on;
      vif.L_on <= Dc_item_curr.L_on;
      vif.DeadTime <= Dc_item_curr.DeadTime;
      vif.rst <= Dc_item_curr.rst; 
      ->drv_done;
    end
    else begin
    @(posedge vif.H_DPWM);
    Dc_item_pre.print("Driver Pre");
    #((Dc_item_pre.H_on/2)*20);
    Dc_item_curr.print("Driver");
    vif.H_on <= Dc_item_curr.H_on;
    vif.L_on <= Dc_item_curr.L_on;
    vif.DeadTime <= Dc_item_curr.DeadTime;
    vif.rst <= Dc_item_curr.rst; 
    Dc_item_pre=Dc_item_curr;
    ->drv_done;
    end
   // add print item
  end
endtask
endclass
class Monitor#(
Dc_length = 13,
Nde = 64);
virtual HR_DPWM_if #(.Dc_length(Dc_length)) vif;
mailbox scb_mbx;
event mon_negL;
task run();
  $display("SimTime=%0t [Monitor] starting...",$time);
  
  forever begin
    HRDPWM_item #(.Dc_length(Dc_length),.Nde(Nde)) Dc_item=new();
    HRPWM_calc calc_item=new();
    if (vif.rst)
    begin
    wait (vif.rst==0);
    Dc_item.H_on=vif.H_on;
    Dc_item.L_on=vif.L_on;
    Dc_item.DeadTime=vif.DeadTime;
    Dc_item.rst=vif.rst;
    Dc_item.print("Monitor");
    end
    @(negedge vif.L_DPWM);
    ->mon_negL;
    Dc_item.H_on=vif.H_on;
    Dc_item.L_on=vif.L_on;
    Dc_item.DeadTime=vif.DeadTime;
    Dc_item.rst=vif.rst;
    Dc_item.print("Monitor");
    scb_mbx.put(Dc_item);
    calc_item.DT_start=$time;
    @(posedge vif.H_DPWM);
    calc_item.DT_stop=$time;
    calc_item.H_start=$time;
    @(negedge vif.H_DPWM);
    calc_item.H_stop=$time;
    @(posedge vif.L_DPWM);
    calc_item.L_start=$time;
    @(negedge vif.L_DPWM);
    calc_item.L_stop=$time;
    calc_item.print("Monitor");
    scb_mbx.put(calc_item);
    
  end
  
endtask

endclass



class Scoreboard#(
Dc_length =13,
Nde = 64);

mailbox scb_mbx;
int num_error=0;
longint er_time=0;
virtual HR_DPWM_if #(.Dc_length(Dc_length)) vif;

task run();
  forever begin
    HRDPWM_item #(.Dc_length(Dc_length),.Nde(Nde)) Dc_item;
    HRPWM_calc calc_item;
    scb_mbx.get(Dc_item);
    Dc_item.print("Scoreboard");
    scb_mbx.get(calc_item);
    calc_item.print("Scoreboard");
    if (Dc_item.rst==1)
      $display("SimTime=%0t , reset switching cycle\n",$time);
    else begin
      if ((calc_item.DT_stop-calc_item.DT_start)!= (Dc_item.DeadTime*20)) begin
        $error("********\n SimTime=%0t , DeadTime1 Fail! calc DT=%0d \n",$time,(calc_item.DT_stop-calc_item.DT_start)/20);
        er_time=$time;
        num_error=num_error+1;
        $stop;
      end
        else
        $display("SimTime=%0t , DeadTime1 Pass! calc DT=%0d \n",$time,(calc_item.DT_stop-calc_item.DT_start)/20);
      if ((calc_item.H_stop-calc_item.H_start)!= (Dc_item.H_on*20)) begin
        $error("********\n SimTime=%0t , H_on Fail! calc H_on=%0d \n",$time,(calc_item.H_stop-calc_item.H_start)/20);
        er_time=$time;
        num_error=num_error+1;
        $stop;
      end
        else
        $display("SimTime=%0t , H_on Pass! calc H_on=%0d \n",$time,(calc_item.H_stop-calc_item.H_start)/20);
      if ((calc_item.L_start-calc_item.H_stop)!= (Dc_item.DeadTime*20)) begin
        $error("********\n SimTime=%0t , DeadTime2 Fail! calc DT2=%0d \n",$time, (calc_item.L_start-calc_item.H_stop)/20);
        er_time=$time;
        num_error=num_error+1;
        $stop;
      end
        else
        $display("SimTime=%0t , DeadTime2 Pass! calc DT2=%0d \n",$time,(calc_item.L_start-calc_item.H_stop)/20);
      if ((calc_item.L_stop-calc_item.L_start)!= (Dc_item.L_on*20)) begin
        $error("********\n SimTime=%0t , L_on Fail! calc L_on = %0d \n",$time,(calc_item.L_stop-calc_item.L_start)/20);
        er_time=$time;
        num_error=num_error+1;
        $stop;
      end
        else
        $display("SimTime=%0t , L_on Pass! calc L_on = %0d\n",$time,(calc_item.L_stop-calc_item.L_start)/20);
    end
    
  end
  endtask

endclass

class Env#(
Dc_length = 13,
Nde = 64);

driver #(.Dc_length(Dc_length),.Nde(Nde)) d0; 
Monitor #(.Dc_length(Dc_length),.Nde(Nde)) m0;
Generator #(.Dc_length(Dc_length),.Nde(Nde)) g0;
Scoreboard #(.Dc_length(Dc_length),.Nde(Nde)) s0;
mailbox scb_mbx;
mailbox drv_mbx;
event drv_done;
event mon_negL;
virtual HR_DPWM_if #(.Dc_length(Dc_length)) vif;
consmode c;
function new();
  d0=new;
  m0=new;
  g0=new;
  s0=new;
  scb_mbx=new();
  drv_mbx=new();
  
  g0.drv_mbx=drv_mbx;
  d0.drv_mbx=drv_mbx;
  m0.scb_mbx=scb_mbx;
  s0.scb_mbx=scb_mbx;
  
  g0.drv_done=drv_done;
  g0.mon_negL=mon_negL;
  d0.drv_done=drv_done;
  m0.mon_negL=mon_negL;
  
endfunction

virtual task run();

  d0.vif=vif;
  m0.vif=vif;

  
  fork
  d0.run();
  m0.run();
  g0.run();
  s0.run();
  join_any
  endtask

endclass

class test#(
   // synopsys template
   parameter Nde          = 64,
   parameter DE_bits      = 6,
   parameter Dc_length    = 13,
   parameter Count_length = Dc_length-DE_bits
);
Env e0;

function new();
  e0=new;
endfunction;

task run();
  e0.run();
endtask

endclass


endpackage
