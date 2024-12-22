`timescale 1ns/1ps

class cpuDriver #(
    parameter HOLD=15
);
    bit [31:0] addr;
    bit read_en;

    function new();
        this.read_en = 0;
    endfunction

    function void drive_request_start();
        $display("cpu drive request start");
        this.addr = $urandom_range(32'h00FF_7a00, 32'h00FF_7aFF);
        this.read_en = 1;
    endfunction

    function void drive_request_end();
        this.addr = 32'd0;
        this.read_en = 0;
        $display("cpu drive request end");
    endfunction

    task automatic drive_request();
        drive_request_start();
        #(HOLD) drive_request_end(); 
    endtask 
endclass


module cpu_sim #(
    parameter REQ_FREQ_CYCLES=10,
    parameter HOLD=15
) (
    ahb_lite.master cpu_intf
);

logic [31:0] cpu_local_addr;
logic [31:0] cpu_local_data;

transfer_handler cpu_cache_transfer_handler_inst(
    .clk(cpu_intf.hclk),
    .rstn(cpu_intf.hrstn),

    .addr(cpu_intf.haddr),
    .hwrite(cpu_intf.hwrite),
    .hrdata(cpu_intf.hrdata),
    .hready(cpu_intf.hready),
    .hwdata(cpu_intf.hwdata),

    .read_addr(cpu_local_addr),
    .read_data(cpu_local_data)
);

endmodule
