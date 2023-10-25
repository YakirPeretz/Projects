// Verification package
// Created By : Yakir Peretz
`resetall
`timescale 1ps/1ps

`include "chn_in_if.sv"

package verif_env_pkg;

    class packet_item#(
        data_size          = 8,
        pkt_length_bits    = 5,
        pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
    );

        rand bit [pkt_length_bits-1:0] m_pkt_length;
        rand bit [pkt_addr_bits-1:0]    m_pkt_addr;
        rand bit [data_size-1:0]   m_pkt_data[$];
        rand bit [data_size-1:0]    m_pkt_parity;
        rand bit                    m_good_parity;
        rand int unsigned           m_delay;

        constraint pkt__c {
            m_pkt_length inside {[1:31]};
            m_pkt_addr < 4;
            m_pkt_data.size() == m_pkt_length -1;
            m_good_parity dist {1:=90,0:=0};
            m_delay inside {[2:30]};
        }

        function void print(string tag = "");
            $display("T = %0t : [%s] - pkt_length = %0d,pkt_addr = %0d,pkt_data.size() = %0d\npkt_data = %p\npkt_parity = 'h%h(8'b%b), m_good_parity = %b",$time,tag,m_pkt_length,m_pkt_addr,m_pkt_data.size(),m_pkt_data,m_pkt_parity,m_pkt_parity,m_good_parity);
        endfunction

        function [data_size-1:0] calc_parity();
            bit [data_size-1:0] calc_par;
            calc_par = {m_pkt_length,m_pkt_addr};
            for (int i = 0; i < m_pkt_length ; i++)
                calc_par = calc_par ^ m_pkt_data[i];
            return calc_par;
        endfunction

        function void set_parity();
            m_pkt_parity = calc_parity();
            if(!m_good_parity)
                m_pkt_parity = ~m_pkt_parity;

        endfunction

        function [data_size-1:0] get_header;
            return {m_pkt_length,m_pkt_addr};
        endfunction

    endclass

    class gen#(
        data_size          = 8,
        pkt_length_bits    = 5,
        pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
    );
        mailbox drv_mbx;
        event drv_done;
        int m_num_of_iter = 20;
        bit [data_size-1:0]   m_data;
        task run();
            for (int i = 0; i < m_num_of_iter ; i++)
            begin
                packet_item pkt_item = new;
                pkt_item.randomize();
                $display("T=%0t : [GEN] - iter %0d/%0d, create pkt_item",$time,i,m_num_of_iter);
                drv_mbx.put(pkt_item);
                @(drv_done);
            end 
            $display("T=%0t : [GEN] - All %0d items done",$time,m_num_of_iter);
        endtask

    endclass

    class driver#(
        data_size          = 8,
        pkt_length_bits    = 5,
        pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
    );
        virtual chn_vif m_chn_vif;
        event drv_done;
        mailbox drv_mbx;

        task run();
            forever 
            begin
                packet_item pkt_item;
                drv_mbx.get(pkt_item);
                pkt_item.print("DRIVER");
                pkt_item.set_parity();
                @(posedge m_chn_vif.clk);
                m_chn_vif.chn_en <= 1'b1;
                $display("T = %0t : [DRIVER] - chn_en high",$time);
                @(posedge m_chn_vif.clk);
                @(m_chn_vif.data_drive_cb);
                $display("T = %0t : [DRIVER] - Driving pkt header = 8'h%h",$time,pkt_item.get_header());
                m_chn_vif.data_drive_cb.data_in <= pkt_item.get_header();
                for(int i = 0 ; i < pkt_item.m_pkt_length -1 ; i++)
                begin
                    @(m_chn_vif.data_drive_cb);
                    $display("T = %0t : [DRIVER] - i = %0d. Driving data pkt = 8'h%h",$time,i,pkt_item.m_pkt_data[i]);
                    m_chn_vif.data_drive_cb.data_in <= pkt_item.m_pkt_data[i];
                end 
                @(m_chn_vif.data_drive_cb);
                $display("T = %0t : [DRIVER] - Driving pkt parity = 8'h%h",$time,pkt_item.m_pkt_parity);
                m_chn_vif.data_drive_cb.data_in <= pkt_item.m_pkt_parity;
                @(posedge m_chn_vif.clk);
                m_chn_vif.chn_en <= 1'b0;
                $display("T = %0t : [DRIVER] - Delay clk before next packet = %0d",$time,pkt_item.m_delay);
                repeat(pkt_item.m_delay)
                    @(posedge m_chn_vif.clk);
                ->drv_done;
                $display("T = %0t : [DRIVER] - Delay clk before next packet done",$time,pkt_item.m_delay);

            end

        endtask


    endclass

    class monitor_in#(
        data_size          = 8,
        pkt_length_bits    = 5,
        pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
    );
        virtual chn_vif m_chn_vif;
        mailbox scb_mbx_in;
        bit [data_size-1:0] data_temp;
        task run();
            forever begin
                packet_item pkt_item = new();
                @(posedge m_chn_vif.chn_en);
                $display("T = %0t : [Monitor_IN] - chn_en asserted" , $time);
                @(posedge m_chn_vif.clk);
                @(posedge m_chn_vif.clk);
                data_temp = m_chn_vif.data_in;
                pkt_item.m_pkt_length = data_temp[data_size-1:data_size-pkt_length_bits];
                pkt_item.m_pkt_addr = data_temp[pkt_addr_bits-1:0];
                $display("T = %0t : [Monitor_IN] - Packet Header: length = %0d, addr = %0d",$time,pkt_item.m_pkt_length,pkt_item.m_pkt_addr);
                fork
                    begin
                        for( int i =0; i< pkt_item.m_pkt_length; i++)
                        begin
                            @(posedge m_chn_vif.clk);
                            data_temp = m_chn_vif.data_in;
                            $display("T = %0t : [Monitor_IN] - Packet data %0d: 8'h%h",$time,i,data_temp);
                            if(i == pkt_item.m_pkt_length - 1)
                            begin
                                pkt_item.m_pkt_parity = data_temp;
                                $display("T = %0t : [Monitor_IN] - Packet parity %0d: 8'h%h",$time,i,pkt_item.m_pkt_parity);
                            end 
                            else
                            begin
                                pkt_item.m_pkt_data.push_back(data_temp);
                                $display("T = %0t : [Monitor_IN] - Packet data(push_back) %0d: 8'h%h",$time,i,data_temp);
                            end 
                        end 
                    end
                    begin
                        @(negedge m_chn_vif.chn_en);
                        $display("T = %0t : [Monitor_IN] - chn_en deasserted",$time);
                    end 
                join_any
                $display("T = %0t : [Monitor_IN] - Packet Done!",$time);
                disable fork;
                pkt_item.print("Monitor_IN");
                scb_mbx_in.put(pkt_item);
            end 

        endtask
    endclass

    class monitor_out#(
        data_size          = 8,
        pkt_length_bits    = 5,
        pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
    );
        virtual chn_vif m_chn_vif;
        mailbox scb_mbx_out;
        bit [data_size-1:0] data_temp;
        task run();
            forever begin
                packet_item pkt_item = new();
                @(posedge m_chn_vif.pkt_to_fifo_en);
                $display("T = %0t : [Monitor_OUT] - pkt_to_fifo_en asserted",$time);
                @(posedge m_chn_vif.clk);
                @(posedge m_chn_vif.clk);
                data_temp = m_chn_vif.data_out;
                pkt_item.m_pkt_length = data_temp[data_size-1:data_size-pkt_length_bits];
                pkt_item.m_pkt_addr = data_temp[pkt_addr_bits-1:0];
                $display("T = %0t : [Monitor_OUT] - Packet Header: length = %0d, addr = %0d",$time,pkt_item.m_pkt_length,pkt_item.m_pkt_addr);
                fork
                    begin
                        for( int i =0; i< pkt_item.m_pkt_length; i++)
                        begin
                            @(posedge m_chn_vif.clk);
                            data_temp = m_chn_vif.data_out;
                            $display("T = %0t : [Monitor_OUT] - Packet data %0d: 8'h%h",$time,i,data_temp);
                            if(i == pkt_item.m_pkt_length - 1)
                            begin
                                pkt_item.m_pkt_parity = data_temp;
                                $display("T = %0t : [Monitor_OUT] - Packet parity %0d: 8'h%h",$time,i,pkt_item.m_pkt_parity);
                            end 
                            else
                            begin
                                pkt_item.m_pkt_data.push_back(data_temp);
                                $display("T = %0t : [Monitor_OUT] - Packet data(push_back) %0d: 8'h%h",$time,i,data_temp);
                            end 
                        end 
                    end
                    begin
                        @(negedge m_chn_vif.pkt_to_fifo_en);
                        $display("T = %0t : [Monitor_OUT] - pkt_to_fifo_en deasserted",$time);
                    end 
                join_any
                $display("T = %0t : [Monitor_OUT] - Packet Done!",$time);
                disable fork;
                pkt_item.print("Monitor_OUT");
                scb_mbx_out.put(pkt_item);
            end 

        endtask
    endclass

    class scorboard#(
        data_size          = 8,
        pkt_length_bits    = 5,
        pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
    );
        mailbox scb_mbx_out;
        mailbox scb_mbx_in;

        task run();
            forever 
            begin
                packet_item pkt_item_in;
                packet_item pkt_item_out;
                scb_mbx_in.get(pkt_item_in);
                pkt_item_in.print("SCB");
                scb_mbx_out.get(pkt_item_out);
                pkt_item_out.print("SCB");
                if(pkt_item_in.m_pkt_length != pkt_item_out.m_pkt_length)
                    $display("T = %0d : ERROR! pkt_length mismatch! pkt_item_in.m_pkt_length = %0d, pkt_item_out.m_pkt_length = %0d",$time,pkt_item_in.m_pkt_length,pkt_item_out.m_pkt_length);
                if(pkt_item_in.m_pkt_addr != pkt_item_out.m_pkt_addr)
                    $display("T = %0d : ERROR! pkt_addr mismatch! pkt_item_in.m_pkt_addr = %0d, pkt_item_out.m_pkt_addr = %0d",$time,pkt_item_in.m_pkt_addr,pkt_item_out.m_pkt_addr);
                
                for (int i = 0; i < pkt_item_in.m_pkt_data.size(); i++)
                begin
                    if(pkt_item_in.m_pkt_data[i] != pkt_item_out.m_pkt_data[i])
                        $display("T = %0d : ERROR! pkt_data[%0d] mismatch! pkt_item_in.pkt_data[%0d] = %0d, pkt_item_out.pkt_data[%0d] = %0d",$time,i,i,pkt_item_in.m_pkt_data[i],i,pkt_item_out.m_pkt_data[i]);
                end 
                if(pkt_item_in.m_pkt_parity != pkt_item_out.m_pkt_parity)
                    $display("T = %0d : ERROR! m_pkt_parity mismatch! pkt_item_in.m_pkt_parity = %0d, pkt_item_out.m_pkt_parity = %0d",$time,pkt_item_in.m_pkt_parity,pkt_item_out.m_pkt_parity);
            end     
        endtask

    endclass

    class in_chn_env#(
        data_size          = 8,
        pkt_length_bits    = 5,
        pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
    );
        gen         m_chn_gen;
        driver      m_chn_in_drv;
        monitor_in  m_chn_mon_in;
        monitor_out m_chn_mon_out;
        scorboard   m_chn_in_scb;
        mailbox     m_scb_mbx_out;
        mailbox     m_scb_mbx_in;
        mailbox     m_drv_mbx;
        event       m_drv_done;

        virtual chn_vif m_chn_vif;

        function new();
            m_chn_gen = new;
            m_chn_in_drv = new;
            m_chn_mon_in = new;
            m_chn_mon_out = new;
            m_chn_in_scb = new;
            m_scb_mbx_out = new();
            m_scb_mbx_in = new();
            m_drv_mbx = new();
            // Driver and gen connect
            m_chn_gen.drv_done = m_drv_done;
            m_chn_gen.drv_mbx = m_drv_mbx;
            m_chn_in_drv.drv_done = m_drv_done;
            m_chn_in_drv.drv_mbx = m_drv_mbx;

            // scb and monitor connect
            m_chn_mon_in.scb_mbx_in = m_scb_mbx_in;
            m_chn_mon_out.scb_mbx_out = m_scb_mbx_out;
            m_chn_in_scb.scb_mbx_out = m_scb_mbx_out;
            m_chn_in_scb.scb_mbx_in = m_scb_mbx_in;

        endfunction

        virtual task run();
            m_chn_in_drv.m_chn_vif = m_chn_vif;
            m_chn_mon_in.m_chn_vif = m_chn_vif;
            m_chn_mon_out.m_chn_vif = m_chn_vif;
            fork
                m_chn_gen.run();
                m_chn_in_drv.run();
                m_chn_mon_in.run();
                m_chn_mon_out.run();
                m_chn_in_scb.run();
            join_any

        endtask
    endclass

    class chn_in_fsm_test#(
        data_size          = 8,
        pkt_length_bits    = 5,
        pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
    );
        in_chn_env m_chn_in_env;

        function new();
            m_chn_in_env = new;
        endfunction

        task run();
            m_chn_in_env.run();
        endtask

    endclass

endpackage