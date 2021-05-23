module uart_test
(
CLOCK_50,
KEY,
LEDG,
LEDR,
// RS232
//UART_RXD,
//UART_TXD
MY_RXD,
MY_TXD, 

//	LCD Module 16X2
LCD_ON,	// LCD Power ON/OFF
LCD_BLON,	// LCD Back Light ON/OFF
LCD_RW,	// LCD Read/Write Select, 0 = Write, 1 = Read
LCD_EN,	// LCD Enable
LCD_RS,	// LCD Command/Data Select, 0 = Command, 1 = Data
LCD_DATA,
SW,
HEX0,
HEX1,
HEX2,
HEX3
);

input CLOCK_50;
input [2:0] KEY;
output [2:0] LEDG;
output [15:0] LEDR;
input MY_RXD;
output MY_TXD;
output[7:0] HEX0;
output[7:0] HEX1;
output[7:0] HEX2;
output[7:0] HEX3;
// LCD
output LCD_ON;	// LCD Power ON/OFF
output LCD_BLON;	// LCD Back Light ON/OFF
output LCD_RW;	// LCD Read/Write Select, 0 = Write, 1 = Read
output LCD_EN;	// LCD Enable
output LCD_RS;	// LCD Command/Data Select, 0 = Command, 1 = Data
inout [7:0] LCD_DATA;	// LCD Data bus 8 bits
input [8:0] SW; 
//---- 


wire reset_b;
wire clk;
wire w_rst_n;
wire clk_25;

assign reset_b = KEY[0];
assign clk = CLOCK_50;
// PLL
my_pll U_PLL(
	.areset		(!reset_b),
	.inclk0		(clk),
	.c0				(),
	.c1				(),
	.c2				(clk_25),	
	.c3				(),
	.locked		(w_rst_n));
	

wire [2:0] w_uart_addr_o;
wire [7:0] w_uart_wdata_o;
wire [7:0] w_uart_rdata_i;
wire w_uart_we_o;
wire w_uart_re_o;
wire [61*8:0] message;
wire [4*8:0] led_sv_out;
wire [8:0] led_out;
wire [8:0] sw_in;
wire [8:0] led_in;
wire [8:0] length_message;

fifo U_Controller
(
	.Enable(!KEY[1]), 
	.CLK(clk_25), 
	.RESET(!w_rst_n), 
	.uart_addr_o(w_uart_addr_o), 
	.uart_wdata_o(w_uart_wdata_o), 
	.uart_rdata_i(w_uart_rdata_i), 
	.uart_we_o(w_uart_we_o), 
	.uart_re_o(w_uart_re_o),
	.cont_key(KEY[2]),
	.led_test(LEDG),
	.message_output(message),
	.led_sv_output(led_sv_out),
	.led_output(led_out),
	.sw_input(sw_in),
	.led_input(led_in),
	.length_of_string(length_message)
);
 
led_sw_cmd U_led_sw(
	.CLK(clk_25),
	.led_red(LEDR),
	.led_output(led_out),
	.sw_input(SW),
	.sw_output(sw_in),
	.led_hex0(HEX0),
	.led_hex1(HEX1),
	.led_hex2(HEX2),
	.led_hex3(HEX3),
	.led_sv_input(led_sv_out)
);
// UART Driver
uart_regs U_Driver(
	.clk(clk_25),
   .wb_rst_i(!w_rst_n), 
	.wb_addr_i(w_uart_addr_o), 
	.wb_dat_i(w_uart_wdata_o), 
	.wb_dat_o(w_uart_rdata_i), 
	.wb_we_i(w_uart_we_o), 
	.wb_re_i(w_uart_re_o), 
	.stx_pad_o   (MY_TXD),
	.srx_pad_i   (MY_RXD)
    );

	 
// LCD --------------------------- 


wire [1:0] isServer;
assign isServer = SW[4:3];
// reset delay gives some time for peripherals to initialize
wire DLY_RST;
reset_delay r0(	.iCLK(CLOCK_50),.oRESET(DLY_RST) );


// turn LCD ON
assign	LCD_ON		=	1'b1;
assign	LCD_BLON	=	1'b1;

lcd_messages lcd_show(
// Host Side
   .iCLK(CLOCK_50),
   .iRST_N(DLY_RST),
// LCD Side
   .LCD_DATA(LCD_DATA),
   .LCD_RW(LCD_RW),
   .LCD_EN(LCD_EN),
   .LCD_RS(LCD_RS),
	.mess(message),
	.isServer(isServer),
	.length_of_string(length_message)
);
endmodule