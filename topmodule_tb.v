`timescale 1ns/1ps

module top_module_tb;

    reg clk;
    reg reset;

    reg code_in;
    reg check2;
    reg [3:0] switch_in;
    reg valid3;
    reg [2:0] dir_in;
    reg check4;
    reg [7:0] plate_in;

    wire all_done;
    wire vault;
    wire waltescape;
    wire epwave;
    wire [1:0] time_lock_out;
    wire alarm;

    top_module uut (
        .clk(clk),
        .reset(reset),
        .code_in(code_in),
        .check2(check2),
        .switch_in(switch_in),
        .valid3(valid3),
        .dir_in(dir_in),
        .check4(check4),
        .plate_in(plate_in),
        .all_done(all_done),
        .vault(vault),
        .waltescape(waltescape),
        .epwave(epwave),
        .time_lock_out(time_lock_out),
        .alarm(alarm)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top_module_tb);

        reset = 1;
        code_in = 0;
        check2 = 0;
        switch_in = 4'b0000;
        valid3 = 0;
        dir_in = 3'b000;
        check4 = 0;
        plate_in = 8'h00;

        #20;
        reset = 0;

        code_in = 1;
        #20;
        code_in = 0;

        check2 = 1;
        switch_in = 4'b1010;
        #20;
        check2 = 0;

        valid3 = 1;
        dir_in = 3'b010;
        #20;
        valid3 = 0;

        check4 = 1;
        plate_in = 8'b10101010;
        #20;
        plate_in = 8'b11001100;
        #20;
        plate_in = 8'b11110000;
        #20;
        check4 = 0;

        #100;

        $display("Time %t: all_done=%b, vault=%b, waltescape=%b, epwave=%b, alarm=%b", 
                 $time, all_done, vault, waltescape, epwave, alarm);

        @(posedge clk);
        #1;
        $display("After 1 cycle epwave=%b", epwave);

        $finish;
    end
endmodule
