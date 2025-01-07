// Test bench for YP_uart_tx modeule
// Created By : Yakir Peretz
`resetall
`timescale 1ns/1ps

module YP_uart_tx_tb#(
    parameter DATA_WIDTH    = 8
);

logic clk;
logic rstn;
logic tx_start;
logic [DATA_WIDTH-1:0] data_in;
logic tx_done;
logic tx_data;
int unsigned time2start;
YP_uart_tx  #(.DATA_WIDTH(DATA_WIDTH)) uart_tx (
    .i_clk(clk),
    .i_rstn(rstn),
    .i_tx_start(tx_start),
    .i_data_in(data_in),
    .o_tx_done(tx_done),
    .o_tx_data(tx_data)
);

initial begin
    clk = 0;
    forever begin
        #10ns clk = ~clk;
    end 
end 

initial begin
    time2start = $urandom_range(10,100);
    $display("Time2start = %u",time2start);
    rstn <= 1'b0;
    tx_start <= 1'b0;
    #100;
    rstn <= 1'b1;
    #time2start;
    data_in <= $urandom_range(0, 255);
    $display("Data in = %h(%8b)",data_in,data_in);
    tx_start <= 1'b1;
    @(posedge tx_done);
    data_in <= $urandom_range(0, 255);
    $display("Data in = %h(%8b)",data_in,data_in);
    @(posedge tx_done);
    data_in <= $urandom_range(0, 255);
    $display("Data in = %h(%8b)",data_in,data_in);
    @(posedge tx_done);
    tx_start <= 1'b0;
    #200;
    data_in <= $urandom_range(0, 255);
    $display("Data in = %h(%8b)",data_in,data_in);
    tx_start <=1;
    @(posedge tx_done);
    tx_start <=0;
    #500;
    $stop;
    $finish;
end
endmodule
