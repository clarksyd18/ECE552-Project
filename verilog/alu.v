`default_nettype none
module alu(
  input  wire [15:0] a, b,
  input  wire [3:0]  op,
  output wire [15:0] out, output wire        neg, zero, cout, lt, eq
);

  // inverted inputs
  wire [15:0] a_inv, b_inv;
  assign a_inv = ~a;
  assign b_inv = ~b;

  // a possible inverted input
  wire [15:0] a_actual;
  assign a_actual = (op[0]) ? a_inv : a;

  // outputs from operational blocks
  wire [15:0] adder_out, shifter_out, and_out, xor_out, shift_or_out, reverse_out;

  // adder
  wire overflow;
  //assign overflow = (a_actual[15]^b[15]) ? 1'b0 : (a_actual[15]^adder_out[15]);
  assign overflow = adder_out[15]^a[15]^b[15]^cout;

  cla_16b add(.a(a_actual),.b(b),.cin(op[0]),.cout(cout),.out(adder_out));

  //cla_16b adder_ofl(.a(a_actual),.b(16'h0000),.cin(1'b1),.out(ofl_adder_out));

  // shifter
  shifter #(.OPERAND_WIDTH(16)) shift(
    .In(a),.ShAmt(b[3:0]),.Oper(op[1:0]),.Out(shifter_out));

  // and
  assign and_out = a & b_inv;

  // xor
  assign xor_out = a ^ b;

  // shift+or
  assign shift_or_out = {a[7:0],b[7:0]};

  // reverse
  reverser rev(.in(a),.out(reverse_out));


  // select the output
  wire [15:0] and_or_xor, add_or_ax, aax_or_shift;
  wire [15:0] none_or_orshift, reverse_or_noos;

  assign and_or_xor      = (op[0]) ? and_out         : xor_out;
  assign none_or_orshift = (op[0]) ? shift_or_out    : b;
  
  assign add_or_ax       = (op[1]) ? and_or_xor      : adder_out;
  assign reverse_or_noos = (op[1]) ? reverse_out     : none_or_orshift;

  assign aax_or_shift    = (op[2]) ? shifter_out     : add_or_ax;

  assign out             = (op[3]) ? reverse_or_noos : aax_or_shift;

  // flag logic
  assign eq   = (a == b); // need to ensure that op[0] is 0
  assign neg  = a[15];
  assign zero = ~|a;
  assign lt   = ((adder_out[15]==~overflow) & (adder_out!=16'h0000)); // need to ensure that op[0] is 1
  //assign lt = (a[15]&~b[15]) | ((adder_out[15]^overflow)&(|adder_out));

endmodule
`default_nettype wire
