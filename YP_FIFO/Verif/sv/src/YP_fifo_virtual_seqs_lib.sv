// Synchronous FIFO virtual sequences
// Create By: Yakir Peretz

class base_fifo_seq extends uvm_sequence;

    `uvm_object_utils(base_fifo_seq)
    `uvm_declare_p_sequencer(fifo_virtual_sequencer)
    base_write_seq write_seq;
    base_read_seq read_seq;

    extern function new (string name = "base_fifo_seq");
    extern task pre_start();
    extern task post_start();
    extern virtual task body();

endclass

task base_fifo_seq::pre_start();
    uvm_phase phase;
    phase = get_starting_phase();
    if (phase != null) begin
        phase.raise_objection(this, get_type_name());
        `uvm_info(get_type_name(), "raise objection", UVM_HIGH)
    end
  endtask

task post_start();
    uvm_phase phase;
    phase = get_starting_phase();
    if (phase != null) begin
        phase.drop_objection(this, get_type_name());
        `uvm_info(get_type_name(), "drop objection", UVM_HIGH)
    end
endtask

virtual task base_fifo_seq::body();

    `uvm_info(get_type_name(), "Executing base_fifo_seq", UVM_LOW )
    fork
        begin
            `uvm_do_on(write_seq, p_sequencer.wr_seqr)
        end 
        begin
            `uvm_do_on(read_seq, p_sequencer.rd_seqr)
        end 
    join

endtask