`default_nettype none
module wb(
  input  wire [15:0] pc_plus2/*,cond_out*/, mem_out, alu_out,
  input  wire  [2:0] wa_in,
  input  wire  [1:0] wd_sel_in,
  input  wire        reg_wr_in,
  output wire [15:0] wd_out,
  output wire  [2:0] wa_out,
  output wire        reg_wr_out
);

  // output mux
  mux4_1_Nb #(.N(16)) outmux(
    .out(wd_out),
    .in0(alu_out),
    .in1(mem_out),
    .in2(/*cond_out*/alu_out),
    .in3(pc_plus2),
    .sel(wd_sel_in));

  // passthrough
  assign wa_out = wa_in;
  assign reg_wr_out = reg_wr_in;

endmodule
`default_nettype wire
