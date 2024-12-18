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
    output hit,
    
    // main mem interface
    output [31:0] mem_addr,
    input [127:0] mem_data_in,
    input mem_ready,
    output reg mem_req
);
    parameter CACHE_LINE = 128;

    // parse the requested address from 
    wire [31 - $clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32):0] tag;
    wire [$clog2(CACHE_SIZE * 8/CACHE_LINE)-1:0] index;
    wire [$clog2(CACHE_LINE/32)-1:0] offset;

    typedef struct packed{
        reg [CACHE_LINE-1:0] cache_line;
        reg valid;
        reg [31 - $clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32):0] tag;
    } cache_entry_t;

    cache_entry_t cache_entries [0:CACHE_SIZE * 8 / 128 -1];

    reg [31:0] mem_data_out_reg;

    reg [31:0] cache_data;
    reg [31:0] mem_data;

    addr_parser #(.CACHE_LINE(CACHE_LINE), .CACHE_SIZE(CACHE_SIZE)) addr_parser_inst(.addr(addr), .tag(tag), .index(index), .offset(offset));

    line_segment_selector line_segment_selector_cache_inst(cache_entries[index].cache_line, offset, cache_data);
    line_segment_selector line_segment_selector_mem_inst(mem_data_in, offset, mem_data);


    parameter IDLE = 0;
    parameter CACHE_REQ_HANDLE = 1;
    parameter MEM_REQ_HANDLE = 2


    reg [1:0] cache_state;

    cache_state_handler #(
        .IDLE(IDLE),
        .CACHE_REQ_HANDLE(CACHE_REQ_HANDLE),
        .MEM_REQ_HANDLE(MEM_REQ_HANDLE)
    ) cache_state_handler_inst(
        .clk(clk),
        .rst(rst),

        .read_en(read_en),
        .hit(hit),
        .mem_ready(mem_ready),

        .state(cache_state),
        .mem_req(mem_req)
    );

    integer idx;

    // initialization
    always_ff @(posedge clk or negedge rst) begin
    if(~rst)    begin
        data_out <= 0;
        for(idx = 0; idx < CACHE_SIZE * 8/CACHE_LINE; idx = idx + 1)    
            cache_entries[idx].valid = 1'b0;
    end
    end

    always_comb begin
        data_out = 0;
        mem_addr = 0;        
        case(state)
            IDLE:
            CACHE_REQ_HANDLE:   begin
                data_out = cache_data;
            end
            MEM_REQ_HANDLE: begin
                data_out = mem_ready ? mem_data : 0;
                mem_addr = mem_req ? addr : 0;
            end
        endcase
    end

    assign hit = read_en && cache_entries[index].valid == 1;

endmodule
