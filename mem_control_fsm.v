`default_nettype none

module mem_control_fsm(clk, start, inread, waitrequest, readdata, flashread, flashwrite, done, outdata, data_valid);
	
	input clk, start, inread, waitrequest, data_valid;
	input [31:0] readdata;
	
	output flashread, flashwrite, done;
	output reg [31:0] outdata;
	
	
	reg [5:0] state = idle;
	
	parameter idle = 		6'b000_000;
	parameter checkop = 		6'b001_000;
	parameter qread = 		6'b010_000;
	parameter read = 		6'b011_000;
	parameter qwrite = 		6'b100_010;
	parameter waitwrite = 		6'b101_010;
	parameter write = 		6'b110_010;
	parameter finished = 		6'b111_100;
	parameter wait_   =     	6'b111_001;
	
	assign flashread = state[0];
	assign flashwrite = state[1];
	assign done = state[2];
	
	
	always @(posedge clk) begin
		case(state)
			idle: 	if(start) 
						state <= checkop;
			checkop: if(inread)
						state <= wait_;
						else
						state <= qwrite;
			wait_ : state <= qread;			
					
			qread: 	if(waitrequest)
						state <= qread;
						else
						state <= read;
						
			read: begin
					state <= finished;
					outdata <= readdata;
				end
			
			qwrite: if(waitrequest)
						state <= qwrite;
						else
						state <= waitwrite;
						
			waitwrite: 	state <= write;
			
			write:		state <= finished;
			
			finished:	state <= idle;
		
		endcase
	end

endmodule
