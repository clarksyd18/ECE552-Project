`default_nettype none
module decode(
  input  wire [15:0] pc_plus2_in, instruction, wd_in,
  input  wire  [2:0] wa_in,
  input  wire        reg_wr_in, clk, rst, fetch_stall,
  output wire [15:0] pc_plus2_out, brpc, long_jpc, alu_a, immediates, mem_val,
  output wire  [3:0] alu_op,
  output wire  [2:0] ra1_out, ra2_out, wa_out, inst_type,
  output wire  [1:0] wd_sel_out, cond_code,
  output wire        branch, jump, longjump, stall, reg_wr_out, mem_wr, mem_rd,
  output wire [1:0] b_src_sel
);

  // janky flop to ensure that the reset value for the instruction isn't a halt
  wire no_halt_n, actual_stall;
  dff_Nb #(.N(1)) no_halt_flop (.Q(no_halt_n),.D(1'b1),.clk(clk),.rst(rst));
  assign stall = actual_stall & no_halt_n;

  // passthrough
  assign pc_plus2_out = pc_plus2_in;

  assign ra1_out = instruction[10:8];
  assign ra2_out = instruction[7:5]; 
  // select bits for muxes
  wire [1:0] wa_sel; //  , b_src_sel;

  // control unit
  wire invalid_op; 

  control ctrl(
    .op(instruction[15:11]),
    .func(instruction[1:0]),
    .err(invalid_op),
    .cond_code(cond_code),
    .longjump(longjump),
    .stall(actual_stall),
    .alu_op(alu_op),
    .inst_type(inst_type),
    .branch(branch),
    .jump(jump),
    .wd_sel(wd_sel_out),
    .b_src_sel(b_src_sel),
    .wa_sel(wa_sel),
    .reg_wr(reg_wr_out),
    .mem_rd(mem_rd),
    .mem_wr(mem_wr));

  // 2nd output from the reg file
  wire rf_err;

  // regfile
  regFile_bypass rf(
    .read1Data(alu_a),
    .read2Data(mem_val),
    .clk(clk),
    .rst(rst),
    .err(rf_err),
    .read1RegSel(ra1_out),
    .read2RegSel(ra2_out),
    .writeRegSel(wa_in),
    .writeData(wd_in),
    .writeEn(reg_wr_in));

  // outputs from sign/zero extension from the instruction
  wire [15:0] zext_5b, sext_5b, sext_8b, sext_11b;

  zext #(.IN_W(5),.OUT_W(16))   z5(.in( instruction[4:0]),.out( zext_5b));
  sext #(.IN_W(5),.OUT_W(16))   s5(.in( instruction[4:0]),.out( sext_5b));
  sext #(.IN_W(8),.OUT_W(16))   s8(.in( instruction[7:0]),.out( sext_8b));
  sext #(.IN_W(11),.OUT_W(16)) s11(.in(instruction[10:0]),.out(sext_11b));

  // muxes
  mux4_1_Nb #(.N(3)) wa_mux(
    .out(wa_out),
    .in0(instruction[4:2]),
    .in1(instruction[7:5]),
    .in2(instruction[10:8]),
    .in3(3'h7),
    .sel(wa_sel));

assign immediates = (~b_src_sel[1])? sext_5b :
		   (b_src_sel[0]) ? sext_8b : zext_5b;
 
 //mux4_1_Nb alub_mux(
   // .out(alu_b),
   // .in0(mem_val),
  //  .in1(sext_5b),
//    .in2(zext_5b),
  //  .in3(sext_8b),
   // .sel(b_src_sel));

  // adders for jump/branch
  wire j_cout, b_cout;
  cla_16b jadder(.cin(1'b0),.a(pc_plus2_in),.b(sext_11b),.out(long_jpc),.cout(j_cout));
  cla_16b badder(.cin(1'b0),.a(pc_plus2_in),.b(sext_8b),.out(brpc),.cout(b_cout));

endmodule
`default_nettype wire
