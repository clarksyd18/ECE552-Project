/*
   CS/ECE 552 Spring '22
   Homework #1, Problem 2
    
   Filename: cla_16b.v
   A 16-bit CLA module (submodule of ALU)
*/
module cla_16b(
  input [15:0]  a, b,
  input         cin,
  output [15:0] out,
  output        cout
);
   // declare constant for size of inputs, outputs (N)
   parameter    N = 16;
   
   wire [N-1: 0]   A, B;
   wire C_in;
   wire [N-1:0]   S;
   wire C_out;

  assign A = a;
  assign B = b;
  assign C_in = cin;
  assign out = S;
  assign cout = C_out;

   // wires (buses) for P and G subvalues (these are the values passed out by
   // cla_4b's)
   wire [N-1:0]     prop, gen;
   // wires for large P and G values
   wire [3:0]       P, G;
   // wires to use between cla_4b's (carries)
   wire [3:0]       cla_cin;
   // these are ignored -- don't care about c_out outputs for CLA4's here
   wire [3:0]       cla_cout;

   // error wires
   wire             errA0, errA1, errA2, errA3;

   // hierarchical combinational logic for CLA16 here
   carryLogic16 C_ins (// OUTPUTS
                       .C_out(cla_cin[3:0]),
                       // INPUTS
                       .c_in(C_in),
                       .prop(prop[N-1:0]),
                       .gen(gen[N-1:0])
                       );
   
   // instantiate 4 cla_4b's to do the math
   cla_4b cla_4b_0 (// OUTPUTS
                    .err(errA0),
                    .prop(prop[3:0]), 
                    .gen(gen[3:0]),
                    .Sum(S[3:0]),
                    .c_out(cla_cout[0]),
                    // INPUTS
                    .A(A[3:0]),
                    .B(B[3:0]),
                    .c_in(C_in)); // C_in = C0

   cla_4b cla_4b_1 (// OUTPUTS
                    .err(errA1),
                    .prop(prop[7:4]), 
                    .gen(gen[7:4]),
                    .Sum(S[7:4]),
                    .c_out(cla_cout[1]),
                    // INPUTS
                    .A(A[7:4]),
                    .B(B[7:4]),
                    .c_in(cla_cin[0])); // C1 = cla_cin[0]

   cla_4b cla_4b_2 (// OUTPUTS
                    .err(errA2),
                    .prop(prop[11:8]),
                    .gen(gen[11:8]),
                    .Sum(S[11:8]),
                    .c_out(cla_cout[2]),
                    // INPUTS
                    .A(A[11:8]),
                    .B(B[11:8]),
                    .c_in(cla_cin[1])); // C2 = cla_cin[1]

   cla_4b cla_4b_3 (// OUTPUTS
                    .err(errA3),
                    .prop(prop[15:12]),
                    .gen(gen[15:12]),
                    .Sum(S[15:12]),
                    .c_out(cla_cout[3]),
                    // INPUTS
                    .A(A[15:12]),
                    .B(B[15:12]), 
                    .c_in(cla_cin[2])); // C3 = cla_cin[2]

   // cla_cin[3] = C4 = C_out
   assign C_out = cla_cin[3];
   // or error wires together
   assign err = (errA0 | errA1 | errA2 | errA3);
   
endmodule
