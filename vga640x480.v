`timescale 1ns / 1ps

module vga640x480(
    input wire flap,
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
	input wire pause,
	input wire [9:0] y,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [2:0] blue,	//blue vga output
	output reg gamestate,
	output reg [10:0] score
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480
parameter bird_x = 240;

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;
reg [9:0] bird_y;
reg [21:0] counter;
reg [11:0] pillar_x;
reg [10:0] pillar_y;
reg overlap;
reg [5:0] pcounter;

initial begin
    bird_y = 10'd240;
    counter = 0;
    gamestate = 0;
    pillar_x = 12'd600;
    pillar_y = 11'd240;
    score = 0;
    overlap = 0;

end

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
//always @(y) begin
//bird_y <= y;
//end


always @(posedge dclk or posedge clr)
begin

    if (!pause) begin
    if (!gamestate && flap) begin
        gamestate = 1;
        score <= 0;
    end
    
    counter <= counter+1;
    
    if (gamestate && counter % 80000 == 0) begin
        
    
    if (flap && bird_y > 10) bird_y <= bird_y - 2;
        else if (bird_y < 455) bird_y <= bird_y + 1;
    if (pillar_x == 0) begin
        pillar_x <= 640;
        if (pcounter == 8) pcounter <= 0;
        else pcounter <= pcounter + 1;
        case(pcounter) 
            0: pillar_y = 240;
            1: pillar_y = 50;
            2: pillar_y = 200;
            3: pillar_y = 160;
            4: pillar_y = 340;
            5: pillar_y = 220;
            6: pillar_y = 70;
            7: pillar_y = 180;
            default: pillar_y = 240;
        endcase
    end
    else pillar_x <= pillar_x - 1;
        
    //If the bird x is in pillar range
                    if(bird_x >= pillar_x && bird_x <= pillar_x+50) begin
        
                        //If bird is in the gap
                        if(bird_y > pillar_y && bird_y < pillar_y + 120 && !overlap) begin
                            score <= score+1;
                            overlap <= 1;
                        end
                        else if(!(bird_y > pillar_y && bird_y < pillar_y + 120)) begin
                            gamestate <= 0;
                            hc <= 0;
                            vc <= 0;
                            bird_y <= 10'd240;
                            pillar_x <= 12'd600;
                            pillar_y <= 11'd240;
                            overlap <= 0;
                            
                        end
                    end
                    else begin
                        overlap <= 0;
                    end
        
    end
    end
    
    
    
    
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
		bird_y <= 10'd240;
		gamestate = 0;
		pillar_x = 12'd600;
		pillar_y = 11'd240;
		score <= 0;
		overlap <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// now display different colors every 80 pixels
		// while we're within the active horizontal range
		// -----------------
		// display blue
		if (hc >= (hbp+pillar_x) && hc < (hbp+pillar_x+50) && hc >= hbp && hc < (hfp) && !(vc >= (vbp+pillar_y) && vc < (vbp+pillar_y+120))) begin
		    red = 3'b000;
            green = 3'b111;
            blue = 3'b000;
		end else
		if (hc >= hbp && hc < (hbp+bird_x))
		begin
			red = 3'b001;
			green = 3'b110;
			blue = 3'b111;
		end
		// display yellow bar
		else if (hc >= (hbp+bird_x) && hc < (hbp+bird_x+20))
		begin
			if (vc >= (vbp+bird_y) && vc < (vbp+bird_y+20))
				begin
				// black part of the eyeball
				if (hc >= (hbp+bird_x+17) && hc < (hbp+bird_x+19) && vc >= (vbp+bird_y+5) && vc < (vbp+bird_y+7)) begin
					red = 0;
					green = 0;
					blue = 0;
				end
				// white part of the eyeball
				else if (hc >= (hbp+bird_x+14) && hc < (hbp+bird_x+20) && vc >= (vbp+bird_y+3) && vc < (vbp+bird_y+9)) begin
					red = 3'b111;
					green = 3'b111;
					blue = 3'b111;
				end 
				//rest of the bird
				else begin
					red = 3'b110;
					green = 3'b110;
					blue = 3'b000;
                  	end 
			// rest of the column	
			end else begin
                      		red = 3'b001;
                      		green = 3'b110;
                      		blue = 3'b111;
                  	end
		end
		// display blue
		else if (hc >= (hbp+bird_x+20) && hc < (hfp))
		begin
			red = 3'b001;
			green = 3'b110;
			blue = 3'b111;
		end
		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
	end
endmodule
