// UART tx module
// Create By: Yakir Peretz

`resetall
`timescale 1ns/1ps
module YP_uart_tx #( // Parameters
    parameter DATA_WIDTH    = 8
)
( // I/O Signals
input logic i_clk,
input logic i_rstn,
input logic i_tx_start,
input logic [DATA_WIDTH-1:0] i_data_in,
output logic o_tx_done,
output logic o_tx_data
);

parameter CNT_WIDTH = $clog2(DATA_WIDTH);

typedef enum logic [2:0] {
    S_IDLE  = 3'b000,
    S_START  = 3'b001,
    S_DATA_DRV = 3'b010,
    S_PARITY = 3'b011,
    S_STOP = 3'b100

} e_uart_tx_state;
e_uart_tx_state       tx_state,next_tx_state;

logic [DATA_WIDTH-1:0] data_in_d;
logic start_bit_done;
logic data_drv_done;
logic parity_bit;
logic parity_drv_done;
logic stop_bit_done;
logic data_out;
// logic [1:0] stop_bits_cnt;
logic [CNT_WIDTH-1:0] drv_bits_cnt;
// logic start_cnt_stop_bits;
// State machine
always_comb 
begin: fsm_comb_block
    next_tx_state = tx_state;
    unique case (tx_state)
        S_IDLE      :   if(i_tx_start)          next_tx_state = S_START;
        S_START     :   if(start_bit_done)      next_tx_state = S_DATA_DRV;
        S_DATA_DRV  :   begin 
                        if(data_drv_done)       next_tx_state = S_PARITY;
                        else if(data_drv_done)  next_tx_state = S_STOP;
                        end 
        S_PARITY    :   if(parity_drv_done)     next_tx_state = S_STOP;
        S_STOP      :   if(stop_bit_done)       next_tx_state = S_IDLE;
    endcase
end

always_ff @(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn)
        tx_state <= S_IDLE;
    else 
        tx_state <= next_tx_state;
end

always_ff @(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn)
        parity_drv_done <= 1'b0;
    else 
        parity_drv_done <= data_drv_done;
end

always_ff @(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn)
        stop_bit_done <= 1'b0;
    else 
        stop_bit_done <= parity_drv_done;
end

always_ff @(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn)
        start_bit_done <= 1'b0;
    else 
        start_bit_done <= i_tx_start;
end
// sample data at the start of drive mode
always_ff @(posedge i_clk) begin
    if(i_tx_start)
        data_in_d <= i_data_in;
end 

always_ff @(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn)
        drv_bits_cnt <= 0;
    else if(tx_state == S_START)
        drv_bits_cnt <= 0;
    else if(tx_state == S_DATA_DRV)
        drv_bits_cnt <= drv_bits_cnt + 1'b1;
end 

always_ff @(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn)
        o_tx_done <= 1'b0;
    else 
        o_tx_done <= stop_bit_done;
end

assign data_drv_done = drv_bits_cnt == (DATA_WIDTH-1);
assign parity_bit = ^(data_in_d);
assign data_out = data_in_d[drv_bits_cnt];

// tx drive
assign o_tx_data =  (tx_state == S_IDLE) ? 1'b1 :
                    (tx_state == S_START) ? 1'b0 : 
                    (tx_state == S_DATA_DRV) ? data_out :
                    (tx_state == S_PARITY) ? parity_bit :
                    (tx_state == S_STOP)   ? 1'b1: 1'b1;

endmodule