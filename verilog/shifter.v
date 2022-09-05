`default_nettype none
/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
 */
module shifter (In, ShAmt, Oper, Out);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH = 16;
    parameter SHAMT_WIDTH   =  4;
    parameter NUM_OPERATIONS = 2;

    input  wire [OPERAND_WIDTH -1:0] In   ; // Input operand
    input  wire [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input  wire [NUM_OPERATIONS-1:0] Oper ; // Operation type
    output wire [OPERAND_WIDTH -1:0] Out  ; // Result of shift/rotate

	/* YOUR CODE HERE */

	// shift left
	wire [OPERAND_WIDTH-1:0] lshift1, lshift2, lshift4, lshift8;
	assign lshift1 = (ShAmt[0]) ? {In[OPERAND_WIDTH-2:0],1'b0}       : In;
	assign lshift2 = (ShAmt[1]) ? {lshift1[OPERAND_WIDTH-3:0],2'b00} : lshift1;
	assign lshift4 = (ShAmt[2]) ? {lshift2[OPERAND_WIDTH-5:0],4'h0}  : lshift2;
	assign lshift8 = (ShAmt[3]) ? {lshift4[OPERAND_WIDTH-9:0],8'h00} : lshift4;

	// rotate left
	wire [OPERAND_WIDTH-1:0] lrot1, lrot2, lrot4, lrot8;
	assign lrot1 = (ShAmt[0]) ? {In[OPERAND_WIDTH-2:0],In[OPERAND_WIDTH-1]} : In;
	assign lrot2 = (ShAmt[1]) ? {lrot1[OPERAND_WIDTH-3:0],lrot1[OPERAND_WIDTH-1:OPERAND_WIDTH-2]} : lrot1;
	assign lrot4 = (ShAmt[2]) ? {lrot2[OPERAND_WIDTH-5:0],lrot2[OPERAND_WIDTH-1:OPERAND_WIDTH-4]} : lrot2;
	assign lrot8 = (ShAmt[3]) ? {lrot4[OPERAND_WIDTH-9:0],lrot4[OPERAND_WIDTH-1:OPERAND_WIDTH-8]} : lrot4;

	// shift right logical
	wire [OPERAND_WIDTH-1:0] rshift1, rshift2, rshift4, rshift8;
	assign rshift1 = (ShAmt[0]) ? {1'b0,In[OPERAND_WIDTH-1:1]}       : In;
	assign rshift2 = (ShAmt[1]) ? {2'b00,rshift1[OPERAND_WIDTH-1:2]} : rshift1;
	assign rshift4 = (ShAmt[2]) ? {4'h0,rshift2[OPERAND_WIDTH-1:4]}  : rshift2;
	assign rshift8 = (ShAmt[3]) ? {8'h0,rshift4[OPERAND_WIDTH-1:8]}  : rshift4;
   
	// rotate right 
	wire [OPERAND_WIDTH-1:0] rrot1, rrot2, rrot4, rrot8;
	assign rrot1 = (ShAmt[0]) ? {In[0],In[OPERAND_WIDTH-1:1]}         : In;
	assign rrot2 = (ShAmt[1]) ? {rrot1[1:0],rrot1[OPERAND_WIDTH-1:2]} : rrot1;
	assign rrot4 = (ShAmt[2]) ? {rrot2[3:0],rrot2[OPERAND_WIDTH-1:4]} : rrot2;
	assign rrot8 = (ShAmt[3]) ? {rrot4[7:0],rrot4[OPERAND_WIDTH-1:8]} : rrot4;

	// output muxes
	wire [OPERAND_WIDTH-1:0] lres, rres;
	assign lres = (Oper[0]) ? lshift8 : lrot8;
	assign rres = (Oper[0]) ? rshift8 : rrot8;
	assign Out  = (Oper[1]) ? rres : lres;
   
endmodule
`default_nettype wire
