//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor:        Xilinx
// \   \   \/    Version:       1.0.0
//  \   \        Filename:      vtc_demo_720p.v
//  /   /        Date Created:  April 8, 2009
// /___/   /\    Author:        Bob Feng   
// \   \  /  \
//  \___\/\___\
//
// Devices:   Spartan-6 Generation FPGA
// Purpose:   SP601 board demo top level
// Contact:   
// Reference: None
//
// Revision History:
// 
//
//////////////////////////////////////////////////////////////////////////////
//
// LIMITED WARRANTY AND DISCLAIMER. These designs are provided to you "as is".
// Xilinx and its licensors make and you receive no warranties or conditions,
// express, implied, statutory or otherwise, and Xilinx specifically disclaims
// any implied warranties of merchantability, non-infringement, or fitness for
// a particular purpose. Xilinx does not warrant that the functions contained
// in these designs will meet your requirements, or that the operation of
// these designs will be uninterrupted or error free, or that defects in the
// designs will be corrected. Furthermore, Xilinx does not warrant or make any
// representations regarding use or the results of the use of the designs in
// terms of correctness, accuracy, reliability, or otherwise.
//
// LIMITATION OF LIABILITY. In no event will Xilinx or its licensors be liable
// for any loss of data, lost profits, cost or procurement of substitute goods
// or services, or for any special, incidental, consequential, or indirect
// damages arising from the use or operation of the designs or accompanying
// documentation, however caused and on any theory of liability. This
// limitation will apply even if Xilinx has been advised of the possibility
// of such damage. This limitation shall apply not-withstanding the failure
// of the essential purpose of any limited remedies herein.
//
//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

// AKU: locked to 1280*720 resolution

module hdmiTx720p #(parameter simulation=0) 
 (
  input  wire RSTBTN, // high active !

  //input  wire clk,
  

	// timing + data
	input wire	clkfx,
	output wire pclk,
   input wire pclk_lckd,
	
	output wire reset,
   output wire [10:0] bgnd_hcount,
   output wire [10:0] bgnd_vcount,
	input wire [7:0] red_data,
	input wire [7:0] blue_data,
	input wire [7:0] green_data,
	// 
  output wire [3:0] TMDS,
  output wire [3:0] TMDSB
);


  //******************************************************************//
  // Create global clock and synchronous system reset.                //
  //******************************************************************//
  //wire locked;

  //wire pclk_lckd;

  //
  // DCM_CLKGEN to generate a pixel clock with a fixed frequency 74MHz
  //
  
  //wire			 clkfx_unused;



  wire pllclk0, pllclk1, pllclk2;
  wire pclkx2, pclkx10, pll_lckd;
  wire clkfbout;

  //
  // Pixel Rate clock buffer
  //
  BUFG pclkbufg (.I(pllclk1), .O(pclk));

  //////////////////////////////////////////////////////////////////
  // 2x pclk is going to be used to drive OSERDES2
  // on the GCLK side
  //////////////////////////////////////////////////////////////////
  BUFG pclkx2bufg (.I(pllclk2), .O(pclkx2));

  //////////////////////////////////////////////////////////////////
  // 10x pclk is used to drive IOCLK network so a bit rate reference
  // can be used by OSERDES2
  //////////////////////////////////////////////////////////////////
  PLL_BASE # (
    .CLKIN_PERIOD(13),
    .CLKFBOUT_MULT(10), //set VCO to 10x of CLKIN
    .CLKOUT0_DIVIDE(1),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT2_DIVIDE(5),
    .COMPENSATION("INTERNAL")
  ) PLL_OSERDES (
    .CLKFBOUT(clkfbout),
    .CLKOUT0(pllclk0),
    .CLKOUT1(pllclk1),
    .CLKOUT2(pllclk2),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .LOCKED(pll_lckd),
    .CLKFBIN(clkfbout),
    .CLKIN(clkfx),
    .RST(~pclk_lckd)
  );

  wire serdesstrobe;
  wire bufpll_lock;
  BUFPLL #(.DIVIDE(5)) ioclk_buf (.PLLIN(pllclk0), .GCLK(pclkx2), .LOCKED(pll_lckd),
           .IOCLK(pclkx10), .SERDESSTROBE(serdesstrobe), .LOCK(bufpll_lock));

  synchro #(.INITIALIZE("LOGIC1"))
  synchro_rstbt (.async(!pll_lckd),.sync(reset),.clk(pclk));

