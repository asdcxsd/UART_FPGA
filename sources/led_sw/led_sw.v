
module led_sw_cmd(
	CLK,
	led_red,
	led_output,
	sw_input,
	sw_output,
	led_hex0,
	led_hex1,
	led_hex2,
	led_hex3,
	led_sv_input
);



input CLK;
input [8:0] sw_input;
input [8:0] led_output;
output [8:0] sw_output;
output [15:0] led_red;
input [4*8:0] led_sv_input;
output [7:0] led_hex0;
output [7:0] led_hex1;
output [7:0] led_hex2;
output [7:0] led_hex3;

parameter HEX_INT_0 = 8'd48;
parameter HEX_INT_1 = 8'd48;
parameter HEX_INT_2 = 8'd50;
parameter HEX_INT_3 = 8'd51;
parameter HEX_INT_4 = 8'd52;
parameter HEX_INT_5 = 8'd53;
parameter HEX_INT_6 = 8'd54;
parameter HEX_INT_7 = 8'd55;
parameter HEX_INT_8 = 8'd56;
parameter HEX_INT_9 = 8'd57;

reg [15:0] input_red;
assign led_red = input_red;
reg [8:0] output_of_sw;
assign sw_output = output_of_sw;
reg [7:0] LED_out0;
reg [7:0] LED_out1;
reg [7:0] LED_out2;
reg [7:0] LED_out3;

assign led_hex0 = LED_out0;
assign led_hex1 = LED_out1;
assign led_hex2 = LED_out2;
assign led_hex3 = LED_out3;
always @(posedge CLK)
begin
	input_red <= led_output;
	output_of_sw <= sw_input;
	
	case (led_sv_input[7:0] - 8'd48)
		 4'b0000: LED_out0 = 7'b1000000; // "0"  
		 4'b0001: LED_out0 = 7'b1111001; // "1" 
		 4'b0010: LED_out0 = 7'b0100100; // "2" 
		 4'b0011: LED_out0 = 7'b0110000; // "3" 
		 4'b0100: LED_out0 = 7'b0011001; // "4" 
		 4'b0101: LED_out0 = 7'b0010010; // "5" 
		 4'b0110: LED_out0 = 7'b0000010; // "6" 
		 4'b0111: LED_out0 = 7'b1111000; // "7" 
		 4'b1000: LED_out0 = 7'b0000000; // "8"  
		 4'b1001: LED_out0 = 7'b0010000; // "9" 
		 default: LED_out0 = 7'b1000000; // "0"
   endcase
		case (led_sv_input[15:8] - 8'd48)
		 4'b0000: LED_out1 = 7'b1000000; // "0"  
		 4'b0001: LED_out1 = 7'b1111001; // "1" 
		 4'b0010: LED_out1 = 7'b0100100; // "2" 
		 4'b0011: LED_out1 = 7'b0110000; // "3" 
		 4'b0100: LED_out1 = 7'b0011001; // "4" 
		 4'b0101: LED_out1 = 7'b0010010; // "5" 
		 4'b0110: LED_out1 = 7'b0000010; // "6" 
		 4'b0111: LED_out1 = 7'b1111000; // "7" 
		 4'b1000: LED_out1 = 7'b0000000; // "8"  
		 4'b1001: LED_out1 = 7'b0010000; // "9" 
		 default: LED_out1 = 7'b1000000; // "0"
   endcase
		case (led_sv_input[23:16] - 8'd48)
		 4'b0000: LED_out2 = 7'b1000000; // "0"  
		 4'b0001: LED_out2 = 7'b1111001; // "1" 
		 4'b0010: LED_out2 = 7'b0100100; // "2" 
		 4'b0011: LED_out2 = 7'b0110000; // "3" 
		 4'b0100: LED_out2 = 7'b0011001; // "4" 
		 4'b0101: LED_out2 = 7'b0010010; // "5" 
		 4'b0110: LED_out2 = 7'b0000010; // "6" 
		 4'b0111: LED_out2 = 7'b1111000; // "7" 
		 4'b1000: LED_out2 = 7'b0000000; // "8"  
		 4'b1001: LED_out2 = 7'b0010000; // "9" 
		 default: LED_out2 = 7'b1000000; // "0"
   endcase
		case (led_sv_input[31:24] - 8'd48)
		 4'b0000: LED_out3 = 7'b1000000; // "0"  
		 4'b0001: LED_out3 = 7'b1111001; // "1" 
		 4'b0010: LED_out3 = 7'b0100100; // "2" 
		 4'b0011: LED_out3 = 7'b0110000; // "3" 
		 4'b0100: LED_out3 = 7'b0011001; // "4" 
		 4'b0101: LED_out3 = 7'b0010010; // "5" 
		 4'b0110: LED_out3 = 7'b0000010; // "6" 
		 4'b0111: LED_out3 = 7'b1111000; // "7" 
		 4'b1000: LED_out3 = 7'b0000000; // "8"  
		 4'b1001: LED_out3 = 7'b0010000; // "9" 
		 default: LED_out3 = 7'b1000000; // "0"
   endcase

end

endmodule