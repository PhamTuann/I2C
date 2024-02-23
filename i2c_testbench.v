module i2c_tb;

	reg clk;
	reg reset_n;
	reg [6:0] addr;
	reg [7:0] data_in;
	reg enable;
	reg rw;


	wire [7:0] data_out;
	wire ready;


	wire i2c_sda_in;
	wire i2c_sda_out;
	wire i2c_scl_in;
	wire i2c_scl_out;

	i2c_top uut(
		.clk(clk), 
		.reset_n(reset_n), 
		.addr(addr), 
		.data_in(data_in), 
		.enable(enable), 
		.rw(rw), 
		.data_out(data_out), 
		.ready(ready), 
		.i2c_sda_in(i2c_sda_in), 
		.i2c_scl_out(i2c_scl_out),
		.i2c_sda_out(i2c_sda_out), 
		.i2c_scl_in(i2c_scl_in)
	);

	
	initial begin
		clk = 0;
		forever begin
			clk = #1 ~clk;
		end		
	end

	initial begin
		clk = 0;
		reset_n = 0;

		#20;
        
		reset_n = 1;		
		addr = 7'b0101010;
		data_in = 8'b10101010;
		rw = 0;	
		enable = 1;
		#5;
		enable = 0;	
		#300
		$finish;
	end      
endmodule
