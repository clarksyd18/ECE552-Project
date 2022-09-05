/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2

    Filename: carryLogic.v
    Description: Takes in 4 bits of prop and gen, returns the corresponding G (bigG).
*/
module bigG (prop, gen, bigG);

    input [3:0]  prop, gen;
    output       bigG;

    // intermediate wires
    wire          g_baseAnd2Out_orIn, g_baseAnd3Out_orIn, g_baseAnd4Out_orIn;


    /*
      G(i,i+3) = g3 + p3 * g2  + p3  * p2 * g1 + p3  * p2 * p1 * g0
      implement this with a 4-OR that takes as inputs g3, a 2-AND, a 3-AND,
      and a 4-AND.
     */
    and2 g_baseAnd2 (// OUTPUT
                     .out(g_baseAnd2Out_orIn),
                     // INPUTS
                     .in1(prop[3]),
                     .in2(gen[2])
                     );

    and3 g_baseAnd3 (// OUTPUT
                     .out(g_baseAnd3Out_orIn),
                     // INPUTS
                     .in1(prop[2]),
                     .in2(prop[3]),
                     .in3(gen[1])
                     );

    and4 g_baseAnd4 (// OUTPUT
                     .out(g_baseAnd4Out_orIn),
                     // INPUTS
                     .in1(prop[1]),
                     .in2(prop[2]),
                     .in3(prop[3]),
                     .in4(gen[0])
                     );

    or4 bigG_outOr (// OUTPUT
                    .out(bigG),
                    // INPUTS
                    .in1(g_baseAnd2Out_orIn),
                    .in2(g_baseAnd3Out_orIn),
                    .in3(g_baseAnd4Out_orIn),
                    .in4(gen[3])
                    );

endmodule // bigG
