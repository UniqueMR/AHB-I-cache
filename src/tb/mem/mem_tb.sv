`timescale 1ns/1ps

module mem_tb #(
    parameter CLK_FREQ_HALF=5,
    parameter RST_DELAY=10,
    parameter MEM_REQ_FREQ=100,
    parameter MEM_REQ_OFFSET=7,
    parameter MEM_REQ_HOLD=15,
    parameter SIM_TIME=1000
);
    logic clk;
    logic rst;
    logic [31:0] mem_addr;
    logic [127:0] mem_data;
    logic mem_ready;
    logic mem_req;

    mem_sim mem_sim_inst(.clk(clk), .rst(rst), .mem_addr(mem_addr), .mem_data_in(mem_data), .mem_ready(mem_ready), .mem_req(mem_req));

    initial begin
        $display("simulation start");
        clk = 1;
        rst = 0;
        mem_req = 0;
        mem_addr = 0;
        #RST_DELAY rst = 1;
        #SIM_TIME $display("simulation finished");
        $finish;
    end

    // always begin
    //     #CLK_FREQ_HALF clk = ~clk;
    // end

    // always begin
    //     #MEM_REQ_OFFSET;
    //     forever begin
    //         mem_req = 1;
    //         mem_addr = $urandom_range(32'h00FF_7a00, 32'h00FF_7aFF);
    //         #MEM_REQ_HOLD;
    //         mem_req = 0;
    //         mem_addr = 0;
    //         #(MEM_REQ_FREQ - MEM_REQ_HOLD);
    //     end 
    // end

    always begin
        fork
            #CLK_FREQ_HALF clk = ~clk;
            begin
                #MEM_REQ_OFFSET;
                forever begin
                    mem_req = 1;
                    mem_addr = $urandom_range(32'h00FF_7a00, 32'h00FF_7aFF);
                    #MEM_REQ_HOLD;
                    mem_req = 0;
                    mem_addr = 0;
                    #(MEM_REQ_FREQ - MEM_REQ_HOLD);
                end
            end
        join_none
    end
    
endmodule