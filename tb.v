`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2024 11:23:25 AM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb;
  
  //Instantiate top module
  
  reg tb_clk;
  reg tb_clr;
  reg tb_pause;
  reg tb_flap;
  reg tb_dclk;
  wire [6:0] tb_seg;
  wire [3:0] tb_an;
  wire tb_dp;
  wire [2:0] tb_red;
  wire [2:0] tb_green;
  wire [2:0] tb_blue;
  wire tb_hsync;
  wire tb_vsync;
//  wire [9:0] tb_y;
  
  NERP_demo_top top_inst(
    .clk(tb_clk),
    .clr(tb_clr),
//    .pause_btn(tb_pause),
    .flap(tb_flap),
    .seg(tb_seg),
    .an(tb_an),
    .dp(tb_dp),
    .red(tb_red),
    .green(tb_green),
    .blue(tb_blue),
    .hsync(tb_hsync),
    .vsync(tb_vsync)
  );
  
  initial begin
    tb_clk = 0;
    tb_pause = 0;
    tb_flap = 0;
    tb_clr = 1;
    #100
    tb_clr = 0;
        
  end
    
  always begin
      #5 tb_clk = ~tb_clk;  //100 MHz clock
  end
  
//  always @(posedge tb_clk) begin
//    $display("%d", tb_y); 
//    $display("%b", tb_y); 
//  end

  initial begin
    	//tb_flap = 1;
        //#10
        //tb_flap = 0;
        #1000000
    	$finish;
  end
      
endmodule
