
// UART design
// System Frequency = 50 MHz
// Baud rate = 9600 bits/sec

`timescale 1ns/1ns

module baud_rate_gen
  #(parameter FINAL_DIVSR = 650)
	 (output 		done_o,
	  input 		clk_i,
	  input 		reset_i);

	reg [10:0] count;
	reg [10:0] count_next;
	
	always@(posedge clk_i , posedge reset_i) begin
		if(reset_i) 
			count <= 11'b0;
		else 
			count <= count_next;	
	end 
	
    assign count_next = (count == FINAL_DIVSR) ? 0 : count + 1'b1;
	assign done_o     = (count == 11'd1);
	  
endmodule
