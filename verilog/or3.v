/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2

    3 input OR built out of required gates
*/
module or3 (in1, in2, in3, out);
    input   in1, in2, in3;
    output  out;

    wire    norOut_notIn;

    // one way to create a 3-input OR out of NORs and NOTs is
    // to have a 3-input NOR followed by a NOT
    nor3 baseNor (// OUTPUT
		  .out(norOut_notIn),
		  // INPUT
		  .in1(in1),
		  .in2(in2),
		  .in3(in3)
		  );

    // now not the output of the NOR to create our 3-input OR
    not1 outNot (// OUTPUT
		 .out(out),
		 // INPUT
		 .in1(norOut_notIn)
		 );

endmodule
