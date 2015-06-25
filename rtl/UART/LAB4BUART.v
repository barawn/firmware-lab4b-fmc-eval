`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:19:14 09/04/2013 
// Design Name: 
// Module Name:    LAB4BUART 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LAB4BUART(
		input SYSCLK_P,
		input SYSCLK_N,
		input USB_1_TX,
		output USB_1_RX
    );

	wire CLK200;
	IBUFGDS sysclk_ibufgds(.I(SYSCLK_P),.IB(SYSCLK_N),.O(CLK200));

	wire [6:0] user_address;
	wire [7:0] user_data_to_interface;
	wire [7:0] user_data_from_interface;
	wire user_data_rd;
	wire user_data_wr;
	wire [17:0] debug;
	qnd_uart_interface #(.CLOCK(200000000))
			qnd(.CLK(CLK200),
				 .TX(USB_1_RX),
				 .RX(USB_1_TX),
				 .user_address_o(user_address),
				 .user_data_o(user_data_from_interface),
				 .user_data_i(user_data_to_interface),
				 .user_rd_o(user_data_rd),
				 .user_wr_o(user_data_wr),
				 .debug_o(debug));
						

	// USER INTERFACE SECTION
	reg [7:0] register_00 = 8'h5A;
	assign user_data_to_interface = register_00;
	always @(posedge CLK200) begin
		if (user_data_wr && user_address == 7'h00) register_00 <= user_data_from_interface;
	end

endmodule
