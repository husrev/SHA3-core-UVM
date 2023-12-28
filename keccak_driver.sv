class keccak_driver extends uvm_driver #(keccak_transaction);

  `uvm_component_utils(keccak_driver)

  virtual keccak_interface keccak_vif;

  // Analysis port to broadcast input values to scoreboard
  uvm_analysis_port #(keccak_transaction) Drv2Sb_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual keccak_interface)::get(this, "", "keccak_vif", keccak_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end
    Drv2Sb_port = new("Drv2Sb",this);
  endfunction 

  task run_phase(uvm_phase phase);

    
    // Now drive normal traffic
    forever begin
      seq_item_port.get_next_item(req);
 
      // Wiggle pins of DUT
      // @(keccak_vif.driver_if_mp.driver_cb)
      // begin 

        // keccak_vif.driver_if_mp.driver_cb.in <= 64'h0000000000000000;
        keccak_vif.driver_if_mp.driver_cb.byte_num <= 3'b000;
        keccak_vif.driver_if_mp.driver_cb.reset <= 1'b1;
        keccak_vif.driver_if_mp.driver_cb.in_ready <= 1'b0;
        keccak_vif.driver_if_mp.driver_cb.is_last <= 1'b0;

        #100

        keccak_vif.driver_if_mp.driver_cb.in <= 64'h0000000000000000;
        keccak_vif.driver_if_mp.driver_cb.byte_num <= 3'b000;
        keccak_vif.driver_if_mp.driver_cb.reset <= 1'b1;
        keccak_vif.driver_if_mp.driver_cb.in_ready <= 1'b0;
        keccak_vif.driver_if_mp.driver_cb.is_last <= 1'b0;

        #10

        keccak_vif.driver_if_mp.driver_cb.in <= 64'h0000000000000000;
        keccak_vif.driver_if_mp.driver_cb.byte_num <= 3'b000;
        keccak_vif.driver_if_mp.driver_cb.reset <= 1'b0;
        keccak_vif.driver_if_mp.driver_cb.in_ready <= 1'b0;
        keccak_vif.driver_if_mp.driver_cb.is_last <= 1'b0;

        #70;

        for(int i=(req.bytes-1)/8; i>=0; i--)
        begin
          keccak_vif.driver_if_mp.driver_cb.in <= req.in[64*i +: 64];
          if(req.bytes%8 != 0 && i==0)
          begin
            keccak_vif.driver_if_mp.driver_cb.byte_num <= req.bytes%8;
            keccak_vif.driver_if_mp.driver_cb.is_last <= 1'b1;
          end
          else
          begin
            keccak_vif.driver_if_mp.driver_cb.byte_num <= 3'b000;
            keccak_vif.driver_if_mp.driver_cb.is_last <= 1'b0;
          end

          keccak_vif.driver_if_mp.driver_cb.reset <= 1'b0;
          keccak_vif.driver_if_mp.driver_cb.in_ready <= 1'b1;
          
          #10;
        end

        if(req.bytes%8 == 0)
        begin
          // keccak_vif.driver_if_mp.driver_cb.in <= req.in[req.bytes%8:0];
          keccak_vif.driver_if_mp.driver_cb.byte_num <= 3'b000;
          keccak_vif.driver_if_mp.driver_cb.reset <= 1'b0;
          keccak_vif.driver_if_mp.driver_cb.in_ready <= 1'b1;
          keccak_vif.driver_if_mp.driver_cb.is_last <= 1'b1;
          #10  ;        
        end


        // keccak_vif.driver_if_mp.driver_cb.in <= req.in;
        keccak_vif.driver_if_mp.driver_cb.byte_num <= 3'b000;
        keccak_vif.driver_if_mp.driver_cb.reset <= 1'b0;
        keccak_vif.driver_if_mp.driver_cb.in_ready <= 1'b0;
        keccak_vif.driver_if_mp.driver_cb.is_last <= 1'b0;

        wait (keccak_vif.driver_if_mp.driver_cb.out_ready == 1'b1);

        // keccak_vif.driver_if_mp.driver_cb.in <= req.in;
        keccak_vif.driver_if_mp.driver_cb.byte_num <= 3'b000;
        keccak_vif.driver_if_mp.driver_cb.reset <= 1'b1;
        keccak_vif.driver_if_mp.driver_cb.in_ready <= 1'b0;
        keccak_vif.driver_if_mp.driver_cb.is_last <= 1'b0;

      // call the write method of implementation port in scoreboard to
      // broadcast input values
      Drv2Sb_port.write(req);

      seq_item_port.item_done();
    end
  endtask

endclass: keccak_driver

