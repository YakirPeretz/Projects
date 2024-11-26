// Synchronous FIFO verification enviorment
// Create By: Yakir Peretz


class fifo_env #(int unsigned FIFO_DEPTH = 32,int unsigned DATA_WIDTH = 8) extends uvm_env;

    `uvm_component_utils(fifo_env)

    fifo_read_agent rd_agent;
    fifo_write_agent wr_agent;
    fifo_scoreboard fifo_sb;

    extern function new (string name = "fifo_env" , uvm_component parent = null);
    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);



endclass

function fifo_env::new(string name = "fifo_env" , uvm_component parent = null);
    super.new(name,parent);
endfunction

function void fifo_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    rd_agent = fifo_read_agent::type_id::create("rd_agent",this);
    wr_agent = fifo_write_agent::type_id::create("wr_agent",this);
    fifo_sb = fifo_scoreboard::type_id::create("fifo_sb",this);

endfunction

function void fifo_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rd_agent.m_read_mon.mon_analysis_port.connect(fifo_sb.m_read_analysis_imp);
    wr_agent.m_write_mon.mon_analysis_port.connect(fifo_sb.m_write_analysis_imp);

endfunction
