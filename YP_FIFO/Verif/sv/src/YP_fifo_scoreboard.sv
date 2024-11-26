// Synchronous FIFO reference model
// Create By: Yakir Peretz

class fifo_scoreboard #(int unsigned FIFO_DEPTH = 32,int unsigned DATA_WIDTH = 8) extends uvm_scorenoard;

    `uvm_analysis_imp_decl(_write_fifo)
    `uvm_analysis_imp_decl(_read_fifo)

    uvm_analysis_imp_write_fifo  #(write_fifo_item, fifo_scoreboard) m_write_analysis_imp;
    uvm_analysis_imp_read_fifo #(read_fifo_item, fifo_scoreboard) m_read_analysis_imp;
    bit [DATA_WIDTH-1:0] fifo_queue [$:FIFO_DEPTH];
    int unsigned num_writes = 0;
    int unsigned num_reads = 0;
    `uvm_component_utils(fifo_scoreboard)


    extern function new (string name = "fifo_scoreboard" , uvm_component parent = null);
    extern function void build_phase (uvm_phase phase);
    extern function void check_phase(uvm_phase phase);
    extern virtual function void write_write_fifo(write_fifo_item wr_fifo_item);
    extern virtual function void write_read_fifo(read_fifo_item rd_fifo_item);
    extern function void fifo_data_cmp(bit [DATA_WIDTH-1:0] data_out);
endclass

function fifo_scoreboard::new(string name = "fifo_scoreboard" , uvm_component parent = null);
    super.new(name,parent);
endfunction

function void fifo_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_write_analysis_imp = new("m_write_analysis_imp",this);
    m_read_analysis_imp = new("m_read_analysis_imp",this);
endfunction


virtual function void fifo_scoreboard::write_write_fifo(write_fifo_item wr_fifo_item);
    write_fifo_item wr_fifo_item_sb;
    bit [DATA_WIDTH-1:0] fifo_data_in;
    $cast(wr_fifo_item_sb,wr_fifo_item);
    fifo_data_in = wr_fifo_item_sb.wr_data;
    if(fifo_queue.size() > FIFO_DEPTH) begin
        `uvm_error(get_type_name(),$sformatf("Trying to write to full fifo. fifo_queue size = %d",fifo_queue.size()));
    end
    else begin
        num_writes++;
        fifo_queue.push_back(fifo_data_in);
        `uvm_info(get_type_name(),$sformatf("Add Data to fifo_queue: 0x%x",fifo_data_in),UVM_HIGH);
    end
endfunction

virtual function void fifo_scoreboard::write_read_fifo(read_fifo_item rd_fifo_item);
    read_fifo_item rd_fifo_item_sb;
    bit [DATA_WIDTH-1:0] fifo_data_out;
    $cast(rd_fifo_item_sb,rd_fifo_item);
    fifo_data_out = rd_fifo_item_sb.rd_data;
    if(fifo_queue.size() == 0) begin
        `uvm_error(get_type_name(),$sformatf("Trying to read from empty fifo. fifo_queue size = %d",fifo_queue.size()));
    end
    else begin
        num_reads++;
        fifo_data_cmp(fifo_data_out);
    end

endfunction

function void fifo_scoreboard::fifo_data_cmp(bit [DATA_WIDTH-1:0] data_out);
    bit [DATA_WIDTH-1:0] exp_data;
    exp_data = fifo_queue.pop_front();
    if(fifo_data != data_out) begin
        `uvm_info(get_type_name(),$sformatf("SB Miscompare - exp data (0x%x) mismatch act(0x%x)",exp_data,data_out),UVM_HIGH);
    end 

endfunction

function void fifo_scoreboard::check_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Checking write and read",UVM_HIGH);
    if(num_reads >= num_writes && fifo_queue.size()>0) begin
        `uvm_error(get_type_name(),$sformatf("Reads are equal or greater than writes but fifo not empty! fifo_queue size = %d, num_reads = %d,num_writes = %d",fifo_queue.size(),num_reads,num_writes));
    end
    else if (num_reads < num_writes && fifo_queue.size() == 0) begin
        `uvm_error(get_type_name(),$sformatf("More writes than read but fifo is empty! fifo_queue size = %d, num_reads = %d,num_writes = %d",fifo_queue.size(),num_reads,num_writes));
    end
    `uvm_info(get_type_name(),"Good fifo behaviour!",UVM_LOW);

endfunction