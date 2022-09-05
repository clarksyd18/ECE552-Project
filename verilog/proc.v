`default_nettype none
`define FORWARD
module proc (
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input wire clk;
   input wire rst;

   output wire err;

  // signals to writeback
  wire [15:0] win_pc_plus2, win_cond_zext, win_mem_out, win_alu_out;
  wire  [2:0] win_wa, win_inst_type;
  wire  [1:0] win_wd_sel;
  wire        win_reg_wr;

  // global stall signal from decode
  wire dout_stall, stall_de;
  wire dump_mem; // from hazard unit

  // nop insertion signals
  wire nop_fd, nop_de, nop_em, nop_mw;
  // reuse signals
  wire rec_fd, rec_de, rec_em, rec_mw;
  
  // error signals from each stage
  wire err_f, err_d, err_e, err_m, err_w;

  // !!SIGNALS BETWEEN FETCH AND DECODE!!
  // from fetch
  wire [15:0] fout_pc_plus2, fout_instruction;
  wire fout_done, fout_stall, fout_hit;
  // muxed signals for nop/stall
  wire [15:0] fd_mux_pc_plus2, fd_mux_instruction;
  // to decode
  wire [15:0] din_pc_plus2, din_instruction;
  // muxes for nop/stall
  assign fd_mux_pc_plus2    = (nop_fd) ? 'h0000 : (rec_fd) ? din_pc_plus2    : fout_pc_plus2;
  assign fd_mux_instruction = (nop_fd) ? 'h0800 : (rec_fd) ? din_instruction : fout_instruction;
  // pipeline flops
  dff_Nb #(.N(16)) reg_fd_pc_plus2    (.D(fd_mux_pc_plus2),.Q(din_pc_plus2),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_fd_instruction (.D(fd_mux_instruction),.Q(din_instruction),.clk(clk),.rst(rst));


  //TODO
  // feedback signals into fetch
  wire [15:0] fin_brpc;   // comes from execute
  wire [15:0] fin_jpc;    // comes from execute
  wire  [1:0] fin_pc_sel; // comes from execute

  wire        force_hold_pc; // comes from hazard unit

  fetch f(
    .clk(clk),.rst(rst),.dump(dump_mem),.force_hold_pc(force_hold_pc),
    .brpc(fin_brpc),.jpc(fin_jpc),
    .pc_sel(fin_pc_sel),.err(err_f),.hit(fout_hit), .done(fout_done),.stall(fout_stall),
    .pc_plus2(fout_pc_plus2),.inst(fout_instruction));

  // !!SIGNALS BETWEEN DECODE AND EXECUTE!!
  // from decode
  wire [15:0] dout_pc_plus2, dout_long_jpc, dout_alu_a, dout_immediates, dout_mem_val, dout_brpc;
  wire  [3:0] dout_alu_op;
  wire  [2:0] dout_ra1, dout_ra2, dout_wa, dout_inst_type;
  wire  [1:0] dout_wd_sel, dout_cond_code;
  wire        dout_branch, dout_jump, dout_longjump, dout_reg_wr, dout_mem_wr, dout_mem_rd;
  wire [1:0]  dout_b_src_sel;  
 // muxed signals for nop/stall
  wire [15:0] de_mux_pc_plus2, de_mux_long_jpc, de_mux_alu_a, de_mux_immediates, de_mux_mem_val, de_mux_brpc;
  wire  [3:0] de_mux_alu_op;
  wire  [2:0] de_mux_ra1, de_mux_ra2, de_mux_wa, de_mux_inst_type;
  wire  [1:0] de_mux_wd_sel, de_mux_cond_code;
  wire        de_mux_branch, de_mux_jump, de_mux_longjump, de_mux_reg_wr, de_mux_mem_wr, de_mux_mem_rd;
  wire [1:0]  de_mux_b_src_sel; 
  // to execute
  wire [15:0] ein_pc_plus2, ein_long_jpc, ein_alu_a, ein_immediates, ein_mem_val, ein_brpc;
  wire  [3:0] ein_alu_op;
  wire  [2:0] ein_ra1, ein_ra2, ein_wa, ein_inst_type;
  wire  [1:0] ein_wd_sel, ein_cond_code;
  wire        ein_branch, ein_jump, ein_longjump, ein_reg_wr, ein_mem_wr, ein_mem_rd;
  wire [1:0]  ein_b_src_sel;

  // muxes for nop/stall
  assign de_mux_pc_plus2  = (nop_de) ? 'b0 : (rec_de) ? ein_pc_plus2  : dout_pc_plus2;
  assign de_mux_long_jpc  = (nop_de) ? 'b0 : (rec_de) ? ein_long_jpc  : dout_long_jpc;
  assign de_mux_alu_a     = (nop_de) ? 'b0 : (rec_de) ? ein_alu_a     : dout_alu_a;
  assign de_mux_immediates     = (nop_de) ? 'b0 : (rec_de) ? ein_immediates     : dout_immediates;
  assign de_mux_mem_val   = (nop_de) ? 'b0 : (rec_de) ? ein_mem_val   : dout_mem_val;
  assign de_mux_brpc      = (nop_de) ? 'b0 : (rec_de) ? ein_brpc      : dout_brpc;
  assign de_mux_alu_op    = (nop_de) ? 'b0 : (rec_de) ? ein_alu_op    : dout_alu_op;
  assign de_mux_ra1       = (nop_de) ? 'b0 : (rec_de) ? ein_ra1       : dout_ra1;
  assign de_mux_ra2       = (nop_de) ? 'b0 : (rec_de) ? ein_ra2       : dout_ra2;
  assign de_mux_wa        = (nop_de) ? 'b0 : (rec_de) ? ein_wa        : dout_wa;
  assign de_mux_wd_sel    = (nop_de) ? 'b0 : (rec_de) ? ein_wd_sel    : dout_wd_sel;
  assign de_mux_cond_code = (nop_de) ? 'b0 : (rec_de) ? ein_cond_code : dout_cond_code;
  assign de_mux_inst_type = (nop_de) ? 'b0 : (rec_de) ? ein_inst_type : dout_inst_type;
  assign de_mux_branch    = (nop_de) ? 'b0 : (rec_de) ? ein_branch    : dout_branch;
  assign de_mux_jump      = (nop_de) ? 'b0 : (rec_de) ? ein_jump      : dout_jump;
  assign de_mux_longjump  = (nop_de) ? 'b0 : (rec_de) ? ein_longjump  : dout_longjump;
  assign de_mux_reg_wr    = (nop_de) ? 'b0 : (rec_de) ? ein_reg_wr    : dout_reg_wr;
  assign de_mux_mem_wr    = (nop_de) ? 'b0 : (rec_de) ? ein_mem_wr    : dout_mem_wr;
  assign de_mux_mem_rd    = (nop_de) ? 'b0 : (rec_de) ? ein_mem_rd    : dout_mem_rd;
  assign de_mux_b_src_sel = (nop_de) ? 'b0 : (rec_de) ? ein_b_src_sel   : dout_b_src_sel;

	// pipeline flops
  dff_Nb #(.N(16)) reg_de_pc_plus2  (.D(de_mux_pc_plus2),.Q(ein_pc_plus2),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_de_long_jpc  (.D(de_mux_long_jpc),.Q(ein_long_jpc),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_de_alu_a     (.D(de_mux_alu_a),.Q(ein_alu_a),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_de_immediates     (.D(de_mux_immediates),.Q(ein_immediates),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_de_mem_val   (.D(de_mux_mem_val),.Q(ein_mem_val),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_de_brpc      (.D(de_mux_brpc),.Q(ein_brpc),.clk(clk),.rst(rst));
  dff_Nb #(.N(4))  reg_de_alu_op    (.D(de_mux_alu_op),.Q(ein_alu_op),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_de_ra1       (.D(de_mux_ra1),.Q(ein_ra1),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_de_ra2       (.D(de_mux_ra2),.Q(ein_ra2),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_de_wa        (.D(de_mux_wa),.Q(ein_wa),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_de_inst_type (.D(de_mux_inst_type),.Q(ein_inst_type),.clk(clk),.rst(rst));
  dff_Nb #(.N(2))  reg_de_wd_sel    (.D(de_mux_wd_sel),.Q(ein_wd_sel),.clk(clk),.rst(rst));
  dff_Nb #(.N(2))  reg_de_cond_code (.D(de_mux_cond_code),.Q(ein_cond_code),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_de_branch    (.D(de_mux_branch),.Q(ein_branch),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_de_jump      (.D(de_mux_jump),.Q(ein_jump),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_de_longjump  (.D(de_mux_longjump),.Q(ein_longjump),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_de_reg_wr    (.D(de_mux_reg_wr),.Q(ein_reg_wr),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_de_mem_wr    (.D(de_mux_mem_wr),.Q(ein_mem_wr),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_de_mem_rd    (.D(de_mux_mem_rd),.Q(ein_mem_rd),.clk(clk),.rst(rst));

  dff_Nb #(.N(2))  reg_de_b_src_sel    (.D(de_mux_b_src_sel),.Q(ein_b_src_sel),.clk(clk),.rst(rst));

  //TODO
  // feedback signals into decode
  wire [15:0] din_wd;     // comes from writeback
  wire  [2:0] din_wa;     // comes from writeback
  wire        din_reg_wr; // comes from writeback

  decode d(
    .pc_plus2_in(din_pc_plus2),.instruction(din_instruction),.wd_in(din_wd),
    .wa_in(din_wa),
    .reg_wr_in(din_reg_wr),.clk(clk),.rst(rst),.fetch_stall(fout_stall),
    .pc_plus2_out(dout_pc_plus2),.brpc(dout_brpc),.long_jpc(dout_long_jpc),.alu_a(dout_alu_a),.immediates(dout_immediates),.mem_val(dout_mem_val),
    .alu_op(dout_alu_op),
    .ra1_out(dout_ra1),.ra2_out(dout_ra2),.wa_out(dout_wa),
    .wd_sel_out(dout_wd_sel),.cond_code(dout_cond_code),.inst_type(dout_inst_type),
    .branch(dout_branch),.jump(dout_jump),.longjump(dout_longjump),.stall(dout_stall),
    .reg_wr_out(dout_reg_wr),.mem_wr(dout_mem_wr),.mem_rd(dout_mem_rd),
    .b_src_sel(dout_b_src_sel)  
);

  // !!SIGNALS BETWEEN EXECUTE AND MEMORY!!
  // signals from execute
  wire [15:0] eout_alu_out, eout_mem_val, eout_pc_plus2;
  wire  [2:0] eout_ra1, eout_ra2, eout_wa, eout_inst_type;
  wire  [1:0] eout_wd_sel;
  wire        /*eout_cond,*/ eout_mem_rd, eout_mem_wr, eout_reg_wr;
  // muxed signals for nop/stall
  wire [15:0] em_mux_alu_out, em_mux_mem_val, em_mux_pc_plus2;
  wire  [2:0] em_mux_ra1, em_mux_ra2, em_mux_wa, em_mux_inst_type;
  wire  [1:0] em_mux_wd_sel;
  wire        /*em_mux_cond,*/ em_mux_mem_rd, em_mux_mem_wr, em_mux_reg_wr;
  // signals to memory
  wire [15:0] min_alu_out, min_mem_val, min_pc_plus2;
  wire  [2:0] min_ra1, min_ra2, min_wa, min_inst_type;
  wire  [1:0] min_wd_sel;
  wire        /*min_cond,*/ min_mem_rd, min_mem_wr, min_reg_wr;
  // muxes for nop/stall
  assign em_mux_alu_out   = (nop_em) ? 'b0 : (rec_em) ? min_alu_out   : eout_alu_out;
  assign em_mux_mem_val   = (nop_em) ? 'b0 : (rec_em) ? min_mem_val   : eout_mem_val;
  assign em_mux_pc_plus2  = (nop_em) ? 'b0 : (rec_em) ? min_pc_plus2  : eout_pc_plus2;
  assign em_mux_ra1       = (nop_em) ? 'b0 : (rec_em) ? min_ra1       : eout_ra1;
  assign em_mux_ra2       = (nop_em) ? 'b0 : (rec_em) ? min_ra2       : eout_ra2;
  assign em_mux_wa        = (nop_em) ? 'b0 : (rec_em) ? min_wa        : eout_wa;
  assign em_mux_wd_sel    = (nop_em) ? 'b0 : (rec_em) ? min_wd_sel    : eout_wd_sel;
  assign em_mux_inst_type = (nop_em) ? 'b0 : (rec_em) ? min_inst_type : eout_inst_type;
  //assign em_mux_cond      = (nop_em) ? 'b0 : (rec_em) ? min_cond      : eout_cond;
  assign em_mux_mem_rd    = (nop_em) ? 'b0 : (rec_em) ? min_mem_rd    : eout_mem_rd;
  assign em_mux_mem_wr    = (nop_em) ? 'b0 : (rec_em) ? min_mem_wr    : eout_mem_wr;
  assign em_mux_reg_wr    = (nop_em) ? 'b0 : (rec_em) ? min_reg_wr    : eout_reg_wr;
  // pipeline flops
  dff_Nb #(.N(16)) reg_em_alu_out   (.D(em_mux_alu_out),.Q(min_alu_out),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_em_mem_val   (.D(em_mux_mem_val),.Q(min_mem_val),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_em_pc_plus2  (.D(em_mux_pc_plus2),.Q(min_pc_plus2),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_em_ra1       (.D(em_mux_ra1),.Q(min_ra1),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_em_ra2       (.D(em_mux_ra2),.Q(min_ra2),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_em_wa        (.D(em_mux_wa),.Q(min_wa),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_em_inst_type (.D(em_mux_inst_type),.Q(min_inst_type),.clk(clk),.rst(rst));
  dff_Nb #(.N(2))  reg_em_wd_sel    (.D(em_mux_wd_sel),.Q(min_wd_sel),.clk(clk),.rst(rst));
  //dff_Nb #(.N(1))  reg_em_cond      (.D(em_mux_cond),.Q(min_cond),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_em_mem_rd    (.D(em_mux_mem_rd),.Q(min_mem_rd),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_em_mem_wr    (.D(em_mux_mem_wr),.Q(min_mem_wr),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_em_reg_wr    (.D(em_mux_reg_wr),.Q(min_reg_wr),.clk(clk),.rst(rst));

  // forwarding logic
 wire [15:0] forwarded_alu_a, forwarded_mem_val;
 assign forwarded_alu_a   = ((min_wa==ein_ra1)&min_reg_wr&ein_inst_type[0])? min_alu_out:
			                      ((win_wa==ein_ra1)&win_reg_wr&ein_inst_type[0])? din_wd:
			                                                                       ein_alu_a; 
 assign forwarded_mem_val = ((min_wa==ein_ra2)&min_reg_wr&ein_inst_type[1])? min_alu_out:
                            ((win_wa==ein_ra2)&win_reg_wr&ein_inst_type[1])? din_wd:
                                                                      			 ein_mem_val;
  execute e(
//`ifdef FORWARD
    .long_jpc(ein_long_jpc),.alu_a(forwarded_alu_a),.immediates(ein_immediates),.pc_plus2_in(ein_pc_plus2),.mem_val_in(forwarded_mem_val),.brpc_in(ein_brpc),
//`else
//    .long_jpc(ein_long_jpc),.alu_a(ein_alu_a),.immediates(ein_immediates),.pc_plus2_in(ein_pc_plus2),.mem_val_in(ein_mem_val),.brpc_in(ein_brpc),
//`endif
    .alu_op(ein_alu_op),
    .ra1_in(ein_ra1),.ra2_in(ein_ra2),.wa_in(ein_wa),
    .wd_sel_in(ein_wd_sel),.cond_code(ein_cond_code),.inst_type_in(ein_inst_type),
    .branch(ein_branch),.jump(ein_jump),.longjump(ein_longjump),.stall(stall_de),
    .reg_wr_in(ein_reg_wr),.mem_wr(ein_mem_wr),.mem_rd(ein_mem_rd),
    .b_src_sel(ein_b_src_sel),
    .jpc_out(fin_jpc),.alu_out(eout_alu_out),.mem_val_out(eout_mem_val),.pc_plus2_out(eout_pc_plus2),.brpc_out(fin_brpc),
    .ra1_out(eout_ra1),.ra2_out(eout_ra2),.wa_out(eout_wa),
    .pc_sel(fin_pc_sel),.wd_sel_out(eout_wd_sel),.inst_type_out(eout_inst_type),
    /*.cond(eout_cond),*/.mem_rd_out(eout_mem_rd),.mem_wr_out(eout_mem_wr),.reg_wr_out(eout_reg_wr)
  );

  // !!SIGNALS BETWEEN MEMORY AND WRITEBACK!!
  // signals from memory
  wire [15:0] mout_pc_plus2, /*mout_cond_zext,*/ mout_mem_out, mout_alu_out;
  wire  [2:0] mout_wa, mout_inst_type;
  wire  [1:0] mout_wd_sel;
  wire        mout_reg_wr, mout_done, mout_stall, mout_hit;
  // muxed signals for nop/stall
  wire [15:0] mw_mux_pc_plus2, /*mw_mux_cond_zext,*/ mw_mux_mem_out, mw_mux_alu_out;
  wire  [2:0] mw_mux_wa, mw_mux_inst_type;
  wire  [1:0] mw_mux_wd_sel;
  wire        mw_mux_reg_wr;

  // muxes for nop/stall
  assign mw_mux_pc_plus2  = (nop_mw) ? 'b0 : (rec_mw) ? win_pc_plus2  : mout_pc_plus2;
  //assign mw_mux_cond_zext = (nop_mw) ? 'b0 : (rec_mw) ? win_cond_zext : mout_cond_zext;
  assign mw_mux_mem_out   = (nop_mw) ? 'b0 : (rec_mw) ? win_mem_out   : mout_mem_out;
  assign mw_mux_alu_out   = (nop_mw) ? 'b0 : (rec_mw) ? win_alu_out   : mout_alu_out;
  assign mw_mux_wa        = (nop_mw) ? 'b0 : (rec_mw) ? win_wa        : mout_wa;
  assign mw_mux_inst_type = (nop_mw) ? 'b0 : (rec_mw) ? win_inst_type : mout_inst_type;
  assign mw_mux_wd_sel    = (nop_mw) ? 'b0 : (rec_mw) ? win_wd_sel    : mout_wd_sel;
  assign mw_mux_reg_wr    = (nop_mw) ? 'b0 : (rec_mw) ? win_reg_wr    : mout_reg_wr;
  // pipeline flops
  dff_Nb #(.N(16)) reg_mw_pc_plus2  (.D(mw_mux_pc_plus2),.Q(win_pc_plus2),.clk(clk),.rst(rst));
  //dff_Nb #(.N(16)) reg_mw_cond_zext (.D(mw_mux_cond_zext),.Q(win_cond_zext),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_mw_mem_out   (.D(mw_mux_mem_out),.Q(win_mem_out),.clk(clk),.rst(rst));
  dff_Nb #(.N(16)) reg_mw_alu_out   (.D(mw_mux_alu_out),.Q(win_alu_out),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_mw_wa        (.D(mw_mux_wa),.Q(win_wa),.clk(clk),.rst(rst));
  dff_Nb #(.N(3))  reg_mw_inst_type (.D(mw_mux_inst_type),.Q(win_inst_type),.clk(clk),.rst(rst));
  dff_Nb #(.N(2))  reg_mw_wd_sel    (.D(mw_mux_wd_sel),.Q(win_wd_sel),.clk(clk),.rst(rst));
  dff_Nb #(.N(1))  reg_mw_reg_wr    (.D(mw_mux_reg_wr),.Q(win_reg_wr),.clk(clk),.rst(rst));


  memory m(
    .pc_plus2_in(min_pc_plus2),.alu_out_in(min_alu_out),.mem_in(min_mem_val),
    .ra1_in(min_ra1),.ra2_in(min_ra2),.wa_in(min_wa),
    .wd_sel_in(min_wd_sel),.inst_type_in(min_inst_type),
    /*.cond(min_cond),*/.mem_rd(min_mem_rd),.mem_wr(min_mem_wr),.reg_wr_in(min_reg_wr),
    .dump(dump_mem),.clk(clk),.rst(rst),
    .pc_plus2_out(mout_pc_plus2),/*.cond_zext(mout_cond_zext),*/.mem_out(mout_mem_out),.alu_out_out(mout_alu_out),
    .wa_out(mout_wa),.inst_type_out(mout_inst_type),
    .wd_sel_out(mout_wd_sel),
    .reg_wr_out(mout_reg_wr),.done(mout_done),.stall(mout_stall),.hit(mout_hit),.err(err_m)
  );

  wb w(
    .pc_plus2(win_pc_plus2),/*.cond_out(win_cond_zext),*/.mem_out(win_mem_out),.alu_out(win_alu_out),
    .wa_in(win_wa),
    .wd_sel_in(win_wd_sel),
    .reg_wr_in(win_reg_wr),
    .wd_out(din_wd),
    .wa_out(din_wa),
    .reg_wr_out(din_reg_wr)
  );

  hazard haz(
    .dout_ra1(dout_ra1),.dout_ra2(dout_ra2),.ein_wa(ein_wa),.min_wa(min_wa),
    .dout_inst_type(dout_inst_type),.ein_inst_type(ein_inst_type),.min_inst_type(min_inst_type),
    .pc_sel(fin_pc_sel),
    .ein_reg_wr(ein_reg_wr),.min_reg_wr(min_reg_wr),
    .halt(dout_stall),
    .stall_fetch(fout_stall), .done_fetch(fout_done),
    .stall_mem(mout_stall), .done_mem(mout_done),
    .rst(rst),.clk(clk),
    .halt_de(stall_de),
    .force_hold_pc(force_hold_pc),.rec_fd(rec_fd),.rec_de(rec_de),.rec_em(rec_em),.rec_mw(rec_mw),
    .nop_fd(nop_fd),.nop_de(nop_de),.nop_em(nop_em),.nop_mw(nop_mw),
    .dump_mem(dump_mem)
  );

  assign err_d = 0;
  assign err_e = 0;
  assign err_w = 0;

  assign err = err_f | err_d | err_e | err_m | err_w;

endmodule
`default_nettype wire

