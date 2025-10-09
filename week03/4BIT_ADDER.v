//4BIT_ADDER
module full_adder( 
    input x, 
    y, 
    cin,
    output cout,
    sum );
    assign sum=x^y^cin;
    assign cout=(x&y)|((x^y)&cin);
endmodule

module top_module (
    input [3:0] x,
    input [3:0] y, 
    output [4:0] sum);
    wire c0;
    wire c1;
    wire c2;
    full_adder fa0 (
        .x(x[0]),
        .y(y[0]),
        .cout(c0),
        .sum(sum[0])
    );
    full_adder fa1 (
        .x(x[1]),
        .y(y[1]),
        .cin(c0),
        .cout(c1),
        .sum(sum[1])
    );
    full_adder fa2 (
        .x(x[2]),
        .y(y[2]),
        .cin(c1),
        .cout(c2),
        .sum(sum[2])
    );
    full_adder fa3 (
        .x(x[3]),
        .y(y[3]),
        .cin(c2),
        .sum(sum[3]),
        .cout(sum[4])
    );
endmodule