/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2

    Filename: carryLogic.v
    Description: This file contains the logic to determine if a specific CLA bit
                 has a carry-out.  This file specifically takes in 4 bits of
                 propagate and generate bits, as well as the carry-in for this
                 4 bit sequence, and returns the 4 bits of carry out based on this
                 information.  Moreover, this file uses the required gates, except
                 we have created ANDs and ORs of the appropriate width using those
                 required gates.
*/
module carryLogic4 (c_in, prop, gen, c_out);
    input        c_in;
    input [3:0]  prop, gen;
    // NOTE: we use 3:0 here because because of how arrays work in verilog,
    // but c_out[0] = c1, c_out[1] = c2, and so on.
    output [3:0] c_out;

    // intermediate wires
    wire         c1_baseAndOut_orIn;
    wire         c2_baseAnd2Out_orIn, c2_baseAnd3Out_orIn;
    wire         c3_baseAnd2Out_orIn, c3_baseAnd3Out_orIn, c3_baseAnd4Out_orIn;
    wire         c4_baseAnd2Out_orIn, c4_baseAnd3Out_orIn, c4_baseAnd4Out_orIn,
                 c4_baseAnd5Out_orIn;
 
    // c1 = g0 + p0 * c0
    // thus we use a 2-AND that feeds into a 2-OR
    and2 c1_baseAnd (// OUTPUT
                     .out(c1_baseAndOut_orIn),
                     // INPUTS
                     .in1(prop[0]),
                     .in2(c_in)
                     );

    or2 c1_outOr (// OUTPUT
                  .out(c_out[0]),
                  // INPUTS
                  .in1(gen[0]),
                  .in2(c1_baseAndOut_orIn)
                  );
   
    // c2 = g1 + p1 * c1 = g1 + g0*p1 + p1*p0*c0
    // thus we use a 2-AND and 3-AND that feed into a 3-OR
    and2 c2_baseAnd2 (// OUTPUT
                      .out(c2_baseAnd2Out_orIn),
                      // INPUTS
                      .in1(prop[1]),
                      .in2(gen[0])
                      );

    and3 c2_baseAnd3 (// OUTPUT
                      .out(c2_baseAnd3Out_orIn),
                      // INPUTS
                      .in1(prop[0]),
                      .in2(prop[1]),
                      .in3(c_in)
                     );

    or3 c2_outOr (// OUTPUT
                  .out(c_out[1]),
                  // INPUTS
                  .in1(c2_baseAnd2Out_orIn),
                  .in2(c2_baseAnd3Out_orIn),
                  .in3(gen[1])
                  );

    // c3 = g2 + p2 * c2 = g2 + g1*p2 + g0*p2*p1 + p2*p1*p0*c0
    // thus we use a 2-AND, 3-AND, and 4-AND that feed into a 4-OR
    and2 c3_baseAnd2 (// OUTPUT
                      .out(c3_baseAnd2Out_orIn),
                      // INPUTS
                      .in1(prop[2]),
                      .in2(gen[1])
                      );

    and3 c3_baseAnd3 (// OUTPUT
                      .out(c3_baseAnd3Out_orIn),
                      // INPUTS
                      .in1(prop[1]),
                      .in2(prop[2]),
                      .in3(gen[0])
                     );

    and4 c3_baseAnd4 (// OUTPUT
                      .out(c3_baseAnd4Out_orIn),
                      // INPUTS
                      .in1(prop[0]),
                      .in2(prop[1]),
                      .in3(prop[2]),
                      .in4(c_in)
                     );

    or4 c3_outOr (// OUTPUT
                  .out(c_out[2]),
                  // INPUTS
                  .in1(c3_baseAnd2Out_orIn),
                  .in2(c3_baseAnd3Out_orIn),
                  .in3(c3_baseAnd4Out_orIn),
                  .in4(gen[2])
                  );

    // c4 = g3 + p3 * c3 = g3 + g2*p3 + g1*p3*p2 + g0*p3*p2*p1 + p3*p2*p1*p0*c0
    // thus we use a 2-AND, 3-AND, 4-AND, and 5-AND that feed into a 5-OR
    and2 c4_baseAnd2 (// OUTPUT
                      .out(c4_baseAnd2Out_orIn),
                      // INPUTS
                      .in1(prop[3]),
                      .in2(gen[2])
                      );

    and3 c4_baseAnd3 (// OUTPUT
                      .out(c4_baseAnd3Out_orIn),
                      // INPUTS
                      .in1(prop[2]),
                      .in2(prop[3]),
                      .in3(gen[1])
                      );

    and4 c4_baseAnd4 (// OUTPUT
                      .out(c4_baseAnd4Out_orIn),
                      // INPUTS
                      .in1(prop[1]),
                      .in2(prop[2]),
                      .in3(prop[3]),
                      .in4(gen[0])
                      );

    and5 c4_baseAnd5 (// OUTPUT
                      .out(c4_baseAnd5Out_orIn),
                      // INPUTS
                      .in1(prop[0]),
                      .in2(prop[1]),
                      .in3(prop[2]),
                      .in4(prop[3]),
                      .in5(c_in)
                      );

    or5 c4_outOr (// OUTPUT
                  .out(c_out[3]),
                  // INPUTS
                  .in1(c4_baseAnd2Out_orIn),
                  .in2(c4_baseAnd3Out_orIn),
                  .in3(c4_baseAnd4Out_orIn),
                  .in4(c4_baseAnd5Out_orIn),
                  .in5(gen[3])
                  );

endmodule // carryLogic4
