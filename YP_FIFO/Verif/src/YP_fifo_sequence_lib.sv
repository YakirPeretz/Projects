// Synchronous FIFO sequence lib
// Create By: Yakir Peretz

class base_write_seq extends uvm_sequence;
    `uvm_object_utils(base_write_seq);
    rand int unsigned num_of_writes;
    write_fifo_item wr_fifo_item;

    constraint num_writes_c { num_of_writes inside {[100:300]}};

    extern function new (string name = "base_write_seq");
    extern task body();

endclass

function base_write_seq::new(string name = "base_write_seq");
    super.new(name);
endfunction

task base_write_seq::body();
    for (int i = 0; i< num_of_writes; i++) begin
        `uvm_do(wr_fifo_item);
    end 
endtask

// sequence to ensure full fifo scenario
class fifo_full_seq extends uvm_sequence;
    `uvm_object_utils(fifo_full_seq);
    rand int unsigned num_of_writes;
    write_fifo_item wr_fifo_item;

    constraint num_writes_c { num_of_writes  == 300};

    extern function new (string name = "fifo_full_seq");
    extern task body();
    
endclass

function fifo_full_seq::new(string name = "fifo_full_seq");
    super.new(name);
endfunction

task fifo_full_seq::body();
    for (int i = 0; i< num_of_writes; i++) begin
        `uvm_do_with(wr_fifo_item,{wait_time2write inside {[0:2]};});
    end 
endtask


class base_read_seq extends uvm_sequence;
    `uvm_object_utils(base_read_seq);
    rand int unsigned num_of_reads;
    read_fifo_item rd_fifo_item;

    constraint num_reads_c { num_of_reads inside {[100:300]}};
    extern function new (string name = "base_read_seq");
    extern task body();

endclass

function base_read_seq::new(string name = "base_read_seq");
    super.new(name);
endfunction

task base_read_seq::body();
    for (int i = 0; i< num_of_writes; i++) begin
        `uvm_do(rd_fifo_item);
    end 
endtask

// sequence to ensure empty fifo scenario
class fifo_empty_seq extends uvm_sequence;
    `uvm_object_utils(fifo_empty_seq);
    rand int unsigned num_of_reads;
    read_fifo_item rd_fifo_item;

    constraint num_reads_c { num_of_reads inside == 300};
    extern function new (string name = "fifo_empty_seq");
    extern task body();

endclass

function fifo_empty_seq::new(string name = "fifo_empty_seq");
    super.new(name);
endfunction

task fifo_empty_seq::body();
    for (int i = 0; i< num_of_writes; i++) begin
        `uvm_do_with(rd_fifo_item,{wait_time2read inside {[0:2]};});
    end 
endtask