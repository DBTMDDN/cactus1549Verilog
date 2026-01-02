module top_module1(
    input clk,
    input reset,
    input in,
    output reg [7:0] out_byte,
    output done
);
    parameter S1 = 3'h0;
    parameter S2 = 3'h1;
    parameter S3 = 3'h2;
    parameter S4 = 3'h3;
    parameter S5 = 3'h4;

    reg [2:0] state;
    reg [2:0] n_state;
    reg [3:0] cnt;

    wire odd;
    wire rst;

    assign rst = (state != S2); 

    parity u_parity (
        .clk(clk),
        .reset(rst),
        .in(in),
        .odd(odd)
    );

    always @(state or in or cnt or odd) begin
        case(state)
            S1: begin // Idle
                if (~in) 
                    n_state = S2;
                else 
                    n_state = S1;
            end

            S2: begin 
                if (cnt == 4'h9) begin
                    if (in == ~odd) 
                        n_state = S3;
                    else 
                        n_state = S5;
                end
                else begin
                    n_state = S2;
                end
            end

            S3: begin 
                if (in) 
                    n_state = S4;
                else 
                    n_state = S5;
            end

            S4: begin
                if (~in) 
                    n_state = S2;
                else 
                    n_state = S1;
            end

            S5: begin
                if (in) 
                    n_state = S1;
                else 
                    n_state = S5;
            end

            default: n_state = S1;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= S1;
            cnt <= 4'h0;
        end
        else begin
            state <= n_state;
            if (n_state == S2) begin
                cnt <= cnt + 4'h1;
                if (cnt >= 4'h1) begin
                    out_byte[cnt - 4'h1] <= in;
                end
            end
            if (n_state == S3 || n_state == S4 || n_state == S5 || n_state == S1) begin
                cnt <= 4'h0;
            end
        end
    end
    
    assign done = (state == S4);

endmodule