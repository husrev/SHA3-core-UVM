`uvm_analysis_imp_decl(_mon_trans)
`uvm_analysis_imp_decl(_drv_trans)

class keccak_scoreboard extends uvm_scoreboard;
    
    // register the scoreboard in the UVM factory
    `uvm_component_utils(keccak_scoreboard);

    keccak_transaction trans, input_trans;

    // analysis implementation ports
    uvm_analysis_imp_mon_trans #(keccak_transaction,keccak_scoreboard) Mon2Sb_port;
    uvm_analysis_imp_drv_trans #(keccak_transaction,keccak_scoreboard) Drv2Sb_port;

    // TLM FIFOs to store the actual and expected transaction values
    uvm_tlm_fifo #(keccak_transaction)  drv_wr_fifo;
    uvm_tlm_fifo #(keccak_transaction)  drv_rd_fifo;
    uvm_tlm_fifo #(keccak_transaction)  mon_wr_fifo;
    // uvm_tlm_fifo #(keccak_transaction)  mon_rd_fifo;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //Instantiate the analysis ports and Fifo
      Mon2Sb_port = new("Mon2Sb",  this);
      Drv2Sb_port = new("Drv2Sb",  this);
      drv_wr_fifo     = new("drv_wr_fifo", this,8);
      mon_wr_fifo     = new("mon_wr_fifo", this,8);
   endfunction : build_phase

   // write_drv_trans will be called when the driver broadcasts a transaction
   // to the scoreboard
   function void write_drv_trans (keccak_transaction input_trans);
       
      uvm_report_info(get_full_name(),"Received Driver packet in scoreboard", UVM_LOW);
      void'(drv_wr_fifo.try_put(input_trans));

   endfunction : write_drv_trans

   // write_mon_trans will be called when the monitor broadcasts the DUT results
   // to the scoreboard 
   function void write_mon_trans (keccak_transaction trans);

      uvm_report_info(get_full_name(),"Received Monitor packet in scoreboard", UVM_LOW);
      void'(mon_wr_fifo.try_put(trans));
	
   endfunction : write_mon_trans

   task run_phase(uvm_phase phase);
   
      keccak_transaction out_trans;
      keccak_transaction drv_trans;
      byte plaintext[128];
      int file_input, file_output;
      string hex, line;

      forever begin

        // use get method of tlm_fifo to obtain the actual DUT
        // output
        `uvm_info("Scoreboard run task", "WAITING for actual output",UVM_HIGH)
        drv_wr_fifo.get(drv_trans);
        mon_wr_fifo.get(out_trans);
        
        $sformat(hex, "%x", out_trans.out);
        $display("DEBUG: in - %x bytes - %d hex - %s \n", drv_trans.in, drv_trans.bytes, hex);

        if(drv_trans.bytes%8 == 0)
        begin
         for(int i=0; i< drv_trans.bytes; i++)
         begin
            //   $display("i=%d", i);
            plaintext[drv_trans.bytes-i-1] = drv_trans.in[8*i +: 8];
         end 
        end
        else begin
         for(int i=8-drv_trans.bytes % 8; i<= drv_trans.bytes + (8 - drv_trans.bytes % 8)-1; i++)
         begin
            //   $display("i=%d", i);
            plaintext[drv_trans.bytes + (8 - drv_trans.bytes % 8)-1 - i] = drv_trans.in[8*i +: 8];
         end           
        end


      //   for(int i=0; i<drv_trans.bytes; i++)
      //   begin
      //     $display("%x", plaintext[i] );
      //   end
          
        file_input = $fopen("input.txt","w");
        for(int i=0; i<drv_trans.bytes; i++) begin
          $fwrite(file_input, "%x", plaintext[i]);
        end
        $fclose(file_input);

        $system("./sha3_512");

        file_output = $fopen("output.txt","r");
        $fgets(line,file_output);
        $fclose(file_output);

        //Add monitor statements below            
        if(hex != line)
        begin
           #20
        `uvm_fatal("ERROR", $sformatf("observed hash - %s actual hash - %s \n", hex, line))
          // $display("FAIL: observed hash - %s actual hash - %s \n", hex, line);
        end 
        else begin
          `uvm_info("PASS", $sformatf("observed hash - %s actual hash - %s \n", hex, line), UVM_LOW)
          // $display("PASS: observed hash - %s actual hash - %s \n", hex, line);
        end

      end
   endtask
endclass : keccak_scoreboard
