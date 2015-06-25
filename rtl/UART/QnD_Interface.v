`timescale 1ns / 1ps
// Standard QnD interface module.
module QnD_Interface(
		input clk_i,
		output [7:0] uart_txd_o,
		input	uart_tx_full_i,
		input uart_tx_empty_i,
		input [7:0] uart_rxd_i,
		input uart_rx_empty_i,
		output uart_wr_o,
		output uart_rd_o,
		output uart_rst_o,
		// User register access.
		input [7:0] user_dat_i,
		output [7:0] user_dat_o,
		output [6:0] user_adr_o,
		output user_rd_o,
		output user_wr_o,
		output [17:0] debug_o
    );

	wire [17:0] pbInstruction;
	wire [11:0] pbAddress;
	wire pbRomEnable;

	wire [7:0] pbOutput;
	wire [7:0] pbInput;
	wire [7:0] pbPort;
	wire pbKWrite;
	wire pbWrite;
	wire pbRead;
	wire pbInterrupt = !uart_rx_empty_i;
	wire pbInterruptAck;
	wire pbSleep = 0;
	wire pbReset = 0;

	kcpsm6 processor(.address(pbAddress),.instruction(pbInstruction),
						  .bram_enable(pbRomEnable),
						  .in_port(pbInput),.out_port(pbOutput),.port_id(pbPort),
						  .write_strobe(pbWrite),.read_strobe(pbRead),.k_write_strobe(pbKWrite),
						  .interrupt(pbInterrupt),.interrupt_ack(pbInterruptAck),
						  .sleep(pbSleep),.reset(pbReset),
						  .clk(clk_i));
	qnd_interface_program rom(.address(pbAddress),.instruction(pbInstruction),
									  .enable(pbRomEnable),.clk(clk_i));
	wire [7:0] uart_status = {{5{1'b0}}, uart_tx_empty_i, uart_tx_full_i};
	wire [7:0] uart_data = (pbPort[0]) ? uart_rxd_i : uart_status;
	wire uart_sel = (!pbPort[7]);

	wire user_sel = (pbPort[7]);

	assign pbInput = (pbPort[7]) ? user_dat_i : uart_data;

	assign uart_txd_o = pbOutput;
	assign uart_rd_o = (pbRead && pbPort[0] && uart_sel);
	assign uart_wr_o = ((pbWrite && pbPort[0] && uart_sel) || (pbKWrite && pbPort[0]));
	assign uart_rst_o = (pbWrite && !pbPort[0] && pbOutput[0]) && uart_sel;

	assign user_dat_o = pbOutput;
	assign user_rd_o = (pbRead && user_sel);
	assign user_wr_o = (pbWrite && user_sel);
	assign user_adr_o = pbPort[6:0];
	assign debug_o[9:0] = pbAddress;
	assign debug_o[17:10] = (pbRead) ? pbInput : pbOutput;

endmodule
