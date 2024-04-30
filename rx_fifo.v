

`timescale 1ns/1ns

module rx_fifo 
	// Parameter definition
	#(parameter D_WIDTH = 8,
	  parameter D_DEPTH = 16)
	  
	 //Ports Declaration
	 (output		empty_o,
	  output 		full_o,		//Status flags
	  
      output [D_WIDTH-1:0]  rd_data_o,
	  input  				rd_ena_i,	
	  
      input  [D_WIDTH-1:0]  wrt_data_i,
	  input  				wrt_ena_i,
	  
	  input  		clk_i,
	  input 		reset_i);
	  
	  localparam PTR_SIZE = $clog2(D_DEPTH);
	  
	  parameter  READ = 2'b01;
	  parameter  WRITE = 2'b10;
	  parameter  READ_WRITE = 2'b11;
	  
	  reg [PTR_SIZE-1:0]	rd_ptr, nxt_rd_ptr;
	  reg [PTR_SIZE-1:0]	wrt_ptr, nxt_wrt_ptr;
	  
	  reg [D_WIDTH-1:0] 	rd_data;
	  reg [D_WIDTH-1:0]	wrt_data;
	  
	  reg 			wrapped_rd_ptr, nxt_wrapped_rd_ptr;
	  reg 			wrapped_wrt_ptr, nxt_wrapped_wrt_ptr;
	  
	  reg [D_WIDTH-1:0] 	mem_rx 	[0:D_DEPTH-1];
	  
	  always@(posedge clk_i , posedge reset_i) begin
			if(reset_i) begin
				{wrapped_rd_ptr,rd_ptr} <= 0;
				{wrapped_wrt_ptr,wrt_ptr} <= 0;
				rd_data <= 0;
			end
			else begin
				{wrapped_rd_ptr,rd_ptr} <= {nxt_wrapped_rd_ptr,nxt_rd_ptr};
				{wrapped_wrt_ptr,wrt_ptr} <= {nxt_wrapped_wrt_ptr,wrt_ptr};				
			end
	  end 
	  
	  always@(*) begin
	  
			nxt_rd_ptr = rd_ptr;
			nxt_wrt_ptr = wrt_ptr;
			nxt_wrapped_rd_ptr = wrapped_rd_ptr;
			nxt_wrapped_wrt_ptr = wrapped_wrt_ptr;
			rd_data = mem_rx[rd_ptr];
			
			
			case({wrt_ena_i,rd_ena_i}) 
			
			READ : begin
					rd_data <= mem_rx[rd_ptr[PTR_SIZE-1:0]];
					if(rd_ptr == D_DEPTH-1) begin
						nxt_wrapped_rd_ptr <= ~wrapped_rd_ptr;
						nxt_rd_ptr <= 0;
					end
					else 
						nxt_rd_ptr <= rd_ptr + PTR_SIZE'(1'b1);
			end
			
			WRITE : begin
					mem_rx[wrt_ptr[PTR_SIZE-1:0]] <= wrt_data;
					if(wrt_ptr == D_DEPTH-1) begin
						nxt_wrapped_wrt_ptr <= ~wrapped_wrt_ptr;
						nxt_wrt_ptr <= 0;
					end
					else 
						nxt_wrt_ptr <= wrt_ptr + PTR_SIZE'(1'b1);
			end
			
			READ_WRITE : begin
					//READ Operation
					rd_data <= mem_rx[rd_ptr[PTR_SIZE-1:0]];
					if(rd_ptr == D_DEPTH-1) begin
						nxt_wrapped_rd_ptr <= ~wrapped_rd_ptr;
						nxt_rd_ptr <= 0;
					end
					else 
						nxt_rd_ptr <= rd_ptr + PTR_SIZE'(1'b1);
						
					mem_rx[wrt_ptr[PTR_SIZE-1:0]] <= wrt_data;
					if(wrt_ptr == D_DEPTH-1) begin
						nxt_wrapped_wrt_ptr = ~wrapped_wrt_ptr;
						nxt_wrt_ptr = 0;
					end
					else 
						nxt_wrt_ptr = wrt_ptr + PTR_SIZE'(1'b1);					
			end
			endcase
	  end
	  
	  assign rd_data_o =  rd_data;
	  assign empty_o   = ({wrapped_rd_ptr,rd_ptr} == {wrapped_wrt_ptr,wrt_ptr});
	  assign full_o	   = (wrapped_rd_ptr == ~wrapped_wrt_ptr) & (rd_ptr == wrt_ptr);
	  
endmodule
	  
