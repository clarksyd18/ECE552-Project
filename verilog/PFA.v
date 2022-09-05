/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2

    Filename        : cla_4b.v
    Description     : a 1-bit Partial Full Adder (PFA) module (submodule of
                      CLA).  It adds A and B and generates appropriate signals.
*/
module PFA(A, B, C_in, P, G, S, err);

   input    A, B, C_in;
   output   P, G, S, err;
   
   // declare wire for P so can use as an input to S XOR
   wire     Prop;
   wire     notG;

   // the PFA uses 2 XOR's and 1 AND
   /*
   assign Prop = A ^ B; // bitwise XOR
   assign G = A & B;  // bitwise And
   assign S = Prop ^ C_in; // bitwise XOR
    */
   // P = A XOR B
   xor2 xorP (// OUTPUT
              .out(Prop),
              // INPUTS
              .in1(A),
              .in2(B));
   // G = AB
   // however, since we don't have an AND though, can use a not and a nand
   nand2 nandG (// OUTPUT
                .out(notG),
                // INPUT
                .in1(A),
                .in2(B)
                );
   not1 notNandG (// OUTPUT
                  .out(G),
                  // INPUT
                  .in1(notG)
                  );

   // S = Prop XOR C_in
   xor2 xorS(// OUTPUT
             .out(S),
             // INPUTS
             .in1(Prop),
             .in2(C_in));

   assign P = Prop;

   // currently no known error cases
   assign      err = 1'b0;
   
endmodule
