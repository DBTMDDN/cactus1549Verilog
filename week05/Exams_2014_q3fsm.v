module top_module (
    input clk,
    input reset,   // Synchronous reset
    input s,
    input w,
    output reg z
);
    reg [2:0] c_state; //값을 저장해야하기 때문에 reg
    reg [2:0] n_state;
    localparam A   = 3'h0; //1번 상태도의 A와B를 나누어 주기위해 선언
    localparam S_1 = 3'h1;
    localparam S_2 = 3'h2;
    localparam S_3 = 3'h3;
    localparam S_4 = 3'h4;
    localparam S_5 = 3'h5;
    localparam S_6 = 3'h6;
    localparam S_7 = 3'h7;
    always@(posedge clk)begin
        if(reset) //acrive-high 싱크로너스 리셋을 위해(문제에서 주어진 리셋은 1에서 리셋되는 방식)
            c_state<=A; 
        else
            c_state<=n_state;
    end

    always@(c_state or w or s)begin
        n_state=A;
        case(c_state)
            A:begin //첫번째 상태도인 A와 B(나머지 경우에 대해 정의하기 위해 설정)
                n_state=(s==1'b1)?S_1:A;
            end
            S_1:begin 
                    n_state=(w==1'b1)?S_2:S_5;

                end
            S_2:begin 
                    n_state=(w==1'b1)?S_3:S_6;

                end
            S_3:begin 
                    n_state=(w==1'b1)?S_1:S_4;

                end
            S_4:begin 
                    n_state=(w==1'b1)?S_2:S_5;

                end
            S_5:begin 
                    n_state=(w==1'b1)?S_6:S_7;

                end
            S_6:begin 
                    n_state=(w==1'b1)?S_4:S_1;

                end
            S_7:begin 
                    n_state=S_1;

                end
            default:begin 
                n_state=A;
                end
        endcase
    end
    always@(c_state) begin //무어머신으로 설계하였으므로 결과 도출은 c_state에 의해서만 되어야하므로 always문 추가
        case (c_state)
            S_4:     z = 1'b1; // 유일한 1 결과(1이 두번만 나왔을때)
            default: z = 1'b0; // 나머지의 0 결과
        endcase
    end
endmodule