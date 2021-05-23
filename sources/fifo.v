
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
	message_output,
	led_sv_output,
	led_output,
	sw_input,
	led_input,
	length_of_string
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


parameter STRING_CONNECT  = 8'd48;
parameter STRING_STATUS_SWITCH  = 8'd49;
parameter STRING_STATUS_LED  = 8'd50;
parameter STRING_SET_LED  = 8'd51;
parameter STRING_SET_LCD  = 8'd52;
parameter STRING_SET_LED_SV  = 8'd53;

// PC Command list
parameter CM_SEND_TEST_CHAR = 8'h2f; // '/'

// PC Command list
parameter CM_SEND_ENTER = 8'h7E; // 'enter'

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
input [8:0]sw_input;
input [8:0] led_input;
output [2:0] led_test;
output [61*8:0] message_output;
output [4*8:0] led_sv_output;
output [8:0]	led_output;
output [8:0] length_of_string;

reg [61*8:0] string_message;
reg [8:0] length_of_message;
reg [8:0] length_of_cmd;
reg [4*8:0] string_led_sv;
reg [8:0] string_led;
assign message_output = string_message;
assign led_sv_output = string_led_sv;
assign led_output = string_led;
assign length_of_string = length_of_message;


reg [8:0] STATUS_SW_END ;
reg [8:0] STATUS_LED_END;


reg [8*70:0] data_input;

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

reg [8*60:0] string_space;
reg [8*31:0] string_NHAP_MA_TAU[0:30];
reg [8*4:0] string_CONNECT[0:3];
reg [8*4:0] string_get_STAUTUS_SWITCHS[0:3];
reg [8*4:0] string_get_STAUTUS_LED[0:3];
reg [8*4:0] string_set_STAUTUS_SWITCHS[0:3];
reg [8*41:0] string_LCD[0:40];
reg [8*5:0] string_LED_SV[0:4];
reg [8*3:0] string_response[0:2];
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
		string_message <= 16'd0;

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
		
					string_response[0] <= CHAR_O;
					string_response[1] <= CHAR_K;
					string_response[2] <= CM_SEND_ENTER;
					string_Length <= 32'd3;
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
	
					
					if (r_counter< 32'd3) begin
						uart_addr_o <= 3'b000;
						uart_we_o <= 1'b1;
						uart_re_o <= 1'b0;
						uart_wdata_o <= string_response[r_counter];
						
						led_3 <= (led_3+1)&1;
						r_counter <= r_counter + 32'd1;
						r_counter2 <= 32'd0;
						state <= ST_SEND_TEST_CHAR_WAIT;
					end else 
					begin 
						start_input_string <= 0;
						length_of_cmd <= 0;
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

							r_counter <= 0;
							case (data_input & 8'b11111111)
							
								STRING_CONNECT: begin
									string_response[1] = STRING_CONNECT;
									string_response[0] = 8'd49;
									string_response[2] = CM_SEND_ENTER;
									
									state <= ST_SEND_TEST_CHAR;
								end
								
								STRING_STATUS_SWITCH: begin
									STATUS_SW_END = sw_input ;
									string_response[1] = STRING_STATUS_SWITCH;
									string_response[0] = STATUS_SW_END;
									string_response[2] = CM_SEND_ENTER;
									state <= ST_SEND_TEST_CHAR;
								end
								STRING_SET_LED: begin
									string_led <= (data_input >> 8);
									string_response[1] = STRING_SET_LED;
									string_response[0] = 8'd49;
									string_response[2] = CM_SEND_ENTER;	
									state <= ST_SEND_TEST_CHAR;							
								end
								
								STRING_SET_LCD: begin
									length_of_message <= length_of_cmd - 1;
									string_message <=  (data_input >> 8);

									string_response[1] = STRING_SET_LCD;
									string_response[0] = 8'd49;
									string_response[2] = CM_SEND_ENTER;	
									state <= ST_SEND_TEST_CHAR;
								end
								
								STRING_SET_LED_SV: begin
									string_led_sv <= (data_input >> 8);
									string_response[1] = STRING_SET_LED_SV;
									string_response[0] = 8'd49;
									string_response[2] = CM_SEND_ENTER;		
									state <= ST_SEND_TEST_CHAR;
								end
								default:
								begin
									
									//string_message <= (data_input >> 8);
									string_message <= (data_input >> 8);
									state <= ST_SHOW_LED_RED;
								end
							endcase
							data_input<= 0;
							length_of_cmd <= 0;
						end

						default: begin
							data_input <= (data_input << 8 ) | uart_rdata_i;
							length_of_cmd <= length_of_cmd + 1;
							state <= ST_LISTEN_PC;
						end
					endcase
					
					
				end
				
				ST_SHOW_LED_RED : begin
					state <= ST_LISTEN_PC;
				end
				
				default: begin
					state <= ST_IDLE;
				end
			endcase	
	end
end

endmodule
