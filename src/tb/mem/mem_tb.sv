`timescale 1ns/1ps

module mem_tb #(
    parameter CLK_FREQ_HALF=5,
    parameter MEM_REQ_FREQ=100,
    parameter MEM_REQ_HOLD=15,
    parameter SIM_TIME=1000
);
    logic clk;
    logic [31:0] mem_addr;
    logic [127:0] mem_data;
    logic mem_ready;
    logic mem_req;

    mem_sim mem_sim_inst(.mem_addr(mem_addr), .mem_data_in(mem_data), .mem_ready(mem_ready), .mem_req(mem_req));

    initial begin
        $display("simulation start");
        clk = 0;
        mem_req = 0;
        mem_addr = 0;
        #SIM_TIME $display("simulation finished");
        $finish;
    end

    always begin
        #CLK_FREQ_HALF clk = ~clk;
    end

    always begin
        mem_req = 1;
        mem_addr = $urandom_range(0, 32'hFFFF_FFFF);
        #MEM_REQ_HOLD;
        mem_req = 0;
        mem_addr = 0;
        #(MEM_REQ_FREQ - MEM_REQ_HOLD); 
    end
    
endmodule