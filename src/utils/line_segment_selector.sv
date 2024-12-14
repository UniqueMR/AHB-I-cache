module line_segment_selector(
    input [127:0] data_line,
    input [1:0] offset,
    output lopgic [31:0] selected_data
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