// Synchronous FIFO virtual sequencer
// Create By: Yakir Peretz


class fifo_virtual_sequencer extends uvm_sequencer;

    `uvm_component_utils(fifo_virtual_sequencer)
    read_sequencer rd_seqr;
    write_sequencer wr_seqr;

    extern function new (string name = "fifo_virtual_sequencer", uvm_componenct parent = null);

endclass

function fifo_virtual_sequencer::new(string name = "fifo_virtual_sequencer", uvm_componenct parent = null);
    super.new(name,parent);
endfunction