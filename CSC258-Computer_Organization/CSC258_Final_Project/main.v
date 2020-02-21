`timescale 1ns / 1ns

`define FPSToCycles(fps) 50000000/fps

module main
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn, play, jump_key;
	assign resetn = KEY[0];
	assign play = ~KEY[1];
	assign jump_key = ~KEY[3];
	

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	
	vga_vpi VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		/*defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";*/
	
	wire [31:0] cycles_per_frame;
	game_speed gs (
		.select(SW[9:7]),
		.cycles_per_frame(cycles_per_frame),
		.clock(CLOCK_50),
		.resetn(resetn)
	);
	
	wire s_collision, s_next_frame;
	wire [2:0] play_state;
	wire [1:0] core_state;
	
	wire [7:0] player_x;
	wire [6:0] player_y;
	
	datapath d0 (
		.clock(CLOCK_50),
		.cycles_per_frame(cycles_per_frame),
		.out_x(x),
		.out_y(y),
		.out_colour(colour),
		.sig_collision(s_collision),
		.sig_next_frame(s_next_frame),
		.play_state(play_state),
		.core_state(core_state),
		.resetn(resetn),
		.player_x(player_x),
		.player_y(player_y)
	);

   main_control c0 (
		.clock(CLOCK_50),
		.resetn(resetn),
		.key_start(play),
		.sig_collision(s_collision),
		.sig_next_frame(s_next_frame),
		.play_state(play_state),
		.core_state(core_state)
	);
	
	player_control pc0 (
		.clock(CLOCK_50),
		.resetn(resetn),
		.x(player_x),
		.y(player_y),
		.jump(jump_key)
	);
    
endmodule

module game_speed (
	select,
	cycles_per_frame,
	clock,
	resetn
);
	input clock, resetn;
	input [2:0] select;
	output reg [31:0] cycles_per_frame;
	
	always @(clock)
	begin
		if(!resetn) cycles_per_frame <= 32'd1_666_666;
		else begin
			case (select)
				3'b000: cycles_per_frame <= `FPSToCycles(32'd30);
				3'b001: cycles_per_frame <= `FPSToCycles(32'd15);
				3'b010: cycles_per_frame <= `FPSToCycles(32'd5);
				3'b011: cycles_per_frame <= `FPSToCycles(32'd1);
				3'b100: cycles_per_frame <= `FPSToCycles(32'd45);
				3'b101: cycles_per_frame <= `FPSToCycles(32'd60);
				3'b111: cycles_per_frame <= `FPSToCycles(32'd100);
				default: cycles_per_frame <= `FPSToCycles(32'd30);
			endcase
		end
	end

endmodule
