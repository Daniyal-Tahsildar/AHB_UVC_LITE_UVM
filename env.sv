class ahb_env extends uvm_env;

    ahb_magent magent;
    ahb_sagent sagent;
    ahb_sbd sbd;

    `uvm_component_utils(ahb_env)
    
    `NEW_COMP

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        magent = ahb_magent::type_id::create("magent", this);
        sagent = ahb_sagent::type_id::create("sagent", this);
        sbd = ahb_sbd::type_id::create("sbd", this);

    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        magent.mon.ap_port.connect(sbd.imp_master);
        sagent.mon.ap_port.connect(sbd.imp_slave);

    endfunction
endclass