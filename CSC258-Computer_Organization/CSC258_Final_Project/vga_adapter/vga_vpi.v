/*
 * VGA VPI Module
*/

module vga_vpi(
			resetn,
			clock,
			colour,
			x, y, plot,
			/* Signals for the DAC to drive the monitor. */
			VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK,
			VGA_SYNC,
			VGA_CLK);

	input resetn;
	input clock;
	input plot;
	
	input [2:0] colour;
	input [7:0] x;
	input [6:0] y;
	
	output [9:0] VGA_R;
	output [9:0] VGA_G;
	output [9:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK;
	output VGA_SYNC;
	output VGA_CLK;

endmodule
	