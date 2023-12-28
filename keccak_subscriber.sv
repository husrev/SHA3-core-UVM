class keccak_subscriber extends uvm_subscriber #(keccak_transaction);
//Register subscriber in uvm factory
`uvm_component_utils(keccak_subscriber)

//Define variables to store read/write request and address
bit wr_req;
bit [1023:0] indata;
//  bit rd_req;
integer inbytes;

//Define covergroup and coverpoints
covergroup cover_keccak;
    option.auto_bin_max = 8;
    coverpoint indata[7:0];
endgroup

//Declare virtual interface object
virtual keccak_interface keccak_vif;

//Declare analysis port to get transactions from monitor
uvm_analysis_imp #(keccak_transaction,keccak_subscriber) aport;


  function new (string name, uvm_component parent);
  begin
    super.new(name,parent);

    //Call new for covergroup
      cover_keccak = new();

  end
  endfunction

  function void build_phase(uvm_phase phase);
    // Get virtual interface reference from config database
    if(!uvm_config_db#(virtual keccak_interface)::get(this, "","keccak_vif", keccak_vif)) begin 
      `uvm_error("", "uvm_config_db::get failed")
end

    //Instantiate analysis port
    aport = new("aport",this);

  endfunction 

  //Write function for the analysis port
  function void write(keccak_transaction t);
    // if(t.wr_req)
    // begin
      wr_req = t.wr_req;
      inbytes = t.bytes;
      
      // rd_req = t.rd_req;
      indata = t.in;
    // end
    // $display("%x",indata);

    cover_keccak.sample();
 endfunction

endclass








