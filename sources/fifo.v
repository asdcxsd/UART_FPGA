
//`define UART_HEX
`define UART_BIN


module fifo(
	Enable, 
	CLK, 
	RESET, 
	uart_addr_o, 
	uart_wdata_o, 
	uart_rdata_i, 
	uart_we_o, 
	uart_re_o,
	cont_key,
	led_test,
	led_red
	);

//=================================================================================================================
// paramaters 

parameter DATA_WIDTH = 12; // real width of lst file  : equal to number of scan_cell  
parameter DATA_DEPTH = 8;


parameter DATA_BIT = 8;
parameter LED_BIT = 5;

parameter ST_IDLE  = 8'd0;
parameter ST_DL_MSB  = 8'd1;
parameter ST_DL_LSB  = 8'd2;
parameter ST_LCR  = 8'd3;
parameter ST_FCR  = 8'd4;
parameter ST_IER  = 8'd5;
parameter ST_SEND_TEST_CHAR  = 8'd6;
parameter ST_READ_LSR  = 8'd7;
parameter ST_CHECK_LSR  = 8'd8;
parameter ST_CMD_DECODE  = 8'd9;
parameter ST_SEND_TEST_CHAR_WAIT  = 8'd10;
parameter ST_WAIT_KEY = 8'd11;
parameter ST_LISTEN_PC = 8'd12;
parameter ST_SHOW_LED_RED  = 8'd13;

// PC Command list
parameter CM_SEND_TEST_CHAR = 8'h2f; // '/'

// PC Command list
parameter CM_SEND_ENTER = 8'h0d; // 'enter'

//=================================================================================================================
// input, output ports

input wire Enable;
input wire CLK;
input wire RESET;


output reg [2:0] uart_addr_o;
output reg [7:0] uart_wdata_o;
input wire [7:0] uart_rdata_i;
output reg uart_we_o;
output reg uart_re_o;
input cont_key;
output [2:0] led_test;
output [15:0] led_red;

reg [15:0] input_red;
reg [15:0] data_input;
assign led_red = input_red;
reg start_input_string;
reg led_1;
reg led_2;
reg led_3;
assign led_test[0] = led_1;
assign led_test[1] = led_2;
assign led_test[2] = led_3;
//===========================================================================================================================


//===========================================================================================================================
// internal registers

reg [7:0] state;
reg [31:0] r_counter;
reg [31:0] r_counter2;


//=============================================================================================================
parameter CHAR_A = 8'h61, 
CHAR_B = 8'h62, 
CHAR_C = 8'h63, 
CHAR_D = 8'h64, 
CHAR_E = 8'h65, 
CHAR_F = 8'h66, 
CHAR_G = 8'h67, 
CHAR_H = 8'h68, 
CHAR_I = 8'h69, 
CHAR_J = 8'h6a, 
CHAR_K = 8'h6b, 
CHAR_L = 8'h6c, 
CHAR_M = 8'h6d, 
CHAR_N = 8'h6e, 
CHAR_O = 8'h6f, 
CHAR_P = 8'h70, 
CHAR_Q = 8'h71, 
CHAR_R = 8'h72, 
CHAR_S = 8'h73, 
CHAR_T = 8'h74, 
CHAR_U = 8'h75, 
CHAR_V = 8'h76, 
CHAR_W = 8'h77, 
CHAR_X = 8'h78, 
CHAR_Y = 8'h79, 
CHAR_Z = 8'h7a, 
CHAR_Space = 8'h20, 
CHAR_Enter = 8'h0a;

reg [8*31:0] string_NHAP_MA_TAU[0:30];
reg string_Length;
//===========================================================================================================================


//start of source 
always @(posedge RESET or posedge CLK)
begin
	if(RESET)
	begin
		/*
			To board sram, initial value is for [not writing] == [read]
		*/
		uart_addr_o <= 3'b000;
		uart_wdata_o <= 8'h00;
		uart_we_o <= 1'b0;
		uart_re_o <= 1'b0;
		led_1 <=  1;
		led_3 <=  0;
		state <= ST_IDLE;
		r_counter <= 32'd0;
		r_counter2 <= 32'd0;
		
		input_red <= 16'd0;
		data_input <= 16'd0;

	end
	else begin
			case (state) 
				/*
					From here, Uart initialization senario starts
				*/
       		ST_IDLE : begin
					/*
						LCR = 0x83;   
					*/
					uart_addr_o <= 3'b011;
					uart_wdata_o <= 8'h83;
					uart_we_o <= 1'b1;
					uart_re_o <= 1'b0;
					r_counter <= 32'd0;
					r_counter2 <= 32'd0;
					
					// ==
		
					string_NHAP_MA_TAU[0] <= CHAR_N;
					string_NHAP_MA_TAU[1] <= CHAR_H;
					string_NHAP_MA_TAU[2] <= CHAR_A;
					string_NHAP_MA_TAU[3] <= CHAR_P;
					string_NHAP_MA_TAU[4] <= CHAR_Space;
					string_NHAP_MA_TAU[5] <= CHAR_M;
					string_NHAP_MA_TAU[6] <= CHAR_A;
					string_NHAP_MA_TAU[7] <= CHAR_Space;
					string_NHAP_MA_TAU[8] <= CHAR_T;
					string_NHAP_MA_TAU[9] <= CHAR_A;
					string_NHAP_MA_TAU[10] <= CHAR_U;
					string_NHAP_MA_TAU[11] <= CHAR_Space;
					string_Length <= 32'd11;
					//==
					
					if(Enable == 1'b1)
					begin
						led_2 <= 1;
						led_1 <= 0;
						led_3 <= 0;
						state <= ST_DL_MSB;
					end
					else
						state <= ST_IDLE;

				end	
				ST_DL_MSB : begin
					/* 25MHz = 0x0E, 50MHz = 0x1B, 12.5MHz = 0x07 
						RB_THR = 0x0E
						Baudrate = 9600 ==> Divisor Latches = 00A3
					*/
					uart_addr_o <= 3'b001;
					uart_wdata_o <= 8'h00;
					uart_we_o <= 1'b1;
					state <= ST_DL_LSB;
				end
				ST_DL_LSB : begin
					/* 25MHz = 0x0E, 50MHz = 0x1B, 12.5MHz = 0x07
						RB_THR = 0x0E
						Baudrate = 9600 ==> Divisor Latches = 00A3
						Baudrate = 115200 ==> DL = 000E
					*/
					uart_addr_o <= 3'b000;
					uart_wdata_o <= 8'h0E; // we use 25MHz clock and baudrate = 115200
					uart_we_o <= 1'b1;
					state <= ST_LCR;
				end
				ST_LCR : begin
					/*
						LCR = 0x03;   
					*/
					uart_addr_o <= 3'b011;
					uart_wdata_o <= 8'h03;
					uart_we_o <= 1'b1;
					state <= ST_FCR;

				end
				ST_FCR : begin
					/*
						IIR_FCR = 0x01;   
					*/
					uart_addr_o <= 3'b010;
					uart_wdata_o <= 8'b00000001;
					uart_we_o <= 1'b1;
					state <= ST_IER;
				end
				ST_IER : begin
					/*
						IER = 0x01;   
					*/
					uart_addr_o <= 3'b001;
					uart_wdata_o <= 8'h01;
					uart_we_o <= 1'b1;
					state <= ST_SEND_TEST_CHAR;
				end
				ST_SEND_TEST_CHAR: begin
					// test pattern == just write 'T' character to the terminal screen

					// below 4 lines is disables in case with tty test
					input_red <= 16'd0;
					data_input <= 16'd0;
					if (r_counter< 32'd11) begin
						uart_addr_o <= 3'b000;
						uart_we_o <= 1'b1;
						uart_re_o <= 1'b0;
						uart_wdata_o <= string_NHAP_MA_TAU[r_counter];
						
						led_3 <= (led_3+1)&1;
						r_counter <= r_counter + 32'd1;
						r_counter2 <= 32'd0;
						state <= ST_SEND_TEST_CHAR_WAIT;
					end else 
					begin 
						start_input_string <= 0;
						state <= ST_LISTEN_PC;
					end
				
				end	
				
				ST_SEND_TEST_CHAR_WAIT: begin 
					uart_addr_o <= 3'b101;
					uart_we_o <= 1'b0;
					uart_re_o <= 1'b0;
					if (r_counter2<32'd2000) begin
						
						state <= ST_SEND_TEST_CHAR_WAIT;
						r_counter2 <= r_counter2 + 32'd1;
					end else begin
						state <= ST_SEND_TEST_CHAR;
					end
				end
				
				ST_WAIT_KEY: begin
					uart_we_o <= 1'b0;
					uart_re_o <= 1'b0;
					if (cont_key==1'b0) begin
						state <= ST_IDLE;
					end else begin
						state <= ST_WAIT_KEY;
					end
				end
				
				ST_LISTEN_PC: begin
					state <= ST_READ_LSR;
				end
				ST_READ_LSR : begin
					/*
						Iteration from this state to ST12
						1_1 - READ from LSR :  Don't need to wait 1 or 2 cycle - immediately reading 
						1_2 - check LSR value is 0x21
						2 - Then, Read from Buffer(RB_THR) and write memory
					*/
					uart_addr_o <= 3'b101;
					uart_we_o <= 1'b0;
					uart_re_o <= 1'b1;
					
					state <= ST_CHECK_LSR;
				end

					/*
						LSR value == 0x21 ?? Receive at least one character?
					*/
				ST_CHECK_LSR : begin	 
					if (uart_rdata_i[0]) begin // if a command come
						uart_addr_o <= 3'b000;
						uart_we_o <= 1'b0;
						uart_re_o <= 1'b1;
						state <= ST_CMD_DECODE;
					end
					else begin // Continue read for received data
						state <= ST_READ_LSR;
					end

				end
				
					/*
						READ from RB_THR;   
					*/
					
				ST_CMD_DECODE : begin  // show the received data on led, if "space" or "\n" then go to transmition step
					uart_re_o <= 1'b0;
					// Command decode
					case (uart_rdata_i)
						CM_SEND_TEST_CHAR: begin
							r_counter <= 32'd0;
							state <= ST_SEND_TEST_CHAR;
						end
						CM_SEND_ENTER: begin
							//r_counter <= 32'd0;
							state <= ST_SHOW_LED_RED;
						end
						/*
						CHAR_A: begin
							data_input <= (data_input << 8 ) |  CHAR_A;
						end
						CHAR_B: begin
							data_input <= (data_input << 8 ) | CHAR_B;
						end
						CHAR_C: begin
							data_input <= (data_input << 8 ) | CHAR_C;
						end
						CHAR_D: begin
							data_input <= (data_input << 8 ) | CHAR_D;
						end
						CHAR_E: begin
							data_input <= (data_input << 8 ) | CHAR_E;
						end
						CHAR_F: begin
							data_input <= (data_input << 8 ) | CHAR_F;
						end
						CHAR_G: begin
							data_input <= (data_input << 8 ) | CHAR_G;
						end */

						default: begin
							data_input <= (data_input << 8 ) | uart_rdata_i;
							state <= ST_LISTEN_PC;
						end
					endcase
					
				end
				
				ST_SHOW_LED_RED : begin
					input_red <= data_input;
					state <= ST_LISTEN_PC;
				end
				
				default: begin
					state <= ST_IDLE;
				end
			endcase	
	end
end

endmodule
