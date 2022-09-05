`default_nettype none
module zext (in,out);
  parameter IN_W  = 8;
  parameter OUT_W = 16;

  input  wire [IN_W-1:0]  in;
  output wire [OUT_W-1:0] out;

  localparam EXTRA = OUT_W-IN_W;
  assign out = {{(EXTRA){1'b0}},in};
endmodule
`default_nettype wire
