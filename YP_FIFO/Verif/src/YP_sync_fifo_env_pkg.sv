// Synchronous FIFO verification enviorment
// Create By: Yakir Peretz

`resetall
`timescale 1ps/1ps
package env_pkg;


    typedef enum int {FREE,FULL,EMPTY} consmode;


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
