`timescale 1ns/1ps

class memDrive #(
    parameter MAIN_MEM_SIZE=32768,
    parameter MEM_READ_DELAY=40,
    parameter MEM_WRITE_DELAY=40,
    parameter MEM_READY_HOLD=15
);

bit [31:0] mem_entries [0:MAIN_MEM_SIZE * 8 / 32 - 1];
bit [127:0] mem_read_val;
bit mem_ready;

function new();
    logic [$clog2(MAIN_MEM_SIZE * 8 / 32) - 1 : 0] init_addr;

    // for(init_addr = 0; init_addr < MAIN_MEM_SIZE * 8 / 32; init_addr = init_addr + 1) 
    for(init_addr = 0; init_addr < 10; init_addr = init_addr + 1) 
        this.mem_entries[init_addr] = $urandom_range(0, 32'hFFFF_FFFF);
    this.mem_read_val = 0;
    this.mem_ready = 0;
endfunction

task automatic mem_read(logic [31:0] mem_addr);
    integer idx = 0;
    logic [$clog2(MAIN_MEM_SIZE * 8 / 32) - 1 : 0] base_addr;
    logic [31:0] mem_read_val_tmp[4];
    $display("start processing read request");
    #MEM_READ_DELAY;
    $display("start generating read data");
    base_addr = {mem_addr[$clog2(MAIN_MEM_SIZE * 8 / 32)-1:2], 2'b00};
    for(idx = 0; idx < 4; idx = idx + 1)
       mem_read_val_tmp[idx] = this.mem_entries[base_addr + idx];
    this.mem_read_val = {mem_read_val_tmp[3], mem_read_val_tmp[2], mem_read_val_tmp[1], mem_read_val_tmp[0]}; 
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
    input clk,
    input rst,

    input [31:0] mem_addr,
    input mem_req,
    output logic [127:0] mem_data_in,
    output logic mem_ready
);

memDrive driver_obj;

initial begin
    driver_obj = new();
end

always @(posedge clk or negedge rst) begin
    if (~rst)    
    else if(mem_req) driver_obj.mem_read(mem_addr);
end

always begin
    mem_data_in = driver_obj.mem_read_val;
    mem_ready = driver_obj.mem_ready;
    #1;
end

endmodule