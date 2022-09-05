module dff_Nb(clk,rst,D,Q);
	parameter N = 16;

	input          clk, rst;
	input  [N-1:0] D;
	output [N-1:0] Q;

dff flops [N-1:0] (.q(Q),.d(D),.clk(clk),.rst(rst));

endmodule
