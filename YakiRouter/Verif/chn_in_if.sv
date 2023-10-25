// input channel interface
// Created By : Yakir Peretz

`resetall
`timescale 1ps/1ps

interface chn_vif#(
    parameter data_size          = 8,
    parameter pkt_length_bits    = 5,
    parameter pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
);
// (
//     input 
//     inout

// );
logic clk;
logic [data_size-1:0] data_in;
logic chn_en;
logic rstn;
logic clr_errors;
logic [data_size-1:0] data_out;
logic busy;
logic error;
logic pkt_to_fifo_en;
logic [data_size-1:0] data_in_temp;
logic [data_size-1:0] data_out_temp;

clocking data_drive_cb @(negedge clk);
    output data_in;
endclocking
 
clocking monitor_data_in @(posedge clk);
    input data_in;
endclocking

clocking monitor_data_out @(posedge clk);
    input data_out;
endclocking


endinterface