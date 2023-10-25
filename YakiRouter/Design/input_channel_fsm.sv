// Input channel fsm
// Create By: Yakir Peretz

`resetall
`timescale 1ps/1ps
module InChannel_fsm #( // Parameters
parameter data_size          = 8,
parameter pkt_length_bits    = 5,
parameter pkt_addr_bits      = data_size-pkt_length_bits// 8-5 = 3
)
( // I/O Signals
input logic i_clk,
input logic i_ch_en,
input logic [data_size-1:0] i_data_in,
input logic i_rstn,
input logic i_clr_errors,
output logic o_busy,
output logic o_error,
output logic o_pkt_to_fifo_en,
output logic [data_size-1:0] o_data_out

);

typedef enum logic [1:0] {
    S_IDLE  = 2'b00,
    S_SYNC  = 2'b01,
    S_READ  = 2'b10,
    S_CHECK = 2'b11
} e_input_channel_state;

e_input_channel_state       chn_in_state,next_chn_in_state;
logic                       ch_en_d;
logic                       read_pkt_done;
logic                       pkt_chk_done;
logic                       start_read_pkt_pulse;
logic [pkt_length_bits:0] pkt_read_byte_cnt;
logic                       read_pkt_en;
logic [pkt_addr_bits-1:0]   pkt_addr;
logic [pkt_length_bits-1:0] pkt_length;
logic [data_size-1:0]       pkt_data;
logic [data_size-1:0]       pkt_data_d;
logic [data_size-1:0]       pkt_parity;
logic [data_size-1:0]       pkt_parity_calc;
logic                       length_error;
logic                       length_error_identication;
logic                       parity_error;
logic                       clr_legnth_err;
logic                       clr_parity_err;
logic                       clr_errors_d;
logic                       clr_errors_pulse;
logic                       length_overflow;
logic                       addr_error;
logic                       clr_addr_error;
logic                       read_pkt_en_d;
logic                       read_pkt_done_d;

always_comb 
begin: fsm_comb_block
    next_chn_in_state = chn_in_state;
    unique case (chn_in_state)
        S_IDLE      :   if(i_ch_en)     next_chn_in_state = S_SYNC;
        S_SYNC      :   if(ch_en_d)     next_chn_in_state = S_READ;
        S_READ      :   if(read_pkt_done)   next_chn_in_state = S_CHECK;
        S_CHECK     :   if(pkt_chk_done)    next_chn_in_state = S_IDLE;
    endcase
end

always_ff @(posedge i_clk or negedge i_rstn) begin
    if(!i_rstn)
        chn_in_state <= S_IDLE;
    else 
        chn_in_state <= next_chn_in_state;
end

always_ff @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn)
        ch_en_d <= 1'b0;
    else
        ch_en_d <= i_ch_en;
end 

always_ff @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn)
        clr_errors_d <= 1'b0;
    else
        clr_errors_d <= i_clr_errors;
end 

always_comb begin
    start_read_pkt_pulse = i_ch_en &(~ch_en_d);
    clr_errors_pulse = i_clr_errors &(~clr_errors_d);
    clr_legnth_err = start_read_pkt_pulse | clr_errors_pulse;
    clr_parity_err = start_read_pkt_pulse | clr_errors_pulse;
    clr_addr_error = start_read_pkt_pulse | clr_errors_pulse;
    o_busy = read_pkt_en | chn_in_state== S_CHECK;
    o_pkt_to_fifo_en = read_pkt_en_d;
    o_error = addr_error | parity_error | length_error;
    read_pkt_done = (pkt_length +1 == pkt_read_byte_cnt) & ~i_ch_en; // Done when reading all the pkt and enable low
    pkt_chk_done = read_pkt_done_d;
    length_error_identication = length_overflow | (read_pkt_done && pkt_length +1 != pkt_read_byte_cnt); // error idendication bit
end

