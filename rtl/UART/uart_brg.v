`timescale 1ns / 1ps
module uart_brg(
		input clk,
		output en_16_x_baud
    );
	parameter CLOCK = 66000000;
	parameter BAUD = 921600;
	localparam BAUDX16 = BAUD*16;
	parameter BRG_WIDTH = 16;
	// (1<<BRG_WIDTH)*(BAUDX16)/CLOCK
	localparam [63:0] BAUD_BRG_ROLLOVER = BAUDX16 << BRG_WIDTH;
	// Calculate the increment value, times 2, so we can round.
	// e.g. for clock=200 MHz, 
	localparam [31:0] BRG_INCX2 = BAUD_BRG_ROLLOVER/(CLOCK>>1);
	localparam [BRG_WIDTH-1:0] BRG_INC = BRG_INCX2[BRG_WIDTH:1] + BRG_INCX2[0];
	//(BAUD_BRG_ROLLOVER/BRG_INC = 151;
	reg [BRG_WIDTH:0] accumulator = {BRG_WIDTH+1{1'b0}};
	always @(posedge clk) begin
		accumulator <= accumulator[BRG_WIDTH-1:0] + BRG_INC;
	end
	assign en_16_x_baud = accumulator[BRG_WIDTH];
endmodule
