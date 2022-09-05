`default_nettype none
module mux4_1_Nb (out,in0,in1,in2,in3,sel);
  parameter N = 16;

  output wire [N-1:0]  out;
  input  wire [N-1:0]  in0, in1, in2, in3;
  input  wire [1:0]    sel;

  mux4_1 muxes [N-1:0] (.out(out),.in0(in0),.in1(in1),.in2(in2),.in3(in3),.sel(sel));

endmodule
`default_nettype wire
