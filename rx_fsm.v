
`timescale 1ns/1ns

module rx_fsm 
  #(parameter D_WIDTH = 8,
    parameter SB_TICK = 16)
  (output [D_WIDTH-1:0] rx_byte_o,
   output 				rx_done_o,
   input 				rx_data_i,
   input 				s_tick_i,
   input 				clk_i,
   input 				reset_i);
  	
  parameter [1:0] IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
  
  reg 	[2:0] 	bits_next, bits_reg;
  reg 	[3:0]	s_next, s_reg;
  reg	[1:0]   next_state, state;
  reg   [7:0]	shift_bits_next,shift_bits_reg;
  reg 			rx_done;
  
  always@(posedge clk_i , posedge reset_i) begin
    if(reset_i) begin
      state <= IDLE;
      s_reg <= 0;
      bits_reg <= 0;
      shift_bits_reg <= 0;
    end
    else begin
      state <= next_state;
      bits_reg <= bits_next;
      s_reg <= s_next;
      shift_bits_reg <= shift_bits_next;
    end    
  end
  
  always@(*) begin
    bits_next = bits_reg;
    s_next    = s_reg;
    rx_done = 1'b0;
    shift_bits_next = shift_bits_reg;
    next_state = state;
    
    case(state) 
      IDLE : begin
        if(~rx_data_i) begin
          	s_next = 1'b0;
            next_state = START;
        end
        else 
          	next_state = IDLE;
      end
      
      START : begin
        if(s_tick_i) begin
          if(s_reg == 4'd7) begin 
            	next_state = DATA;
            	s_next     = 1'b0;
            	bits_next  = 3'b0;
          end
          	else
              	s_next	   = s_reg + 1'b1;
        end
      end
      
      DATA : begin
        if(s_tick_i) begin
          if(s_reg == 4'd15) begin
            s_next = 0;
            shift_bits_next = {rx_data_i,shift_bits_reg[7:1]};
            if(bits_reg == D_WIDTH - 1)
              next_state = STOP;
            else 
              bits_next = bits_reg + 1'b1;
          end
          	s_next = s_reg + 1'b1;          
        end
      end
      
      STOP: begin
        if(s_tick_i) begin
          if(s_reg == SB_TICK - 1) begin
            rx_done = 1'b1;
            next_state = IDLE;
          end
          else
            rx_done = 0;          
        end
        else 
          	s_next = s_reg +1'b1;
      end
      
      default : next_state = IDLE;
    endcase
    
  end
  
  assign rx_done_o = rx_done;
endmodule
   
   