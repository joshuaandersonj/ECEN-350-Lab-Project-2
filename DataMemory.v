`timescale 1ns / 1ps

module DataMemory(
	output [31:0] ReadData,
	input [31:0] Address,
	input [31:0] WriteData,
	input MemoryRead,
	input MemoryWrite,
	input Clock
);

// ReadData needs to be a reg to be driven in the ALWAYS block
reg [31:0] ReadData;

//  Memory
reg [31:0] SavedData [63:0];

// Reading data
always @ (posedge Clock) begin
	if (MemoryRead) ReadData<= #20  SavedData[Address[31:2]];
end

// Writing data
always @ (negedge Clock) begin
	if (MemoryWrite) SavedData[Address[31:2]]<= #20 WriteData;
end

endmodule
