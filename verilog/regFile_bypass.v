/*
   CS/ECE 552, Spring '22
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (read1Data,read2Data,err,clk,rst,writeEn,read1RegSel,read2RegSel,writeRegSel,writeData);
	parameter N = 16;
    // Outputs
    output [N-1:0] read1Data, read2Data;
	output err;
    // Inputs
	input clk, rst, writeEn;
	input [2:0] read1RegSel, read2RegSel, writeRegSel;
	input [N-1:0] writeData;


	wire [N-1:0] out1, out2;

	regFile #(.N(N)) rf (.read1Data(out1),.read2Data(out2),.err(err),.clk(clk),.rst(rst),
						 .writeEn(writeEn),.read1RegSel(read1RegSel),.read2RegSel(read2RegSel),
						 .writeRegSel(writeRegSel),.writeData(writeData));

	assign read1Data = (writeEn & (read1RegSel == writeRegSel)) ? writeData : out1;	
	assign read2Data = (writeEn & (read2RegSel == writeRegSel)) ? writeData : out2;	

endmodule
