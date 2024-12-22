module top #(
    parameter CACHE_SIZE = 8192
)(
    ahb_lite.slave upstream_intf,
    ahb_lite.master downstream_intf
);

// entries 
parameter CACHE_LINE = 128;

typedef struct packed{
    reg [CACHE_LINE-1:0] cache_line;
    reg valid;
    reg [31 - $clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32):0] tag;
} cache_entry_t;

cache_entry_t cache_entries [0:CACHE_SIZE * 8 / 128 -1];

logic [31:0] idx;
logic [31:0] init_addr;

assign init_addr = 32'h0000_0a00;

always_ff @(posedge upstream_intf.hclk or negedge upstream_intf.hrstn) begin    
    if(~upstream_intf.hrstn) begin
       for(idx = 0; idx < 16'hFF; idx = idx + 1) begin
        cache_entries[base_addr + idx].cache_line = {idx, idx, idx, idx};
        cache_entries[base_addr + idx].valid = 1'b1;
       end
    end
end

// upstream transfer handler
logic [31:0] cache_local_addr;
logic [31:0] cache_local_data;

transfer_handler cpu_cache_transfer_handler_inst(
    .clk(upstream_intf.hclk),
    .rstn(upstream_intf.hrstn),

    .addr(upstream_intf.haddr),
    .hwrite(upstream_intf.hwrite),
    .hrdata(cache_local_data),
    .hready(upstream_intf.hready),
    .hwdata(upstream_intf.hwdata),

    .read_addr(cache_local_addr),
    .read_data(upstream_intf.hrdata)
);

// cache entries access

// addr parsing 
wire [31 - $clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32):0] tag;
wire [$clog2(CACHE_SIZE * 8/CACHE_LINE)-1:0] index;
wire [$clog2(CACHE_LINE/32)-1:0] offset;

addr_parser #(.CACHE_LINE(CACHE_LINE), .CACHE_SIZE(CACHE_SIZE)) addr_parser_inst(.addr(cache_local_addr), .tag(tag), .index(index), .offset(offset));

// cache entries access
line_segment_selector line_segment_selector_cache_inst(cache_entries[index].cache_line, offset, cache_local_data);

always_comb begin
    upstream_intf.hready = 1'b1;
end

endmodule
