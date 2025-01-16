`include "./src/include/interface_pkg.svh"

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
logic [3:0] local_addr_offset;
logic [1:0] trans_out;

logic mem_burst_ready;
logic [127:0] cache_mem_buf;

transfer_handler cpu_cache_transfer_handler_inst(
    .clk(upstream_intf.hclk),
    .rstn(upstream_intf.hrstn),

    .addr(upstream_intf.haddr),
    .hwrite(upstream_intf.hwrite),
    .hready(upstream_intf.hready),
    .hwdata(upstream_intf.hwdata),
    .hburst(upstream_intf.hburst),
    .htrans(upstream_intf.htrans),

    .read_addr(local_addr),
    .read_addr_offset(local_addr_offset),
    .trans_out(trans_out)
);

// cache entries access

// addr parsing 
wire [31 - $clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32):0] tag;
wire [$clog2(CACHE_SIZE * 8/CACHE_LINE)-1:0] index;
wire [$clog2(CACHE_LINE/32)-1:0] offset;

addr_parser #(.CACHE_LINE(CACHE_LINE), .CACHE_SIZE(CACHE_SIZE)) addr_parser_inst(.addr(local_addr), .tag(tag), .index(index), .offset(offset));

// hit or miss
wire hit;
assign hit = cache_entries[index].valid == 1'b0 ? 0 : (cache_entries[index].tag == tag ? 1'b1 : 1'b0);

// cache entries access & mem access
logic [31:0] cache_local_data, mem_local_data;
line_segment_selector line_segment_selector_cache_inst(cache_entries[index].cache_line, offset, cache_local_data);
line_segment_selector line_segment_selector_mem_inst(cache_mem_buf, offset, mem_local_data);

assign upstream_intf.hready = hit ? 1'b1 : mem_burst_ready;
assign upstream_intf.hrdata = hit ? cache_local_data : mem_local_data;
assign downstream_intf.hwrite = hit ? 1'b1 : 1'b0;
assign downstream_intf.haddr = local_addr;

// update cache entries in the case of hit 
always_ff @(posedge upstream_intf.hclk or negedge upstream_intf.hrstn) begin
    if(~upstream_intf.hrstn);
    else if(~hit && mem_burst_ready) begin
        cache_entries[index].cache_line <= cache_mem_buf;
        cache_entries[index].valid <= 1'b1;
        cache_entries[index].tag <= tag;  
    end
end

// downstream transfer handler
logic [31:0] mem_addr;
logic [3:0] mem_addr_offset;
logic [1:0] mem_trans_out;

transfer_handler cache_mem_transfer_handler_inst(
    .clk(downstream_intf.hclk),
    .rstn(downstream_intf.hrstn),

    .addr(downstream_intf.haddr),
    .hwrite(downstream_intf.hwrite),
    .hready(downstream_intf.hready),
    .hwdata(downstream_intf.hwdata),
    .hburst(downstream_intf.hburst),
    .htrans(downstream_intf.htrans),

    .read_addr(mem_addr),
    .read_addr_offset(mem_addr_offset),
    .trans_out(mem_trans_out)
);

logic [1:0] last_mem_trans_out;

always_ff @(posedge downstream_intf.hclk or negedge downstream_intf.hrstn) begin
    if(~downstream_intf.hrstn) begin
        cache_mem_buf <= 0;
        last_mem_trans_out <= 0;
    end

    else if(downstream_intf.hready) begin
        last_mem_trans_out <= mem_trans_out; 
        if(mem_trans_out == TRANS_TYPES'(NONSEQ) || mem_trans_out == TRANS_TYPES'(SEQ))
            case(mem_addr_offset)
                4'h0: cache_mem_buf[31:0] <= downstream_intf.hrdata;
                4'h4: cache_mem_buf[63:32] <= downstream_intf.hrdata;
                4'h8: cache_mem_buf[95:64] <= downstream_intf.hrdata;
                4'hc: cache_mem_buf[127:96] <= downstream_intf.hrdata;
            endcase 
    end
end

assign downstream_intf.htrans = hit ? TRANS_TYPES'(IDLE) : trans_out;
assign downstream_intf.hburst = TRANS_TYPES'(WRAP4);

assign mem_burst_ready = last_mem_trans_out == TRANS_TYPES'(SEQ) && mem_trans_out == TRANS_TYPES'(IDLE); 

endmodule
