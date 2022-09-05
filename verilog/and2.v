/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2

    2 input AND built out of required gates
*/
module and2 (in1,in2,out);
    input   in1, in2;
    output  out;

    wire    nandOut_notIn;

    // one way to create a 2-input AND out of NANDs and NOTs is
    // to have a 2-input NAND followed by a NOT
    nand2 baseNand (// OUTPUT
		    .out(nandOut_notIn),
		    // INPUT
		    .in1(in1),
		    .in2(in2)
		    );

    // now not the output of the NOR to create our 2-input OR
    not1 outNand (// OUTPUT
		  .out(out),
		  // INPUT
		  .in1(nandOut_notIn)
		  );

endmodule
