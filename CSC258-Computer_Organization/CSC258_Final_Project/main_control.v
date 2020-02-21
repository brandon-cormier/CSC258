module main_control (
	clock,
	resetn,
	key_start,
	sig_collision,
	sig_next_frame,
	play_state,
	core_state
);

	input clock, resetn;
	input key_start, sig_collision, sig_next_frame;
	
	output [2:0] play_state;
	output [1:0] core_state;
	
	// Two FSMs. OUTER and INNER (play).
	
	reg [1:0] o_current_state, o_next_state;
	reg [2:0] i_current_state;
	
	assign play_state = i_current_state;
	assign core_state = o_current_state;
	
	localparam [1:0]  O_S_WAIT = 2'd0,
					  O_S_PLAY = 2'd1,
				      O_S_END = 2'd2;
					  
	localparam [2:0]  I_S_INITIALIZE = 3'd0,
					  I_S_READ_NEXT = 3'd1,
					  I_S_READ = 3'd2,
				      I_S_WRITE_HERE = 3'd3,
					  I_S_NEXT_PIXEL = 3'd4;

	always @(*)
	begin: o_state_table 
		case (o_current_state)
			O_S_WAIT: o_next_state = key_start ? O_S_PLAY : O_S_WAIT;
			O_S_PLAY: o_next_state = sig_collision ? O_S_END : O_S_PLAY;
			O_S_END: o_next_state = key_start ? O_S_WAIT : O_S_END;
			default: o_next_state = O_S_WAIT;
		endcase
	end
	
	always @(posedge clock)
	begin: i_state_table
		if(o_current_state == O_S_PLAY) begin
			case (i_current_state)
				I_S_INITIALIZE: i_current_state <= I_S_READ_NEXT;
				I_S_READ_NEXT: i_current_state <= sig_next_frame ? I_S_INITIALIZE : I_S_READ;
				I_S_READ: i_current_state <= sig_next_frame ? I_S_INITIALIZE : I_S_WRITE_HERE;
				I_S_WRITE_HERE: i_current_state <= sig_next_frame ? I_S_INITIALIZE : I_S_NEXT_PIXEL;
				I_S_NEXT_PIXEL: i_current_state <= sig_next_frame ? I_S_INITIALIZE : I_S_READ_NEXT;
				default: i_current_state <= I_S_INITIALIZE;
			endcase
		end else begin
			i_current_state <= I_S_INITIALIZE;
		end
	end

    always @(posedge clock)
    begin: state_FFs
		if(!resetn) begin
			o_current_state <= O_S_WAIT;
			i_current_state <= I_S_INITIALIZE;
		end
		else o_current_state <= o_next_state;
    end

endmodule
