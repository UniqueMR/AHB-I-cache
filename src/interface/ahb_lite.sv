interface ahb_lite;
    logic hclk;
    logic hrstn;

    logic hready;
    logic hready_in;
    logic hresp;

    logic [31:0] hrdata;

    logic [31:0] haddr;
    
    logic hwrite;
    logic [2:0] hsize;
    logic [2:0] hburst;
    logic [3:0] hport;
    logic [1:0] htrans;
    logic hmastlock;

    logic [31:0] hwdata;

    logic hselx;

    modport master (
    input hclk,
    input hrstn,

    input hready,
    input hresp,

    input hrdata,
    
    output haddr,
    output hwrite,
    output hsize,
    output hburst,
    output hport,
    output htrans,
    output hmastlock,

    output hwdata
    );

    modport slave (
    input hclk,
    input hrstn,

    input hselx,
    input haddr,
    input hwrite,
    input hsize,
    input hburst,
    input hport,
    input htrans,
    input hmastlock,
    input hready_in,

    input hwdata,

    output hready,
    output hresp,
    output hrdata
    );

endinterface 