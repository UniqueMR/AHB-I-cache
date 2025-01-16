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
    
    output [31:0] read_addr,
    output [3:0] read_addr_offset,
    output reg [1:0] trans_out,
    output reg ready_out
);

parameter WRAP4_BOUNDARY_MASK = 32'hFFFF_FFF0;

reg [31:0] base_addr, next_base_addr;
reg [31:0] offset_addr, next_offset_addr;

BURST_TYPES burst_type;
TRANS_TYPES trans_type_in;

assign burst_type = BURST_TYPES'(hburst);
assign trans_type_in = TRANS_TYPES'(htrans);

reg [3:0] cnt_burst, next_cnt_burst;

always_ff @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        cnt_burst <= 4'd0;
        base_addr <= 0;
        offset_addr <= 0;
    end
    else begin
        cnt_burst <= next_cnt_burst;
        base_addr <= next_base_addr;
        offset_addr <= next_offset_addr;
    end
end

always_comb begin
    if(trans_type_in == NONSEQ) next_cnt_burst = 4'd1;
    else if(~hready) next_cnt_burst = cnt_burst;
    else begin
        case(burst_type)
            SINGLE: next_cnt_burst = cnt_burst == 4'd1 ? 4'd0 : cnt_burst + 1;
            WRAP4: next_cnt_burst = cnt_burst == 4'd4 ? 4'd0 : cnt_burst + 1;
        endcase
    end
end

always_comb begin
    case(cnt_burst)
        4'd0: trans_out = TRANS_TYPES'(IDLE);
        4'd1: trans_out = TRANS_TYPES'(NONSEQ);
        4'd2: trans_out = TRANS_TYPES'(SEQ);
    endcase
end

always_comb begin
    if(trans_type_in == NONSEQ) begin
        next_base_addr = addr & WRAP4_BOUNDARY_MASK;;
        next_offset_addr = addr - next_base_addr;
    end
    else if(~hready) begin
        next_base_addr = base_addr;
        next_offset_addr = offset_addr;
    end
    else begin
        case(burst_type)
            SINGLE: begin
                next_base_addr = 0;
                next_offset_addr = 0;
            end
            WRAP4: begin
                next_base_addr = cnt_burst == 4'd4 ? 0 : base_addr;
                next_offset_addr = cnt_burst == 4'd4 ? 0 : (offset_addr + 4 == 32'h10 ? 0 : offset_addr + 4);
            end
        endcase
    end
end

assign read_addr = base_addr + offset_addr;
assign read_addr_offset = offset_addr[3:0];

always_ff @(posedge clk or negedge rstn) begin
    if(~rstn) ready_out <= 0;
    else begin
        case(burst_type)
            SINGLE: ready_out <= hready && cnt_burst == 4'd1;
            WRAP4: ready_out <= hready && cnt_burst == 4'd4;
        endcase
    end 
end

endmodule