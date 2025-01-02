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

reg [31:0] local_addr;

reg [31:0] next_addr;

BURST_TYPES burst_type;

assign burst_type = hburst;

reg [1:0] cnt_wrap4;

always_ff @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        local_addr <= addr;
        cnt_wrap4 <= 0;
    end
    else begin
        local_addr <= next_addr;
        cnt_wrap4 <= hready ? (cnt_wrap4 == 2'b11 ? 0 : cnt_wrap4 + 1) : cnt_wrap4;
    end
end

always_comb begin
    next_addr = hready ? addr : local_addr;
end

assign read_data = hrdata;
assign read_addr = local_addr;

endmodule