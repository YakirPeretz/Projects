// Synchronous FIFO verification enviorment
// Create By: Yakir Peretz

`resetall
`timescale 1ps/1ps
package env_pkg;

    class write_fifo_item#(
        parameter DATA_WIDTH    = 8,
    );
        rand bit [DATA_WIDTH-1:0] wr_data;
        rand int unsigned wait_time2write;

        constraint wait_time_c {
            wait_time2write inside {[0:100]};
        }
        constraint write_stress_c {
            wait_time2write dist {0:/50,1:/30,[2:5]:/20};
        }

        function void print(string tag="");
            $display("SimTime=%0t [%s] wr_data = 0x%x, wait_time = %d\n",$time,tag,wr_data,wait_time2write);
        endfunction
        
    endclass


    class read_fifo_item(
        parameter DATA_WIDTH    = 8,
        );
        rand int unsigned wait_time2read;
        bit [DATA_WIDTH-1:0] rd_data;

        constraint wait_time_c {
            wait_time2read inside {[0:100]};
        }
        constraint read_stress_c {
            wait_time2read dist {0:/50,1:/30,[2:5]:/20};
        }
        function void print(string tag="");
            $display("SimTime=%0t [%s] wait_time = %d\n",$time,tag,wait_time2read);
        endfunction
    endclass

    typedef enum int {FREE,FULL,EMPTY} consmode;

    class Generator #(
        parameter DATA_WIDTH    = 8
    );

        int unsigned num_wr_trans = $urandom_range(20, 200);
        int unsigned num_rd_trans = $urandom_range(20, 200);

        event wr_drv_done;
        event rd_drv_dome;
        mailbox wr_drv_mbx;
        mailbox rd_drv_mbx;

        consmode c;

        task run();
            fork 
                begin: wr_fifo_thread
                    for (int i=0; i<num_wr_trans;i++) 
                    begin
                        write_fifo_item #(.DATA_WIDTH(DATA_WIDTH)) wr_item=new;
                        case (c)
                            FREE: begin 
                                wr_item.write_stress_c.constraint_mode(0);
                                $display("GEN : Free mode");
                                end
                            FULL:  begin 
                                wr_item.write_stress_c.constraint_mode(1);
                                $display("GEN : FULL mode");
                                end
                            EMPTY: begin 
                                wr_item.write_stress_c.constraint_mode(0);
                                $display("GEN : EMPTY mode");
                            end
                        endcase
                        $display ("SimTime=%0t [Generator - wr] Loop:%0d/%0d create item",$time,i+1,num_wr_trans);
                        drv_mbx.put(wr_item);
                        $display ("SimTime=%0t [Generator - wr] Wait for driver to be done",$time);
                        @(wr_drv_done);
                        end
                end 
                begin:rd_fifo_thread
                    for (int i=0; i<num_rd_trans;i++) 
                    begin
                        read_fifo_item rd_item = new;
                        case (c)
                            FREE: begin 
                                rd_item.read_stress_c.constraint_mode(0);
                                $display("GEN : Free mode");
                                end
                            FULL:  begin 
                                rd_item.read_stress_c.constraint_mode(0);
                                $display("GEN : FULL mode");
                                end
                            EMPTY: begin 
                                rd_item.read_stress_c.constraint_mode(1);
                                $display("GEN : EMPTY mode");
                            end
                        endcase
                        $display ("SimTime=%0t [Generator - rd] Loop:%0d/%0d create item",$time,i+1,num_rd_trans);
                        drv_mbx.put(rd_item);
                        $display ("SimTime=%0t [Generator - rd] Wait for driver to be done",$time);
                        @(rd_drv_done);
                    end
                end 
            join
                
        endtask

    endclass

    class wr_driver#(
        parameter DATA_WIDTH    = 8
        );
        virtual YP_sync_fifo_if #(.DATA_WIDTH(DATA_WIDTH)) vif;
        event wr_drv_done;
        mailbox wr_drv_mbx;
        write_fifo_item #(.DATA_WIDTH(DATA_WIDTH)) wr_item;

        task run();
            $display ("SimTime= %0t [WR-Driver] start...",$time);
            forever begin
                $display("SimTime= %0t [WR-Driver] waiting for item...",$time);
                wr_drv_mbx.get(wr_item);
                repeat (wr_item.wait_time2write)
                    @(posedge vif.i_clk);
                vif.i_data_in <= wr_item.wr_data;
                vif.i_wr_en <= 1'b1;
                @(posedge vif.i_clk);
                vif.i_wr_en <= 1'b0;
                ->wr_drv_done;
            end
        endtask
    endclass

    class rd_driver#(
        parameter DATA_WIDTH    = 8
        );
        virtual YP_sync_fifo_if #(.DATA_WIDTH(DATA_WIDTH)) vif;
        event rd_drv_done;
        mailbox rd_drv_mbx;
        read_fifo_item rd_item;

        task run();
            $display ("SimTime= %0t [RD-Driver] start...",$time);
            forever begin
                $display("SimTime= %0t [RD-Driver] waiting for item...",$time);
                rd_drv_mbx.get(rd_item);
                repeat (rd_item.wait_time2read)
                    @(posedge vif.i_clk);
                vif.i_rd_en <= 1'b1;
                @(posedge vif.i_clk);
                vif.i_rd_en <= 1'b0;
                ->rd_drv_mbx;
            end
        endtask
    endclass


    class Monitor#(
        parameter DATA_WIDTH    = 8
        );
        virtual YP_sync_fifo_if #(.DATA_WIDTH(DATA_WIDTH)) vif;
        mailbox wr_scb_mbx;
        mailbox rd_scb_mbx;

        task run();
            $display("SimTime=%0t [Monitor] starting...",$time);
                fork
                    begin:wr_data_catch
                        forever begin
                            @(posedge vif.i_wr_en && !vif.o_full);
                            write_fifo_item #(.DATA_WIDTH(DATA_WIDTH)) wr_item = new;
                            wr_item.wr_data = vif.i_data_in;
                            wr_item.print("Monitor");
                            wr_scb_mbx.put(wr_item);
                        end 
                    end

                    begin
                        forever begin
                            @(posedge vif.i_rd_en && !vif.o_empty);
                            read_fifo_item #(.DATA_WIDTH(DATA_WIDTH)) rd_item = new;
                            rd_item.rd_data = vif.o_data_out;
                            rd_item.print("Monitor");
                            rd_scb_mbx.put(rd_item);
                        end
                    end 
                join
    
        endtask

    endclass



    class sync_fifo_ref_model#(
        parameter DATA_WIDTH    = 8,
        parameter FIFO_DEPTH    = 32
    );

        mailbox wr_scb_mbx;
        mailbox rd_scb_mbx;
        int unsigned num_error=0;
        virtual YP_sync_fifo_if #(.DATA_WIDTH(DATA_WIDTH)) vif;
        bit [DATA_WIDTH-1:0] fifo_queue [$:FIFO_DEPTH];
        bit [DATA_WIDTH-1:0] rd_data;
        bit [DATA_WIDTH-1:0] wr_data;

        task run();
            fork 
            begin
                write_fifo_item #(.DATA_WIDTH(DATA_WIDTH)) wr_item;
                wr_scb_mbx.get(wr_item);
                wr_item.print("REF_MODEL");
                wr_data = wr_item.wr_data;
                fifo_queue.push_back(wr_data);
                check_fifo_full();
            end 
            begin
                read_fifo_item #(.DATA_WIDTH(DATA_WIDTH)) rd_item;
                rd_scb_mbx.get(rd_item);
                rd_item.print("REF_MODEL");
                rd_data = fifo_queue.pop_front();
                check_fifo_empty();
                if(rd_data != rd_item.rd_data)
                    begin
                        $error("********\n SimTime=%0t , Read data doesn't match expected! rd_data = 0x%x, exp_data = 0x%x\n",$time,rd_data,rd_item.rd_data);
                        num_error=num_error+1;
                        $stop;
                    end 
                
            end 
        endtask

        
        function void check_fifo_full();
            if(fifo_queue.size()==FIFO_DEPTH) begin
                $display("SimTime= %0t [REF_MODEL] exp fifo full. fifo_size = %d",$time,fifo_queue.size());
                vif.exp_full = 1'b1;
            end 
            else
                vif.exp_full = 1'b0;
        endfunction

        function void check_fifo_empty();
            if(fifo_queue.size()==0) begin
                $display("SimTime= %0t [REF_MODEL] exp fifo empty. fifo_size = %d",$time,fifo_queue.size());
                vif.exp_empty = 1'b1;
            end 
            else
                vif.exp_empty = 1'b0;
        endfunction
            

    endclass

    class 

    class sync_fifo_env#(
        parameter DATA_WIDTH    = 8,
        parameter FIFO_DEPTH    = 32
        );

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
