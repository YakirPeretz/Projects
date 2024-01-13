// input channel interface
// Created By : Yakir Peretz

`resetall
`timescale 1ps/1ps


interface chn_vif#(
    parameter data_size          = 8,
    parameter pkt_length_bits    = 5,
    parameter pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3
);

logic clk;
logic [data_size-1:0] data_in;
logic chn_en;
logic rstn;
logic clr_errors;
logic [data_size-1:0] data_out;
logic busy;
logic error;
logic pkt_to_fifo_en0;
logic pkt_to_fifo_en1;
logic pkt_to_fifo_en2;
logic pkt_to_fifo_en3;


logic [pkt_addr_bits -1 : 0] pkt_address;
logic [3:0] exp_en_change;
logic [3:0] enables_mutex;
bit stable_chk_en = 1'b0;
int num_of_errors = 0;
assign enables_mutex = {pkt_to_fifo_en3,pkt_to_fifo_en2,pkt_to_fifo_en1,pkt_to_fifo_en0};

always @(posedge chn_en)
begin
    @(posedge clk);
    #0.1;
    exp_en_change[pkt_address] = 1'b1;
end 

always @(posedge rstn)
begin
    stable_chk_en = 1'b1;
end 

always @(negedge rstn)
begin
    exp_en_change = 4'hf;
end 

`define CHECK_FIFO_EN_LOW(ind)\
always @(negedge chn_en) begin\
    repeat (3)\
        @(posedge clk);\
    if(pkt_to_fifo_en``ind`` == 1'b1) begin\
        $display("********* T = %0d : ERROR! pkt_to_fifo_en%0d high while not expected.",$time,``ind``);\
        num_of_errors +=1;\
    end\
end

`define CHECK_FIFO_EN_STABLE(ind)\
always @(posedge pkt_to_fifo_en``ind``) begin\
    #1;\
    if(exp_en_change[``ind] != 1'b1 && stable_chk_en) begin\
        $display("********* T = %0d : ERROR! pkt_to_fifo_en%0d changed while not expected.",$time,``ind``);\
        num_of_errors +=1;\
    end\
end
`CHECK_FIFO_EN_LOW(0)
`CHECK_FIFO_EN_LOW(1)
`CHECK_FIFO_EN_LOW(2)
`CHECK_FIFO_EN_LOW(3)
`CHECK_FIFO_EN_STABLE(0)
`CHECK_FIFO_EN_STABLE(1)
`CHECK_FIFO_EN_STABLE(2)
`CHECK_FIFO_EN_STABLE(3)

property MUTEX_EN(clk,rstn,enables);
    disable iff (!rstn)
    @(posedge clk) $countones(enables) <=1;
endproperty

FIFO_ENABLES_MUTEX : assert property (MUTEX_EN(clk,rstn,enables_mutex)) else begin
    $display("********* T = %0d : FIFO_ENABLES_MUTEX: more then one enables is active. enables_mutex = %b",$time,enables_mutex);
    num_of_errors +=1;
    end 

endinterface