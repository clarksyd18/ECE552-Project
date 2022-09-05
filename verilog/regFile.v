/*
   CS/ECE 552, Spring '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile(read1Data,read2Data,err,clk,rst,read1RegSel,read2RegSel,writeRegSel,writeData,writeEn);
	parameter N = 16;
    // Outputs
	output [N-1:0] read1Data, read2Data;
	output err;
    // Inputs
    input clk, rst;
	input [2:0] read1RegSel, read2RegSel, writeRegSel;
	input [N-1:0] writeData;
	input writeEn;

// regs
wire [N-1:0] regs_in  [7:0];
wire [N-1:0] regs_out [7:0];
dff_Nb #(.N(N)) reg0 (.clk(clk),.rst(rst),.D(regs_in[0]),.Q(regs_out[0]));
dff_Nb #(.N(N)) reg1 (.clk(clk),.rst(rst),.D(regs_in[1]),.Q(regs_out[1]));
dff_Nb #(.N(N)) reg2 (.clk(clk),.rst(rst),.D(regs_in[2]),.Q(regs_out[2]));
dff_Nb #(.N(N)) reg3 (.clk(clk),.rst(rst),.D(regs_in[3]),.Q(regs_out[3]));
dff_Nb #(.N(N)) reg4 (.clk(clk),.rst(rst),.D(regs_in[4]),.Q(regs_out[4]));
dff_Nb #(.N(N)) reg5 (.clk(clk),.rst(rst),.D(regs_in[5]),.Q(regs_out[5]));
dff_Nb #(.N(N)) reg6 (.clk(clk),.rst(rst),.D(regs_in[6]),.Q(regs_out[6]));
dff_Nb #(.N(N)) reg7 (.clk(clk),.rst(rst),.D(regs_in[7]),.Q(regs_out[7]));

// read 1
wire [N-1:0] out_r1_mux1 [3:0];
assign out_r1_mux1[0] = (read1RegSel[0]) ? regs_out[1] : regs_out[0];
assign out_r1_mux1[1] = (read1RegSel[0]) ? regs_out[3] : regs_out[2];
assign out_r1_mux1[2] = (read1RegSel[0]) ? regs_out[5] : regs_out[4];
assign out_r1_mux1[3] = (read1RegSel[0]) ? regs_out[7] : regs_out[6];

wire[N-1:0] out_r1_mux2 [1:0];
assign out_r1_mux2[0] = (read1RegSel[1]) ? out_r1_mux1[1] : out_r1_mux1[0];
assign out_r1_mux2[1] = (read1RegSel[1]) ? out_r1_mux1[3] : out_r1_mux1[2];

assign read1Data = (read1RegSel[2]) ? out_r1_mux2[1] : out_r1_mux2[0];

// read 2
wire [N-1:0] out_r2_mux1 [3:0];
assign out_r2_mux1[0] = (read2RegSel[0]) ? regs_out[1] : regs_out[0];
assign out_r2_mux1[1] = (read2RegSel[0]) ? regs_out[3] : regs_out[2];
assign out_r2_mux1[2] = (read2RegSel[0]) ? regs_out[5] : regs_out[4];
assign out_r2_mux1[3] = (read2RegSel[0]) ? regs_out[7] : regs_out[6];

wire[N-1:0] out_r2_mux2 [1:0];
assign out_r2_mux2[0] = (read2RegSel[1]) ? out_r2_mux1[1] : out_r2_mux1[0];
assign out_r2_mux2[1] = (read2RegSel[1]) ? out_r2_mux1[3] : out_r2_mux1[2];

assign read2Data = (read2RegSel[2]) ? out_r2_mux2[1] : out_r2_mux2[0];

// write
wire en_reg [7:0];

assign en_reg[0] = writeEn & (writeRegSel == 3'h0);
assign en_reg[1] = writeEn & (writeRegSel == 3'h1);
assign en_reg[2] = writeEn & (writeRegSel == 3'h2);
assign en_reg[3] = writeEn & (writeRegSel == 3'h3);
assign en_reg[4] = writeEn & (writeRegSel == 3'h4);
assign en_reg[5] = writeEn & (writeRegSel == 3'h5);
assign en_reg[6] = writeEn & (writeRegSel == 3'h6);
assign en_reg[7] = writeEn & (writeRegSel == 3'h7);

assign regs_in[0] = (en_reg[0]) ? writeData : regs_out[0];
assign regs_in[1] = (en_reg[1]) ? writeData : regs_out[1];
assign regs_in[2] = (en_reg[2]) ? writeData : regs_out[2];
assign regs_in[3] = (en_reg[3]) ? writeData : regs_out[3];
assign regs_in[4] = (en_reg[4]) ? writeData : regs_out[4];
assign regs_in[5] = (en_reg[5]) ? writeData : regs_out[5];
assign regs_in[6] = (en_reg[6]) ? writeData : regs_out[6];
assign regs_in[7] = (en_reg[7]) ? writeData : regs_out[7];

endmodule
