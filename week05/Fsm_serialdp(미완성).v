module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output reg [7:0] out_byte,
    output reg done
); 

    //FSM 상태
    localparam S_0 = 3'h0; // IDLE
    localparam S_1 = 3'h1; // RECV
    localparam S_2 = 3'h2; // STOP (검사)
    localparam S_3 = 3'h3; // ERROR
    localparam S_4 = 3'h4; // DONE (Moore 출력 상태)

    reg [2:0] c_state, n_state;
    reg [3:0] cnt;
    
    reg p_rst; 
    wire p_in;   

    wire odd;   
    //3. Parity 모듈 인스턴스화
    assign p_in = (c_state == S_1) ? in : 1'b0;

    parity u_parity (
        .clk    (clk),
        .reset  (p_rst),
        .in     (p_in), 
        .odd    (odd)
    );

    //FSM 블록 1 상태
    always @(posedge clk) begin
        if (reset)
            c_state <= S_0;
        else
            c_state <= n_state;
    end

    //FSM 블록 2 카운터, out_byte
    always @(posedge clk) begin
        if (reset) begin
            cnt <= 4'd0;
            out_byte <= 8'd0; // '글로벌' 리셋
        end 
        else if (p_rst) begin 
            cnt <= 4'd0;
        end
        else if (c_state == S_1) begin
            cnt <= cnt + 4'd1; 
            
            if (cnt < 4'd8) begin
                out_byte <= {in, out_byte[7:1]};
            end
        end
    end

    //FSM 블록 3: 다음 상태 및 출력 결정
    always @* begin
        // 기본값 설정
        n_state = c_state;
        done    = 1'b0; // S_4에서만 1이 됨
        p_rst   = 1'b0; 

        case (c_state)
            S_0: begin // IDLE
                if (in == 1'b0) begin
                    n_state = S_1;
                    p_rst = 1'b1; 
                end
            end

            S_1: begin // RECV
                if (cnt == 4'd8) begin // 9비트(0~8) 수신 완료 시
                    n_state = S_2;
                end
            end

            S_2: begin // STOP (검사)
                if (in == 1'b1) begin // 정지 비트 정상
                    if (odd == 1'b1) begin // [버그 1 수정] 'wire odd' 값을 읽음
                        n_state = S_4; // 성공! -> S_4 (DONE) 상태로
                    end else begin
                        n_state = S_0; // 패리티 실패 -> S_0 (IDLE)로
                    end
                end
                else begin // 정지 비트 0 (오류)
                    n_state = S_3;
                end
            end

            S_3: begin // ERROR
                if (in == 1'b1) begin 
                    n_state = S_0;
                end
            end
            
            S_4: begin // DONE (Moore 상태)
                // [FSM Type] 이 상태에 진입하면 'done'이 1이 됨 (한 클럭 늦게 켜짐)
                done = 1'b1;
                n_state = S_0;
            end
            
            default: n_state = S_0;
        endcase
    end
endmodule