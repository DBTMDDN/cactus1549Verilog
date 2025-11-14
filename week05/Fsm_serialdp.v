module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output [7:0] out_byte,
    output done
); //

reg [2:0] c_state; //값을 저장해야하기 때문에 reg
reg [2:0] n_state;
reg c_state;
reg n_state;
reg cnt;
reg p_rst;
wire odd;
wire p_in;
assign p_in=(c_state==S_1)?in:1'b0;

localparam S_0=3'h0; //정지상태
localparam S_1=3'h1; //시작비트 상태
localparam S_2=3'h2; //데이터 수신 상태
localparam S_3=3'h3; //정지 상태

 parity u_parity (
        .clk    (clk),
        .reset  (p_rst), 
        .in     (p_in),        
        .odd    (odd)
    );

always@(posedge clk)begin //state변환 블록
    if(reset) 
        c_state<=S_0; 
    else 
        c_state<=n_state;
end

always@(posedge clk) begin //카운터 및 데이터 관련 블록
    if(reset)begin
        cnt<=3'd0;
        out_byte<=8'd0;
    end
    else if (p_rst) 
        cnt<=3'd0;
    else if (c_state==S_1)
        cnt<=cnt+3'd1;
        if (cnt<3'd8)begin
            out_byte<={in, out_byte[7:1]}; //벡터로 쉬프트 레지스터 처럼 in이 들어왔을때 바이트로 구성
        end
end

always@(c_state or in)
    n_state=c_state; //무어머신이므로 상태에 의해서만출력변화
    done = 1'b0;
    p_rst = 1'b0; //기본은 0으로 설정
    case(c_state)
        S_0: begin
            if(in == 1'b0)begin
                n_state=S_1;
                p_rst=1'b1; //패리티 모듈과 cnt 리셋신호
            end
        end
        S_1:begin
            if(cnt==4'd8)begin
            n_state=S_2;
            end
        end
        S_2:begin
            if(cnt)
        end
        S_3:begin
            if(in==1'b1)begin
            n_state=S_0; //S_3상태에서 in에 1이 들어오면 정지비트이므로 S_0으로 복귀
            end
        end
    endcase
endmodule