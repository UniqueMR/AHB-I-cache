module interface_tb_slave(
    ahb_lite.slave ahb_lite_s
);
    always @(posedge ahb_lite_s.hclk or negedge ahb_lite_s.hrstn) begin
        if (!ahb_lite_s.hrstn) begin
            ahb_lite_s.hready_out <= 1'b0;
            ahb_lite_s.hrdata <= 32'd0;
        end else if (ahb_lite_s.hselx && ahb_lite_s.hwrite) begin
            ahb_lite_s.hready_out <= 1'b1; // Ready to accept data
            ahb_lite_s.hrdata <= ahb_lite_s.hwdata + 32'd1; // Example processing
        end
    end

endmodule