`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2024 11:14:17 AM
// Design Name: 
// Module Name: game
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


module game (
    input clk,       // Clock input
  	input flap,
    output reg signed [9:0] y  // 10-bit y coordinate output
);
  
  //Constants
  //parameter [9:0] VERTICAL_BOUND = 9'd480;
  //parameter [9:0] HORIZONTAL_BOUND = 9'd640;
  //parameter [7:0] start_y = 9'd240;
  //parameter signed [7:0] GRAVITY = -8'd1;
  
  //Variables
  reg signed [7:0] velocity = 8'd0;
  reg signed [9:0] temp_y;
  

    // Initialize y coordinate
    initial begin
      y = 10'd240;
      temp_y = y;
    end
  //When flap, bird gets a velocity of 4
  always @(posedge flap) begin
    velocity <= 8'd4;
  end
    always @(posedge clk) begin
		//Update the birds velocity and y coordinates each clk cycle
      	if(temp_y != 0 || flap == 1) begin
          velocity <= velocity + -8'd1;
          //velocity <= velocity + 8'd1; for testing upward velocity
          temp_y <= temp_y + velocity;
        end
          //Ground check
      if (temp_y[9] == 1) begin
        //If y value is negative, set velocity to 0 and y to 0
            temp_y<= 10'd0;
            velocity <= 0;
      end else if (temp_y > 10'd480) begin
        //If our y hits the top of the screen, set velocity to 0 and y to top of the screen
          	temp_y<= 10'd480;
        	velocity<= 0;
        end else begin
          //Else if our y value if valid, set the output
          y = temp_y;
        end
      end 
endmodule
