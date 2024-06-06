`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:25 03/19/2013 
// Design Name: 
// Module Name:    NERP_demo_top 
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
module NERP_demo_top(
	input wire clk,			//master clock = 100MHz
	input wire clr,			//right-most pushbutton for reset
	input wire pause,
	input wire flap,
	output wire [6:0] seg,	//7-segment display LEDs
	output wire [3:0] an,	//7-segment display anode enable
	output wire dp,			//7-segment display decimal point
	output wire [2:0] red,	//red vga output - 3 bits
	output wire [2:0] green,//green vga output - 3 bits
	output wire [2:0] blue,	//blue vga output - 3 bits
	output wire hsync,		//horizontal sync out
	output wire vsync			//vertical sync out
	);
	
wire gamestate;



// 7-segment clock interconnect
wire segclk, gclk, blink_clk;

// VGA display clock interconnect
wire dclk;

// disable the 7-segment decimal points
assign dp = 1;

wire [9:0] y;

wire [10:0] score = 0;

// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.clr(clr),
	.segclk(segclk),
	.dclk(dclk),
	.gclk(gclk),
	.blink_clk(blink_clk)
	);

// 7-segment display controller
segdisplay U2(
    .game_state(gamestate),
    .score(score),
    .clk_blink(blink_clk),
	.clk_fast(segclk),
	.LED_out(seg),
	.Anode_Activate(an)
	);

// VGA controller
vga640x480 U3(
    .flap(flap),
	.dclk(dclk),
	.clr(clr),
	.pause(pause),
	.y(y),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue),
	.gamestate(gamestate)
	);


endmodule
