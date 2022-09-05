`default_nettype none
module control(
  // inputs
  input  wire [4:0] op,
  input  wire [1:0] func,
  // outputs
  output reg  [3:0] alu_op,
  output reg  [2:0] inst_type,
  output reg  [1:0] cond_code, wd_sel, b_src_sel, wa_sel,
  output reg        longjump, stall, branch, jump, reg_wr, mem_rd, mem_wr, err
);
localparam LD    = 3'b100;
localparam PORT1 = 3'b001;
localparam BOTH  = 3'b011;
always @(*) begin
  // default outputs
  err       = 1'b0;
  alu_op    = 4'b0000;
  cond_code = 2'h0;
  wd_sel    = 2'h0;
  b_src_sel = 2'h0;
  wa_sel    = 2'h0;
  inst_type = 2'h0;
  longjump  = 1'b0;
  stall     = 1'b0;
  branch    = 1'b0;
  jump      = 1'b0;
  reg_wr    = 1'b0;
  mem_rd    = 1'b0;
  mem_wr    = 1'b0;
  casex (op)
    //HALT
    5'h00: begin
      stall = 1'b1;
    end

    //NOP
    5'h01: begin
      reg_wr = 1'b0;
    end

    //ADDI
    5'h08: begin
      reg_wr    = 1'b1;
      alu_op    = 4'b0000;
      b_src_sel = 2'h1;
      wa_sel    = 2'h1;
      wd_sel    = 2'h0;
      inst_type = PORT1;
    end

    //SUBI
    5'h09: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0001;
      b_src_sel = 2'h1;
      wa_sel    = 2'h1;
      wd_sel    = 2'h0;
      inst_type = PORT1;
    end

    //XORI
    5'h0A: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0010;
      b_src_sel = 2'h2;
      wa_sel    = 2'h1;
      wd_sel    = 2'h0;
      inst_type = PORT1;
    end

    //ANDNI
    5'h0B: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0011;
      b_src_sel = 2'h2;
      wa_sel    = 2'h1;
      wd_sel    = 2'h0;
      inst_type = PORT1;
    end

    //ROLI
    5'h14: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0100;
      b_src_sel = 2'h1;
      wa_sel    = 2'h1;
      wd_sel    = 2'h0;
      inst_type = PORT1;
    end

    //SLLI
    5'h15: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0101;
      b_src_sel = 2'h1;
      wa_sel    = 2'h1;
      wd_sel    = 2'h0;
      inst_type = PORT1;
    end

    //RORI
    5'h16: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0110;
      b_src_sel = 2'h1;
      wa_sel    = 2'h1;
      wd_sel    = 2'h0;
      inst_type = PORT1;
    end

    //SRLI
    5'h17: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0111;
      b_src_sel = 2'h1;
      wa_sel    = 2'h1;
      wd_sel    = 2'h0;
      inst_type = PORT1;
    end

    //ST
    5'h10: begin
      reg_wr = 1'b0;
      mem_wr = 1'b1;
      mem_rd = 1'b0;

      alu_op    = 4'b0000;
      b_src_sel = 2'h1;
      inst_type = BOTH;
    end

    //LD
    5'h11: begin
      reg_wr = 1'b1;
      mem_wr = 1'b0;
      mem_rd = 1'b1;

      alu_op    = 4'b0000;
      b_src_sel = 2'h1;
      wa_sel    = 2'h1;
      wd_sel    = 2'h1;
      inst_type = (PORT1|LD);
    end

    //STU
    5'h13: begin
      reg_wr = 1'b1;
      mem_wr = 1'b1;
      mem_rd = 1'b0;

      alu_op    = 4'b0000;
      b_src_sel = 2'h1;
      wa_sel    = 2'h2;
      wd_sel    = 2'h0;
      inst_type = BOTH;
    end

    //BTR
    5'h19: begin
      reg_wr = 1'b1;
      alu_op    = 4'b1010;
      wa_sel    = 2'h0;
      wd_sel    = 2'h0;
      inst_type = PORT1;
    end

    //ADD-SUB-XOR-ANDN
    5'h1B: begin
      reg_wr = 1'b1;
      alu_op    = {2'b00,func};
      b_src_sel = 2'h0;
      wa_sel    = 2'h0;
      wd_sel    = 2'h0;
      inst_type = BOTH;
    end

    //ROL-SLL-ROR-SRL
    5'h1A: begin
      reg_wr = 1'b1;
      alu_op    = {2'b01,func};
      b_src_sel = 2'h0;
      wa_sel    = 2'h0;
      wd_sel    = 2'h0;
      inst_type = BOTH;
    end

    //SEQ
    5'h1C: begin
      reg_wr = 1'b1;
      cond_code = 2'b00;
      b_src_sel = 2'h0;
      wa_sel    = 2'h0;
      wd_sel    = 2'h2;
      inst_type = BOTH;
    end

    //SLT
    5'h1D: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0001;
      cond_code = 2'b01;
      b_src_sel = 2'h0;
      wa_sel    = 2'h0;
      wd_sel    = 2'h2;
      inst_type = BOTH;
    end

    //SLE
    5'h1E: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0001;
      cond_code = 2'b10;
      b_src_sel = 2'h0;
      wa_sel    = 2'h0;
      wd_sel    = 2'h2;
      inst_type = BOTH;
    end

    //SCO
    5'h1F: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0000;
      cond_code = 2'b11;
      b_src_sel = 2'h0;
      wa_sel    = 2'h0;
      wd_sel    = 2'h2;
      inst_type = BOTH;
    end

    //BEQZ
    5'h0C: begin
      reg_wr = 1'b0;
      cond_code = 2'h0;
      branch = 1'b1;
      inst_type = PORT1;
    end

    //BNEZ
    5'h0D: begin
      reg_wr = 1'b0;
      cond_code = 2'h1;
      branch = 1'b1;
      inst_type = PORT1;
    end

    //BLTZ
    5'h0E: begin
      reg_wr = 1'b0;
      cond_code = 2'h2;
      branch = 1'b1;
      inst_type = PORT1;
    end

    //BGEZ
    5'h0F: begin
      reg_wr = 1'b0;
      cond_code = 2'h3;
      branch = 1'b1;
      inst_type = PORT1;
    end

    //LBI
    5'h18: begin
      reg_wr = 1'b1;
      alu_op = 4'b1000;
      wa_sel = 2'h2;
      b_src_sel = 2'h3;
    end

    //SLBI
    5'h12: begin
      reg_wr = 1'b1;
      alu_op = 4'b1001;
      wa_sel = 2'h2;
      b_src_sel = 2'h3;
      inst_type = PORT1;
    end

    //J
    5'h04: begin
      reg_wr = 1'b0;
      jump     = 1'b1;
      longjump = 1'b1;
    end

    //JR
    5'h05: begin
      reg_wr = 1'b0;
      alu_op = 4'b0000;
      b_src_sel = 2'h3;
      jump     = 1'b1;
      longjump = 1'b0;
      inst_type = PORT1;
    end

    //JAL
    5'h06: begin
      reg_wr = 1'b1;
      jump     = 1'b1;
      longjump = 1'b1;
      wa_sel   = 2'h3;
      wd_sel   = 2'h3;
    end

    //JALR
    5'h07: begin
      reg_wr = 1'b1;
      alu_op    = 4'b0000;
      b_src_sel = 2'h3;
      jump      = 1'b1;
      longjump  = 1'b0;
      wa_sel    = 2'h3;
      wd_sel    = 2'h3;
      inst_type = PORT1;
    end

//BEGIN NOT IMPLEMENTED
    //siic
    5'h02: begin
      reg_wr = 1'b0;
    end

    //RTI
    5'h03: begin
      reg_wr = 1'b0;
    end
//END NOT IMPLEMENTED
    // INVALID INSTRUCTION!!!
    default: begin
      err = 1'b1;
    end
  endcase
end
endmodule
`default_nettype wire
