`timescale 1ns/1ps

module top_tb;

    logic clk, rst, read_en, hit, mem_ready, mem_req;
    logic [31:0] addr;
    logic [31:0] data_out;
    logic [31:0] mem_addr;
    logic [127:0] mem_data_in;

    top top_inst(
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .data_out(data_out),
        .read_en(read_en),
        .hit(hit),
        .mem_addr(mem_addr),
        .mem_data_in(mem_data_in),
        .mem_ready(mem_ready),
        .mem_req(mem_req)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b0;

        addr = 32'd0;
        read_en = 1'b0;

        mem_data_in = 128'd0;
        mem_ready = 1'b0;

        #10 rst = 1'b1;
        
        #200 $finish;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule
