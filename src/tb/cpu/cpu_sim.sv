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

cpuDriver driver_obj;

reg [3:0] request_delay_counter; 

    initial begin
        driver_obj = new();
    end

always_ff @( posedge cpu_intf.hclk or negedge cpu_intf.hrstn) begin : read_request
    if(~cpu_intf.hrstn) begin
        request_delay_counter <= 0;
    end
    else begin
        if(request_delay_counter == REQ_FREQ_CYCLES - 1) driver_obj.drive_request();
        request_delay_counter <= request_delay_counter == (REQ_FREQ_CYCLES - 1) ? 0 : request_delay_counter + 1;
    end
end

always begin
    cpu_intf.haddr = driver_obj.addr;
    cpu_intf.hwrite = ~driver_obj.read_en;
    #1;
end

endmodule
