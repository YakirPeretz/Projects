// Synchronous FIFO verification package
// Create By: Yakir Peretz

`include "YP_sync_fifo_if.svi"

package fifo_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "YP_fifo_classlib.sv"
    `include "YP_fifo_read_monitor.sv"
    `include "YP_fifo_write_monitor.sv"
    `include "YP_fifo_read_sequencer.sv"
    `include "YP_fifo_write_sequencer.sv"
    `include "YP_fifo_sequence_lib.sv"
    `include "YP_fifo_virtual_sequencer.sv"
    `include "YP_fifo_virtual_seqs_lib.sv"
    `include "YP_fifo_read_driver.sv"
    `include "YP_fifo_write_driver.sv"
    `include "YP_fifo_read_agent.sv"
    `include "YP_fifo_write_agent.sv"
    `include "YP_fifo_scoreboard.sv"
    `include "YP_fifo_env.sv"
endpackage