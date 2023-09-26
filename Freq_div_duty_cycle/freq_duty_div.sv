// freq and duty div module
// divide the frequency and adjast the duty
// Create By: Yakir Peretz

`resetall
`timescale 1ps/1ps
module Freq_Duty_div #( // Parameters
parameter Count_bits = 16
)
( // I/O Signals
input i_clk,
input [Count_bits-1:0] i_div_count,
input [Count_bits-1:0] i_duty_count,
input i_rstn,
input i_enable,
output wire o_div_clk
);
// internal signals
logic clk_out;
wire no_div;
wire clr_div_counter;
logic [Count_bits-1:0] div_counter;

assign no_div = ~i_enable;
assign clr_div_counter = div_counter == i_div_count;
assign duty_done = div_counter == i_duty_count;

always_ff @(posedge i_clk)
begin: freq_dic_counter
    if(!i_rstn || !i_enable)
        div_counter <= 0;
    else if (clr_div_counter) 
        div_counter <= 0;
    else
        div_counter <= div_counter + 1;
end 

always_ff @(posedge i_clk) begin
   if(!i_rstn || !i_enable)
        clk_out <= 0;
    else if (clr_div_counter || duty_done)
        clk_out <= ~clk_out;
end


assign o_div_clk = no_div == 1 ? i_clk : clk_out;

endmodule