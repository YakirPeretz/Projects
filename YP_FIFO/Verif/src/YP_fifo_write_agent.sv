// Synchronous FIFO write agent
// Create By: Yakir Peretz

class fifo_write_agent extends uvm_agent;

    `uvm_component_utils(fifo_write_agent)
    fifo_write_monitor m_write_mon;
    fifo_write_driver m_write_driver;
    fifo_write_sequencer #(write_fifo_item) m_write_sequencer;

    extern function new (string name = "fifo_write_agent", uvm_component parent= null);
    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass

function fifo_write_agent::new(string name = "fifo_write_agent", uvm_component parent= null);
    super.new(name,parent);

endfunction

function void fifo_write_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(get_is_active()) begin
        m_write_driver = fifo_write_driver::type_id::create("m_write_driver",this);
        m_write_sequencer = m_write_sequencer::type_id::create("m_write_sequencer",this);
    end 
    m_write_mon = fifo_write_monitor::type_id::create("m_write_mon",this);

endfunction

function void fifo_write_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active()) begin
        m_write_driver.seq_item_port.coonect(m_write_sequencer.seq_item_export);
    end

endfunction