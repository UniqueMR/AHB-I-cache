module top #(
    parameter CACHE_SIZE = 8192
)(
    ahb_lite.slave upstream_intf,
    ahb_lite.master downstream_intf
);

logic [31:0] cache_local_addr;
logic [31:0] cache_local_data;

transfer_handler cpu_cache_transfer_handler_inst(
    .clk(downstream_intf.hclk),
    .rstn(downstream_intf.hrstn),

    .addr(downstream_intf.haddr),
    .hwrite(downstream_intf.hwrite),
    .hrdata(downstream_intf.hrdata),
    .hready(downstream_intf.hready),
    .hwdata(downstream_intf.hwdata),

    .read_addr(cache_local_addr),
    .read_data(cache_local_data)
);

endmodule
