`default_nettype none
`define STALL_DMEM
`define CACHE_DMEM
module memory (
  input  wire [15:0] pc_plus2_in, alu_out_in, mem_in,
  input  wire  [2:0] ra1_in, ra2_in, wa_in, inst_type_in,
  input  wire  [1:0] wd_sel_in,
  input  wire        /*cond,*/ mem_rd, mem_wr, reg_wr_in, dump, clk, rst,
  output wire [15:0] pc_plus2_out,/* cond_zext,*/ mem_out, alu_out_out,
  output wire  [2:0] wa_out, inst_type_out,
  output wire  [1:0] wd_sel_out,
  output wire        reg_wr_out, done, stall, hit, err
);

  // data memory
//`ifdef STALL_DMEM
//  `ifdef CACHE_DMEM
  mem_system #(.memtype(1)) dmem(
    .DataOut(mem_out),
    .Done(done),
    .Stall(stall),
    .CacheHit(hit),
    .err(err),
    .Addr(alu_out_in),
    .DataIn(mem_in),
    .Rd(mem_rd),
    .Wr(mem_wr),
    .createdump(dump),
    .clk(clk),
    .rst(rst));
  //assign err = 0;
//  `else
//  stallmem dmem(
//    .DataOut(mem_out),
//    .Done(done),
//    .Stall(stall),
//    .CacheHit(hit),
//    .err(err),
//    .Addr(alu_out_in),
//    .DataIn(mem_in),
//    .Rd(mem_rd),
//    .Wr(mem_wr),
//    .createdump(dump),
//    .clk(clk),
//    .rst(rst));
//  `endif
//`else
//  memory2c dmem(
//    .data_out(mem_out),
//    .data_in(mem_in),
//    .addr(alu_out_in),
//    .enable(mem_wr|mem_rd),
//    .wr(mem_wr),
//    .createdump(dump),
//    .clk(clk),
//    .rst(rst));
//
//  assign done = 0;
//  assign stall = 0;
//  assign hit = 0;
//  assign err = 0;
//`endif

  //// zero extend the condition code
  //zext #(.IN_W(1),.OUT_W(16)) cz(.in(cond),.out(cond_zext));

  // passthrough
  assign pc_plus2_out = pc_plus2_in;
  assign alu_out_out = alu_out_in;
  assign wa_out = wa_in;
  assign wd_sel_out = wd_sel_in;
  assign reg_wr_out = reg_wr_in;
  assign inst_type_out = inst_type_in;

endmodule
`default_nettype wire
