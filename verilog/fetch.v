`default_nettype none
`define STALL_IMEM
`define CACHE_IMEM
module fetch(
  input  wire        clk, rst, dump, force_hold_pc,
  input  wire [15:0] brpc, jpc,
  input  wire [1:0]  pc_sel,
  output wire err, hit, stall, done,
  output wire [15:0] pc_plus2, inst
);

  wire [15:0] pc_next, pc;

  // allows override for holding pc when a stall occurs
  wire [1:0] real_pc_sel;
  
  wire cout;

  assign real_pc_sel = (force_hold_pc) ? 2'b01 : pc_sel;

  cla_16b plus2(.a(pc),.b(16'h0002),.cin(1'b0),.out(pc_plus2),.cout(cout));

  mux4_1_Nb #(.N(16)) next_mux(
    .out(pc_next),.in0(pc_plus2),.in1(pc),.in2(jpc),.in3(brpc),.sel(real_pc_sel));

  dff_Nb #(.N(16)) pc_reg(.D(pc_next),.Q(pc),.clk(clk),.rst(rst));

  wire [15:0] fake_inst;

  assign inst = (stall) ? 16'h0800 : fake_inst;


//`ifdef STALL_IMEM
//  `ifdef CACHE_IMEM
  mem_system #(.memtype(0)) imem(
    .DataOut(fake_inst),
    .Done(done),
    .Stall(stall),
    .CacheHit(hit),
    .err(err),
    .Addr(pc),
    .DataIn(16'h0000),
    .Rd(1'b1),
    .Wr(1'b0),
    .createdump(dump),
    .clk(clk),
    .rst(rst));
//  `else
//  stallmem imem(
//    .DataOut(fake_inst),
//    .Done(done),
//    .Stall(stall),
//    .CacheHit(hit),
//    .err(err),
//    .Addr(pc),
//    .DataIn(16'h0000),
//    .Rd(1'b1),
//    .Wr(1'b0),
//    .createdump(dump),
//    .clk(clk),
//    .rst(rst));
//  `endif
//`else
//  assign done = 0;
//  assign stall = 0;
//  assign hit = 0;
//  assign err = 0;
//  memory2c imem(
//    .data_out(inst),
//    .data_in(16'h0000),
//    .addr(pc),
//    .enable(1'b1),
//    .wr(1'b0),
//    .createdump(dump),
//    .clk(clk),
//    .rst(rst));
//`endif

endmodule
`default_nettype wire
