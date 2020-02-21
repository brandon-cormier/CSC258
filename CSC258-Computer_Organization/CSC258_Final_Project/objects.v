module ObjectNone (
	y,
	distance,
	colour,
	resetn,
	clock
);

	input clock, resetn;
	input [6:0] y;
	input [3:0] distance;
	
	output reg [2:0] colour;
	
	always @(clock) begin
		if(!resetn) colour <= 3'b100;
		else colour <= 3'b100;
	end
endmodule

module ObjectBench (
	y,
	distance,
	colour,
	resetn,
	clock
);

	input clock, resetn;
	input [6:0] y;
	input [3:0] distance;
	
	output reg [2:0] colour;
	
	always @(clock) begin
		if(!resetn) colour <= 3'b011;
		else if(distance <= 1 || distance >= 10 || y < 75) colour <= 3'b011;
		else if (distance < 4 || distance > 7) colour <= 3'b101;
		else if (y < 78) colour <= 3'b101;
		else colour <= 3'b011;
	end
endmodule

module ObjectTree (
	y,
	distance,
	colour,
	resetn,
	clock
);
	
	input clock, resetn;
	input [6:0] y;
	input [3:0] distance;
	
	output reg [2:0] colour;
	
	always @(clock) begin
		if(!resetn) colour <= 3'b011;
		else if(distance <= 1 || distance >= 6 || y < 65) colour <= 3'b011;
		else colour <= 3'b100;
	end
endmodule