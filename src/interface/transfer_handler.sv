module transfer_handler(
    input clk,
    input rstn,
    input [31:0] addr,
    input hwrite,
    input [31:0] hrdata,
    input hready,
    input [31:0] hwdata,

    output [31:0] read_addr,
    output [31:0] read_data
);

reg [31:0] local_addr;

reg [31:0] next_addr;

always_ff @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        local_addr <= addr;
    end
    else begin
        local_addr <= next_addr;
    end
end

always_comb begin
    if(hwrite);
    else begin
        next_addr = hready ? addr : local_addr;
    end
end

assign read_data = hrdata;
assign read_addr = local_addr;

endmodule