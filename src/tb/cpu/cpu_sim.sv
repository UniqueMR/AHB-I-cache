class cpuDriver;
    bit [31:0] addr;
    bit read_en;

    function new();
        this.read_en = 0;
    endfunction

    function void drive_request();
        this.addr = $urandom_range(0, 32'hFFFF_FFFF);
        this.read_en = 1;
    endfunction
endclass


module cpu_sim #(
    parameter CLK_PERIOD=5
) (
    input [31:0] requested_data,
    input hit,
    output logic [31:0] request_addr,
    output logic read_en
);
    cpuDriver driver_obj;

    initial begin
        driver_obj = new();
    end

    always begin
        #CLK_PERIOD driver_obj.drive_request();
        request_addr = driver_obj.addr;
        read_en = driver_obj.read_en;
        $display("CPU Driver: Driving request at addr=0x%08x", request_addr);
    end

endmodule

