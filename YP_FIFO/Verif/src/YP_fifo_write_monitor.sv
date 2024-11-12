// Synchronous FIFO write monitor
// Create By: Yakir Peretz

class fifo_write_monitor#(int unsigned DATA_WIDTH = 8) extends uvm_monitor;

    `uvm_component_utils(fifo_write_monitor)
    virtual YP_sync_fifo_if vif;
    uvm_analysis_port #(write_fifo_item)   mon_analysis_port;
    extern function new (string name = "fifo_write_monitor",uvm_component parent = null);
    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    
endclass

function fifo_write_monitor::new(string name = "fifo_write_monitor",uvm_component parent = null);
    supuer.new(name,parent);
endfunction

function void fifo_write_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_analysis_port = new ("mon_analysis_port", this);
    if(! uvm_config_db#(YP_sync_fifo_if)::get(this, "", vif, vif)) 
    begin
        `uvm_fatal(get_name(), "YP_sync_fifo_if is missing from config_db")
        
    end 
endfunction

function void fifo_write_monitor::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction

task fifo_write_monitor::run_phase(uvm_phase phase);

    wr_fifo_item = write_fifo_item::type_id::create("wr_fifo_item",this);
    super.run_phase(phase);
    forever 
    begin
        @(posedge vif.i_wr_en && !vif.o_full);
        wr_fifo_item.wr_data = vif.i_data_in;
        `uvm_info(get_type_name(),"Write data item = %s",wr_fifo_item.sprint());
        mon_analysis_port.write(wr_fifo_item);
    end


endtask