class ahb_responder extends uvm_driver#(ahb_tx);

    //virtual ahb_intf.slave_mp vif;
    virtual ahb_intf vif;
    virtual ahb_intf vif_nocb;

   //memory declaration
    byte mem[*];
    bit [31:0] addr_t ;
    bit [2:0] burst_t;
    bit [6:0] prot_t ;
    bit [2:0] size_t ;
    bit [1:0] prev_htrans ;
    bit write_t ;

     `uvm_component_utils(ahb_responder)

    `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_resource_db#(virtual ahb_intf)::read_by_name("AHB", "INTF", vif, this)) begin
            `uvm_error("RESOURCE_DB_ERROR"," Not able to retrive ahb_vif!!")
        end
        if(!uvm_resource_db#(virtual ahb_intf)::read_by_name("AHB", "INTF", vif_nocb, this)) begin
            `uvm_error("RESOURCE_DB_ERROR"," Not able to retrive ahb_vif!!")
        end
    endfunction

    task run_phase(uvm_phase phase);
        //respond to the requests comming from the master driver
    fork
        //handelling read/write requests
        forever begin
           // @(vif_nocb.htrans);
            @(posedge vif_nocb.hclk);
           // if(vif_nocb.htrans inside {})
            vif_nocb.hreadyout = 0;
            //checks values of previous htrans and current htrans
            //case(vif.slave_cb.htrans)
            case(vif_nocb.htrans)
                IDLE: begin
                    case(prev_htrans)
                        IDLE: begin
                            //do nothing
                            idle_phase();
                        end
                        BUSY: begin
                            `uvm_error("AHB_TX", "Illegal htrans scenario: HTRANS_BUSY_IDLE")
                        end
        
                        NONSEQ: begin
                            data_phase();
                            vif_nocb.hreadyout = 1;

                        end
        
                        SEQ: begin
                            data_phase();
                            vif_nocb.hreadyout = 1;

                        end
                    endcase

                end
                BUSY: begin
                    case(prev_htrans)
                        IDLE: begin
                            `uvm_error("AHB_TX", "Illegal htrans scenario: HTRANS_IDLE_BUSY")
        
                        end
                        BUSY: begin
                            //nothing
                        end
        
                        NONSEQ: begin
                            data_phase();
                            vif_nocb.hreadyout = 1;

                        end
        
                        SEQ: begin
                            data_phase();
                            vif_nocb.hreadyout = 1;
                        end
                    endcase
                end

                NONSEQ: begin
                    case(prev_htrans)
                        IDLE: begin
                            collect_addr_phase();
                            vif_nocb.hreadyout = 1;

                        end
                        BUSY: begin
                            `uvm_error("AHB_TX", "Illegal htrans scenario: HTRANS_BUSY_NONSEQ")
                            
                        end
        
                        NONSEQ: begin
                            data_phase();
                            collect_addr_phase();
                            vif_nocb.hreadyout = 1;

                        end
        
                        SEQ: begin
                            data_phase();
                            collect_addr_phase();
                            vif_nocb.hreadyout = 1;

                        end
                    endcase

                end

                SEQ: begin
                    case(prev_htrans)
                        IDLE: begin
                            `uvm_error("AHB_TX", "Illegal htrans scenario: HTRANS_IDLE_SEQ")
        
                        end
                        BUSY: begin
                            collect_addr_phase();
                            vif_nocb.hreadyout = 1;
        
                        end
        
                        NONSEQ: begin
                            data_phase();
                            collect_addr_phase();
                            vif_nocb.hreadyout = 1;
        
                        end
        
                        SEQ: begin
                            data_phase();
                            collect_addr_phase();
                            vif_nocb.hreadyout = 1;

                        end
                    endcase
                    
                end
            endcase
            prev_htrans = vif_nocb.htrans;
            // if(vif.slave_cb.htrans inside {NONSEQ, SEQ}) begin
            //     vif.slave_cb.hreadyout <= 1;
                
            // end
            // else begin
            //     vif.slave_cb.hreadyout <= 0;
            // end
        end
    join
    endtask

    task collect_addr_phase();
        //addr_t = vif.slave_cb.haddr;
        addr_t = vif.haddr;
        burst_t = vif_nocb.hburst;
        prot_t = vif_nocb.hprot;
        size_t = vif_nocb.hsize;
        prev_htrans = vif_nocb.htrans;
        write_t = vif_nocb.hwrite;
    endtask

    task data_phase();
        //more efficient code to replace the code below
        bit [63:0] wdata_t , rdata_t;
        wdata_t = vif_nocb.hwdata;
            if(write_t==1) begin
				$display("%t : ENTRY_WRITE - addr_t=%h, wdata_t=%h", $time, addr_t, wdata_t);
			end
        for (int i = 0; i < 2**size_t; i++) begin
            if(write_t==1) begin
                mem[addr_t + i] = wdata_t[7:0];
                wdata_t >>= 8;
            end
            if(write_t==0) begin
                rdata_t <<= 8;
                rdata_t[7:0] = mem[addr_t + 2**size_t - 1 - i] ;
            end
        end
            if(write_t==0) begin
				$display("%t : ENTRY_READ - addr_t=%h, rdata_t=%h", $time, addr_t, rdata_t);
            end
        //vif_nocb.hrdata = rdata_t; 
        vif.slave_cb.hrdata <= rdata_t; 
        //this code give errors because of assigning unpacked values to a paked array, 
        //check initial_design_III file for commented code

    endtask

    task idle_phase();
        
        vif_nocb.hrdata[7:0] = 0 ;
        vif_nocb.hrdata[15:8] = 0 ;
        vif_nocb.hrdata[23:16] = 0 ;
        vif_nocb.hrdata[31:24] = 0 ;

    endtask
endclass
