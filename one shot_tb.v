`timescale 1ns/1ps
module tb_one_shot();
reg clk = 0;
reg trigger = 0;
reg async_reset = 0;
wire pulse;
one_shot uut (
    .clk(clk),
    .trigger(trigger),
    .async_reset(async_reset),
    .pulse(pulse)
);
always #5 clk = ~clk; 
initial begin
    $dumpfile("one_shot.vcd");
    $dumpvars(0, tb_one_shot);
    async_reset = 1; #10;
    async_reset = 0; #10;
  #10 trigger = 1; #10 trigger = 0;
  #30 trigger = 1; #10 trigger = 0;
   #30 async_reset = 1; #5 async_reset = 0;
  #30 trigger = 1; #10 trigger = 0;
   #50 $finish;
end
endmodule

