module i2c_master(
	input clk,
	input reset,
	input enable,
	input [6:0] addr,
	input [7:0] data_in,
	input rw,
	
	output [7:0] data_out,
	output ready,

	inout sda,
	inout scl
	);
	
	localparam IDLE = 0;
	localparam START = 1;
	localparam ADDRESS = 2;
	localparam READ_ACK = 3;
	localparam WRITE_DATA = 4;
	localparam READ_DATA = 5;
	localparam READ_ACK2 = 6;
	localparam WRITE_ACK = 7;
	localparam STOP = 8;
	
	localparam DIVIDE_BY = 4;

	reg [7:0] state;
	reg [7:0] saved_addr;
	reg sda_out;
	reg write_enable;
	reg i2c_scl_enable;
	reg i2c_clk;
	reg [2:0] counter;
	reg [2:0] counter2;
	
	assign ready = ((reset == 0) && (state == IDLE)) ? 1 : 0;

	assign scl = (i2c_scl_enable == 0 ) ? 1 : i2c_clk;
	assign sda = (write_enable == 1) ? sda_out : 'bz;
	pullup(sda);
	
	always @(negedge i2c_clk, posedge reset) begin
		if(reset == 1) begin
			i2c_scl_enable <= 0;
		end else begin
			if ((state == IDLE) || (state == START) || (state == STOP)) begin
				i2c_scl_enable <= 0;
			end else begin
				i2c_scl_enable <= 1;
			end
		end
	
	end
	
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			i2c_clk <= 0;
			counter2 <= 0;
		end
		else begin
			if (counter2 == (DIVIDE_BY/2) - 1) begin
				i2c_clk <= ~i2c_clk;
				counter2 <= 0;
			end
			else counter2 <= counter2 + 1;
		end
	end
	
	//FSM	
	always @(posedge i2c_clk or posedge reset) begin
		if(reset) begin
			state <= IDLE;
			saved_addr <= 0;
		end
		else begin
			case(state)
				IDLE: begin
					if(enable) begin
						state <= START;
						saved_addr = {addr,rw};
					end
				end
				
				START: begin
					counter <= 7;
					state <= ADDRESS;
				end
			
				ADDRESS: begin
					if(counter == 0) begin
						state <= READ_ACK;
					end
					else counter = counter - 1;
				end
			
				READ_ACK: begin
					counter <= 7;
					if(sda == 0) begin
						if (saved_addr[0]) state <= READ_DATA;
						else state <= WRITE_DATA;
					end
					else state <= STOP;
				end
			
				READ_DATA: begin
					if(counter == 0) begin
						state <= WRITE_ACK;
					end
					else counter = counter - 1;
				end

				WRITE_DATA: begin
					if(counter == 0) begin
						state <= READ_ACK2;
					end
					else counter = counter - 1;
				end
				
				WRITE_ACK: begin
					if(sda) state <= START;
					else state <= STOP;
				end
				
				READ_ACK2: begin
					if(sda) state <= START;
					else state <= STOP;
				end
		
				STOP: begin
					state <= IDLE;
				end
			endcase
		end
	end

	//Datapath
	always @(negedge i2c_clk or posedge reset) begin
		if(reset) begin
			sda_out <= 0;
			write_enable <= 0;
		end
		else begin
			case(state)
				START: begin
					write_enable <= 1;
					sda_out <= 0;
				end
			
				ADDRESS: begin
					write_enable <= 1;
					sda_out <= saved_addr[counter];
				end
			
				READ_ACK: begin
					write_enable <= 0;
				end
			
				READ_DATA: begin
					write_enable <= 0;
				end

				WRITE_DATA: begin
					write_enable <= 1;
					sda_out <= data_in[counter];
				end
				
				WRITE_ACK: begin
					write_enable <= 1;		
				end
				
				READ_ACK2: begin
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