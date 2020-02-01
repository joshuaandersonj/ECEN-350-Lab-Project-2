`timescale 1ns / 1ps

module NextPClogic(
	output [31:0] NextPC,
	input  [31:0] CurrentPC,
	input  [25:0] JumpField,
	input  [31:0] SignExtImm32,
	input  Branch, ALUZero, Jump
);

reg [31:0] out, IncPC, IncBR;

assign #1 IncPC = CurrentPC + 4;
assign #2 IncBR = IncPC + $signed(SignExtImm32<<2);

always @ (*) begin

	if (Jump)
		// if jumping, upper 4 bits of PC are the page number
		// jump cannot jump between pages.
		// append 00 to the end of the jump field to keep PC word aligned
		out = #1 {IncPC[31:28] , JumpField, 2'b00};

	else if (Branch & ALUZero)
		// add immediate from branch to the new PC (PC+4)
		out = #2 IncBR;

	else
		out = #2 IncPC;
end

assign NextPC = out;

endmodule
