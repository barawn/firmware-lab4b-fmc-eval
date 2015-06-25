`timescale 1ns / 1ps
// QnD interface, through a UART.
module qnd_uart_interface(
    input CLK,
    output TX,
    input RX,
	 output [6:0] user_address_o,
	 input [7:0] user_data_i,
	 output [7:0] user_data_o,
	 output user_rd_o,
	 output user_wr_o,
	 output [17:0] debug_o
    );

//	parameter CLOCK = 200000000;
	parameter CLOCK = 66000000;

   wire [7:0] uart_txd;
   wire uart_wr;
   wire uart_tx_empty;
   wire tx_data_present;
   wire uart_tx_full;
   wire [7:0] uart_rxd;
   wire uart_rd;
   wire uart_rx_empty;
   wire rx_data_present;
	wire en_16_x_baud;
	
	uart_brg #(.CLOCK(CLOCK)) baudGen(.clk(CLK),.en_16_x_baud(en_16_x_baud));
	uart_tx6 tx(.serial_out(TX),.data_in(uart_txd),
					.buffer_write(uart_wr),.buffer_data_present(tx_data_present),
					.buffer_reset(uart_rst),
					.clk(CLK),
					.en_16_x_baud(en_16_x_baud));
   assign uart_tx_empty = !tx_data_present;
   uart_rx6 rx(.serial_in(RX), .data_out(uart_rxd),
               .buffer_read(uart_rd),
               .buffer_data_present(rx_data_present),
               .buffer_reset(uart_rst),
               .clk(CLK),
               .en_16_x_baud(en_16_x_baud));
   assign uart_rx_empty = !rx_data_present;
	QnD_Interface interface(.clk_i(CLK),
                           .uart_txd_o(uart_txd),
									.uart_tx_empty_i(uart_tx_empty),
									.uart_tx_full_i(uart_tx_full),
									.uart_rxd_i(uart_rxd),
									.uart_rx_empty_i(uart_rx_empty),
									.uart_wr_o(uart_wr),
									.uart_rd_o(uart_rd),
									.uart_rst_o(uart_rst),

									.user_dat_o(user_data_o),
									.user_dat_i(user_data_i),
									.user_adr_o(user_address_o),
									.user_rd_o(user_rd_o),
									.user_wr_o(user_wr_o),

									.debug_o(debug));
endmodule
