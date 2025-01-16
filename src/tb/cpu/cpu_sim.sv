`timescale 1ns/1ps
`include "./src/include/interface_pkg.svh"

class cpuDriver #(
    parameter HOLD=15
);
    bit [31:0] addr;
    bit read_en;

    bit first_req;
    int unsigned addr_hist[$];
    int addr_hist_assoc[int unsigned];
    int assoc_ptr;

    BURST_TYPES burst_type;
    TRANS_TYPES trans_type;

    function new();
        this.read_en = 0;
        this.first_req = 0;
        this.assoc_ptr = 0;
        this.burst_type = SINGLE;
        this.trans_type = IDLE;
    endfunction

    function void drive_request_start();
        bit hit;
        int unsigned addr_gen;
        int unsigned idx;
        if(this.first_req == 0) begin
            hit = 0;
            do begin
                addr_gen = $urandom_range(32'h0000_0a00, 32'h0000_0aFF);
            end while (addr_gen % 4 != 0);
            this.first_req = 1;
            this.addr_hist.push_back(addr_gen);
            this.addr_hist_assoc[addr_gen] = this.assoc_ptr;
            this.assoc_ptr = this.assoc_ptr + 1;
            
        end
        else begin
            hit = $urandom_range(0, 1);
            if(hit) begin
                idx = $urandom_range(0, this.addr_hist.size()-1);
                addr_gen = addr_hist[idx];
            end
            else begin
                do begin
                    addr_gen = $urandom_range(32'h0000_0a00, 32'h0000_0aFF);
                end while (this.addr_hist_assoc.exists(addr_gen) || addr_gen % 4 != 0);
                this.addr_hist.push_back(addr_gen);
                this.addr_hist_assoc[addr_gen] = this.assoc_ptr;
                this.assoc_ptr = this.assoc_ptr + 1;
            end
        end
        this.addr = addr_gen;
        this.read_en = 1;
        this.burst_type = SINGLE;
        this.trans_type = NONSEQ;
        $display("cpu drive request start: addr = %h, mode = %s", addr_gen, hit ? "hit" : "miss");
    endfunction

    function void drive_request_end();
        this.addr = 32'd0;
        this.read_en = 0;
        this.trans_type = IDLE;
        $display("cpu drive request end");
    endfunction

    task automatic drive_request();
        drive_request_start();
        #(HOLD) drive_request_end(); 
    endtask 
endclass


module cpu_sim #(
    parameter REQ_FREQ_CYCLES=10,
    parameter HOLD=15,
    parameter BASE_ADDR=32'h0000_0a00
) (
    ahb_lite.master cpu_intf
);

cpuDriver #(HOLD) driver_obj;

logic [31:0] mem_idx, mem_data_exp;
sim_addr_data_mapping_gen #(.BASE_ADDR(BASE_ADDR)) sim_addr_data_mapping_gen_inst(
    .addr(cpu_intf.haddr),
    .mem_idx(mem_idx),
    .sim_data_exp(mem_data_exp)
);

property check_hrdata_valid;
 @(posedge cpu_intf.hclk)
    (cpu_intf.hready) |-> (mem_data_exp == cpu_intf.hrdata);
endproperty

assert (check_hrdata_valid) else $error("hrdata mismatched: expected=%0h, actual=%0h", mem_data_exp, cpu_intf.hrdata);

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
    cpu_intf.hburst = BURST_TYPES'(driver_obj.burst_type);
    cpu_intf.htrans = TRANS_TYPES'(driver_obj.trans_type);
    #1;
end

endmodule
