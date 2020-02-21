module player_control (
	clock,
	resetn,
	x,
	y,
	jump
);
	
	input clock, resetn, jump;
	output reg [7:0] x;
	output reg [6:0] y;
	
	always @(posedge clock) begin
		if(!resetn) begin
			x <= 8'd33;
			y <= 7'd71;
		end
	end
	
endmodule