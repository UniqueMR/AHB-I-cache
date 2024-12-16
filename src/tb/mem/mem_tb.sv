module mem_tb #(
    parameter CLK_FREQ_HALF=5,
    parameter MEM_REQ_FREQ=100,
    parameter MEM_REQ_HOLD=15
);
    logic clk;
    logic [31:0] mem_addr;
    logic [127:0] mem_data;
    logic mem_ready;
    logic mem_req;

    mem_sim mem_sim_inst(.mem_addr(mem_addr), .mem_data(mem_data), .mem_ready(mem_ready), .mem_req(mem_req));

    initial begin
        clk = 0;
        mem_req = 0;
        mem_addr = 0;
    end

    always begin
        fork
            forever begin
                #CLK_FREQ_HALF clk = ~clk; 
            end
            forever begin
                mem_req = 1;
                mem_addr = $urandom_range(0, 32'hFFFF_FFFF);
                #MEM_REQ_HOLD;
                mem_req = 0;
                mem_addr = 0;
                #(MEM_REQ_FREQ - MEM_REQ_HOLD);
            end
        join_none
    end
endmodule