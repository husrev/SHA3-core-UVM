`include "uvm_macros.svh"
`include "keccak_testbench_pkg.sv"

module top;
  import uvm_pkg::*;
  import keccak_testbench_pkg::*;
  
  bit clk;
  
  //clock generation
  always #5 clk = ~clk;
  
  initial 
  begin
    clk = 0;
  end

  // Instantiate the interface
  keccak_interface keccak_if(clk);

  //Instantiate keccak DUT
  keccak dut (.clk(clk), 
    .in(keccak_if.in), 
    .reset(keccak_if.reset), 
    .in_ready(keccak_if.in_ready), 
    .is_last(keccak_if.is_last), 
    .buffer_full(keccak_if.buffer_full), 
    .out_ready(keccak_if.out_ready),
    .byte_num(keccak_if.byte_num), 
    .out(keccak_if.out)
  );
  
  initial 
  begin
    
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual keccak_interface)::set(null, "*", "keccak_vif", keccak_if);
    
    // Start the test
    run_test();
  end

  initial begin
    $vcdpluson();
  end


  assert property (@(posedge clk) $fell(keccak_if.in_ready) |-> $fell(keccak_if.is_last));
  assert property (@(posedge clk) $fell(keccak_if.in_ready) |-> ##[0:25] $rose(keccak_if.buffer_full));
  assert property (@(posedge clk) $fell(keccak_if.in_ready) |-> ##[0:25] $rose(keccak_if.out_ready));
  assert property (@(posedge clk) keccak_if.buffer_full |-> $stable(keccak_if.in));
  assert property (@(posedge clk) $rose(keccak_if.reset) |-> ##[0:7] $stable(keccak_if.reset));
  assert property (@(posedge clk) $rose(keccak_if.reset) |-> ##[7:13] $fell(keccak_if.reset));

endmodule
