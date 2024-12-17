`timescale 1ns/1ps

module cpu_tb #(
    parameter CLK_FREQ_HALF=5,
    parameter RST_DELAY=30
);
    logic clk;
    logic rst;
    logic hit;
    logic read_en;
    logic [31:0] requested_data, request_addr;
    
    cpu_sim cpu_sim_inst(
        .clk(clk),
        .rst(rst),
        .requested_data(requested_data),
        .hit(hit),
        .request_addr(request_addr),
        .read_en(read_en)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        #RST_DELAY rst = 1'b1;
        #1000 $finish;
    end

    always begin
        #CLK_FREQ_HALF clk = ~clk;
    end

endmodule
