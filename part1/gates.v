
module conv_8_4_8_1 ( clk, reset, s_data_in_x, s_valid_x, s_ready_x, 
        m_data_out_y, m_valid_y, m_ready_y );
  input [7:0] s_data_in_x;
  output [7:0] m_data_out_y;
  input clk, reset, s_valid_x, m_ready_y;
  output s_ready_x, m_valid_y;
  wire   w_conv_done, \cx/overflow , \cc/hold_state , \cc/en_val_y , n208,
         n276, n277, n278, n279, n280, n281, n282, n284, n285, n286, n288,
         n289, n290, n291, n292, n293, n294, n295, n296, n297, n298, n299,
         n300, n301, n302, n303, n304, n305, n306, n307, n308, n309, n310,
         n311, n312, n313, n314, n315, n316, n317, n318, n319, n320, n321,
         n322, n323, n324, n325, n326, n327, n328;
  wire   [2:0] w_write_addr_x;
  wire   [1:0] w_read_addr_f;
  wire   [2:0] \cc/number_x ;
  assign m_data_out_y[7] = 1'b0;
  assign m_data_out_y[6] = 1'b0;
  assign m_data_out_y[5] = 1'b0;
  assign m_data_out_y[4] = 1'b0;
  assign m_data_out_y[3] = 1'b0;
  assign m_data_out_y[2] = 1'b0;
  assign m_data_out_y[1] = 1'b0;
  assign m_data_out_y[0] = 1'b0;

  DFF_X1 \cc/m_addr_read_f_reg[0]  ( .D(n280), .CK(clk), .Q(w_read_addr_f[0])
         );
  DFF_X1 \cc/m_addr_read_f_reg[1]  ( .D(n279), .CK(clk), .Q(w_read_addr_f[1])
         );
  DFF_X1 \cc/en_val_y_reg  ( .D(n288), .CK(clk), .Q(\cc/en_val_y ) );
  DFF_X1 \cc/conv_done_reg  ( .D(n285), .CK(clk), .Q(w_conv_done) );
  DFF_X1 \cx/m_addr_x_reg[2]  ( .D(n284), .CK(clk), .Q(w_write_addr_x[2]) );
  DFF_X1 \cc/number_x_reg[1]  ( .D(n277), .CK(clk), .Q(\cc/number_x [1]) );
  DFF_X1 \cc/hold_state_reg  ( .D(n208), .CK(clk), .Q(\cc/hold_state ) );
  DFF_X1 \cc/m_valid_y_reg  ( .D(n286), .CK(clk), .Q(m_valid_y), .QN(n323) );
  DFF_X1 \cx/m_addr_x_reg[0]  ( .D(n282), .CK(clk), .Q(w_write_addr_x[0]), 
        .QN(n325) );
  DFF_X1 \cc/number_x_reg[0]  ( .D(n278), .CK(clk), .Q(\cc/number_x [0]), .QN(
        n322) );
  DFF_X1 \cx/m_addr_x_reg[1]  ( .D(n281), .CK(clk), .Q(w_write_addr_x[1]), 
        .QN(n324) );
  DFF_X1 \cx/overflow_reg  ( .D(n328), .CK(clk), .Q(n326), .QN(\cx/overflow )
         );
  DFF_X1 \cc/number_x_reg[2]  ( .D(n276), .CK(clk), .Q(\cc/number_x [2]), .QN(
        n327) );
  NOR2_X1 U320 ( .A1(reset), .A2(\cx/overflow ), .ZN(s_ready_x) );
  NOR4_X1 U321 ( .A1(\cc/hold_state ), .A2(m_valid_y), .A3(\cc/en_val_y ), 
        .A4(n326), .ZN(n311) );
  NOR2_X1 U322 ( .A1(w_read_addr_f[0]), .A2(n311), .ZN(n291) );
  NAND3_X1 U323 ( .A1(w_read_addr_f[0]), .A2(w_read_addr_f[1]), .A3(
        \cc/number_x [2]), .ZN(n289) );
  NOR4_X1 U324 ( .A1(\cc/hold_state ), .A2(\cc/number_x [1]), .A3(n322), .A4(
        n289), .ZN(n302) );
  NOR2_X1 U325 ( .A1(reset), .A2(n302), .ZN(n316) );
  NOR3_X1 U326 ( .A1(\cc/hold_state ), .A2(m_valid_y), .A3(\cc/en_val_y ), 
        .ZN(n290) );
  NAND3_X1 U327 ( .A1(n290), .A2(w_read_addr_f[0]), .A3(w_read_addr_f[1]), 
        .ZN(n317) );
  NAND2_X1 U328 ( .A1(n316), .A2(n317), .ZN(n318) );
  AOI211_X1 U329 ( .C1(w_read_addr_f[0]), .C2(n311), .A(n291), .B(n318), .ZN(
        n280) );
  NOR2_X1 U337 ( .A1(m_ready_y), .A2(n323), .ZN(n293) );
  INV_X1 U338 ( .A(reset), .ZN(n292) );
  MUX2_X1 U339 ( .A(\cc/hold_state ), .B(n293), .S(n292), .Z(n208) );
  NAND2_X1 U341 ( .A1(s_valid_x), .A2(s_ready_x), .ZN(n295) );
  INV_X1 U342 ( .A(n295), .ZN(n294) );
  NAND2_X1 U343 ( .A1(n294), .A2(w_write_addr_x[0]), .ZN(n309) );
  NOR2_X1 U344 ( .A1(n324), .A2(n309), .ZN(n304) );
  INV_X1 U345 ( .A(n304), .ZN(n298) );
  NAND2_X1 U346 ( .A1(n294), .A2(n325), .ZN(n306) );
  AOI21_X1 U347 ( .B1(w_conv_done), .B2(n323), .A(reset), .ZN(n305) );
  NAND2_X1 U348 ( .A1(n305), .A2(n295), .ZN(n307) );
  NAND2_X1 U349 ( .A1(n306), .A2(n307), .ZN(n308) );
  NOR2_X1 U350 ( .A1(w_write_addr_x[1]), .A2(n295), .ZN(n296) );
  OAI21_X1 U351 ( .B1(n308), .B2(n296), .A(w_write_addr_x[2]), .ZN(n297) );
  OAI21_X1 U352 ( .B1(w_write_addr_x[2]), .B2(n298), .A(n297), .ZN(n284) );
  NOR2_X1 U353 ( .A1(reset), .A2(n317), .ZN(n288) );
  NOR2_X1 U354 ( .A1(m_valid_y), .A2(\cc/en_val_y ), .ZN(n300) );
  AOI21_X1 U355 ( .B1(m_valid_y), .B2(m_ready_y), .A(reset), .ZN(n301) );
  INV_X1 U356 ( .A(n301), .ZN(n299) );
  NOR2_X1 U357 ( .A1(n300), .A2(n299), .ZN(n286) );
  OAI21_X1 U358 ( .B1(n302), .B2(w_conv_done), .A(n301), .ZN(n303) );
  INV_X1 U359 ( .A(n303), .ZN(n285) );
  AOI22_X1 U360 ( .A1(\cx/overflow ), .A2(n305), .B1(w_write_addr_x[2]), .B2(
        n304), .ZN(n328) );
  OAI21_X1 U361 ( .B1(n325), .B2(n307), .A(n306), .ZN(n282) );
  INV_X1 U362 ( .A(n308), .ZN(n310) );
  AOI22_X1 U363 ( .A1(w_write_addr_x[1]), .A2(n310), .B1(n309), .B2(n324), 
        .ZN(n281) );
  AOI21_X1 U364 ( .B1(w_read_addr_f[0]), .B2(n311), .A(w_read_addr_f[1]), .ZN(
        n312) );
  NOR2_X1 U365 ( .A1(n318), .A2(n312), .ZN(n279) );
  INV_X1 U366 ( .A(n317), .ZN(n313) );
  OAI221_X1 U367 ( .B1(n313), .B2(n322), .C1(n317), .C2(\cc/number_x [0]), .A(
        n316), .ZN(n278) );
  NOR2_X1 U368 ( .A1(n322), .A2(n317), .ZN(n315) );
  OAI21_X1 U369 ( .B1(\cc/number_x [1]), .B2(n315), .A(n316), .ZN(n314) );
  AOI21_X1 U370 ( .B1(\cc/number_x [1]), .B2(n315), .A(n314), .ZN(n277) );
  NAND3_X1 U371 ( .A1(\cc/number_x [1]), .A2(\cc/number_x [0]), .A3(n316), 
        .ZN(n320) );
  OAI21_X1 U372 ( .B1(n317), .B2(n320), .A(n316), .ZN(n321) );
  NAND2_X1 U373 ( .A1(n318), .A2(n327), .ZN(n319) );
  OAI22_X1 U374 ( .A1(n321), .A2(n327), .B1(n320), .B2(n319), .ZN(n276) );
endmodule

