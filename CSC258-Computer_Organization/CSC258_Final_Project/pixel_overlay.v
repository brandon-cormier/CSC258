module pixel_overlay (
	clock,
	resetn,
	out_colour,
	in_colour,
	x,
	y,
	sig_collision,
	player_x,
	player_y
);

	input clock, resetn;
	input [7:0] x, player_x;
	input [6:0] y, player_y;
	input [2:0] in_colour;
	output reg [2:0] out_colour;
	output reg sig_collision;
	
	/*
		To animate the player (jumping), the player's coordinates
		would be wired to another module responsible for controlling
		the character.
	*/
	
	/*
		We can also draw text overlays in this module,
		perhaps by using a helper module to draw different
		letters/numbers.
	*/
	
	always @(clock) begin
		if(!resetn) begin
			out_colour <= 3'b011;
			sig_collision <= 1'b0;
		end else if(x >= player_x && x <= player_x + 8'd6 && y >= player_y && y <= player_y + 7'd9) begin
			out_colour <= 3'b000;
			
			/* If a non-sky colour would have been drawn, trigger a collision. */
			if(in_colour != 3'b011) begin
				sig_collision <= 1'b1;
			end
		end else begin
			out_colour <= in_colour;
			sig_collision <= 1'b0;
		end
	end

endmodule