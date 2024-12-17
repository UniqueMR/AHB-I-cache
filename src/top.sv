module top #(
    parameter CACHE_SIZE = 8192
)(
    // clock and reset
    input clk,
    input rst,
    
    // processor interface
    input [31:0] addr,
    output reg [31:0] data_out,
    input read_en,
    output reg hit,
    
    // main mem interface
    output [31:0] mem_addr,
    input [127:0] mem_data_in,
    input mem_ready,
    output mem_req
);
    parameter CACHE_LINE = 128;

    // parse the requested address from 
    wire [31 - $clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32):0] tag;
    wire [$clog2(CACHE_SIZE * 8/CACHE_LINE)-1:0] index;
    wire [$clog2(CACHE_LINE/32)-1:0] offset;

    addr_parser #(.CACHE_LINE(CACHE_LINE), .CACHE_SIZE(CACHE_SIZE)) addr_parser_inst(.addr(addr), .tag(tag), .index(index), .offset(offset));

    typedef struct packed{
        reg [CACHE_LINE-1:0] cache_line;
        reg valid;
        reg [31 - $clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32):0] tag;
    } cache_entry_t;

    parameter HIT=1;
    parameter MISS=0;
    parameter TRUE=1;
    parameter FALSE=0;
    
    cache_entry_t cache_entries [0:CACHE_SIZE * 8 / 128 -1];

    reg [31:0] mem_data_out_reg;

    reg [31:0] cache_data;
    reg [31:0] mem_data;

    line_segment_selector line_segment_selector_cache_inst(cache_entries[index].cache_line, offset, cache_data);
    line_segment_selector line_segment_selector_mem_inst(mem_data_in, offset, mem_data);

    always_ff @(posedge clk or negedge rst) begin
    if(~rst)    begin
        data_out <= 0;
        integer idx;
        for(idx = 0; idx < CACHE_SIZE * 8/CACHE_LINE; idx = idx + 1)    
            cache_entries[idx].valid = 1'b0;
    end
    else    begin
        if(read_en) data_out <= hit ? cache_data : mem_data_out_reg;  
    end
    end

    always_comb begin
        if(mem_req) mem_data_out_reg = mem_data;
    end

    reg mem_req_reg;
    assign mem_req = mem_req_reg;
    
    // handle hit or miss
    always_comb begin
    hit=MISS;
    mem_req_reg=FALSE;
    if(read_en) begin
        if(cache_entries[addr].valid == HIT)  hit = HIT;
        else    hit = MISS;           
    end
    if(read_en && ~hit) mem_req_reg = TRUE;    
    end
endmodule
