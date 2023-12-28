class keccak_transaction extends uvm_sequence_item;

  `uvm_object_utils(keccak_transaction)
  
  // rand bit [7:0] address;
  // rand bit [15:0] data;
  rand bit [1023:0] in;
  rand integer bytes;
  rand bit [511:0] out;
  bit wr_req;

  // constraint c_address { address > 8'h3F; address < 8'hF0; }
  constraint bytes_range {bytes > 0; bytes <= 64; }

  function new (string name = "");
    super.new(name);
  endfunction

endclass: keccak_transaction

class wr_sequence extends uvm_sequence#(keccak_transaction);

  `uvm_object_utils(wr_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  bit [1023:0] indata;
  bit [511:0] outdata;
  integer bytes;

  task body;
    
      req = keccak_transaction::type_id::create("req");

      start_item(req);

      if (!req.randomize()) begin
        `uvm_error("WRITE_SEQUENCE", "Randomize failed.");
      end

      // req.rd_req = 1'b0;
      // req.wr_req = 1'b1;
     
      indata = req.in;
      outdata = req.out;
      bytes = req.bytes;

      finish_item(req);
    
  endtask: body

endclass: wr_sequence

class keccak_sequence extends uvm_sequence#(keccak_transaction);

  `uvm_object_utils(keccak_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  // rd_sequence rd_seq;
  wr_sequence wr_seq;

  bit [1023:0] indata [0:127];
  integer inbytes [0:127];

  task body;
    
     for(int i =0;i<128;i++) 
     begin
       wr_seq = wr_sequence::type_id::create("wr_seq");
       wr_seq.start(m_sequencer);
       indata[i] = wr_seq.indata;
       inbytes[i] = wr_seq.bytes;
     end
    
  endtask: body

endclass: keccak_sequence


