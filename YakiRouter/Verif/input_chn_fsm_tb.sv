// Test bench for input channel fsm
// Created By : Yakir Peretz
`resetall
`timescale 1ps/1ps

import verif_env_pkg::*;

module in_chn_fsm_tb#(
    parameter data_size          = 8,
    parameter pkt_length_bits    = 5,
    parameter pkt_addr_bits      = data_size-pkt_length_bits // 8-5 = 3

);

chn_vif m_vif();
int total_errors = 0;
InChannel_fsm  #(.data_size(data_size),.pkt_length_bits(pkt_length_bits),.pkt_addr_bits(pkt_addr_bits)) In_chn_fsm (
    // inputs
    .i_clk(m_vif.clk),
    .i_ch_en(m_vif.chn_en),
    .i_data_in(m_vif.data_in),
    .i_rstn(m_vif.rstn),
    .i_clr_errors(m_vif.clr_errors),
// outputs
    .o_busy(m_vif.busy),
    .o_error(m_vif.error),
    .o_data2fifo_out(m_vif.data_out),
    .o_pkt_to_fifo_en0(m_vif.pkt_to_fifo_en0),
    .o_pkt_to_fifo_en1(m_vif.pkt_to_fifo_en1),
    .o_pkt_to_fifo_en2(m_vif.pkt_to_fifo_en2),
    .o_pkt_to_fifo_en3(m_vif.pkt_to_fifo_en3)
);

assign m_vif.pkt_address = In_chn_fsm.pkt_addr;
always begin
  #100ps m_vif.clk = ~m_vif.clk;
end

initial begin
  chn_in_fsm_test test1;
  test1 = new;
  test1.m_chn_in_env.m_chn_vif = m_vif;
  m_vif.rstn <= 0;
  m_vif.clk <= $urandom_range(0, 1);
  m_vif.chn_en <= 0;
  m_vif.data_in <= 'h0;
  m_vif.clr_errors <= 0;
  repeat (10) @(posedge m_vif.clk);
  m_vif.rstn <= 1;
  repeat (5) @(posedge m_vif.clk);
  test1.run();
  repeat (10) @(posedge m_vif.clk);
  total_errors = test1.m_chn_in_env.m_chn_in_scb.num_of_errors + m_vif.num_of_errors;
  $display("Num of errors = %0d. scb errors = %0d. vif errors = %0d",total_errors,test1.m_chn_in_env.m_chn_in_scb.num_of_errors,m_vif.num_of_errors);
  $stop;
end

endmodule
