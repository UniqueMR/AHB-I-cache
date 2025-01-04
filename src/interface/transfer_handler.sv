`include "./src/include/interface_pkg.svh"

module transfer_handler(
    input clk,
    input rstn,
    input [31:0] addr,
    input hwrite,
    input [31:0] hrdata,
    input hready,
    input [31:0] hwdata,
    input [3:0] hburst,
    
    output [1:0] htrans,
    output [31:0] read_addr,
    output [31:0] read_data
);

parameter WRAP4_BOUNDARY_MASK = 32'hFFFF_FFF0;

reg [31:0] local_addr;
reg [31:0] next_addr;
reg [31:0] base_addr;
reg [31:0] offset_addr;
reg [31:0] next_offset_addr;

BURST_TYPES burst_type;
assign burst_type = BURST_TYPES'(hburst);

reg [1:0] cnt_wrap4;

always_ff @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        local_addr <= addr;
        cnt_wrap4 <= 0;
        offset_addr <= 0;
    end
    else begin
        local_addr <= next_addr;
        cnt_wrap4 <= hready ? (cnt_wrap4 == 2'b11 ? 0 : cnt_wrap4 + 1) : cnt_wrap4;
        offset_addr <= next_offset_addr;
    end
end

always_comb begin
    next_offset_addr = hready ? ((offset_addr + 4) == 32'h10 ? 0 : offset_addr + 4) : offset_addr;
    case(burst_type)
        SINGLE: next_addr = hready ? addr : local_addr;
        WRAP4: begin
            if(cnt_wrap4 == 2'b11)  next_addr = hready ? addr : local_addr;
            else if(cnt_wrap4 == 2'b00) begin
                base_addr = addr & WRAP4_BOUNDARY_MASK;
                next_addr = hready ? addr : local_addr;
            end
            else next_addr = hready ? base_addr + offset_addr : local_addr;
        end
    endcase
end

assign read_data = hrdata;
assign read_addr = local_addr;

endmodule