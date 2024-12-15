class cpuDriver;
    rand uint addr;
    rand bit read_en;

    function void drive_request();
        addr = $urandom_range(0, 32'hFFFF_FFFF);
        read_en = 1;
        $$display("CPU Driver: Driving request at addr=0x%08x", addr);
    endfunction
endclass


module cpu_sim(
    input clk,
    input rst,

    input [31:0] requested_data,
    input hit,
    output [31:0] request_addr,
    output read_en
);
    cpuDriver driver_obj;

    initial begin
        driver_obj = new();
    end

    always_ff @(posedge clk or negedge rst) begin
        if(~rst)    driver_obj.read_en = 0;
        else driver_obj.drive_request();
    end

endmodule

