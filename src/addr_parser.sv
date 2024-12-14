module addr_parser #(
    parameter CACHE_LINE=128,
    parameter CACHE_SIZE=8192
) (
    input [31:0] addr,
    output [31 - clog2(CACHE_SIZE * 8/CACHE_LINE) - $clog2(CACHE_LINE/32):0] tag,
    output [$clog2(CACHE_SIZE * 8/CACHE_LINE)-1:0] index,
    output [$clog2(CACHE_LINE/32)-1:0] offset
);

    assign {tag, index, offset} = addr;
    
endmodule