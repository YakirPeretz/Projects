// Synchronous FIFO read agent
// Create By: Yakir Peretz

class fifo_read_agent extends uvm_agent;

    `uvm_component_utils(fifo_read_agent)
    fifo_read_monitor m_read_mon;
    fifo_read_driver m_read_driver;
    fifo_read_sequencer #(read_fifo_item) m_read_sequencer;

    extern function new (string name = "fifo_read_agent", uvm_componenct = null);
    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass

function fifo_read_agent::new(string name = "fifo_read_agent", uvm_componenct = null);
    super.new(name.parent);

endfunction

function void fifo_read_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(get_is_active()) begin
        m_read_driver = fifo_read_driver::type_id::create("m_read_driver",this);
        m_read_sequencer = fifo_read_sequencer::type_id::create("m_read_sequencer",this);
    end 
    m_read_mon = fifo_read_monitor::type_id::create("m_read_mon",this);

endfunction

function void fifo_read_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active()) begin
        m_read_driver.seq_item_port.coonect(m_read_sequencer.seq_item_export);
    end

endfunction