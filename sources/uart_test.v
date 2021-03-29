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
MY_TXD
);

input CLOCK_50;
input [2:0] KEY;
output [2:0] LEDG;
output [15:0] LEDR;
input MY_RXD;
output MY_TXD;


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
	.led_red(LEDR)
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

endmodule