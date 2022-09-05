`default_nettype none
`define FORWARD
module hazard(
  input  wire [2:0] dout_ra1, dout_ra2, ein_wa, min_wa,
  input  wire [2:0] dout_inst_type, ein_inst_type, min_inst_type,
  input  wire [1:0] pc_sel,
  input  wire       ein_reg_wr, min_reg_wr,
  input  wire       halt,                           //stall from halt instruction (decode)
  input  wire       stall_fetch, done_fetch,
  input  wire       stall_mem, done_mem,             //TODO THIS LINE IS NEW AND MAY NOT WORK!!!
  input  wire       rst, clk,
  output wire halt_de,
  output wire force_hold_pc, rec_fd, rec_de, rec_em, rec_mw, //signals for recycling register values
  output wire nop_fd, nop_de, nop_em, nop_mw,        //nop insertion signals
  output wire dump_mem                               //signal for dumping memory
);

// branch detection for flushing
wire branch_or_jump_taken;
assign branch_or_jump_taken = pc_sel[1];

// halting_logic
wire halt_fd, halt_em, halt_mw, halt_latched;
dff_Nb #(.N(1)) reg_halt_latched (.Q(halt_latched),.D((halt|halt_latched)&~pc_sel[1]),.clk(clk),.rst(rst));
dff_Nb #(.N(1)) reg_halt_de      (.Q(halt_de),.D((halt|halt_latched)&~pc_sel[1]),.clk(clk),.rst(rst));
dff_Nb #(.N(1)) reg_halt_em      (.Q(halt_em),.D(halt_de&~stall_mem),.clk(clk),.rst(rst));
dff_Nb #(.N(1)) reg_halt_mw      (.Q(halt_mw),.D((halt_em&~stall_mem)),.clk(clk),.rst(rst));
assign halt_fd = halt | halt_latched;

// hazard logic
wire e_hazard_ra1, e_hazard_ra2, m_hazard_ra1, m_hazard_ra2;
//`ifndef FORWARD
//assign e_hazard_ra1 = ((dout_ra1==ein_wa)&ein_reg_wr&dout_inst_type[0]);
//assign e_hazard_ra2 = ((dout_ra2==ein_wa)&ein_reg_wr&dout_inst_type[1]);
//assign m_hazard_ra1 = ((dout_ra1==min_wa)&min_reg_wr&dout_inst_type[0]);
//assign m_hazard_ra2 = ((dout_ra2==min_wa)&min_reg_wr&dout_inst_type[1]);
//`else
assign e_hazard_ra1 = ((dout_ra1==ein_wa)&ein_reg_wr&(ein_inst_type[2])&dout_inst_type[0]);
assign e_hazard_ra2 = ((dout_ra2==ein_wa)&ein_reg_wr&(ein_inst_type[2])&dout_inst_type[1]);
assign m_hazard_ra1 = 0;
assign m_hazard_ra2 = 0;
//`endif

wire raw_hazard;
assign raw_hazard = e_hazard_ra1|e_hazard_ra2|m_hazard_ra1|m_hazard_ra2;

//recycle signal assignment
assign force_hold_pc = (stall_mem | raw_hazard | stall_fetch) & ~branch_or_jump_taken;
assign rec_fd        = (stall_mem | raw_hazard) & ~branch_or_jump_taken;
assign rec_de        = (stall_mem | raw_hazard) & ~branch_or_jump_taken;
assign rec_em        =  stall_mem;
assign rec_mw        =  stall_mem;

//nop signal assignment
assign nop_fd = halt_fd | branch_or_jump_taken | (stall_fetch&~(raw_hazard|stall_mem));
assign nop_de = halt_de | (rec_fd&~rec_em) | branch_or_jump_taken;
assign nop_em = halt_em;
assign nop_mw = halt_mw;

assign dump_mem = halt_mw;

endmodule
`default_nettype wire

