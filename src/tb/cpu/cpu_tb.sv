module cpu_tb;
    logic clk;
    logic rst;
    logic hit;
    logic read_en;
    logic [31:0] requested_data, request_addr;
    
    cpu_sim #(
        .CLK_PERIOD(5)
    ) cpu_sim_inst(
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
        #5 clk = ~clk;
    end

endmodule