/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2

    3 input AND built out of required gates
*/
module and3 (in1, in2, in3, out);
    input   in1, in2, in3;
    output  out;

    wire    nandOut_notIn;

    // one way to create a 2-input AND out of NANDs and NOTs is
    // to have a 3-input NAND followed by a NOT
    nand3 baseNand (// OUTPUT
		    .out(nandOut_notIn),
		    // INPUT
		    .in1(in1),
		    .in2(in2),
		    .in3(in3)
		    );

    // now not the output of the NOR to create our 2-input OR
    not1 outNand (// OUTPUT
		  .out(out),
		  // INPUT
		  .in1(nandOut_notIn)
		  );

endmodule