///////////////////////////////////////////////////////////////////////////
// Video Timing Parameters
///////////////////////////////////////////////////////////////////////////

  //1280x720@60HZ
  parameter HPIXELS_HDTV720P = 11'd1280; //Horizontal Live Pixels
  parameter VLINES_HDTV720P  = 11'd720;  //Vertical Live ines
  parameter HSYNCPW_HDTV720P = 11'd80;  //HSYNC Pulse Width
  parameter VSYNCPW_HDTV720P = 11'd5;    //VSYNC Pulse Width
  parameter HFNPRCH_HDTV720P = 11'd72;   //Horizontal Front Portch
  parameter VFNPRCH_HDTV720P = 11'd3;    //Vertical Front Portch
  parameter HBKPRCH_HDTV720P = 11'd216;  //Horizontal Front Portch
  parameter VBKPRCH_HDTV720P = 11'd22;   //Vertical Front Portch


  reg [10:0] tc_hsblnk;
  reg [10:0] tc_hssync;
  reg [10:0] tc_hesync;
  reg [10:0] tc_heblnk;
  reg [10:0] tc_vsblnk;
  reg [10:0] tc_vssync;
  reg [10:0] tc_vesync;
  reg [10:0] tc_veblnk;

  reg hvsync_polarity; //1-Negative, 0-Positive
  always @ (*)
  begin
        hvsync_polarity = 1'b0;

        tc_hsblnk = HPIXELS_HDTV720P - 11'd1;
        tc_hssync = HPIXELS_HDTV720P - 11'd1 + HFNPRCH_HDTV720P;
        tc_hesync = HPIXELS_HDTV720P - 11'd1 + HFNPRCH_HDTV720P + HSYNCPW_HDTV720P;
        tc_heblnk = HPIXELS_HDTV720P - 11'd1 + HFNPRCH_HDTV720P + HSYNCPW_HDTV720P + HBKPRCH_HDTV720P;
        tc_vsblnk =  VLINES_HDTV720P - 11'd1;
        tc_vssync =  VLINES_HDTV720P - 11'd1 + VFNPRCH_HDTV720P;
        tc_vesync =  VLINES_HDTV720P - 11'd1 + VFNPRCH_HDTV720P + VSYNCPW_HDTV720P;
        tc_veblnk =  VLINES_HDTV720P - 11'd1 + VFNPRCH_HDTV720P + VSYNCPW_HDTV720P + VBKPRCH_HDTV720P;
  end

  wire VGA_HSYNC_INT, VGA_VSYNC_INT;
//  wire   [10:0] bgnd_hcount;
  wire          bgnd_hsync;
  wire          bgnd_hblnk;
