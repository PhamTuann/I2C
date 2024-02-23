module i2c_clock_gen (
	input clk,
	output reg i2c_clk = 1
	);		
	localparam DIVIDE_BY = 4;
	reg counter2 = 0;
	always @(posedge clk) begin
		if (counter2 == (DIVIDE_BY/2) - 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end
		else counter2 <= counter2 + 1;
	end 
endmodule
