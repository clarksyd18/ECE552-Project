/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2

    4 input OR built out of required gates
*/
module or4 (in1, in2, in3, in4, out);
    input   in1, in2, in3, in4;
    output  out;

    wire    nor1Out_nandIn1, nor2Out_nandIn2;

    // one way to create a 4-input OR out of NANDs, NORs, and NOTs is
    // to have 2 2-input NORs followed by a 2-input NAND
    nor2 baseNor1 (// OUTPUT
		   .out(nor1Out_nandIn1),
		   // INPUT
		   .in1(in1),
		   .in2(in2)
		   );

    nor2 baseNor2 (// OUTPUT
		   .out(nor2Out_nandIn2),
		   // INPUT
		   .in1(in3),
		   .in2(in4)
		   );

    // now use a 2-NAND to get a 4-input OR
    nand2 outNand (// OUTPUT
		   .out(out),
		   // INPUT
		   .in1(nor1Out_nandIn1),
		   .in2(nor2Out_nandIn2)
		   );

endmodule
