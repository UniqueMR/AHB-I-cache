`timescale  1ns/1ps
`include "./src/include/interface_pkg.svh"

module transfer_handler_tb;

reg clk, rstn, hwrite, ready;
reg [31:0] addr;
reg [31:0] rdata;
reg [31:0] wdata;
reg [2:0] burst;

reg [1:0] trans;
reg [31:0] read_addr;
reg [31:0] read_data;

reg [1:0] trans_out;

transfer_handler transfer_handler_inst(
    .clk(clk),
    .rstn(rstn),

    .addr(addr),
    .hwrite(hwrite),
    .hrdata(rdata),
    .hready(ready),
    .hwdata(wdata),
    .hburst(burst),
    .htrans(trans),

    .read_addr(read_addr),
    .read_data(read_data),
    .trans_out(trans_out)
);

initial begin
    clk = 0;
    rstn = 0;
    hwrite = 0;
    ready = 0;
    burst = 3'b010;
    #10 rstn = 1;
    #1000 $finish;
end

always begin
    #5 clk = ~clk;
end

always begin
    #20;
    forever begin
        do begin
            addr = $urandom_range(0, 32'hffff_ffff);
        end while(addr % 4 == 0)
        trans = TRANS_TYPES'(NONSEQ);
        #10 addr = 0;
        trans = TRANS_TYPES'(IDLE);
        #90;
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
    #35 ready = ~ready;
end

endmodule