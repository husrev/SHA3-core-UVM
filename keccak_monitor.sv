class keccak_monitor extends uvm_monitor;
     // register the monitor in the UVM factory
     `uvm_component_utils(keccak_monitor)

     //Declare virtual interface
     virtual keccak_interface keccak_vif;

     // Analysis port to broadcast results to scoreboard 
     uvm_analysis_port #(keccak_transaction) Mon2Sb_port; 
     
     // Analysis port to broadcast results to subscriber 
     uvm_analysis_port #(keccak_transaction) aport;
     
     function new(string name, uvm_component parent);
       super.new(name, parent);
     endfunction
     
     function void build_phase(uvm_phase phase);
       // Get interface reference from config database
       if(!uvm_config_db#(virtual keccak_interface)::get(this, "", "keccak_vif", keccak_vif)) begin
         `uvm_error("", "uvm_config_db::get failed")
       end
       Mon2Sb_port = new("Mon2Sb",this);

       //Instantiate analysis port to send transactions to subscriber
       aport = new("aport",this);

     endfunction

     task run_phase(uvm_phase phase);
        //uvm_report_info(get_full_name(),"Run", UVM_LOW);
        // keccak_transaction read_trans;
        keccak_transaction write_trans;
        // read_trans = new ("trans");
        write_trans = new ("trans");

        fork

          forever begin

            @(keccak_vif.monitor_if_mp.monitor_cb)
            begin

              if(keccak_vif.monitor_if_mp.monitor_cb.out_ready)
              begin
                // write_trans.address = keccak_vif.monitor_if_mp.monitor_cb.address;
                write_trans.in = keccak_vif.monitor_if_mp.monitor_cb.in;
                write_trans.out = keccak_vif.monitor_if_mp.monitor_cb.out;
                // write_trans.bytes = keccak_vif.monitor_if_mp.monitor_cb.bytes;
                // write_trans.wr_req = keccak_vif.monitor_if_mp.monitor_cb.wr_req;
                // write_trans.rd_req = keccak_vif.monitor_if_mp.monitor_cb.rd_req;
                Mon2Sb_port.write(write_trans);

                //Send write transaction to subscriber
                aport.write(write_trans);
              end
            end


          end

        join



     endtask : run_phase

endclass : keccak_monitor