always_ff @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn)
        read_pkt_done_d <= 1'b0;
    else
        read_pkt_done_d <= read_pkt_done;
end 

always_ff @( posedge i_clk or negedge i_rstn ) begin
    if(!i_rstn)
        read_pkt_en <= 1'b0;
    else if (start_read_pkt_pulse)
        read_pkt_en <= 1'b1;
    else if (read_pkt_done || ~i_ch_en)
        read_pkt_en <= 1'b0;
end 

always_ff @( posedge i_clk or negedge i_rstn ) begin 
    if(!i_rstn)
        pkt_read_byte_cnt <= 'h0;
    else if (start_read_pkt_pulse || pkt_chk_done) 
        pkt_read_byte_cnt <= 'h0;
    else if (read_pkt_en)
        pkt_read_byte_cnt <= pkt_read_byte_cnt + 1'b1;
end

always_ff @( posedge i_clk or negedge i_rstn ) begin
    if(!i_rstn)
        length_overflow <= 1'b0;
    else if (start_read_pkt_pulse) 
        length_overflow <= 1'b0;
    else if (read_pkt_en && pkt_read_byte_cnt[5] == 1'b1 && pkt_read_byte_cnt[0] == 1'b1)
        length_overflow <= 1'b1;
end

// packet header,payload and parity
always_ff @( posedge i_clk or negedge i_rstn ) begin
    if (!i_rstn)
        begin
        pkt_data <= 'h0;
        pkt_length <= 'h0;
        pkt_addr <= 'h0;
        pkt_parity <= 'h0;
        end
    else if (read_pkt_en)
        begin
            pkt_data <= i_data_in;
        if(read_pkt_en && pkt_read_byte_cnt == 0)
        begin
            pkt_length <= i_data_in[data_size-1:data_size-pkt_length_bits];
            pkt_addr <= i_data_in[pkt_addr_bits-1:0];
        end 
        else if(read_pkt_en && pkt_read_byte_cnt == pkt_length)
        begin
            pkt_parity <= i_data_in;
        end 
    end
    else if (!read_pkt_en)
        pkt_data <='h0;
end 

always_ff @( posedge i_clk or negedge i_rstn ) begin
    if (!i_rstn)
        read_pkt_en_d <= 'h0;
    else 
        read_pkt_en_d <= read_pkt_en;
end 

always_ff @( posedge i_clk or negedge i_rstn ) begin
    if (!i_rstn)
        pkt_data_d <= 'h0;
    else if (read_pkt_en_d)
        pkt_data_d <= pkt_data;
    else if (!read_pkt_en_d)
        pkt_data_d <='h0;
end 

always_comb begin
    o_data_out = pkt_data_d;
end 

always_ff @( posedge i_clk or negedge i_rstn )  begin
    if (!i_rstn)
        addr_error <= 1'b0;
    else if (pkt_addr>3)
        addr_error <= 1'b1;
    else if (clr_addr_error)
        addr_error <='h0;
end 


// parity
always_ff @( posedge i_clk or negedge i_rstn ) begin
    if (!i_rstn)
        pkt_parity_calc <= 'h0;
    else if (read_pkt_en && pkt_read_byte_cnt <= pkt_length)
        pkt_parity_calc <= pkt_parity_calc ^ pkt_data;
    else if (!read_pkt_en_d)
        pkt_parity_calc <='h0;
end 

always_ff @( posedge i_clk or negedge i_rstn ) begin
    if (!i_rstn)
        parity_error <= 'h0;
    else if ((pkt_parity != pkt_parity_calc) && read_pkt_done)
        parity_error <= 1'b1;
    else if (clr_parity_err)
        parity_error <='h0;
end 

always_ff @( posedge i_clk or negedge i_rstn ) begin
    if (!i_rstn)
        length_error <= 1'b0;
    else if (length_error_identication)
        length_error <= 1'b1;
    else if (clr_legnth_err)
        length_error <='h0;
end 



endmodule