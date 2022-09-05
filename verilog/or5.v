/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2

    5 input OR built out of required gates
*/
module or5 (in1, in2, in3, in4, in5, out);
    input   in1, in2, in3, in4, in5;
    output  out;

    wire    nor1Out_nandIn1, nor3Out_nandIn2;

    // one way to create a 5-input OR out of NANDs, NORs, and NOTs is
    // to have a 2-input NOR and 3-input NOR followed by a 2-input NAND
    nor2 baseNor1 (// OUTPUT
		   .out(nor1Out_nandIn1),
		   // INPUT
		   .in1(in1),
		   .in2(in2)
		   );

    nor3 baseNor2 (// OUTPUT
		   .out(nor3Out_nandIn2),
		   // INPUT
		   .in1(in3),
		   .in2(in4),
		   .in3(in5)
		   );


    // now use a 2-NAND to get a 5-input OR
    nand2 outNand (// OUTPUT
		   .out(out),
		   // INPUT
		   .in1(nor1Out_nandIn1),
		   .in2(nor3Out_nandIn2)
		   );

endmodule
