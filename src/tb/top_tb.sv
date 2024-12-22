`timescale 1ns/1ps

module top_tb #(
    parameter CLK_FREQ_HALF=5,
    parameter RST_DELAY=30,
    parameter SIM_TIME=1000
);

    logic clk, rst;
    // logic clk, rst, read_en, hit, mem_ready, mem_req;
    // logic [31:0] addr;
    // logic [31:0] data_out;
    // logic [31:0] mem_addr;
    // logic [127:0] mem_data;

    ahb_lite upstream_intf_inst();
    ahb_lite downstream_intf_inst();

    // global clk and rst
    assign upstream_intf_inst.hclk = clk;
    assign upstream_intf_inst.hrstn = rst;
    assign downstream_intf_inst.hclk = clk;
    assign downstream_intf_inst.hrstn = rst;

    top top_inst(
        .upstream_intf(upstream_intf_inst.slave),
        .downstream_intf(downstream_intf_inst.master)
    );

    cpu_sim cpu_sim_inst(
        .cpu_intf(upstream_intf_inst.master)
    );

    mem_sim mem_sim_inst(
        .mem_intf(downstream_intf_inst.slave)
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
