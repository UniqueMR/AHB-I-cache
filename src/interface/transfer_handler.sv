`include "./src/include/interface_pkg.svh"

module transfer_handler(
    input clk,
    input rstn,
    input [31:0] addr,
    input hwrite,
    input [31:0] hrdata,
    input hready,
    input [31:0] hwdata,
    input [2:0] hburst,
    input [1:0] htrans,
    
    output [31:0] read_addr,
    output [31:0] read_data,
    output [1:0] trans_out
);

parameter WRAP4_BOUNDARY_MASK = 32'hFFFF_FFF0;

reg [31:0] local_addr, next_addr;
reg [31:0] base_addr, next_base_addr;
reg [31:0] offset_addr, next_offset_addr;

BURST_TYPES burst_type;
assign burst_type = BURST_TYPES'(hburst);

TRANS_TYPES trans_type_in;
TRANS_TYPES trans_type_out;

assign trans_type_in = TRANS_TYPES'(htrans);

reg [1:0] cnt_burst;
reg [1:0] next_cnt_burst;

always_ff @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        local_addr <= addr;
        cnt_burst <= 2'b11;
        base_addr <= 0;
        offset_addr <= 0;
    end
    else begin
        local_addr <= next_addr;
        cnt_burst <= next_cnt_burst;
        base_addr <= next_base_addr;
        offset_addr <= next_offset_addr;
    end
end

always_comb begin
    if(burst_type == WRAP4)
        if(trans_type_in == NONSEQ) next_cnt_burst = 0;
        else next_cnt_burst = hready ? (cnt_burst == 2'b11 ? cnt_burst : cnt_burst + 1) : cnt_burst;
end

always_comb begin
    case(burst_type)
        SINGLE: next_addr = hready ? addr : local_addr;
        WRAP4: begin
            if(trans_type_in == NONSEQ) begin
                next_addr = addr;
                next_base_addr = next_addr & WRAP4_BOUNDARY_MASK;
                next_offset_addr = next_addr - next_base_addr;
            end
            else begin
                next_addr = hready ? base_addr + offset_addr : local_addr;
                next_offset_addr = hready ? ((offset_addr + 4) == 32'h10 ? 0 : offset_addr + 4) : offset_addr;
                next_base_addr = base_addr;
            end
        end
    endcase
end

assign read_data = hrdata;
assign read_addr = local_addr;

endmodule