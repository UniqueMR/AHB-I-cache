module cache_state_handler #(
    parameter IDLE=0,
    parameter CACHE_REQ_HANDLE=1,
    parameter MEM_REQ_HANDLE=2
) (
    input clk,
    input rst,

    input read_en,
    input hit,
    input mem_ready

    output reg [1:0] state
);

reg [1:0] next_state;

always_ff @(posedge clk or negedge rst)    begin
    if(~rst)    state <= IDLE;
    else state <= next_state;
end

always_comb begin
    case(state)
        IDLE: begin
            if(read_en) next_state = hit ? CACHE_REQ_HANDLE : MEM_REQ_HANDLE;
            else next_state = IDLE;
        end
        CACHE_REQ_HANDLE: next_state = IDLE;
        MEM_REQ_HANDLE: next_state = mem_ready ? IDLE : MEM_REQ_HANDLE;
        default: next_state = IDLE;
    endcase
end

endmodule