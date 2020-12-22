module led_average(input audio_enable, input [7:0] audio_data, output [7:0] out, output av_valid );

	reg [7:0] counter = 0;
	reg [31:0] average = 0;
	reg [7:0] out_wire;
	reg [1:0] state = 2'b00;

 	parameter sum_up = 2'b00;
 	parameter calc_av = 2'b01;
 	parameter reset = 2'b10;
 
 	assign av_valid = state[0];
 
 	rev_Arbiter arb( out_wire, out);

	always_ff @(posedge audio_enable) 
 		case (state) 
 
 		reset: 	begin // reset counter and average to zero
        		counter <= 8'b0;
        		average <= 32'b0;
		  	state <= sum_up;
			end
 
 		sum_up: begin	
			counter <= counter + 8'b1;
        		if(audio_data[7] == 1'b1) begin
				average <= average + 1 + ~audio_data; // two's complement negation
		 	end

		  	else begin
				average <= average + audio_data;
		  	end
         		state <= (counter == 8'b11111111) ? calc_av : sum_up; // calculate the average when counter is 255
			end
 		calc_av: begin
			out_wire <= average >>  8; // divide by 256
          		state <= reset;
			end

 		default: state <= reset;
 endcase
endmodule 

//=====================================================
//    Resverse Arbiter
//=====================================================

module rev_Arbiter( r, g);
 	input [7:0] r;
 	output [7:0] g;
 	wire [7:0] c;
	
 	assign c = {1'b1,(~r[7:1] & c[7:1])} ; // reverse arbiter
 	assign g = r & c ;
endmodule 



/*  TEST BENCH
module arbiter_tb;

	reg [7:0] r;
	wire [7:0] g;

	rev_Arbiter DUT( r, g);

	initial begin

		r = 8'b00010100; 
		#20;
		r = 8'b01000101;
		#20;
		$stop;
	end
endmodule 

module av_tb;

	reg clk;
	reg [7:0] audio_data;
	wire [7:0] out;
	wire valid;
	reg  counter = 0;

	led_average DUT(.audio_enable(clk), .audio_data(audio_data), .out(out),.av_valid(valid) );

	initial forever begin
		#5;
		clk = 1'b0;
		#5;
		clk = 1'b1;
	end

	initial begin

		audio_data = 8'b1;

		while(valid == 0) begin
			 #10;
		end
 	$stop;
	end
endmodule 
*/
