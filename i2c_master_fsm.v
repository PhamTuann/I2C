module i2c_master_fsm(
	input wire i2c_clk,
	input wire reset_n,
	input wire [6:0] addr,
	input wire [7:0] data_in,
	input wire enable,
	input wire rw,

	output reg [7:0] data_out,
	output ready,

	input i2c_sda_in,
	input i2c_scl_in,
	output i2c_sda_out,
	output i2c_scl_out,

	output reg [2:0] State
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

	assign ready = ((reset_n == 1) && (State == IDLE)) ? 1 : 0;
	always @(posedge i2c_clk) begin
		if(reset_n == 0) begin
			State <= IDLE;
		end		
		else begin
			case(State)
				IDLE: begin
					if (enable) begin
						State <= START;
						saved_addr <= {addr, rw};
						saved_data <= data_in;
					end
					else State <= IDLE;
				end

				START: begin
					counter <= 7;
					State <= ADDRESS;
				end

				ADDRESS: begin
    					if (counter == 0) begin 
     						State <= READ_ACK;
    					end else begin
        					counter <= counter - 1;
   					end
					end

				READ_ACK: begin
					if (i2c_sda_in == 0) begin
						counter <= 7;
						if(saved_addr[0] == 0) State <= WRITE_DATA;
						else State <= READ_DATA;
					end else State <= STOP;
				end

				WRITE_DATA: begin
					if(counter == 0) begin
						State <= READ_ACK2;
					end else counter <= counter - 1;
				end
				
				READ_ACK2: begin
					if ((i2c_sda_in == 0) && (enable == 1)) State <= IDLE;
					else State <= STOP;
				end

				READ_DATA: begin
					data_out[counter] <= i2c_sda_in;
					if (counter == 0) State <= WRITE_ACK;
					else counter <= counter - 1;
				end
				
				WRITE_ACK: begin
					State <= STOP;
				end

				STOP: begin
					State <= IDLE;
				end
			endcase
		end
	end
endmodule
