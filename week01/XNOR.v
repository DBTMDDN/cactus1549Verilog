//XNOR
module top_module(
input a,
input b,
output out );
assign out=~(a^b);
endmodule
Declaring wires
`default_nettype none
module top_module(
input a,
input b,
input c,
input d,
output out,
output out_n );
assign out=(a&b)|(c&d);
assign out_n=!((a&b)|(c&d));
endmodule