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
module carryLogic16 (c_in, prop, gen, C_out);
    input         c_in;
    input [15:0]  prop, gen;
    // NOTE: we use 3:0 here because because of how arrays work in verilog,
    // but C_out[0] = C1, C_out[1] = C2, and so on.
    output [3:0] C_out;

    // intermediate wires
    wire [3:0] 	  BigProp, BigGen;
    wire          bigC1_baseAndOut_orIn;
    wire          bigC2_baseAnd2Out_orIn, bigC2_baseAnd3Out_orIn;
    wire          bigC3_baseAnd2Out_orIn, bigC3_baseAnd3Out_orIn, bigC3_baseAnd4Out_orIn;
    wire          bigC4_baseAnd2Out_orIn, bigC4_baseAnd3Out_orIn, bigC4_baseAnd4Out_orIn,
                  bigC4_baseAnd5Out_orIn;
 
    // calculate P0, P1, P2, P3
    // P0 = P(0:3) = p0 * p1 * p2 * p3
    and4 p0And (// OUTPUTS
		.out(BigProp[0]),
		// INPUTS
		.in1(prop[0]),
		.in2(prop[1]),
		.in3(prop[2]),
		.in4(prop[3])
		);
 
    // P1 = P(4:7) = p4 * p5 * p6 * p7
    and4 p1And (// OUTPUTS
		.out(BigProp[1]),
		// INPUTS
		.in1(prop[4]),
		.in2(prop[5]),
		.in3(prop[6]),
		.in4(prop[7])
		);
 
    // P2 = P(11:8) = p8 * p9 * p10 * p11
    and4 p2And (// OUTPUTS
		.out(BigProp[2]),
		// INPUTS
		.in1(prop[8]),
		.in2(prop[9]),
		.in3(prop[10]),
		.in4(prop[11])
		);
 
    // P3 = P(15:12) = p15 * p14 * p13 * p12
    and4 p3And (// OUTPUTS
		.out(BigProp[3]),
		// INPUTS
		.in1(prop[12]),
		.in2(prop[13]),
		.in3(prop[14]),
		.in4(prop[15])
		);
 
    // calculate G0, G1, G2, G3
    bigG bigG_G0 (// OUTPUT
		  .bigG(BigGen[0]),
		  // INPUTS
		  .prop(prop[3:0]),
		  .gen(gen[3:0])
		  );

    bigG bigG_G1 (// OUTPUT
		  .bigG(BigGen[1]),
		  // INPUTS
		  .prop(prop[7:4]),
		  .gen(gen[7:4])
		  );

    bigG bigG_G2 (// OUTPUT
		  .bigG(BigGen[2]),
		  // INPUTS
		  .prop(prop[11:8]),
		  .gen(gen[11:8])
		  );   

    bigG bigG_G3 (// OUTPUT
		  .bigG(BigGen[3]),
		  // INPUTS
		  .prop(prop[15:12]),
		  .gen(gen[15:12])
		  );

    /*
      Now we can finally calculate C1, C2, C3, and C4.

      However, this requires doing some unrolling of equations just like
      carryLogic4 to avoid ripple.
     */
    /*
     C1 = c4 = G0,3 + P0,3 * c0 = G0 + P0*c0

     Use a 2 AND followed by a 2 OR to implement this.
     */
    and2 bigC1_baseAnd (// OUTPUT
			.out(bigC1_baseAndOut_orIn),
			// INPUTS
			.in1(BigProp[0]),
			.in2(c_in)
			);

    or2 bigC1_outOr (// OUTPUT
                     .out(C_out[0]), // C_out[0] = C1 = c4
                     // INPUTS
                     .in1(BigGen[0]),
                     .in2(bigC1_baseAndOut_orIn)
                     );

    /*
     C2 = c8 = G4,7 + P4,7 * c0 = G4,7 + G0,3*P4,7 + P4,7*P0,3*c0
             = G1 + G0*P1 + P1*P0*c0 

     Use a 2-AND and 3-AND that feed into a 3-OR to implement this.
     */
    and2 bigC2_baseAnd2 (// OUTPUT
			 .out(bigC2_baseAnd2Out_orIn),
			 // INPUTS
			 .in1(BigProp[1]),
			 .in2(BigGen[0])
			 );

    and3 bigC2_baseAnd3 (// OUTPUT
			 .out(bigC2_baseAnd3Out_orIn),
			 // INPUTS
			 .in1(BigProp[0]),
			 .in2(BigProp[1]),
			 .in3(c_in)
			 );

    or3 bigC2_outOr (// OUTPUT
                     .out(C_out[1]),
                     // INPUTS
                     .in1(bigC2_baseAnd2Out_orIn),
                     .in2(bigC2_baseAnd3Out_orIn),
                     .in3(BigGen[1])
                     );

    /*
     C3 = c12 = G11,8 + P11,8*G7,4 + P11,8*P4,7*G0,3 + P11,8*P4,7*P0,3*c0
              = G2 + G1*P2 + G0*P1*P0 + P2*P1*P0*c0

     Use a 2-AND, 3-AND, and 4-AND that feed into a 4-OR to implement this.
     */
    and2 bigC3_baseAnd2 (// OUTPUT
			 .out(bigC3_baseAnd2Out_orIn),
			 // INPUTS
			 .in1(BigProp[2]),
			 .in2(BigGen[1])
			 );

    and3 bigC3_baseAnd3 (// OUTPUT
			 .out(bigC3_baseAnd3Out_orIn),
			 // INPUTS
			 .in1(BigProp[1]),
			 .in2(BigProp[2]),
			 .in3(BigGen[0])
			 );

    and4 bigC3_baseAnd4 (// OUTPUT
			 .out(bigC3_baseAnd4Out_orIn),
			 // INPUTS
			 .in1(BigProp[0]),
			 .in2(BigProp[1]),
			 .in3(BigProp[2]),
			 .in4(c_in)
			 );

    or4 bigC3_outOr (// OUTPUT
                     .out(C_out[2]),
                     // INPUTS
                     .in1(bigC3_baseAnd2Out_orIn),
                     .in2(bigC3_baseAnd3Out_orIn),
                     .in3(bigC3_baseAnd4Out_orIn),
                     .in4(BigGen[2])
                     );

    /*
      C4 = c16 = G15,12 + G11,8*P15,12 + G7,4*P15,12*P11,8 + G3,0*P15,12*P11,8*P7,4 + P15,12*P11,8*P7,4*P3,0*c0
               = G3 + G2*P3 + G1*P2*P1*P0 + G0*P3*P2*P1 + P3*P2*P1*P0*c0

      Use a 2-AND, 3-AND, 4-AND, and 5-AND that feed into a 5-OR to implement this.
     */
    and2 bigC4_baseAnd2 (// OUTPUT
			 .out(bigC4_baseAnd2Out_orIn),
			 // INPUTS
			 .in1(BigProp[3]),
			 .in2(BigGen[2])
			 );

    and3 bigC4_baseAnd3 (// OUTPUT
			 .out(bigC4_baseAnd3Out_orIn),
			 // INPUTS
			 .in1(BigProp[2]),
			 .in2(BigProp[3]),
			 .in3(BigGen[1])
			 );

    and4 bigC4_baseAnd4 (// OUTPUT
			 .out(bigC4_baseAnd4Out_orIn),
			 // INPUTS
			 .in1(BigProp[1]),
			 .in2(BigProp[2]),
			 .in3(BigProp[3]),
			 .in4(BigGen[0])
			 );

    and5 bigC4_baseAnd5 (// OUTPUT
			 .out(bigC4_baseAnd5Out_orIn),
			 // INPUTS
			 .in1(BigProp[0]),
			 .in2(BigProp[1]),
			 .in3(BigProp[2]),
			 .in4(BigProp[3]),
			 .in5(c_in)
			 );

    or5 bigC4_outOr (// OUTPUT
                     .out(C_out[3]),
                     // INPUTS
                     .in1(bigC4_baseAnd2Out_orIn),
                     .in2(bigC4_baseAnd3Out_orIn),
                     .in3(bigC4_baseAnd4Out_orIn),
                     .in4(bigC4_baseAnd5Out_orIn),
                     .in5(BigGen[3])
                     );

endmodule // carryLogic16
