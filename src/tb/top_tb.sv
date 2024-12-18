`timescale 1ns/1ps

module top_tb #(
    parameter CLK_FREQ_HALF=5,
    parameter RST_DELAY=30,
    parameter SIM_TIME=1000
);

    logic clk, rst, read_en, hit, mem_ready, mem_req;
    logic [31:0] addr;
    logic [31:0] data_out;
    logic [31:0] mem_addr;
    logic [127:0] mem_data;

    top top_inst(
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .data_out(data_out),
        .read_en(read_en),
        .hit(hit),
        .mem_addr(mem_addr),
        .mem_data_in(mem_data),
        .mem_ready(mem_ready),
        .mem_req(mem_req)
    );

    cpu_sim cpu_sim_inst(
        .clk(clk),
        .rst(rst),
        .requested_data(data_out),
        .hit(hit),
        .request_addr(addr),
        .read_en(read_en)
    );

    mem_sim mem_sim_inst(
        .clk(clk),
        .rst(rst),
        .mem_addr(mem_addr),
        .mem_req(mem_req),
        .mem_data_out(mem_data),
        .mem_ready(mem_ready)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b0;

        #RST_DELAY rst = 1'b1;
        
        #SIM_TIME $finish;
    end

    always begin
        #CLK_FREQ_HALF clk = ~clk;
    end

endmodule
