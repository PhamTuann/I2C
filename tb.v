`timescale 1ns / 1ns

module i2c_controller_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [6:0] addr;
	reg [7:0] data_in;
	reg enable;
	reg rw;

	// Outputs
	wire [7:0] data_out;
	wire ready;

	// Bidirs
	wire sda;
	wire scl;
	
	reg sda_en_tb;
	reg sda_in;

	
	assign sda = sda_en_tb ? sda_in : 1'bz;                                                                                     


	// Instantiate the Unit Under Test (UUT)
	i2c_master master (
		.clk(clk), 
		.reset(reset), 
		.addr(addr), 
		.data_in(data_in), 
		.enable(enable), 
		.rw(rw), 
		.data_out(data_out), 
		.ready(ready), 
		.sda(sda), 
		.scl(scl)
	);
	
		

	
	initial begin
		clk = 0;
		forever begin
			clk = #1 ~clk;
		end		
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		sda_en_tb = 0;

		// Wait 100 ns for global reset to finish
		#20;
        
		// Add stimulus here
		reset = 0;		
		addr = 7'b0101010;
		data_in = 8'b10101010;
		rw = 0;	
		enable = 1;
		#10;
		enable = 0;
			
		#73;
      		sda_en_tb = 1;                                                    
       		sda_in = 0; 
		
		#4;
      		sda_en_tb = 0;                                                    
		
		#68;
      		sda_en_tb = 1;                                                    
       		sda_in = 0; 
		
		#4;
      		sda_en_tb = 0;  
		
		#500
		$finish;
		
	end      
endmodule