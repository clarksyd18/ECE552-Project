`default_nettype none
module execute(
  input  wire [15:0] long_jpc, alu_a, immediates, pc_plus2_in, mem_val_in, brpc_in,
  input  wire  [3:0] alu_op,
  input  wire  [2:0] ra1_in, ra2_in, wa_in, inst_type_in,
  input  wire  [1:0] wd_sel_in, cond_code,
  input  wire        branch, jump, longjump, stall, reg_wr_in, mem_wr, mem_rd,
  input  wire [1:0]  b_src_sel,
  output wire [15:0] jpc_out, alu_out, pc_plus2_out, mem_val_out, brpc_out,
  output wire  [2:0] ra1_out, ra2_out, wa_out, inst_type_out,
  output wire  [1:0] pc_sel, wd_sel_out,
  output wire        mem_rd_out, mem_wr_out, reg_wr_out
);

  // passthrough
  assign pc_plus2_out = pc_plus2_in;
  assign mem_val_out  = mem_val_in;
  assign brpc_out     = brpc_in;

  assign ra1_out = ra1_in;
  assign ra2_out = ra2_in;
  assign  wa_out =  wa_in;

  assign wd_sel_out = wd_sel_in;//= (wd_sel_in == 2'b10) ? 2'b00 : wd_sel_in;
  assign inst_type_out = inst_type_in;

  assign mem_rd_out = mem_rd;
  assign mem_wr_out = mem_wr;
  assign reg_wr_out = reg_wr_in;

  wire [15:0] alu_b; 
  // Mux for alu_b
  assign alu_b = (b_src_sel== 2'b00)? mem_val_in: immediates; 

 // alu
  wire [15:0] alu_fake_out, cond_zext;
  wire neg, zero, cout, lt, eq;

  alu workhorse(
    .a(alu_a),
    .b(alu_b),
    .out(alu_fake_out),
    .op(alu_op),
    .neg(neg),
    .zero(zero),
    .cout(cout),
    .lt(lt),
    .eq(eq));

  assign alu_out = (wd_sel_in == 2'b10) ? cond_zext : alu_fake_out;

  // deal with condition codes
  wire lt_eq, cond;
  assign lt_eq = eq | lt;

  mux4_1_Nb #(.N(1)) cc_mux(
    .out(cond),
    .in0(eq),
    .in1(lt),
    .in2(lt_eq),
    .in3(cout),
    .sel(cond_code));

  // deal with pc mux select compute (resolve branches)
  wire zero_or_neg, br_cond, branch_valid;

  assign zero_or_neg = (cond_code[1]) ? neg : zero;
  assign br_cond = (cond_code[0]) ? ~zero_or_neg : zero_or_neg;

  assign branch_valid = branch & br_cond;

  assign pc_sel[1] = branch_valid | jump;
  assign pc_sel[0] = branch_valid | stall;
  //assign pc_sel = 2'h0;


  // deal with jumps
  wire [15:0] short_jpc;
  assign short_jpc = alu_out;
  assign jpc_out = (longjump) ? long_jpc : short_jpc;

  // zero extend the condition code
  zext #(.IN_W(1),.OUT_W(16)) cz(.in(cond),.out(cond_zext));


endmodule
`default_nettype wire
