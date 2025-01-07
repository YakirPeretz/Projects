// Synchronous FIFO module
// Create By: Yakir Peretz

`resetall
`timescale 1ns/1ps
module YP_sync_fifo #( // Parameters
    parameter DATA_WIDTH    = 8,
    parameter FIFO_DEPTH    = 32
)
( // I/O Signals
input logic i_clk,
input logic i_rstn,
input logic i_rd_en,
input logic i_wr_en,
input logic [DATA_WIDTH-1:0] i_data_in,
output logic [DATA_WIDTH-1:0] o_data_out,
output logic o_full,
output logic o_empty
);

parameter WR_RD_WIDTH = $clog2(FIFO_DEPTH);
reg [DATA_WIDTH-1:0] yp_fifo[FIFO_DEPTH];
logic [WR_RD_WIDTH:0] wr_ptr;
logic [WR_RD_WIDTH:0] rd_ptr;
logic full;
logic empty;
logic ptr_wrap;
logic en_wr;
logic en_rd;

always_ff @(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        o_data_out <= 0;
    end 
end

assign en_wr = ~full & i_wr_en;

always_ff @(posedge i_clk) begin
    if(en_wr) begin
        yp_fifo[wr_ptr[WR_RD_WIDTH-1:0]] <= i_data_in;
    end 
end 
always_ff @(posedge i_clk) begin
    if(en_wr) begin
        wr_ptr = wr_ptr + 1;
    end 
end 

assign en_rd = ~empty & i_rd_en;
always_ff @(posedge i_clk) begin
    if(en_rd) begin
        o_data_out <= yp_fifo[rd_ptr[WR_RD_WIDTH-1:0]];
    end 
end 
always_ff @(posedge i_clk) begin
    if(en_rd) begin
        rd_ptr <= rd_ptr + 1;
    end 
end 

assign ptr_wrap = rd_ptr[WR_RD_WIDTH] ^ wr_ptr[WR_RD_WIDTH]; // help bit to indicate wrap around of the pointers
assign empty = wr_ptr == rd_ptr;
assign o_empty = empty;

assign full = ptr_wrap & (rd_ptr[WR_RD_WIDTH-1:0] == wr_ptr[WR_RD_WIDTH-1:0]);

assign o_full = full;



endmodule