/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2

    5 input AND built out of required gates
*/
module and5 (in1, in2, in3, in4, in5, out);
    input   in1, in2, in3, in4, in5;
    output  out;

    wire    nand1Out_norIn1, nand3Out_norIn2;

    // one way to create a 4-input AND out of NANDs, NORs, and NOTs is
    // to have 2 2-input NANDs followed by a 2-input NOR
    nand2 baseNand1 (// OUTPUT
		     .out(nand1Out_norIn1),
		     // INPUT
		     .in1(in1),
		     .in2(in2)
		     );

    nand3 baseNand2 (// OUTPUT
		     .out(nand3Out_norIn2),
		     // INPUT
		     .in1(in3),
		     .in2(in4),
		     .in3(in5)
		     );

    // now use a NOR2 to get a 5-input AND
    nor2 outNor (// OUTPUT
		 .out(out),
		 // INPUT
		 .in1(nand1Out_norIn1),
		 .in2(nand3Out_norIn2)
		 );

endmodule
