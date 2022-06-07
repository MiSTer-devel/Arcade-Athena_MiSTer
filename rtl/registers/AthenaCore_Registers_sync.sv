//AthenaCore_Registers_sync.sv
//Author: @RndMnkIII
//Date: 25/05/2022
`default_nettype none
`timescale 1ns/1ps


module AthenaCore_Registers_sync(
  input wire VIDEO_RSTn,
  input wire reset,
  input wire clk,
  input wire MSB,
  input wire [7:0] VD_in, //VD_in data bus

  //Register MSB bits 7,6,4,3,1,0
  output logic INV, //Flip screen, in real pcb two LS368 chained gates
  output logic INVn,
  output logic SIDE_ROM_BK,
  output logic B1X8,
  output logic FX8,
  output logic B1Y8,
  output logic FY8,

  input wire COIN_COUNTERS,
  output logic COIN1_CNT,
  output logic COIN2_CNT,

  input wire FSY,
  output logic [7:0] FY
);
    reg [7:0] vdin_r;

     always @(posedge clk) begin
        vdin_r <= VD_in;
    end

    logic b11_inv, a4_dum5, a4_dum2;
    ttl_74273_sync A4(.RESETn(reset), .CLRn(1'b1), .Clk(clk), .Cen(MSB), .D(vdin_r), .Q({b11_inv, SIDE_ROM_BK, a4_dum5, B1X8, FX8, a4_dum2, B1Y8, FY8}));

    //debug B1Y8
    // always @( posedge MSB) begin
    //     $display("MSB:%06b",VD_in[5:0]);
    // end
    assign INV = b11_inv; //add delay for two inverter buffer LS368 chained gates
    assign INVn = ~b11_inv; //add delay for one inverter buffer LS368 gate

    //Coin counters, goes to EDGE22 CONN pins 29,30. 
    logic [3:0] a2_dummy;
    ttl_74174_sync A2
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(COIN_COUNTERS),
        .Clr_n(1'b1),
        .D(vdin_r[5:0]),
        .Q({a2_dummy,COIN2_CNT,COIN1_CNT})
    );

    ttl_74273_sync B8(.RESETn(reset), .CLRn(1'b1), .Clk(clk), .Cen(FSY), .D(vdin_r), .Q(FY));
endmodule