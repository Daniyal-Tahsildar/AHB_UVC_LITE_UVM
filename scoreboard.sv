`uvm_analysis_imp_decl(_master)
`uvm_analysis_imp_decl(_slave)
class ahb_sbd extends uvm_scoreboard;
    uvm_analysis_imp_master#(ahb_tx, ahb_sbd) imp_master;
    uvm_analysis_imp_slave#(ahb_tx, ahb_sbd) imp_slave;
    ahb_tx master_tx, slave_tx;
    ahb_tx master_txQ[$];
    ahb_tx slave_txQ[$];

    `uvm_component_utils(ahb_sbd)

    `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp_master = new("imp_master",this);
        imp_slave = new("imp_slave",this);
    endfunction

    function void write_master(ahb_tx tx);
        master_txQ.push_back(tx);
    endfunction

    function void write_slave(ahb_tx tx);
        slave_txQ.push_back(tx);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            wait (master_txQ.size() > 0 && slave_txQ.size() > 0);
            master_tx = master_txQ.pop_front();
            slave_tx = slave_txQ.pop_front();
            if (master_tx.compare(slave_tx)) begin
                ahb_common::num_matches++;
            end
            else begin
                ahb_common::num_mismatches++;

            end
        end
    endtask
endclass