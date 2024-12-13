
typedef struct packed{
    reg [127:0] cache_data;
    reg valid;
    reg tag;
} cache_entry_t;

module top #(
    parameter CACHE_SIZE = 128,
)(
    // clock and reset
    input clk,
    input rst,
    
    // processor interface
    input [31:0] addr,
    output [31:0] data_out,
    input wire read_en,
    output hit,
    
    // main mem interface
    output [31:0] mem_addr,
    input [127:0] mem_data_in,
    input mem_ready,
    output mem_req
);
    cache_entry_t cache_entries [0:CACHE_SIZE-1];

endmodule