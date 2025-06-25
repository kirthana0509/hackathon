module one_shot(
    input wire clk,
    input wire trigger,
    input wire async_reset,
    output reg pulse
);
reg trigger_d;
always @(posedge clk or posedge async_reset) begin
    if (async_reset) begin
        pulse <= 0;
        trigger_d <= 0;
    end else begin
        trigger_d <= trigger;
        pulse <= (trigger & ~trigger_d); 
    end
end
endmodule 
