module wait_draw (
	x,
	y,
	colour,
	clock,
	resetn
);

	input clock, resetn;
	input [7:0] x;
	input [6:0] y;
	output reg [2:0] colour;
	
	always @(clock)
	begin
		if(!resetn) colour <= 3'b011;
		else if(y > 7'd79) colour <= 3'b010;
		else colour <= 3'b011;
	end
endmodule

module scroll_draw (
	resetn,
	x,
	y,
	colour,
	right_colour,
	enable,
	clock
);

	input [7:0] x;
	input [6:0] y;
	output reg [2:0] colour;
	input [2:0] right_colour;
	input resetn, enable, clock;
	
	wire [2:0] object_colour;
	ObjectMapper object (
		.y(y),
		.colour(object_colour),
		.enable(enable),
		.resetn(resetn),
		.clock(clock)
	);
	
	always @(clock)
	begin
		/*
			If pixel is below ground (which it should never be), draw ground.
			If the pixel to the right is off screen, use object_colour,
			otherwise use the colour from memory, stored in right_colour, which
			comes from the I_S_READ_NEXT state.
		*/
		if(!resetn) colour <= right_colour;
		else if(y > 7'd79) colour <= 3'b010;
		else if(x < 8'd159) colour <= right_colour;
		else if(x == 8'd159) colour <= object_colour;
	end
endmodule

module ObjectMapper (
	resetn,
	y,
	colour,
	enable,
	clock
);

	input resetn, enable, clock;
	input [6:0] y;
	output reg [2:0] colour;
	
	localparam [2:0] OBJECT_NONE = 0,
					 OBJECT_BENCH = 1,
			         OBJECT_TREE = 2;
			   
	localparam [3:0] DISTANCE_NONE = 4,
					 DISTANCE_BENCH = 10,
			         DISTANCE_TREE = 6;
	
	reg [2:0] object_type;
	reg [3:0] distance;
	
	wire [4:0] random_value;
	lfsr_5 randomy (
		.resetn(resetn),
		.clock(clock),
		.seed(32'b10101011110010110100110110100101),
		.q(random_value)
	);
	
	wire [2:0] colour_none, colour_bench, colour_tree;
	
	ObjectNone obj_none (
		.distance(distance),
		.y(y),
		.colour(colour_none),
		.resetn(resetn),
		.clock(clock)
	);
	
	ObjectBench obj_bench (
		.distance(distance),
		.y(y),
		.colour(colour_bench),
		.resetn(resetn),
		.clock(clock)
	);
	
	ObjectTree obj_tree (
		.distance(distance),
		.y(y),
		.colour(colour_tree),
		.resetn(resetn),
		.clock(clock)
	);
	
	always @(posedge clock) begin
		if(!resetn) begin
			object_type <= OBJECT_NONE;
			distance <= DISTANCE_NONE;
		end else if(enable) begin
			if(distance == 4'b0) begin
				if(random_value < 5'd5) begin
					object_type <= OBJECT_NONE;
					distance <= DISTANCE_NONE;
				end else if(random_value < 5'd10) begin
					object_type <= OBJECT_BENCH;
					distance <= DISTANCE_BENCH;
				end else if(random_value < 5'd15) begin
					object_type <= OBJECT_TREE;
					distance <= DISTANCE_TREE;
				end else begin
					object_type <= OBJECT_NONE;
					distance <= DISTANCE_NONE;
				end
			end else if(y == 7'd119) begin
				distance <= distance - 4'b1;
			end
		end
	end
	
	always @(*) begin
		case (object_type)
			OBJECT_BENCH: colour <= colour_bench;
			OBJECT_TREE: colour <= colour_tree;
			default: colour <= colour_none;
		endcase
	end

endmodule

/*
	LFSR Psuedo-Randomization
*/
module lfsr_5 (
	resetn,
	clock,
	seed,
	q
);
	input resetn, clock;
	input [31:0] seed;
	output [4:0] q;

	reg [31:0] internal;
	
	always @(posedge clock) begin
		if(~resetn) internal <= seed;
		else internal <= { internal[28:0], internal[29] ^ internal[10], internal[30] ^ internal[28], internal[31] ^ internal[20] };
	end
	
	assign q = internal[4:0];
endmodule
