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
        this.addr = $urandom_range(0, 32'hFFFF_FFFF);
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
    parameter REQ_FREQ=100,
    parameter HOLD=15
) (
    input [31:0] requested_data,
    input hit,
    output logic [31:0] request_addr,
    output logic read_en
);
    cpuDriver #(.HOLD(15)) driver_obj;

    initial begin
        driver_obj = new();
    end

    always begin
        #REQ_FREQ driver_obj.drive_request();
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
