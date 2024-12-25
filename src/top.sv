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

always_ff @(posedge upstream_intf.hclk or negedge upstream_intf.hrstn) begin    
    if(~upstream_intf.hrstn) begin
       for(idx = 0; idx < CACHE_SIZE * 8/CACHE_LINE; idx = idx + 1) begin
        cache_entries[idx].valid = 1'b0;
       end
    end
end

// upstream transfer handler
logic [31:0] local_addr;
logic [31:0] local_data;

transfer_handler cpu_cache_transfer_handler_inst(
    .clk(upstream_intf.hclk),
    .rstn(upstream_intf.hrstn),

    .addr(upstream_intf.haddr),
    .hwrite(upstream_intf.hwrite),
    .hrdata(local_data),
    .hready(upstream_intf.hready),
    .hwdata(upstream_intf.hwdata),

    .read_addr(local_addr),
    .read_data(upstream_intf.hrdata)
);

// cache entries access

// addr parsing 
wire [31 - $clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32):0] tag;
wire [$clog2(CACHE_SIZE * 8/CACHE_LINE)-1:0] index;
wire [$clog2(CACHE_LINE/32)-1:0] offset;

addr_parser #(.CACHE_LINE(CACHE_LINE), .CACHE_SIZE(CACHE_SIZE)) addr_parser_inst(.addr(local_addr), .tag(tag), .index(index), .offset(offset));

// hit or miss
wire hit;
reg hit_r;
assign hit = cache_entries[index].valid == 1'b0 ? 0 : (cache_entries[index].tag == tag ? 1'b1 : 1'b0);

always_ff @(posedge upstream_intf.hclk or negedge upstream_intf.hrstn) begin
    if(~upstream_intf.hrstn) hit_r <= 0;
    else hit_r <= upstream_intf.hready ? hit : hit_r;
end

// cache entries access
logic [31:0] cache_local_data;
line_segment_selector line_segment_selector_cache_inst(cache_entries[index].cache_line, offset, cache_local_data);

assign upstream_intf.hready = hit_r ? 1'b1 : downstream_intf.hready;
assign local_data = hit_r ? cache_local_data : downstream_intf.hrdata; 

// update cache entries in the case of hit 
always_ff @(posedge upstream_intf.hclk or negedge upstream_intf.hrstn) begin
    if(~upstream_intf.hrstn);
    else if(downstream_intf.hready) begin
        cache_entries[index].cache_line <= 128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
        cache_entries[index].valid <= 1'b1;
        cache_entries[index].tag <= tag;  
    end
end

endmodule
