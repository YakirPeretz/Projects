// Synchronous FIFO write sequencer
// Create By: Yakir Peretz

class fifo_write_sequencer #(type REQ = write_fifo_item, RSP = REQ) extends uvm_sequencer;
    `uvm_component_utils (fifo_write_sequencer)

    extern function new (string name = "fifo_write_sequencer",uvm_component parent = null);

endclass

function fifo_write_sequencer::new(string name = "fifo_write_sequencer",uvm_component parent = null);
    super.new(name,parent);

endfunction