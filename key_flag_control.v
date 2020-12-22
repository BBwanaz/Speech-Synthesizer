`default_nettype none
module key_flag_control(clk, key_val, adr, bF, fF, rst, pause);
	
	input clk;
	input [7:0] key_val;
	input [23:0] adr;

	output bF, fF, rst, pause;
	
	reg bF, state, reset_was_last;
	reg fF = 1'b1;
	reg pause = 1'b1;
	
	parameter character_B =8'h42;
	parameter character_D =8'h44;
	parameter character_E =8'h45;
	parameter character_F =8'h46;
	parameter character_R =8'h52;
	parameter character_lowercase_b= 8'h62;
	parameter character_lowercase_d= 8'h64;
	parameter character_lowercase_e= 8'h65;
	parameter character_lowercase_f= 8'h66;
	parameter character_lowercase_r= 8'h72;
	
	parameter check_key = 1'b0;
	parameter wait_for_rst = 1'b1;
	
	assign rst = state;
	
	always @(posedge clk) begin
		case(state)
		
		check_key: 
					begin
						if((key_val == character_B) || (key_val == character_lowercase_b))
							begin
								//set backwards flag
								bF = 1'b1;
								fF = 1'b0;
							end
						if((key_val == character_F) || (key_val == character_lowercase_f))
							begin
								//set forwards flag
								bF = 1'b0;
								fF = 1'b1;
							end
						if((key_val == character_D) || (key_val == character_lowercase_d))
							begin
								//pause
								pause = 1'b1;
							end
						if((key_val == character_E) || (key_val == character_lowercase_e))
							begin
								//play
								pause = 1'b0;
							end
						if((key_val == character_R) || (key_val == character_lowercase_r))
							begin
									//prevents continuosly resetting if R was the last key pressed
								if(!reset_was_last)
									state = wait_for_rst;
								reset_was_last <= 1'b1;
							end	
						else reset_was_last <= 1'b0;	
					end	
					
		wait_for_rst: if(adr == 23'b0)
							state <= check_key;
							
		endcase
	end

endmodule
