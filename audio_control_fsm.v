`default_nettype none
module audio_control_fsm(rst_adr, forward_f, back_f, pause, clk_50, clk_song, done_read, start_read, read_f, enable_data, flash_adr, data_pos, start_address, end_address, last_addr);
	
	parameter MAX_ADR = 23'h7FFFF;
	
	input rst_adr, forward_f, back_f, pause, clk_50, clk_song, done_read;
	input [23:0] start_address, end_address;
	
	output start_read, read_f, enable_data;
	output reg [23:0] flash_adr;
	output [1:0] data_pos;
	output [1:0] last_addr;
	reg [23:0] stop_adr;
	reg  terminal_addr = 1'b0; // phoneme rec means that we have gotten the new phoneme,
	reg  phoneme_rec = 1'b0;
	reg [5:0] state = 6'b0;
	
	assign last_addr = {phoneme_rec, terminal_addr};
								//	(enable_data) (start and read)
	parameter terminal =       6'b1111_00;
	parameter idle = 			   6'b0000_00;
	parameter get_adr = 			6'b1000_00;
	parameter read_mem = 		6'b0001_00;
	parameter wait_read = 		6'b0010_01;
	parameter wait_data1 = 		6'b0011_00;
	parameter give_data1 = 		6'b0100_10;
	parameter wait_clk_rst1 = 	6'b0101_10;
	parameter wait_data2 = 		6'b0110_00;
	parameter give_data2 = 		6'b0111_10;
	parameter wait_clk_rst2 = 	6'b1000_10;
	parameter wait_data3 = 		6'b1001_00;
	parameter give_data3 = 		6'b1010_10;
	parameter wait_clk_rst3 = 	6'b1011_10;
	parameter wait_data4 = 		6'b1100_00;
	parameter give_data4 = 		6'b1101_10;
	parameter wait_clk_rst4 = 	6'b1110_10;
   	wire new_phoneme = rst_adr;
	
	assign start_read = state[0];
	assign read_f = state[0];
	assign enable_data = state[1];
	
	always @(posedge clk_50) begin
		case (state)
		terminal: begin	
				state <= get_adr;
		                terminal_addr <= 1'b0 ;
				flash_adr <= start_address >> 2; 	// divide the addresses by four to translate byte address into word address
				stop_adr <= end_address >> 2;
			end
	
      		idle: begin     
				if(new_phoneme) begin  			 // if we have a new phoneme
				state <= terminal;
				phoneme_rec <= 1'b1;		 
				end			 		// idle until next phoneme is asserted	  
			end				
			
		get_adr: begin	
				if(!pause) begin				//get the new address for flash memory
					if((flash_adr >= stop_adr))begin
						state <= idle; 		// time to get a new phoneme
						terminal_addr <= 1'b1;
						end
					else begin
						flash_adr <= (flash_adr + 24'b1);
						state <= read_mem;
						end
					end
				else 
					state <= get_adr;
			end			
			
		read_mem: begin	
				state <= wait_read;				//get data from flash memory
			end
		
		wait_read: begin	
					if(done_read)
					state <= wait_data1;
					else state <= wait_read;
			end
		wait_data1: begin 
				if(pause)	//first/4 data set
					state <= get_adr;
					else if(clk_song)
						state <= give_data1;
					phoneme_rec <= 1'b0; 
					terminal_addr <= 1'b0 ; 
			    end
		give_data1: begin 
				state <= wait_clk_rst1;
				data_pos <= 2'b00;
			    end

		wait_clk_rst1: if(~clk_song)
					state <= wait_data2;
		
//second/4 data set
		wait_data2: 	if(clk_song)
					state <= give_data2;
		
		give_data2: begin
				state <= wait_clk_rst2;
				data_pos <= 2'b01;
			    end

		wait_clk_rst2: if(~clk_song)
					state <= wait_data3;

//third/4 data set
		wait_data3: 	if(clk_song)
					state <= give_data3;
		
		give_data3: begin
				state <= wait_clk_rst3;
				data_pos <= 2'b10;
			    end

		wait_clk_rst3: 	if(~clk_song)
					state <= wait_data4;
		
//fourth/4 data set
		wait_data4: 	if(clk_song)
					state <= give_data4;
		
		give_data4: begin
				state <= wait_clk_rst4;
				data_pos <= 2'b11;
			    end
			
		wait_clk_rst4: 	if(~clk_song)
				 	state <= get_adr;	
								
		default: begin 
				state <= idle;	
		               	phoneme_rec <= 1'b0;
				terminal_addr <= 1'b0 ;
			end

		endcase
	end
	
endmodule
