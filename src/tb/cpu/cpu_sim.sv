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
        this.addr = $urandom_range(32'h00FF_7a00, 32'h00FF_7aFF);;
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
    input clk,
    input rst,
    input [31:0] requested_data,
    input hit,
    output logic [31:0] request_addr,
    output logic read_en
);
    cpuDriver #(.HOLD(15)) driver_obj;
    logic [$clog2(REQ_FREQ_CYCLES)-1:0] req_delay_cnt;

    initial begin
        driver_obj = new();
    end

    always @(posedge clk or negedge rst) begin
        if(~rst) req_delay_cnt <= 0;
        else if(req_delay_cnt == REQ_FREQ_CYCLES-1) req_delay_cnt <= 0;
        else req_delay_cnt <= req_delay_cnt + 1;
    end

    always @(posedge clk or negedge rst)    begin
        if(~rst);
        else if(req_delay_cnt == REQ_FREQ_CYCLES-1) driver_obj.drive_request();
    end

    always begin
        request_addr = driver_obj.addr;
        read_en = driver_obj.read_en;
        #1;
    end

    always begin
        #10 $display("CPU Driver: Driving request at addr=0x%08x", request_addr);
    end

endmodule
