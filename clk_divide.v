`default_nettype none

module clk_divide(clk_input, divisor,clk_output);
	
	input clk_input;
	input [31:0] divisor;
	output reg clk_output;
	
	reg [31:0] counter = 32'd0;
	
	always @(posedge clk_input)
		begin
			counter = counter + 1'd1; 			//increment counter
			if(counter >= divisor/2-1) 			//at half the cycle
				begin
					counter = 1'd0; 		//reset counter after full cycle
					clk_output = ~clk_output; 	//flip the clock
				end
		end	
endmodule

