module addr_parser #(
    parameter CACHE_LINE=128,
    parameter CACHE_SIZE=8192
) (
    input [31:0] addr,
    output [31 - $clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32) - 2:0] tag,
    output [$clog2(CACHE_SIZE * 8/CACHE_LINE)-1:0] index,
    output [$clog2(CACHE_LINE/32)-1:0] offset
);

    assign {tag, index, offset} = addr[31:2];
    
endmodule

module line_segment_selector(
    input [127:0] data_line,
    input [1:0] offset,
    output logic [31:0] selected_data
);

always_comb begin
    case(offset)
        2'd0: selected_data = data_line[31:0];
        2'd1: selected_data = data_line[63:32];
        2'd2: selected_data = data_line[95:64];
        2'd3: selected_data = data_line[127:96];
    endcase
end

endmodule

module sim_addr_data_mapping_gen #(
    parameter BASE_ADDR = 32'h0000_0a00
) (
    input [31:0] addr,
    output [31:0] mem_idx,
    output [31:0] sim_data_exp
);

    assign mem_idx = {2'b00, addr[31:2]};
    assign sim_data_exp = addr - BASE_ADDR;

endmodule
