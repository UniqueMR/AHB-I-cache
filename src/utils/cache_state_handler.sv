module cache_state_handler #(
    parameter IDLE=0,
    parameter CACHE_REQ_HANDLE=1,
    parameter MEM_REQ_HANDLE=2
) (
    input clk,
    input rst,

    input read_en,
    input hit,
    input mem_ready,

    output reg [1:0] state,
    output reg mem_req
);

reg [1:0] next_state;

always_ff @(posedge clk or negedge rst)    begin
    if(~rst)    state <= IDLE;
    else state <= next_state;
end

always_comb begin
    case(state)
        IDLE: begin
            if(read_en) begin
                next_state = hit ? CACHE_REQ_HANDLE : MEM_REQ_HANDLE;
            end
            else next_state = IDLE;
        end
        CACHE_REQ_HANDLE: next_state = IDLE;
        MEM_REQ_HANDLE: begin
            next_state = mem_ready ? IDLE : MEM_REQ_HANDLE;
        end
        default: next_state = IDLE;
    endcase
end

always_ff @(posedge clk or negedge rst) begin
    if(~rst)    mem_req <= 0;
    else mem_req <= (state == IDLE && next_state == MEM_REQ_HANDLE) ? 1'b1 : 1'b0;   
end

endmodule