// Synchronous FIFO testbench
// Create By: Yakir Peretz
`resetall
`timescale 1ns/1ps
`define TOP_MODULE_NAME YP_sync_fifo_top

module `TOP_MODULE_NAME();

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    initial begin
        uvm_config_db#(virtual YP_sync_fifo_if)::set(null,"*","vif",`TOP_MODULE_NAME.vif)
        run_test();
    end
    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 32;
    wire i_clk;
    wire i_rstn;
    wire i_rd_en;
    wire i_wr_en;
    wire [DATA_WIDTH-1:0] i_data_in;
    wire [DATA_WIDTH-1:0] o_data_out;
    wire o_full;
    wire o_empty;

    YP_sync_fifo sync_fifo( 
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_rd_en(i_rd_en),
    .i_wr_en(i_wr_en),
    .i_data_in(i_data_in),
    .o_data_out(o_data_out),
    .o_full(o_full),
    .o_empty(o_empty)
    );
    // clk gen
    reg gen_clk;
    initial begin
        gen_clk = $urandom_range(0,1);
        forever begin
            #10 gen_clk = ~gen_clk;
        end

    end 
    
    assign i_clk = clk;




endmodule