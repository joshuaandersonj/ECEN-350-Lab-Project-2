`timescale 1ns / 1ps

module RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr, Clk);
  output [31:0] BusA;
  output [31:0] BusB;
  input  [31:0] BusW;
  input  [4:0] RA;
  input  [4:0] RB;
  input  [4:0] RW;
  input  RegWr;
  input  Clk;

  reg [31:0] registers [31:0];


initial begin
integer i =0;
	for (i =0; i<32;i=i+1) begin
		registers[i] <= 0;
	end
end


// if the zero register is accessed, always return 0
// otherwise return the value stored in the register
  assign  #2 BusA = ( (RA==4'b0) ? 32'b0 : registers[RA] );
  assign  #2 BusB = ( (RB==4'b0) ? 32'b0 : registers[RB] );

// write on the negative edge of the clock
  always @ (negedge Clk) begin
      if(RegWr) begin
	if (RW != 0) // do not write to the 0 register
		 registers[RW] <= #3 BusW;
      end
  end
endmodule
