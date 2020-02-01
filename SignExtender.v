module SignExtender(BusImm, Imm16, Ctrl);
output [31:0] BusImm;
input [15:0] Imm16;
input Ctrl;

wire extBit;

// if Ctrl is 1, zero extend. if Ctrl is 0, sign extend
assign #1 extBit = (~Ctrl ?  Imm16[15] : 1'b0);

// put the first 16 bits to the value of extBit,
// then concatenate with Imm16
assign BusImm = {{16{extBit}}, Imm16};

endmodule
