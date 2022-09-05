/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2

    2 input OR built out of required gates
*/
module or2 (in1,in2,out);
    input   in1, in2;
    output  out;

    wire    norOut_notIn;

    // one way to create a 2-input OR out of NORs and NOTs is
    // to have a 2-input NOR followed by a NOT
    nor2 baseNor (// OUTPUT
		  .out(norOut_notIn),
		  // INPUT
		  .in1(in1),
		  .in2(in2)
		  );

   // now not the output of the NOR to create our 2-input OR
   not1 outNot (// OUTPUT
		.out(out),
		// INPUT
		.in1(norOut_notIn)
		);

endmodule
