module cpu_tb;
    logic clk, rst, hit, read_en;
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
        #10 rst = 1'b1;
        #200 $finish;
    end

    always begin
        clk = ~clk;
    end

endmodule