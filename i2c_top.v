module i2c_top (
	input clk,
	input reset_n,
	input [6:0] addr,
	input [7:0] data_in,
	input enable,
	input rw,

	output [7:0] data_out,
	output ready,

	input i2c_sda_in,
	input i2c_scl_in,
	output i2c_sda_out,
	output i2c_scl_out
	);
	wire i2c_clk;
	wire [2:0] State;

	i2c_clock_gen clock_gen(
		.clk(clk),
		.i2c_clk(i2c_clk)
	);

	i2c_master_fsm master_fsm(
		.i2c_clk(i2c_clk), 
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
		.i2c_scl_in(i2c_scl_in),
		.State(State)
	);
	
	i2c_master_datapath master_datapath(
		.i2c_clk(i2c_clk), 
		.reset_n(reset_n), 
		.addr(addr), 
		.data_in(data_in), 
		.enable(enable), 
		.rw(rw), 
		.data_out(data_out), 
		.i2c_sda_in(i2c_sda_in), 
		.i2c_scl_out(i2c_scl_out),
		.i2c_sda_out(i2c_sda_out), 
		.i2c_scl_in(i2c_scl_in),
		.State(State)
	);
	
	i2c_slave slave(
		.i2c_sda_in(i2c_sda_in), 
		.i2c_scl_out(i2c_scl_out),
		.i2c_sda_out(i2c_sda_out), 
		.i2c_scl_in(i2c_scl_in)
	);


endmodule
