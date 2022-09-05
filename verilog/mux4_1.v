`default_nettype none
/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 1

    4-1 mux template
*/
module mux4_1(
    output wire       out,
    input  wire       in0, in1, in2, in3,
    input  wire [1:0] sel
);

wire mux_upper, mux_lower;

assign mux_upper = (sel[0]) ? in3 : in2;
assign mux_lower = (sel[0]) ? in1 : in0;

assign out = (sel[1]) ? mux_upper : mux_lower;

endmodule
`default_nettype wire
