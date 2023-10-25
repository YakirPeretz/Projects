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
    .o_data_out(m_vif.data_out),
    .o_pkt_to_fifo_en(m_vif.pkt_to_fifo_en)
);

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
  $stop;
end

endmodule
