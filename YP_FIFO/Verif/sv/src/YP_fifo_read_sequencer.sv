// Synchronous FIFO read sequencer
// Create By: Yakir Peretz

class read_sequencer #(type REQ = read_fifo_item, RSP = REQ) extends uvm_sequencer;
    `uvm_component_utils (read_sequencer)

    extern function new (string name = "read_sequencer",uvm_component parent = null);

endclass

function read_sequencer::new(string name = "read_sequencer",uvm_component parent = null);
    super.new(name,parent);

endfunction