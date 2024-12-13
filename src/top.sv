
typedef struct packed{
    reg [127:0] cache_data;
    reg valid;
    reg tag;
} cache_entry_t;

module top #(
    parameter CACHE_SIZE = 128
)(
    // clock and reset
    input clk,
    input rst,
    
    // processor interface
    input [31:0] addr,
    output [31:0] data_out,
    input wire read_en,
    output hit,
    
    // main mem interface
    output [31:0] mem_addr,
    input [127:0] mem_data_in,
    Tinput mem_ready,
    output mem_req
);
    parameter HIT=1;
    parameter MISS=0;
    parameter TRUE=1;
    parameter FALSE=0;
    
    cache_entry_t cache_entries [0:CACHE_SIZE-1];

    reg [31:0] data_out_reg;
    reg [31:0] mem_data_out_reg;

    assign data_out = data_out_reg;

    always_ff @(posedge clk or negedge rst) begin
    if(~rst)    begin
        data_out_reg <= 0;
    end
    else    begin
        if(read_en) data_out_reg <= hit ? cache_entries[addr].data : mem_data_out_reg;  
    end
    end

    always_comb begin
        if(mem_req) mem_data_out_reg = mem_data_in[31:0];
    end

    reg hit_reg;
    reg mem_req_reg;
    assign hit = hit_reg;
    assign mem_req = mem_req_reg;
    
    // handle hit or miss
    always_comb begin
    hit_reg=MISS;
    mem_req_reg=FLASE;
    if(read_en) begin
        if(cache_entries[addr].valid == HIT)  hit_reg = HIT;
        else    hit_reg = MISS;           
    end
    if(read_en && ~hit) mem_req_reg = TRUE;    
    end
endmodule
