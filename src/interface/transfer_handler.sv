`include "./src/include/interface_pkg.svh"

module transfer_handler(
    input clk,
    input rstn,
    input [31:0] addr,
    input hwrite,
    input hready,
    input [31:0] hwdata,
    input [2:0] hburst,
    input [1:0] htrans,
    
    output reg [31:0] read_addr,
    output reg [1:0] trans_out,
    output [3:0] read_addr_offset
);

parameter WRAP4_BOUNDARY_MASK = 32'hFFFF_FFF0;

reg [31:0] local_addr, next_addr;
reg [31:0] base_addr, next_base_addr;
reg [31:0] offset_addr, next_offset_addr;

BURST_TYPES burst_type;
assign burst_type = BURST_TYPES'(hburst);

TRANS_TYPES trans_type_in;
TRANS_TYPES next_trans_out;

assign trans_type_in = TRANS_TYPES'(htrans);

reg [1:0] cnt_burst;
reg [1:0] next_cnt_burst;

always_ff @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        local_addr <= addr;
        cnt_burst <= 2'b11;
        base_addr <= 0;
        offset_addr <= 0;
        trans_out <= 0;
    end
    else begin
        local_addr <= next_addr;
        cnt_burst <= next_cnt_burst;
        base_addr <= next_base_addr;
        offset_addr <= next_offset_addr;
        trans_out <= TRANS_TYPES'(next_trans_out);
    end
end

always_comb begin
    if(burst_type == WRAP4)
        if(trans_type_in == NONSEQ) next_cnt_burst = 0;
        else next_cnt_burst = hready ? (cnt_burst == 2'b11 ? cnt_burst : cnt_burst + 1) : cnt_burst;
end

always_comb begin
    case(burst_type)
        SINGLE: begin 
            read_addr = local_addr;
            next_addr = trans_type_in == NONSEQ ? addr : local_addr;
            next_trans_out = trans_type_in == NONSEQ ? IDLE : trans_type_in;
        end
        WRAP4: begin
            read_addr = trans_out == TRANS_TYPES'(IDLE) ? 0 : local_addr;
            if(trans_type_in == NONSEQ) begin
                next_addr = addr;
                next_base_addr = next_addr & WRAP4_BOUNDARY_MASK;
                next_offset_addr = next_addr - next_base_addr;
                next_trans_out = NONSEQ;
            end
            else begin
                next_trans_out = cnt_burst < 2'b11 ? SEQ : IDLE;
                next_offset_addr = (next_trans_out == TRANS_TYPES'(SEQ) && hready) ? ((offset_addr + 4) == 32'h10 ? 0 : offset_addr + 4) : offset_addr;
                next_base_addr = base_addr;
                next_addr = (next_trans_out == TRANS_TYPES'(SEQ) && hready) ? next_base_addr + next_offset_addr : local_addr;
            end
        end
    endcase
end

assign read_addr_offset = offset_addr[3:0];

endmodule