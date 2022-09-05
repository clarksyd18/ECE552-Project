/*
   CS/ECE 552 Spring '20
   Homework #1, Problem 2
  
   Filename        : cla_4b.v
   Description     : This module is designed for the 4 bit carry look ahead adder.
*/
module cla_4b(A, B, c_in, prop, gen, Sum, c_out, err);

   // declare constant for size of inputs, outputs (N)
   parameter    N = 4;

   input [N-1: 0]   A, B;
   input            c_in;
   output [N-1:0]   prop, gen, Sum;
   output           c_out, err;
   
   // wires to use between PFA's
   wire [N-1:0]     cla_cin;

   // error wires
   wire             errPFA0, errPFA1, errPFA2, errPFA3;
   
   // combinational logic for CLA4 here
   carryLogic4 c_ins (// OUTPUTS
		      .c_out(cla_cin[N-1:0]),
		      // INPUTS
		      .c_in(c_in),
		      .prop(prop[N-1:0]),
		      .gen(gen[N-1:0])
		      );

   // instantiate 4 PFA's to do the math
   PFA pfa0 (// OUTPUTS
	     .err(errPFA0),
	     .S(Sum[0]),
	     .P(prop[0]),
             .G(gen[0]),
	     // INPUTS
	     .A(A[0]),
	     .B(B[0]),
	     .C_in(c_in));

   PFA pfa1 (// OUTPUTS
	     .err(errPFA1),
	     .S(Sum[1]),
	     .P(prop[1]),
             .G(gen[1]),
	     // INPUTS
	     .A(A[1]),
	     .B(B[1]),
	     .C_in(cla_cin[0]));

   PFA pfa2 (// OUTPUTS
	     .err(errPFA2),
	     .S(Sum[2]),
	     .P(prop[2]),
             .G(gen[2]),
	     // INPUTS
	     .A(A[2]),
	     .B(B[2]),
	     .C_in(cla_cin[1]));

   PFA pfa3 (// OUTPUTS
	     .err(errPFA3),
	     .S(Sum[3]),
	     .P(prop[3]),
             .G(gen[3]),
	     // INPUTS
	     .A(A[3]),
	     .B(B[3]),
	     .C_in(cla_cin[2]));

   // cla_cin[3] = c_out
   assign c_out = cla_cin[3];

   // or error wires together
   assign      err = (errPFA0 | errPFA1 | errPFA2 | errPFA3);
   
endmodule
