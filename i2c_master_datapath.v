module i2c_master_datapath(
	input i2c_clk,
	input reset_n,
	input [6:0] addr,
	input [7:0] data_in,
	input enable,
	input  rw,
	input [2:0] State,
	output reg [7:0] data_out,

	input i2c_sda_in,
	output i2c_sda_out,
	input i2c_scl_in,
	output i2c_scl_out
	);
	assign i2c_sda_in = i2c_sda_out;
	assign i2c_scl_in = i2c_scl_out;
	localparam IDLE = 0;
	localparam START = 1;
	localparam ADDRESS = 2;
	localparam READ_ACK = 3;
	localparam WRITE_DATA = 4;
	localparam WRITE_ACK = 5;
	localparam READ_DATA = 6;
	localparam READ_ACK2 = 7;
	localparam STOP = 8;

	reg [7:0] saved_addr;
	reg [7:0] saved_data;
	reg [7:0] counter;
	reg write_enable;
	reg sda_out;
	reg i2c_scl_enable = 0;

	assign i2c_scl_out = (i2c_scl_enable == 0 ) ? 1 : i2c_clk;
	assign i2c_sda_out = (write_enable == 1) ? sda_out : 'bz;

	
	always @(posedge i2c_clk) begin
		if(reset_n == 0) begin
			i2c_scl_enable <= 0;
		end else begin
			if ((State == IDLE) || (State == START) || (State == STOP)) begin
				i2c_scl_enable <= 0;
			end else begin
				i2c_scl_enable <= 1;
			end
		end
	
	end
	
	always @(posedge i2c_clk) begin
		if(reset_n == 0) begin
			write_enable <= 1;
			sda_out <= 1;
		end else begin
			case(State)
				IDLE: begin
					if (enable) begin
						saved_addr = {addr, rw};
						saved_data = data_in;
					end
				end
				START: begin
					counter <= 7;
					write_enable <= 1;
					sda_out <= 0;
				end
				
				ADDRESS: begin
					if (counter == 0) counter <=0;
					else begin 
					counter <= counter -1;
					sda_out <= saved_addr[counter];
					end
				end
				
				READ_ACK: begin
					counter <=7;
					write_enable <= 0;
				end
				
				WRITE_DATA: begin 
					counter <= counter - 1;
					write_enable <= 1;
					sda_out <= saved_data[counter];
				end
				
				WRITE_ACK: begin
					write_enable <= 1;
					sda_out <= 0;
				end
				
				READ_DATA: begin
					write_enable <= 0;				
				end
				
				STOP: begin
					write_enable <= 1;
					sda_out <= 1;
				end
			endcase
		end
	end

endmodule
