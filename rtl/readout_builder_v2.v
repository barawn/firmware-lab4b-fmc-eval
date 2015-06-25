module readout_builder_v2(
		input CLK,
		input new_data_ready,
		input [4:0] digitize_address,
		input [11:0] PData_in,
		input subtract_pedestal,
		input update_pedestals,
		input show_pedestals,
		output [11:0] event_data,
		output [4:0] event_address,
		output write_event_out,
		output write_event_out_finished
);

	reg [11:0] data_array[1023:0];
	reg [4:0] data_addr_array[1023:0];
	reg [11:0] pedestal_array[4095:0];

	reg [11:0] data_output;
	reg [4:0] data_addr_output;
	reg [4:0] data_addr_ped_output;
	reg [11:0] pedestal_output;

	reg [9:0] write_pointer = {10{1'b0}};
	reg data_write_finished = 0;
	reg [9:0] read_pointer = {10{1'b0}};
	reg [9:0] ped_addr_read_pointer = {10{1'b0}};
	reg doing_pedestals = 0;
	
	reg [11:0] event_data_out = {12{1'b0}};
	reg [4:0] event_address_out = {5{1'b0}};
	reg event_data_latch = 0;
	reg event_data_done = 0;
	
	localparam FSM_BITS = 3;
	localparam [FSM_BITS-1:0] READ_DATA = 0;
	localparam [FSM_BITS-1:0] FETCH_FIRST_ADDRESS = 1;
	localparam [FSM_BITS-1:0] BEGIN_READOUT = 2;
	localparam [FSM_BITS-1:0] READOUT = 3;
	localparam [FSM_BITS-1:0] DONE = 4;
	reg [FSM_BITS-1:0] state = READ_DATA;
	always @(posedge CLK) begin
		case (state)
			// Normal idle state: when new_data_ready comes in, increment write pointer.
			// When we receive 1024 samples of data, done.
			READ_DATA: if (write_pointer == 1023 && new_data_ready) state <= FETCH_FIRST_ADDRESS;
			// After we've read 1024 samples of data, fetch the first sample address...
			FETCH_FIRST_ADDRESS: state <= BEGIN_READOUT;
			// And now the first sample address is at the pedestal BRAM,
			// and the read pointer is at the data BRAM, and the
			// read address pointer is at the data address BRAM.
			BEGIN_READOUT: state <= READOUT;
			// Now data is available on the outputs. When the read pointer wraps around,
			// then we're done. (When the read pointer wraps around, the data for sample
			// 1023 is on the output).
			READOUT: if (read_pointer == 0) state <= DONE;
			// Flag user that the data is done. Wait for more.
			DONE: state <= READ_DATA;
		endcase
	end
	
	// Block RAM logic. This just infers the block RAM, and is kept as simple as possible.
	always @(posedge CLK) begin
		if (new_data_ready) begin
			data_array[write_pointer] <= PData_in;
		end
		data_output <= data_array[read_pointer];
		// Dual-port, read/write block RAM logic.
		if (new_data_ready) begin
			data_addr_array[write_pointer] <= digitize_address;
		end 
		data_addr_ped_output <= data_addr_array[ped_addr_read_pointer];
	end
	// Delay the data_addr output so that it lines up with the data output (it's prefetched one ahead)
	always @(posedge CLK) begin
		data_addr_output <= data_addr_ped_output;
	end
	
	// Write pointer logic.
	always @(posedge CLK) begin
		if (state == READ_DATA) begin
			if (new_data_ready) write_pointer <= write_pointer + 1;
		end else write_pointer <= {10{1'b0}};
	end
	// Read pointer logic.
	always @(posedge CLK) begin
		if (state == BEGIN_READOUT || state == READOUT) read_pointer <= read_pointer + 1;
		else read_pointer <= {10{1'b0}};
	end	
	// Multiplex the outputs. Don't care that they're not valid at other times.
	always @(posedge CLK) begin
		if (show_pedestals)
			event_data_out <= pedestal_output;
		else if (subtract_pedestal)
			event_data_out <= data_output - pedestal_output;
		else
			event_data_out <= data_output;
	end
	// And also delay the event outputs (since there's no mux).
	always @(posedge CLK) begin
		event_address_out <= data_addr_output;
	end

	// This indicates that the data is valid/done. Delayed by 1 since the multiplex
	// above is registered.
	always @(posedge CLK) begin
		event_data_latch <= (state == READOUT);
		event_data_done <= (state == DONE);
	end
	
	// Pedestal Handling:
	// State machine:
	// IDLE : if (update_pedestals) -> READOUT
	// READOUT: when new data is available, store it in {digitize_address,current_address_ped}
	// I don't think this actually needs a state machine...?
	// We can just 
	always @(posedge CLK) begin
		if (event_data_done) doing_pedestals <= 0;
		else if (update_pedestals) doing_pedestals <= 1;
	end
	// Pedestal write pointer logic.
	reg [6:0] pedestal_sample_counter = {7{1'b0}};
	always @(posedge CLK) begin
		if (doing_pedestals && new_data_ready)
			pedestal_sample_counter <= pedestal_sample_counter + 1;
		else if (!doing_pedestals)
			pedestal_sample_counter <= {7{1'b0}};
	end	
	wire [11:0] pedestal_write_pointer = {digitize_address, pedestal_sample_counter};
	// Pedestal read pointer logic.
	// The pedestal read pointer is derived from the data address. It needs to be ready
	// a sample ahead, so we prep it at the end of the event readout (the data write).

	// So here we go:
	// clk state write_pointer read_pointer data ped 			data_addr_ped ped_addr_read_pointer
	// 0   READ  1023          0 				 X    X   			X   			  X             
	// 1   FETCH 0 			   0            X    X   			X             0
	// 2   BEGIN 0             0				 X    X   			A<0>          1
	// 3   READ  0					1            D<0> P<A<0>>		A<1>			  2
	// 4   READ  0					2            D<1> P<A<1>>     A<2>          3
	// (etc.)
	always @(posedge CLK) begin
		if (state == FETCH_FIRST_ADDRESS || state == BEGIN_READOUT || state == READOUT)
			ped_addr_read_pointer <= ped_addr_read_pointer + 1;
		else
			ped_addr_read_pointer <= {10{1'b0}};
	end	
	wire [11:0] pedestal_read_pointer = {data_addr_ped_output,read_pointer[6:0]};
	always @(posedge CLK) begin
		if (doing_pedestals && new_data_ready) 
			pedestal_array[pedestal_write_pointer] <= PData_in;
		pedestal_output <= pedestal_array[pedestal_read_pointer];
	end

	// Now assign the outputs:
	assign write_event_out = event_data_latch;
	assign write_event_out_finished = event_data_done;
	assign event_data = event_data_out;
	assign event_address = event_address_out;
	
endmodule
