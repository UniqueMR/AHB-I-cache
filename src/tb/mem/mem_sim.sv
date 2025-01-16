`timescale 1ns/1ps
`include "./src/include/interface_pkg.svh"

class memDrive #(
    parameter MAIN_MEM_SIZE=32768,
    parameter MEM_READ_DELAY=42,
    parameter MEM_WRITE_DELAY=42,
    parameter MEM_READY_HOLD=15,
    parameter BASE_ADDR=32'h0000_0a00,
    parameter END_ADDR=32'h0000_0aff
);

bit [31:0] mem_entries [0:MAIN_MEM_SIZE * 8 / 32 - 1];
bit [31:0] mem_read_val;
bit [31:0] mem_idx;
bit [31:0] mem_data_exp;

bit mem_ready;

function new();
    logic [$clog2(MAIN_MEM_SIZE * 8 / 32) - 1 : 0] init_addr;

    for(init_addr = BASE_ADDR; init_addr < END_ADDR; init_addr = init_addr + 4)
        this.mem_entries[init_addr >> 2] = init_addr >> 2 - BASE_ADDR >> 2;

    this.mem_ready = 0;
endfunction

task automatic mem_read(logic [31:0] mem_addr);
    integer idx = 0;
    $display("start processing read request");
    #MEM_READ_DELAY;
    $display("start generating read data");
    this.mem_read_val = this.mem_entries[mem_addr / 4];
    this.mem_ready = 1;
    #MEM_READY_HOLD this.mem_ready = 0;
    this.mem_read_val = 0;
    $display("finished generating read data");
endtask

task automatic mem_write(logic [31:0] mem_addr, logic [31:0] mem_data);
    logic [$clog2(MAIN_MEM_SIZE * 8 / 32) - 1 : 0] write_addr;
    #MEM_WRITE_DELAY;
    write_addr = mem_addr[$clog2(MAIN_MEM_SIZE * 8 / 32)-1:0];
    this.mem_entries[write_addr] = mem_data;
endtask

endclass

module mem_sim #(
    parameter MAIN_MEM_SIZE=37268
)(  
    ahb_lite.slave mem_intf
);

// downstream transfer handler 
logic [31:0] mem_local_addr;
logic [3:0] mem_local_addr_offset;

logic [1:0] trans_out;

transfer_handler cache_mem_transfer_handler_inst(
    .clk(mem_intf.hclk),
    .rstn(mem_intf.hrstn),

    .addr(mem_intf.haddr),
    .hwrite(mem_intf.hwrite),
    .hready(mem_intf.hready),
    .hwdata(mem_intf.hwdata),
    .hburst(mem_intf.hburst),
    .htrans(mem_intf.htrans),

    .read_addr(mem_local_addr),
    .read_addr_offset(mem_local_addr_offset),
    .trans_out(trans_out)
);

memDrive #(.MEM_READ_DELAY(0)) driver_obj;

initial begin
    driver_obj = new();
end

always_ff @(posedge mem_intf.hclk or negedge mem_intf.hrstn) begin
    if(~mem_intf.hrstn);
    else if(~mem_intf.hwrite && (trans_out == TRANS_TYPES'(NONSEQ) || trans_out == TRANS_TYPES'(SEQ))) driver_obj.mem_read(mem_local_addr);
end

always begin
    mem_intf.hrdata = driver_obj.mem_read_val;
    mem_intf.hready = driver_obj.mem_ready;
    #1;
end

endmodule