// Code your design here
`include "baud_rate_gen.v"
`include "rx_fifo.v"
`include "tx_fifo.v"
`include "rx_fsm.v"
`include "tx_fsm.v"


`timescale 1ns/1ns

module uart 
  #(parameter D_BITS = 8,
    parameter SB_TICKS = 16)
  ( output 				tx_data_o,
    output 				rx_empty_o,
    output				tx_full_o,
   output 	[D_BITS-1:0]rx_byte_o,
   input	[D_BITS-1:0]tx_byte_i,
   input 				tx_wrt_ena_i,
   input 				rx_rd_ena_i,
   input 				rx_data_i,
   input				clk_i,
   input 				reset_i);
  
  wire 				baud_tick;
  wire 	[D_BITS-1:0]rx_fsm_o;
  wire				rx_fsm_done;
  wire  [D_BITS-1:0]tx_fsm_i;
  wire 				tx_fifo_empty,tx_fsm_done;
  //Instantiating  Baud Rate Generator
  
  baud_rate_gen baud_inst(
    .done_o(baud_tick),
    .clk_i(clk_i),
    .reset_i(reset_i));
  
  rx_fifo rx_fifo_inst(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .empty_o(rx_empty_o),
    .rd_data_o(rx_byte_o),
    .rd_ena_i(rx_rd_ena_i),
    .wrt_data_i(rx_fsm_o),
    .wrt_ena_i(rx_fsm_done));
  
  tx_fifo tx_fifo_inst(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .empty_o(tx_fifo_empty),
    .full_o(tx_full_o),
    .rd_data_o(tx_fsm_i),
    .rd_ena_i(tx_fsm_done),
    .wrt_data_i(tx_byte_i),
    .wrt_ena_i(tx_wrt_ena_i));
  
  rx_fsm rx_fsm_inst(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .s_tick_i(baud_tick),
    .rx_data_i(rx_data_i),
    .rx_done_o(rx_fsm_done),
    .rx_byte_o(rx_fsm_o));
  
  tx_fsm tx_fsm_inst(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .s_tick_i(baud_tick),
    .tx_start_i(~tx_fifo_empty),
    .tx_data_i(tx_fsm_i),
    .tx_done_o(tx_fsm_done),
    .tx_data_o(tx_data_o));
  
endmodule