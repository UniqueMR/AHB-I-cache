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
reg [31:0] local_data;

reg [31:0] next_addr;
reg [31:0] next_data;

always_ff @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        local_data <= 0;
        local_addr <= 0;
    end
    else begin
        local_data <= next_data;
        local_addr <= next_addr;
    end
end

always_comb begin
    if(hwrite);
    else begin
        next_addr = addr : local_addr;
        next_data = hready ? hrdata : local_data;
    end
end

assign read_data = local_data;
assign read_addr = local_addr;

endmodule