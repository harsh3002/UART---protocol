
`timescale 1ns/1ns


module tx_fsm 
  #(parameter D_BITS = 8,
    parameter SB_TICK = 16)
  (output 				tx_data_o,
   output 				tx_done_o,
   input  [D_BITS-1:0]  tx_data_i,
   input 		 		clk_i,
   input 				reset_i,
   input 				s_tick_i,
   input 				tx_start_i);
  
  parameter [1:0] IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
  
  reg [1:0] 		next_state, state;
  reg [3:0] 		s_next, s_reg;
  reg [2:0]		 	bits_next, bits_reg;
  reg [D_BITS-1:0]  shift_bit_next, shift_bit_reg;
  reg 				tx_next, tx_reg;
  reg				tx_done;
  
  always@(posedge clk_i , posedge reset_i) begin
    if(reset_i) begin
      state <= IDLE;
      shift_bit_reg <= 0;
      s_reg <= 0;
      bits_reg <= 0;
      tx_reg <= 0;
    end
    else begin
      state <= next_state;
      shift_bit_reg <= shift_bit_next;
      s_reg <= s_next;
      bits_reg <= bits_next;
      tx_reg <= tx_next;
    end
  end
  
  always@(*) begin
    next_state = state;
    shift_bit_next = shift_bit_reg;
    s_next = s_reg;
    tx_next = tx_reg;
    bits_next = bits_reg;
    case(state) 
      IDLE: begin
        tx_next = 1'b1;
        if(tx_start_i) begin
          next_state = START;
          s_next = 0;
          shift_bit_next = tx_data_i;
        end
      end
      
      START : begin
        tx_next = 1'b0;
        if(s_tick_i) begin
          if(s_reg == 4'd15) begin
            next_state = DATA;
            s_next = 4'd0;
            bits_next = 3'd0;
          end
          else 
          	s_next = s_reg + 1'b1;
        end
      end
      
      DATA : begin
        tx_next = shift_bit_reg[0];
        if(s_tick_i) begin
          if(s_reg == 4'd15) begin
            s_next = 0;
            shift_bit_next = shift_bit_reg >> 1;
            if(bits_reg == D_BITS - 1) 
              next_state = STOP;
            else 
              bits_next = bits_reg + 1'b1;
          end
          else 
            s_next = s_reg + 1'b1;
        end
      end
      
      STOP : begin
        tx_next = 1'b1;
        if(s_tick_i) begin
          if(s_reg == SB_TICK - 1) begin
            tx_done = 1'b1;
            next_state = IDLE;
          end
          s_next = s_reg + 1'b1;
        end
      end
      default : next_state = IDLE;
    endcase
  end
  
  assign tx_done_o = tx_done;
  assign tx_data_o = tx_reg;
endmodule