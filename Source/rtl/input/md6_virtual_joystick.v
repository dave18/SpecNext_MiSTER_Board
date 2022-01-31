`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2022 13:41:16
// Design Name: 
// Module Name: md6_virtual_joystick
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//X Z Y START A C B U D L R
module md6_virtual_joystick(
    input wire clk,
	 input wire reset,
    input wire [10:0] vj,  //virtual joystick
    input wire pin_7,
    output reg [5:0] data_bits
    );
    
	 reg [2:0] status;			//status of select bit - to drive state engine
	 reg	old_pin_7;
    
	 always @(posedge clk or posedge reset)
    begin
		if (reset)
		begin
			status <=3'b000;
			old_pin_7 <= 1'b1;
		end
		else
		begin
			case (status)		         
				'b000:   begin	//idle (pin 7 high)
					data_bits <= ~{vj[5],vj[4],vj[0],vj[1],vj[2],vj[3]};   // C B R L D U
					if (pin_7 == 1'b0) status<=status + 3'b001;					// increase state machine if select pin goes low
				end
				'b001:   begin	//first pulse low
					data_bits <= ~{vj[7],vj[6],2'b00,vj[2],vj[3]};   // START A 0 0 D U
					if (pin_7 == 1'b1) status<=status + 3'b001;					// increase state machine if select pin goes high
				end
				'b010:   begin	//first pulse high
					data_bits <= ~{vj[5],vj[4],vj[0],vj[1],vj[2],vj[3]};   // C B R L D U
					if (pin_7 == 1'b0) status<=status + 3'b001;					// increase state machine if select pin goes low
				end
				'b011:   begin	//second pulse low
					data_bits <= ~{vj[7],vj[6],2'b00,vj[2],vj[3]};   // START A 0 0 D U
					if (pin_7 == 1'b1) status<=status + 3'b001;					// increase state machine if select pin goes high
				end
				'b100:   begin	//second pulse high
					data_bits <= ~{vj[5],vj[4],vj[0],vj[1],vj[2],vj[3]};   // C B R L D U
					if (pin_7 == 1'b0) status<=status + 3'b001;					// increase state machine if select pin goes low
				end
				'b101:   begin	//third pulse low
					data_bits <= ~{vj[7],vj[6],4'b0011};   // START A 0 0 1 1
					if (pin_7 == 1'b1) status<=status + 3'b001;					// increase state machine if select pin goes high
				end
				'b110:   begin	//third pulse high
					data_bits <= ~{vj[5],vj[4],1'b0,vj[10],vj[8],vj[9]};   // C B MODE X Y Z
					if (pin_7 == 1'b0) status<=status + 3'b001;					// increase state machine if select pin goes low
				end
				'b111:   begin	//final pulse low
					data_bits <= ~{vj[7],vj[6],4'bzzzz};   // START A zzzz
					if (pin_7 == 1'b1) status<=status + 3'b001;					// increase state machine if select pin goes low
				end
			endcase
		end
	end
endmodule
