`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    16:24 04/24/2015
// Design Name:
// Module Name:    HazardDummyModule
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module Hazard(PCWrite, IFWrite, Bubble, Branch, ALUZero4, Jump, rw, rs, rt, Reset_L, CLK);
	input			Branch;
	input			ALUZero4;
	input			Jump;
	input	[4:0]	rw;
	input	[4:0]	rs;
	input	[4:0]	rt;
	input			Reset_L;
	input			CLK;
	output reg		PCWrite;
	output reg		IFWrite;
	output reg		Bubble;

	/*state definition for FSM*/
				parameter NoHazard_state = 3'b000;
				parameter Bubble0_state  = 3'b001;
				parameter Bubble1_state  = 3'b010;
				parameter Branch0_state  = 3'b011;
				parameter Branch1_state  = 3'b100;
				parameter Branch2_state  = 3'b101;
				parameter Jump0_state    = 3'b110;


	/*internal signals*/
	wire cmp1, cmp2, cmp3;

	/*internal state*/
	reg [2:0] FSM_state, FSM;
	reg [4:0] rw1, rw2, rw3; //rw history registers

	/*create compare logic*/
	assign  cmp1 = (((rs==rw1)||(rt==rw1))&&(rw1!= 0)) ? 1:0;
	assign  cmp2 = (((rs==rw2)||(rt==rw2))&&(rw2!= 0)) ? 1:0;
	assign  cmp3 = (((rs==rw3)||(rt==rw3))&&(rw3!= 0)) ? 1:0;
	/* finds the dependancy btween current instruction and the
			one before */
	initial begin
		FSM_state = NoHazard_state;
	end


	/*keep track of rw*/
	always @(negedge CLK) begin
		if(Reset_L ==  0) begin
			rw1 <=  0;
			rw2 <=  0;
			rw3 <=  0;
		end
		else begin
			rw1 <= Bubble ? 0:rw;//insert bubble if needed
			rw2 <= rw1;
			rw3 <= rw2;
		end
	end


	/*FSM state register*/
	always @(negedge CLK) begin
		if(Reset_L == 0)
			FSM_state <= 0;
		else
			FSM_state <= FSM;
	end

	/*FSM next state and output logic*/
	always @(*) begin //combinatory logic
		case(FSM_state)
			NoHazard_state: begin
				if(Jump== 1'b1) begin //prioritize jump
					{PCWrite,IFWrite,Bubble} <= #2 3'b10x;
					FSM <= #2 Jump0_state;
				end
				else if(cmp1== 1'b1) begin //3-delay data hazard
					FSM <= #2 3'b001;
					{PCWrite,IFWrite,Bubble} <= #2 3'b001;
				//	FSM <= #2 Bubble0_state;
				//	FSM <= #2 Bubble0_state;
				end
				else if(cmp2== 1'b1) begin //2-delay data hazard
					{PCWrite,IFWrite,Bubble} <= #2 3'b001;
					FSM <= #2 Bubble1_state;
				end
				else if(cmp3== 1'b1) begin //1-delay data hazard
					{PCWrite,IFWrite,Bubble} <= #2 3'b001;
					FSM <= #2 NoHazard_state;
				end
				else if(Branch==1'b1) begin //branch
					{PCWrite,IFWrite,Bubble} <= #2 3'b000;
					FSM <= #2 Branch0_state;
				end
				else begin
					// normal
					{PCWrite,IFWrite,Bubble} <= #2 3'b110;
					FSM <= #2 NoHazard_state;
				end
			end

			Bubble0_state: begin
			//uncondition return to no hazard state
			/* Provde the value of FSM and outputs 				    			(PCWrite,IFWrite,Buble)*/
				{PCWrite,IFWrite,Bubble} <= #2 3'b001;
				FSM <= #2 Bubble1_state;
			end

			Bubble1_state: begin
				{PCWrite,IFWrite,Bubble} <= #2 3'b001;
				FSM <= #2 NoHazard_state;
			end

			Branch0_state: begin
				{PCWrite,IFWrite,Bubble} <= #2 3'b001;
				FSM <= #2 Branch1_state;
			end

			Branch1_state: begin
				if (ALUZero4 == 0) begin //branch not taken
					{PCWrite,IFWrite,Bubble} <= #2 3'b111;
					FSM <= #2 NoHazard_state;
				end
				else if (ALUZero4 == 1) begin // branch taken
					{PCWrite,IFWrite,Bubble} <= #2 3'b101;
					FSM <= #2 Branch2_state;
				end
			end

			Branch2_state: begin
				{PCWrite,IFWrite,Bubble} <= #2 3'b111;
				FSM <= #2 NoHazard_state;
			end

			Jump0_state: begin
				{PCWrite,IFWrite,Bubble} <= #2 3'b11x;
				FSM <= #2 NoHazard_state;
			end

			default: begin
				FSM <= #2 NoHazard_state;
				PCWrite <= #2 1'bx;
				IFWrite <= #2 1'bx;
				Bubble  <= #2 1'bx;
			end
		endcase
	end
endmodule
