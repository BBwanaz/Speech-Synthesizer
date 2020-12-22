`default_nettype none
module speed_control(clk, speedup, speeddown, reset, clk_divisor);

	input clk, speedup, speeddown, reset;
	output [31:0] clk_divisor;
	parameter CLK72KHZ = 6944; // 7200 
		//470=44k   8E0=22k	5EB=33k
	reg [31:0] clk_divisor = CLK72KHZ;
	reg first = 1'b1;
	
	always @(posedge clk) begin
		if(speedup) clk_divisor <= clk_divisor - 3'b100;
		if(speeddown) clk_divisor <= clk_divisor + 3'b100;
		if(reset) clk_divisor <= CLK72KHZ;
	end

endmodule
