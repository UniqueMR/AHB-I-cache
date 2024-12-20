module interface_tb;

    ahb_lite ahb_lite_inst();
    initial begin
        ahb_lite_inst.hclk = 0;
        forever #5 ahb_lite_inst.hclk = ~ahb_lite_inst.hclk; 
    end

    initial begin
        ahb_lite_inst.hrstn = 0;
        #15 ahb_lite_inst.hrstn = 1; 
    end

    interface_tb_master u_master ( .ahb_lite_m(ahb_lite_inst.master) );

    interface_tb_slave u_slave ( .ahb_lite_s(ahb_lite_inst.slave) );

    initial begin
        $monitor($time, " hclk=%b hrstn=%b haddr=%h hwrite=%b hready=%b hwdata=%h hrdata=%h",
            ahb_lite_inst.hclk, ahb_lite_inst.hrstn, ahb_lite_inst.haddr, ahb_lite_inst.hwrite, ahb_lite_inst.hready, ahb_lite_inst.hwdata, ahb_lite_inst.hrdata);
    end

    initial begin
        #100 $finish; 
    end

endmodule