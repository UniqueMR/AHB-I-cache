`timescale  1ns/1ps

module transfer_handler_tb;

reg clk, rstn, hwrite;
reg [31:0] addr;
reg [31:0] rdata;
reg [31:0] wdata;
reg [1:0] trans;
reg [31:0] read_addr;
reg [31:0] read_data;

BURST_TYPES burst_type;

transfer_handler transfer_handler_inst(
    .clk(clk),
    .rstn(rstn),

    .addr(addr),
    .hwrite(hwrite),
    .hrdata(rdata),
    .hready(ready),
    .hwdata(wdata),
    .hburst(burst_type),

    .htrans(trans),
    .read_addr(read_addr),
    .read_data(read_data)
);

initial begin
    clk = 0;
    rst = 0;
    hwrite = 0;
    ready = 0;
    burst_type = WRAP4;
    #10 rst = 1;
end

always begin
    #5 clk = ~clk;
end

always begin
    #20;
    forever begin
        addr = $urandom_range(0, 32'hffff_ffff);
        #100;
    end
end

always begin
    #15;
    forever begin
        rdata = $urandom_range(0, 32'hffff_ffff);
        #65;
    end
end

always begin
    #130 ready = ~ready;
end

endmodule