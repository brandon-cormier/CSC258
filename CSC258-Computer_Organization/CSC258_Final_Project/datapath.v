`define XYAddress(X, Y) ((Y)*160) + (X)

module datapath (
	clock,
	cycles_per_frame,
	out_x,
	out_y,
	out_colour,
	sig_collision,
	sig_next_frame,
	play_state,
	core_state,
	resetn,
	player_x,
	player_y
);

	input resetn, clock;
	input [31:0] cycles_per_frame;
	input [1:0] core_state;
	input [2:0] play_state;

	input [7:0] player_x;
	input [6:0] player_y;
	
	output reg sig_collision;
	output reg sig_next_frame;
	output reg [7:0] out_x; 
	output reg [6:0] out_y;
	output reg [2:0] out_colour;
	
	reg [13:0] buffer_address;
	reg [2:0] buffer_colour_in;
	wire [2:0] buffer_colour_out;
	reg buffer_write;
	
	localparam [1:0]  O_S_WAIT = 2'd0,
					  O_S_PLAY = 2'd1,
				      O_S_END = 2'd2;
					  
	localparam [2:0]  I_S_INITIALIZE = 3'd0,
					  I_S_READ_NEXT = 3'd1,
					  I_S_READ = 3'd2,
				      I_S_WRITE_HERE = 3'd3,
					  I_S_NEXT_PIXEL = 3'd4;
	
	/*
		Store left-right, top-down.
	*/
	ram160x80x3 vga_buffer (
		.address(buffer_address),
		.clock(clock),
		.data(buffer_colour_in),
		.wren(buffer_write),
		.q(buffer_colour_out)
	);
	
	wire rate_elapsed;
	
	rate_divider rate_div (
		.clock(clock),
		.elapsed(rate_elapsed),
		.load(cycles_per_frame),
		.resetn(resetn)
	);

	wire [2:0] wait_colour;
	wire [2:0] scroll_colour;
	
	wait_draw wait_pixels (
		.x(out_x),
		.y(out_y),
		.colour(wait_colour),
		.clock(clock),
		.resetn(resetn)
	);
	
	reg next_object_distance;
	
	scroll_draw scroll_pixels (
		.resetn(resetn),
		.x(out_x),
		.y(out_y),
		.colour(scroll_colour),
		.right_colour(buffer_colour_out),
		.enable(next_object_distance),
		.clock(clock)
	);
	
	wire [2:0] overlay_colour;
	wire overlay_collision;
	
	pixel_overlay overlay (
		.clock(clock),
		.resetn(resetn),
		.out_colour(overlay_colour),
		.in_colour(scroll_colour),
		.x(out_x),
		.y(out_y),
		.sig_collision(overlay_collision),
		.player_x(player_x),
		.player_y(player_y)
	);
	
	always @(posedge clock)
	begin
		if(!resetn) begin
			out_x <= 8'd0;
			out_y <= 7'd0;
			out_colour <= wait_colour;
			sig_next_frame <= 1'b1;
			sig_collision <= 1'b0;
			
			buffer_address <= `XYAddress(8'd0, 7'd0);
			buffer_colour_in <= 3'b011;
			buffer_write <= 1'b1;
			
			next_object_distance <= 1'b0;
		end else begin		
			if(core_state == O_S_WAIT || core_state == O_S_END) begin
				sig_next_frame <= 1'b0;
				sig_collision <= 1'b0;
				out_colour <= wait_colour;
				
				/*
					If in O_S_WAIT, for each pixel, draw on screen.
					If pixel is within bounds, store in RAM.
				*/
				
				if(out_y < 7'd80) begin
					buffer_write <= 1'b1;
					buffer_colour_in <= wait_colour;
					buffer_address <= `XYAddress(out_x, out_y);
				end else buffer_write <= 1'b0;
				
				if(out_y < 7'd119) out_y <= out_y + 7'd1;
				else if(out_y == 7'd119) begin
					if(out_x < 8'd159) begin
						out_x <= out_x + 8'd1;
						out_y <= 7'd0;
					end
				end
			end else if(core_state == O_S_PLAY) begin
				if(out_y == 7'd79 && out_x == 8'd159 && rate_elapsed) begin
					sig_next_frame <= 1'b1;
				end
				
				next_object_distance <= 1'b0;

				case (play_state)
					I_S_READ_NEXT:
						begin
							if(out_x < 8'd159) begin
								buffer_address <= `XYAddress(out_x + 1, out_y);
							end
							buffer_write <= 1'b0;
						end
					I_S_READ:
						begin
							out_colour <= overlay_colour;
							
							/* sig_collision hasn't been tested, but reg overlay has. */
							sig_collision <= overlay_collision;
						end
					I_S_WRITE_HERE:
						begin
							buffer_address <= `XYAddress(out_x, out_y);
							buffer_write <= 1'b1;
							buffer_colour_in <= scroll_colour;
						end
					I_S_NEXT_PIXEL:
						begin
							/*
								Only draw the top 80 pixels. The bottom 40 was drawn in O_S_WAIT.
								If we reach the last pixel (159, 79), wait for rate_elapsed before
								moving back to initialize state.
							*/
							
							if(out_y < 7'd79) out_y <= out_y + 7'd1;
							else if(out_y == 7'd79) begin
								if(out_x < 8'd159) begin
									out_x <= out_x + 8'd1;
									out_y <= 7'd0;
								end
							end
						end
					default:
						begin
							/*
								Assume I_S_INITIALIZE.
								Move pointer to top-left.
							*/
							
							out_x <= 8'd0;
							out_y <= 7'd0;
							buffer_write <= 1'b0;
							sig_next_frame <= 1'b0;
							out_colour <= 3'b011;
							
							next_object_distance <= 1'b1;
						end
				endcase
			end
		end
	end

endmodule

module rate_divider (
	clock,
	elapsed,
	load,
	resetn
);
	input clock, resetn;
	input [31:0] load;
	
	output reg elapsed;

	reg [31:0] counter;
	
	always @(posedge clock)
	begin
		elapsed <= 1'b0;
		
		if(!resetn) counter <= load;
		else if(counter > 32'd0) counter <= counter - 32'b1;
		else if (counter == 32'd0) begin
			counter <= load;
			elapsed <= 1'b1;
		end
	end
endmodule

