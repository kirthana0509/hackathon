module phase1 (
    input clk,
    input reset,
    input code_in,
    output reg phase1_done,
    output reg phase1_fail,
    output reg alarm
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase1_done <= 0;
            phase1_fail <= 0;
            alarm <= 0;
        end else begin
            phase1_done <= 1;
            phase1_fail <= 0;
            alarm <= 0;
        end
    end
endmodule

module phase2 (
    input clk,
    input reset,
    input check,
    input [3:0] switch_in,
    output reg phase2_done,
    output reg phase2_fail,
    output reg alarm
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase2_done <= 0;
            phase2_fail <= 0;
            alarm <= 0;
        end else begin
            phase2_done <= 1;
            phase2_fail <= 0;
            alarm <= 0;
        end
    end
endmodule

module phase3 (
    input clk,
    input reset,
    input [2:0] dir_in,
    input valid,
    output reg phase3_done,
    output reg phase3_fail,
    output reg alarm
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase3_done <= 0;
            phase3_fail <= 0;
            alarm <= 0;
        end else begin
            phase3_done <= 1;
            phase3_fail <= 0;
            alarm <= 0;
        end
    end
endmodule

module phase4 (
    input clk,
    input reset,
    input check,
    input [7:0] plate_in,
    output reg phase4_done,
    output reg phase4_fail,
    output reg alarm
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase4_done <= 0;
            phase4_fail <= 0;
            alarm <= 0;
        end else begin
            phase4_done <= 1;
            phase4_fail <= 0;
            alarm <= 0;
        end
    end
endmodule

module phase5_time_lock (
    input clk,
    input reset,
    output reg [1:0] time_lock_out,
    output reg phase5_done,
    output reg phase5_fail,
    output reg alarm
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            time_lock_out <= 0;
            phase5_done <= 0;
            phase5_fail <= 0;
            alarm <= 0;
        end else begin
            time_lock_out <= 2'b11;
            phase5_done <= 1;
            phase5_fail <= 0;
            alarm <= 0;
        end
    end
endmodule

module top_module (
    input clk,
    input reset,
    input code_in,
    input check2,
    input [3:0] switch_in,
    input valid3,
    input [2:0] dir_in,
    input check4,
    input [7:0] plate_in,

    output reg all_done,
    output [1:0] time_lock_out,
    output reg vault,
    output reg waltescape,
    output reg epwave,
    output reg alarm
);

    wire phase1_done, phase1_fail, alarm1;
    wire phase2_done, phase2_fail, alarm2;
    wire phase3_done, phase3_fail, alarm3;
    wire phase4_done, phase4_fail, alarm4;
    wire phase5_done, phase5_fail, alarm5;

    typedef enum reg [2:0] {
        PH1 = 3'd0,
        PH2 = 3'd1,
        PH3 = 3'd2,
        PH4 = 3'd3,
        PH5 = 3'd4,
        DONE_STATE = 3'd5
    } top_state_t;

    reg [2:0] current_state, next_state;
    reg vault_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= PH1;
            vault <= 0;
            waltescape <= 0;
            epwave <= 0;
            vault_d <= 0;
        end else begin
            current_state <= next_state;
            if (next_state == DONE_STATE)
                vault <= 1;
            else
                vault <= 0;

            if (current_state != DONE_STATE && next_state == DONE_STATE)
                waltescape <= 1;
            else
                waltescape <= 0;

            vault_d <= vault;
            epwave <= (~vault_d) & vault;
        end
    end

    always @(*) begin
        next_state = current_state;
        all_done = 0;
        case (current_state)
            PH1: begin
                if (phase1_fail)
                    next_state = PH1;
                else if (phase1_done)
                    next_state = PH2;
            end
            PH2: begin
                if (phase2_fail)
                    next_state = PH2;
                else if (phase2_done)
                    next_state = PH3;
            end
            PH3: begin
                if (phase3_fail)
                    next_state = PH2;
                else if (phase3_done)
                    next_state = PH4;
            end
            PH4: begin
                if (phase4_fail)
                    next_state = PH2;
                else if (phase4_done)
                    next_state = PH5;
            end
            PH5: begin
                if (phase5_fail)
                    next_state = PH2;
                else if (phase5_done)
                    next_state = DONE_STATE;
            end
            DONE_STATE: begin
                all_done = 1;
                next_state = DONE_STATE;
            end
            default: next_state = PH1;
        endcase
    end

    assign alarm = alarm1 | alarm2 | alarm3 | alarm4 | alarm5;

    phase1 phase1_inst (
        .clk(clk),
        .reset(reset || (current_state != PH1)),
        .code_in(code_in),
        .phase1_done(phase1_done),
        .phase1_fail(phase1_fail),
        .alarm(alarm1)
    );

    phase2 phase2_inst (
        .clk(clk),
        .reset(reset || (current_state != PH2)),
        .check(check2),
        .switch_in(switch_in),
        .phase2_done(phase2_done),
        .phase2_fail(phase2_fail),
        .alarm(alarm2)
    );

    phase3 phase3_inst (
        .clk(clk),
        .reset(reset || (current_state != PH3)),
        .dir_in(dir_in),
        .valid(valid3),
        .phase3_done(phase3_done),
        .phase3_fail(phase3_fail),
        .alarm(alarm3)
    );

    phase4 phase4_inst (
        .clk(clk),
        .reset(reset || (current_state != PH4)),
        .check(check4),
        .plate_in(plate_in),
        .phase4_done(phase4_done),
        .phase4_fail(phase4_fail),
        .alarm(alarm4)
    );

    phase5_time_lock phase5_inst (
        .clk(clk),
        .reset(reset || (current_state != PH5)),
        .time_lock_out(time_lock_out),
        .phase5_done(phase5_done),
        .phase5_fail(phase5_fail),
        .alarm(alarm5)
    );

endmodule
