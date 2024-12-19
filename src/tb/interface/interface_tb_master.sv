module interface_tb_master(
    ahb_lite.master ahb_lite_m
);
    always @(posedge ahb_lite_m.hclk or negedge ahb_lite_m.hrstn) begin
        if (!ahb_lite_m.hrstn) begin
            ahb_lite_m.haddr <= 32'd0;
            ahb_lite_m.hwrite <= 1'b0;
        end else begin
            ahb_lite_m.haddr <= ahb_lite_m.haddr + 32'd4; // Increment address
            ahb_lite_m.hwrite <= 1'b1;              // Write operation
        end
    end
    
endmodule