//  wire   [10:0] bgnd_vcount;
  wire          bgnd_vsync;
  wire          bgnd_vblnk;

  timing timing_inst (
    .tc_hsblnk(tc_hsblnk), //input
    .tc_hssync(tc_hssync), //input
    .tc_hesync(tc_hesync), //input
    .tc_heblnk(tc_heblnk), //input
    .hcount(bgnd_hcount), //output
    .hsync(VGA_HSYNC_INT), //output
    .hblnk(bgnd_hblnk), //output
    .tc_vsblnk(tc_vsblnk), //input
    .tc_vssync(tc_vssync), //input
    .tc_vesync(tc_vesync), //input
    .tc_veblnk(tc_veblnk), //input
    .vcount(bgnd_vcount), //output
    .vsync(VGA_VSYNC_INT), //output
    .vblnk(bgnd_vblnk), //output
    .restart(reset),
    .clk(pclk));

  /////////////////////////////////////////
  // V/H SYNC and DE generator
  /////////////////////////////////////////
  assign active = !bgnd_hblnk && !bgnd_vblnk;

  reg active_q;
  reg vsync, hsync;
  reg VGA_HSYNC, VGA_VSYNC;
  reg de;

  always @ (posedge pclk)
  begin
    hsync <= VGA_HSYNC_INT ^ hvsync_polarity ;
    vsync <= VGA_VSYNC_INT ^ hvsync_polarity ;
    VGA_HSYNC <= hsync;
    VGA_VSYNC <= vsync;

    active_q <= active;
    de <= active_q;
  end

  ///////////////////////////////////
  // Video pattern generator:
  //   SMPTE HD Color Bar
  ///////////////////////////////////
//  wire [7:0] red_data, green_data, blue_data;


//`endif
  ////////////////////////////////////////////////////////////////
  // DVI Encoder
  ////////////////////////////////////////////////////////////////
  wire [4:0] tmds_data0, tmds_data1, tmds_data2;

  dvi_encoder enc0 (
    .clkin      (pclk),
    .clkx2in    (pclkx2),
    .rstin      (reset),
    .blue_din   (blue_data),
    .green_din  (green_data),
    .red_din    (red_data),
    .hsync      (VGA_HSYNC),
    .vsync      (VGA_VSYNC),
    .de         (de),
    .tmds_data0 (tmds_data0),
    .tmds_data1 (tmds_data1),
    .tmds_data2 (tmds_data2));


  wire [2:0] tmdsint;

  wire serdes_rst = RSTBTN | ~bufpll_lock;


  serdes_n_to_1 #(.SF(5)) oserdes0 (
             .ioclk(pclkx10),
             .serdesstrobe(serdesstrobe),
             .reset(serdes_rst),
             .gclk(pclkx2),
             .datain(tmds_data0),
             .iob_data_out(tmdsint[0])) ;

  serdes_n_to_1 #(.SF(5)) oserdes1 (
             .ioclk(pclkx10),
             .serdesstrobe(serdesstrobe),
             .reset(serdes_rst),
             .gclk(pclkx2),
             .datain(tmds_data1),
             .iob_data_out(tmdsint[1])) ;

  serdes_n_to_1 #(.SF(5)) oserdes2 (
             .ioclk(pclkx10),
             .serdesstrobe(serdesstrobe),
             .reset(serdes_rst),
             .gclk(pclkx2),
             .datain(tmds_data2),
             .iob_data_out(tmdsint[2])) ;

  OBUFDS TMDS0 (.I(tmdsint[0]), .O(TMDS[0]), .OB(TMDSB[0])) ;
  OBUFDS TMDS1 (.I(tmdsint[1]), .O(TMDS[1]), .OB(TMDSB[1])) ;
  OBUFDS TMDS2 (.I(tmdsint[2]), .O(TMDS[2]), .OB(TMDSB[2])) ;


  reg [4:0] tmdsclkint = 5'b00000;
  reg toggle = 1'b0;

  always @ (posedge pclkx2 or posedge serdes_rst) begin
    if (serdes_rst)
      toggle <= 1'b0;
    else
      toggle <= ~toggle;
  end

  always @ (posedge pclkx2) begin
    if (toggle)
      tmdsclkint <= 5'b11111;
    else
      tmdsclkint <= 5'b00000;
  end

  wire tmdsclk;

  serdes_n_to_1 #(
    .SF           (5))
  clkout (
    .iob_data_out (tmdsclk),
    .ioclk        (pclkx10),
    .serdesstrobe (serdesstrobe),
    .gclk         (pclkx2),
    .reset        (serdes_rst),
    .datain       (tmdsclkint));

  OBUFDS TMDS3 (.I(tmdsclk), .O(TMDS[3]), .OB(TMDSB[3])) ;// clock


endmodule
