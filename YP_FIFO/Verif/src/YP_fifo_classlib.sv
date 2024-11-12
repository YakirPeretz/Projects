// Synchronous FIFO verification classlib
// Create By: Yakir Peretz

class write_fifo_item#(int unsigned DATA_WIDTH = 8) extends uvm_sequence_item;
    rand bit [DATA_WIDTH-1:0] wr_data;
    rand int unsigned wait_time2write;

    constraint wait_time_c {
        wait_time2write inside {[0:100]};
    }

    `uvm_object_utils_begin(write_fifo_item)
        `uvm_field_int(wr_data,UVM_ALL_ON | UVM_HEX )
        `uvm_field_int(wait_time2write,UVM_ALL_ON | UVM_DEC )
    `uvm_object_utils_end

    extern funtion new (string name = "write_fifo_item");
    
endclass

function write_fifo_item::new(string name "write_fifo_item");
    super.new(name);
endfunction


class read_fifo_item#(int unsigned DATA_WIDTH = 8) extends uvm_sequence_item;

    rand int unsigned wait_time2read;
    bit [DATA_WIDTH-1:0] rd_data;

    constraint wait_time_c {
        wait_time2read inside {[0:100]};
    }


    `uvm_object_utils_begin(read_fifo_item)
        `uvm_field_int(rd_data,UVM_ALL_ON | UVM_HEX )
        `uvm_field_int(wait_time2read,UVM_ALL_ON | UVM_DEC )
    `uvm_object_utils_end

    extern funtion new (string name = "read_fifo_item");
endclass
function read_fifo_item::new(string name "read_fifo_item");
    super.new(name);
endfunction