`timescale 1ns/1ps

module cpu_tb #(
    parameter CLK_FREQ_HALF=5,
    parameter RST_DELAY=30
);
    ahb_lite.master cpu_intf_inst();
    
    cpu_sim cpu_sim_inst(
        .cpu_intf(cpu_intf_inst)
    );

    initial begin
        cpu_intf_inst.hclk = 1'b0;
        cpu_intf_inst.hrstn = 1'b0;
        #RST_DELAY cpu_intf_inst.hrstn = 1'b1;
        #1000 $finish;
    end

    always begin
        #CLK_FREQ_HALF cpu_intf_inst.hclk = ~cpu_intf_inst.hclk;
    end

endmodule
