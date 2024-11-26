// Synchronous FIFO base test
// Create By: Yakir Peretz

class fifo_base_test extends uvm_test;

    `uvm_component_utils(fifo_base_test)
    fifo_env    m_fifo_env;
    base_fifo_seq fifo_vseq;
    virtual YP_sync_fifo_if vif;
    extern function new (string name = "fifo_base_test" , uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);
    extern task do_rst();
    extern task main_phase (uvm_phase phase);

endclass

function fifo_base_test::new(string name = "fifo_base_test" , uvm_component parent = null);
    super.new(name,parent);
endfunction

function void fifo_base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_fifo_env = fifo_env::type_id::create("m_fifo_env",this);
    fifo_vseq = base_fifo_seq::type_id::create("fifo_vseq",this);
    if(! uvm_config_db#(YP_sync_fifo_if)::get(this, "", vif, vif))  begin
        `uvm_fatal(get_name(), "YP_sync_fifo_if is missing from config_db")
    end 

endfunction

task fifo_base_test::reset_phase(uvm_phase phase);
    
    uvm_objection phase_done;
    phase_done = phase.get_objection();
    phase.raise_objection(this,"fifo_base_test reset phase raise objection");
    do_rst();
    phase.drop_objection(this,"fifo_base_test reset phase drop objection");
    `uvm_info(get_full_name(),"End of reset phase",UVM_LOW)

endtask

task fifo_base_test::do_rst();
    int unsigned num_clk_rst,num_clk_post_reset;
    num_clk_rst = $urandom_range(1, 5);
    num_clk_post_reset = $urandom_range(1,10);
    `uvm_info(get_type_name(),$sformatf("Start reset: rst_clk = %d,post_rst_clk = %d",num_clk_rst,num_clk_post_reset ),UVM_LOW)
    m_vif.i_rstn <= 1'b0;
    repeat(num_clk_rst)
        @(posedge vif.i_clk);
    m_vif.i_rstn <= 1'b1;
    repeat(num_clk_post_reset)
        @(posedge vif.i_clk);
endtask

task fifo_base_test::main_phase(uvm_phase phase);
    uvm_objection phase_done;
    phase_done = phase.get_objection();
    phase_done.set_drain_time(this,1000ns);
    phase.raise_objection(this,"fifo_base_test main_phase raise objection");
    fifo_vseq.start(null);
    phase.drop_objection(this,"fifo_base_test main_phase drop objection");
    `uvm_info(get_full_name(),"End of main_phase",UVM_LOW)

endtask