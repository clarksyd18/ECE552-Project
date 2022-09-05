`default_nettype none
module sext(in,out);

  parameter IN_W  = 8;
  parameter OUT_W = 16;

  input  wire [IN_W-1:0]  in;
  output wire [OUT_W-1:0] out;

  localparam EXTRA = OUT_W-IN_W;
  localparam LAST_BIT = IN_W-1;
  assign out = {{(EXTRA){in[LAST_BIT]}},in};
endmodule
`default_nettype wire
