// Synchronous FIFO testbench bind
// Create By: Yakir Peretz

bind YP_sync_fifo_top YP_sync_fifo_if vif(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_rd_en(i_rd_en),
    .i_wr_en(i_wr_en),
    .i_data_in(i_data_in),
    .o_data_out(o_data_out),
    .o_full(o_full),
    .o_empty(o_empty)
);