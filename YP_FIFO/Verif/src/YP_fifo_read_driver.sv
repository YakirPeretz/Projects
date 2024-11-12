// Synchronous FIFO write driver
// Create By: Yakir Peretz

class fifo_read_driver#(int unsigned DATA_WIDTH = 8) extends uvm_driver #(read_fifo_item);

    `uvm_component_utils(fifo_read_driver)
    virtual YP_sync_fifo_if vif;

    extern function new (string name = "fifo_read_driver",uvm_component parent = null);
    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    
endclass

function fifo_read_driver::new(string name = "fifo_read_driver",uvm_component parent = null);
    supuer.new(name,parent);
endfunction

function void fifo_read_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(! uvm_config_db#(YP_sync_fifo_if)::get(this, "", vif, vif)) 
    begin
        `uvm_fatal(get_name(), "YP_sync_fifo_if is missing from config_db")
        
    end 
endfunction

function void fifo_read_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction

task fifo_read_driver::run_phase(uvm_phase phase);

    read_fifo_item rd_fifo_item;
    super.run_phase(phase);
    forever 
    begin
        `uvm_info(get_type_name(),"waiting for item...");
        seq_item_port.get_next_item(rd_fifo_item);
        repeat (rd_item.wait_time2read)
            @(posedge vif.i_clk);
        vif.i_rd_en <= 1'b1;
        @(posedge vif.i_clk);
        vif.i_rd_en <= 1'b0;
        seq_item_port.item_done();
    end


endtask