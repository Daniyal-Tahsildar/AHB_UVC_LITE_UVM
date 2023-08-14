module ahb_assertions(hclk, hrst, haddr, hburst, hprot, hsize,
      htrans, hwdata, hrdata, hwrite, hreadyout,
     hresp );
    input hclk, hrst;
    input [31:0] haddr;
    input [2:0] hburst;
    input[3:0] hprot;
    input[2:0] hsize;
    
    input [1:0] htrans;
    input [31:0] hwdata;
    input [31:0] hrdata;
    input hwrite;
    input hreadyout;
    input [1:0] hresp;

    property ahb_handshake_prop;
        @(posedge hclk) disable iff (hrst) (htrans == 2'b10 || htrans == 2'b11) |-> ##[1:5] (hreadyout == 1);
    endproperty

    property ahb_write_data_prop;
        @(posedge hclk) disable iff (hrst) ((htrans == 2'b10 || htrans == 2'b11) && hwrite == 1) |=> !($isunknown(hwdata));
    endproperty

    ahb_handshake: assert property (ahb_handshake_prop);
    ahb_write_data: assert property (ahb_write_data_prop);

endmodule