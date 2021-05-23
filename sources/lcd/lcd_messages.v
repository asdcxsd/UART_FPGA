module lcd_messages(
// Host Side
  input iCLK,iRST_N,
// Server Message input,
  input [61*8:0] mess,
  input [1:0] isServer,
// LCD Side
  output [7:0] 	LCD_DATA,
  output LCD_RW,LCD_EN,LCD_RS,
  input [8:0] length_of_string
);
//	Internal Wires/Registers
reg	[5:0]	LUT_INDEX;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST;
reg	[17:0]	mDLY;
reg		mLCD_Start;
reg	[7:0]	mLCD_DATA;
reg		mLCD_RS;
wire		mLCD_Done;
reg [7:0] keyy ;
reg [61*8:0] message;


parameter	LCD_INTIAL	=	0;
parameter	LCD_LINE1	=	5;
parameter	LCD_CH_LINE	=	LCD_LINE1+16;
parameter	LCD_LINE2	=	LCD_LINE1+16+1;
parameter	LUT_SIZE	=	LCD_LINE1+32+1;

initial begin
	refresh = 1;
end
/** Message Arrays **/
reg [9:0] line1_mess [15:0];
reg [9:0] line2_mess [15:0];


always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
			case(mLCD_ST)
			0:	begin
					mLCD_DATA	<=	LUT_DATA[7:0];
					mLCD_RS		<=	LUT_DATA[8];
					mLCD_Start	<=	1;
					mLCD_ST		<=	1;
				end
			1:	begin
					if(mLCD_Done)
					begin
						mLCD_Start	<=	0;
						mLCD_ST		<=	2;
					end
				end
			2:	begin
					if(mDLY<18'h3FFFE)
					mDLY	<=	mDLY + 1'b1;
					else
					begin
						mDLY	<=	0;
						mLCD_ST	<=	3;
					end
				end
			3:	begin
					LUT_INDEX	<=	LUT_INDEX + 1'b1;
					mLCD_ST	<=	0;
				end
			endcase
		end else if(refresh == 1) begin
			LUT_INDEX <= 0;
      // line 1 message value is set here
	
			 line1_mess[0] <= clientMessage[0];
			 line1_mess[1] <= clientMessage[1];
			 line1_mess[2] <= clientMessage[2];
			 line1_mess[3] <= clientMessage[3];
			 line1_mess[4] <= clientMessage[4];
			 line1_mess[5] <= clientMessage[5];
			 line1_mess[6] <= clientMessage[6];
			 line1_mess[7] <= clientMessage[7];
			 line1_mess[8] <= clientMessage[8];
			 line1_mess[9] <= clientMessage[9];
			 line1_mess[10] <= clientMessage[10];
			 line1_mess[11] <= clientMessage[11];
			 line1_mess[12] <= clientMessage[12];
			 line1_mess[13] <= clientMessage[13];
			 line1_mess[14] <= clientMessage[14];
			 line1_mess[15] <= clientMessage[15];

				// line 2 message value is set here
			message = mess >> ((run_length_string-1)*8);

			line2_mess[0] <= 9'h100 | (message[127:120] == 8'b0 ? 8'd32 : message[127:120]);
			line2_mess[1] <= 9'h100 | (message[119:112]  == 8'b0 ? 8'd32 : message[119:112]);
			line2_mess[2] <= 9'h100 | (message[111:104]  == 8'b0 ? 8'd32 : message[111:104]);
			line2_mess[3] <= 9'h100 | (message[103:96]  == 8'b0 ? 8'd32 : message[103:96]);
			line2_mess[4] <= 9'h100 | (message[95:88]  == 8'b0 ? 8'd32 : message[95:88]);
			line2_mess[5] <= 9'h100 | (message[87:80]  == 8'b0 ? 8'd32 : message[87:80]);
			line2_mess[6] <= 9'h100 | (message[79:72]  == 8'b0 ? 8'd32 : message[79:72]);
			line2_mess[7] <= 9'h100 | (message[71:64]  == 8'b0 ? 8'd32 : message[71:64]);
			line2_mess[8] <= 9'h100 | (message[63:56]  == 8'b0 ? 8'd32 : message[63:56]);
			line2_mess[9] <= 9'h100 | (message[55:48]  == 8'b0 ? 8'd32 : message[55:48]);
			line2_mess[10] <= 9'h100 | (message[47:40]  == 8'b0 ? 8'd32 : message[47:40]);
			line2_mess[11] <= 9'h100 | (message[39:32]  == 8'b0 ? 8'd32 : message[39:32]);
			line2_mess[12] <= 9'h100 | (message[31:24]  == 8'b0 ? 8'd32 : message[31:24]);
			line2_mess[13] <= 9'h100 | (message[23:16]  == 8'b0 ? 8'd32 : message[23:16]);
			line2_mess[14] <= 9'h100 | (message[15:8]  == 8'b0 ? 8'd32 : message[15:8]);
			line2_mess[15] <= 9'h100 | (message[7:0]  == 8'b0 ? 8'd32 : message[7:0]);

		end
	end
end

reg [31:0] counter;
reg refresh;
reg [8:0] run_length_string;
always@(posedge iCLK) begin: increment_counter
	if(counter == 27'd25000000	) begin
		refresh <= 1;
		counter <= 0;
		run_length_string <= run_length_string -1;
		if (run_length_string <= 8'b0)
			run_length_string <= length_of_string;
	end else begin
		counter <= counter + 1;
		refresh <= 0;
	end
end




/** Client/Server Status message **/
wire [9:0] clientMessage [15:0];
assign clientMessage[0] = 9'h143; // CLIENT STATUS
assign clientMessage[1] = 9'h14c;
assign clientMessage[2] = 9'h149;
assign clientMessage[3] = 9'h145;
assign clientMessage[4] = 9'h14e;
assign clientMessage[5] = 9'h154;
assign clientMessage[6] = 9'h120;
assign clientMessage[7] = 9'h153;
assign clientMessage[8] = 9'h154;
assign clientMessage[9] = 9'h141;
assign clientMessage[10] = 9'h154;
assign clientMessage[11] = 9'h155;
assign clientMessage[12] = 9'h153;
assign clientMessage[13] = 9'h120;
assign clientMessage[14] = 9'h120;
assign clientMessage[15] = 9'h120;

wire [9:0] serverMessage [15:0];
assign serverMessage[0] = 9'h153; // SERVER STATUS
assign serverMessage[1] = 9'h145;
assign serverMessage[2] = 9'h152;
assign serverMessage[3] = 9'h156;
assign serverMessage[4] = 9'h145;
assign serverMessage[5] = 9'h152;
assign serverMessage[6] = 9'h120;
assign serverMessage[7] = 9'h153;
assign serverMessage[8] = 9'h154;
assign serverMessage[9] = 9'h141;
assign serverMessage[10] = 9'h154;
assign serverMessage[11] = 9'h155;
assign serverMessage[12] = 9'h153;
assign serverMessage[13] = 9'h120;
assign serverMessage[14] = 9'h120;
assign serverMessage[15] = 9'h120;

always@(posedge iCLK)
begin

	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0:	LUT_DATA	<=	line1_mess[0];	//	WEBSERVER STATUS
	LCD_LINE1+1:	LUT_DATA	<=	line1_mess[1];
	LCD_LINE1+2:	LUT_DATA	<=	line1_mess[2];
	LCD_LINE1+3:	LUT_DATA	<=	line1_mess[3];
	LCD_LINE1+4:	LUT_DATA	<=	line1_mess[4];
	LCD_LINE1+5:	LUT_DATA	<=	line1_mess[5];
	LCD_LINE1+6:	LUT_DATA	<=	line1_mess[6];
	LCD_LINE1+7:	LUT_DATA	<=	line1_mess[7];
	LCD_LINE1+8:	LUT_DATA	<=	line1_mess[8];
	LCD_LINE1+9:	LUT_DATA	<=	line1_mess[9];
	LCD_LINE1+10:	LUT_DATA	<=	line1_mess[10];
	LCD_LINE1+11:	LUT_DATA	<=	line1_mess[11];
	LCD_LINE1+12:	LUT_DATA	<=	line1_mess[12];
	LCD_LINE1+13:	LUT_DATA	<=	line1_mess[13];
	LCD_LINE1+14:	LUT_DATA	<=	line1_mess[14];
	LCD_LINE1+15:	LUT_DATA	<=	line1_mess[15];
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	//	Line 2
	LCD_LINE2+0:	LUT_DATA	<=	line2_mess[0];	//	0: Page Recieved
	LCD_LINE2+1:	LUT_DATA	<=	line2_mess[1]; // 1: Page Loaded
	LCD_LINE2+2:	LUT_DATA	<=	line2_mess[2]; // 2: Page Sent
	LCD_LINE2+3:	LUT_DATA	<=	line2_mess[3];
	LCD_LINE2+4:	LUT_DATA	<=	line2_mess[4];
	LCD_LINE2+5:	LUT_DATA	<=	line2_mess[5];
	LCD_LINE2+6:	LUT_DATA	<=	line2_mess[6];
	LCD_LINE2+7:	LUT_DATA	<=	line2_mess[7];
	LCD_LINE2+8:	LUT_DATA	<=	line2_mess[8];
	LCD_LINE2+9:	LUT_DATA	<=	line2_mess[9];
	LCD_LINE2+10:	LUT_DATA	<=	line2_mess[10];
	LCD_LINE2+11:	LUT_DATA	<=	line2_mess[11];
	LCD_LINE2+12:	LUT_DATA	<=	line2_mess[12];
	LCD_LINE2+13:	LUT_DATA	<=	line2_mess[13];
	LCD_LINE2+14:	LUT_DATA	<=	line2_mess[14];
	LCD_LINE2+15:	LUT_DATA	<=	line2_mess[15];
	default:		LUT_DATA	<=	9'dx ;
	endcase
end




lcd_controller u0(
//    Host Side
.iDATA(mLCD_DATA),
.iRS(mLCD_RS),
.iStart(mLCD_Start),
.oDone(mLCD_Done),
.iCLK(iCLK),
.iRST_N(iRST_N),
//    LCD Interface
.LCD_DATA(LCD_DATA),
.LCD_RW(LCD_RW),
.LCD_EN(LCD_EN),
.LCD_RS(LCD_RS)    );

endmodule
