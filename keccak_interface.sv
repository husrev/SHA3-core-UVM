interface keccak_interface(input clk);
  
    logic     clk, reset, in_ready, is_last, buffer_full, out_ready;
    logic     [63:0]  in;
    logic     [2:0]   byte_num;
    logic     [511:0] out;

  clocking driver_cb @ (posedge clk);
    input clk; 
    output reset; 
    output in; 
    output in_ready; 
    output is_last;
    output byte_num; 
    input buffer_full;
    input out_ready; 
    input out;
  endclocking : driver_cb

  modport driver_if_mp (clocking driver_cb);

  clocking monitor_cb @ (negedge clk);
    input clk;
    input reset;
    input in; 
    input in_ready;  
    input is_last;
    input byte_num;
    input buffer_full;
    input out_ready;
    input out;
  endclocking : monitor_cb

  modport monitor_if_mp (clocking monitor_cb);
  
endinterface
