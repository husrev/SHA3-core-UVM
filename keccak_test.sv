class keccak_test extends uvm_test;
 `uvm_component_utils(keccak_test)
   
   keccak_env env;
   keccak_sequence keccak_seq;

   function new(string name, uvm_component parent);
     super.new(name, parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
     env = keccak_env::type_id::create("env", this);
     keccak_seq = keccak_sequence::type_id::create("keccak_seq");
   endfunction

   function void end_of_elaboration_phase(uvm_phase phase);
     print();
   endfunction
   
   
   task run_phase(uvm_phase phase);
     
     // We raise objection to keep the test from completing
     phase.raise_objection(this);
     `uvm_warning("", "keccak test!")
     #10;
    
     keccak_seq.start(env.agent.sequencer);
     
     #1000;
     // We drop objection to allow the test to complete
     phase.drop_objection(this);
   endtask

endclass
 
