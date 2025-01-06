`timescale 1ns/1ps

class memDrive #(
    parameter MAIN_MEM_SIZE=32768,
    parameter MEM_READ_DELAY=42,
    parameter MEM_WRITE_DELAY=42,
    parameter MEM_READY_HOLD=15
);

bit [31:0] mem_entries [0:MAIN_MEM_SIZE * 8 / 32 - 1];
bit [127:0] mem_read_val;
bit mem_ready;

function new();
    logic [$clog2(MAIN_MEM_SIZE * 8 / 32) - 1 : 0] init_addr;
    bit [31:0] idx;

    init_addr = 32'h0000_0a00;

    for(idx = 0; idx < 32'hFF; idx = idx + 1)
        this.mem_entries[init_addr + idx] = idx;

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
    ahb_lite.slave mem_intf
);

// downstream transfer handler 
logic [31:0] mem_local_addr;
logic [31:0] mem_local_data;

logic [1:0] trans_out;

transfer_handler cache_mem_transfer_handler_inst(
    .clk(mem_intf.hclk),
    .rstn(mem_intf.hrstn),

    .addr(mem_intf.haddr),
    .hwrite(mem_intf.hwrite),
    .hrdata(mem_local_data),
    .hready(mem_intf.hready),
    .hwdata(mem_intf.hwdata),
    .hburst(mem_intf.hburst),
    .htrans(mem_intf.htrans),

    .read_addr(mem_local_addr),
    .read_data(mem_intf.hrdata),
    .trans_out(trans_out)
);

memDrive driver_obj;

initial begin
    driver_obj = new();
end

always_ff @(posedge mem_intf.hclk or negedge mem_intf.hrstn) begin
    if(~mem_intf.hrstn);
    else if(~mem_intf.hwrite && (trans_out == TRANS_TYPES'(NONSEQ) || trans_out == TRANS_TYPES'(SEQ))) driver_obj.mem_read(mem_local_addr);
end

always begin
    mem_local_data = driver_obj.mem_read_val[31:0];
    mem_intf.hready = driver_obj.mem_ready;
    #1;
end

endmodule