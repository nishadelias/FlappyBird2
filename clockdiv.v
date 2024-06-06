`timescale 1ns / 1ps

module clockdiv(
	input wire clk,		//master clock: 100MHz
	input wire clr,		//asynchronous reset
	output wire dclk,		//pixel clock: 25MHz
	output wire segclk,	//7-segment clock: 381.47Hz
	output wire gclk,   // about 50Hz
	output wire blink_clk
	);

// 17-bit counter variable
	reg [25:0] q;

// Clock divider --
// Each bit in q is a clock signal that is
// only a fraction of the master clock.
always @(posedge clk or posedge clr)
begin
	// reset condition
	if (clr == 1)
		q <= 0;
	// increment counter by one
	else
		q <= q + 1;
end

// 100Mhz ÷ 2^18 = 381.47Hz
assign segclk = q[17];

// 100Mhz ÷ 4 = 25MHz --bottom 2 bits will count from 0 to 4
assign dclk = q[0] & q[1];
assign gclk = q[23];
assign blink_clk = q[25];

endmodule
