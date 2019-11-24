
module conv_16_4_16_1 ( clk, reset, s_data_in_x, s_valid_x, s_ready_x, 
        m_data_out_y, m_valid_y, m_ready_y );
  input [15:0] s_data_in_x;
  output [15:0] m_data_out_y;
  input clk, reset, s_valid_x, m_ready_y;
  output s_ready_x, m_valid_y;
  wire   \cx/overflow , \cc/hold_state , \cc/en_val_y , n611, n872, n873, n874,
         n875, n876, n877, n878, n879, n880, n881, n882, n883, n884, n886,
         n887, n888, n889, n890, n891, n892, n893, n894, n895, n896, n897,
         n898, n899, n900, n901, n902, n903, n904, n905, n906, n907, n908,
         n909, n910, n911, n912, n913, n914, n915, n916, n917, n918, n919,
         n920, n921, n922, n923, n924, n925, n926, n927, n928, n929, n930,
         n931, n932, n933, n934, n935, n936;
  wire   [3:0] w_write_addr_x;
  wire   [1:0] w_read_addr_f;
  wire   [3:0] \cc/number_x ;
  assign m_data_out_y[15] = 1'b0;
  assign m_data_out_y[14] = 1'b0;
  assign m_data_out_y[13] = 1'b0;
  assign m_data_out_y[12] = 1'b0;
  assign m_data_out_y[11] = 1'b0;
  assign m_data_out_y[10] = 1'b0;
  assign m_data_out_y[9] = 1'b0;
  assign m_data_out_y[8] = 1'b0;
  assign m_data_out_y[7] = 1'b0;
  assign m_data_out_y[6] = 1'b0;
  assign m_data_out_y[5] = 1'b0;
  assign m_data_out_y[4] = 1'b0;
  assign m_data_out_y[3] = 1'b0;
  assign m_data_out_y[2] = 1'b0;
  assign m_data_out_y[1] = 1'b0;
  assign m_data_out_y[0] = 1'b0;

  DFF_X1 \cc/m_addr_read_f_reg[0]  ( .D(n877), .CK(clk), .Q(w_read_addr_f[0])
         );
  DFF_X1 \cc/m_addr_read_f_reg[1]  ( .D(n876), .CK(clk), .Q(w_read_addr_f[1])
         );
  DFF_X1 \cc/en_val_y_reg  ( .D(n886), .CK(clk), .Q(\cc/en_val_y ) );
  DFF_X1 \cc/m_valid_y_reg  ( .D(n884), .CK(clk), .Q(m_valid_y), .QN(n935) );
  DFF_X1 \cc/number_x_reg[3]  ( .D(n872), .CK(clk), .Q(\cc/number_x [3]), .QN(
        n936) );
  DFF_X1 \cc/conv_done_reg  ( .D(n883), .CK(clk), .QN(n929) );
  DFF_X1 \cx/m_addr_x_reg[2]  ( .D(n878), .CK(clk), .Q(w_write_addr_x[2]), 
        .QN(n928) );
  DFF_X1 \cx/m_addr_x_reg[3]  ( .D(n882), .CK(clk), .Q(w_write_addr_x[3]) );
  DFF_X1 \cx/overflow_reg  ( .D(n881), .CK(clk), .Q(\cx/overflow ), .QN(n933)
         );
  DFF_X1 \cx/m_addr_x_reg[0]  ( .D(n880), .CK(clk), .Q(w_write_addr_x[0]), 
        .QN(n932) );
  DFF_X1 \cx/m_addr_x_reg[1]  ( .D(n879), .CK(clk), .Q(w_write_addr_x[1]), 
        .QN(n930) );
  DFF_X1 \cc/number_x_reg[0]  ( .D(n875), .CK(clk), .Q(\cc/number_x [0]), .QN(
        n931) );
  DFF_X1 \cc/number_x_reg[1]  ( .D(n874), .CK(clk), .Q(\cc/number_x [1]), .QN(
        n934) );
  DFF_X1 \cc/number_x_reg[2]  ( .D(n873), .CK(clk), .Q(\cc/number_x [2]) );
  DFF_X1 \cc/hold_state_reg  ( .D(n611), .CK(clk), .Q(\cc/hold_state ) );
  INV_X1 U961 ( .A(reset), .ZN(n926) );
  NAND2_X1 U962 ( .A1(w_read_addr_f[1]), .A2(w_read_addr_f[0]), .ZN(n888) );
  NAND3_X1 U963 ( .A1(\cc/number_x [3]), .A2(\cc/number_x [0]), .A3(
        \cc/number_x [2]), .ZN(n887) );
  OR4_X1 U964 ( .A1(\cc/hold_state ), .A2(n888), .A3(n934), .A4(n887), .ZN(
        n903) );
  NAND2_X1 U965 ( .A1(n926), .A2(n903), .ZN(n919) );
  INV_X1 U966 ( .A(n919), .ZN(n916) );
  INV_X1 U967 ( .A(n888), .ZN(n890) );
  NOR3_X1 U968 ( .A1(\cc/hold_state ), .A2(m_valid_y), .A3(\cc/en_val_y ), 
        .ZN(n889) );
  NAND2_X1 U969 ( .A1(n890), .A2(n889), .ZN(n918) );
  NAND2_X1 U970 ( .A1(n916), .A2(n918), .ZN(n894) );
  NOR4_X1 U971 ( .A1(\cc/hold_state ), .A2(m_valid_y), .A3(\cc/en_val_y ), 
        .A4(n933), .ZN(n893) );
  AOI21_X1 U972 ( .B1(w_read_addr_f[0]), .B2(n893), .A(w_read_addr_f[1]), .ZN(
        n891) );
  NOR2_X1 U973 ( .A1(n894), .A2(n891), .ZN(n876) );
  NOR2_X1 U974 ( .A1(w_read_addr_f[0]), .A2(n893), .ZN(n892) );
  AOI211_X1 U975 ( .C1(n893), .C2(w_read_addr_f[0]), .A(n892), .B(n894), .ZN(
        n877) );
  NOR2_X1 U976 ( .A1(reset), .A2(\cx/overflow ), .ZN(s_ready_x) );
  INV_X1 U992 ( .A(n894), .ZN(n924) );
  NAND3_X1 U993 ( .A1(\cc/number_x [1]), .A2(\cc/number_x [0]), .A3(n916), 
        .ZN(n895) );
  NOR2_X1 U994 ( .A1(n924), .A2(n895), .ZN(n897) );
  NAND4_X1 U995 ( .A1(\cc/number_x [1]), .A2(\cc/number_x [0]), .A3(
        \cc/number_x [2]), .A4(n916), .ZN(n923) );
  OAI21_X1 U996 ( .B1(n918), .B2(n923), .A(n916), .ZN(n922) );
  INV_X1 U997 ( .A(n922), .ZN(n896) );
  MUX2_X1 U998 ( .A(n897), .B(n896), .S(\cc/number_x [2]), .Z(n873) );
  NAND2_X1 U999 ( .A1(s_valid_x), .A2(s_ready_x), .ZN(n898) );
  INV_X1 U1000 ( .A(n898), .ZN(n904) );
  NAND2_X1 U1001 ( .A1(n932), .A2(n904), .ZN(n912) );
  OAI211_X1 U1002 ( .C1(n929), .C2(m_valid_y), .A(n898), .B(n926), .ZN(n913)
         );
  AND2_X1 U1003 ( .A1(n912), .A2(n913), .ZN(n915) );
  OAI21_X1 U1004 ( .B1(w_write_addr_x[1]), .B2(n898), .A(n915), .ZN(n905) );
  NAND2_X1 U1005 ( .A1(n904), .A2(w_write_addr_x[0]), .ZN(n914) );
  NOR2_X1 U1006 ( .A1(n914), .A2(n930), .ZN(n899) );
  MUX2_X1 U1007 ( .A(n905), .B(n899), .S(n928), .Z(n878) );
  NOR2_X1 U1009 ( .A1(reset), .A2(n918), .ZN(n886) );
  NOR2_X1 U1010 ( .A1(m_valid_y), .A2(\cc/en_val_y ), .ZN(n901) );
  AOI21_X1 U1011 ( .B1(m_valid_y), .B2(m_ready_y), .A(reset), .ZN(n900) );
  INV_X1 U1012 ( .A(n900), .ZN(n902) );
  NOR2_X1 U1013 ( .A1(n901), .A2(n902), .ZN(n884) );
  AOI21_X1 U1014 ( .B1(n903), .B2(n929), .A(n902), .ZN(n883) );
  OR2_X1 U1015 ( .A1(n914), .A2(w_write_addr_x[3]), .ZN(n907) );
  NAND2_X1 U1016 ( .A1(w_write_addr_x[1]), .A2(w_write_addr_x[2]), .ZN(n909)
         );
  AND2_X1 U1017 ( .A1(n904), .A2(w_write_addr_x[3]), .ZN(n908) );
  AOI22_X1 U1018 ( .A1(w_write_addr_x[3]), .A2(n905), .B1(n908), .B2(n928), 
        .ZN(n906) );
  OAI21_X1 U1019 ( .B1(n907), .B2(n909), .A(n906), .ZN(n882) );
  OAI21_X1 U1020 ( .B1(m_valid_y), .B2(n929), .A(n926), .ZN(n911) );
  NAND2_X1 U1021 ( .A1(n908), .A2(w_write_addr_x[0]), .ZN(n910) );
  OAI22_X1 U1022 ( .A1(n933), .A2(n911), .B1(n910), .B2(n909), .ZN(n881) );
  OAI21_X1 U1023 ( .B1(n932), .B2(n913), .A(n912), .ZN(n880) );
  AOI22_X1 U1024 ( .A1(w_write_addr_x[1]), .A2(n915), .B1(n914), .B2(n930), 
        .ZN(n879) );
  INV_X1 U1025 ( .A(n918), .ZN(n917) );
  OAI221_X1 U1026 ( .B1(n917), .B2(n931), .C1(n918), .C2(\cc/number_x [0]), 
        .A(n916), .ZN(n875) );
  NOR2_X1 U1027 ( .A1(n918), .A2(n931), .ZN(n921) );
  INV_X1 U1028 ( .A(n921), .ZN(n920) );
  AOI221_X1 U1029 ( .B1(\cc/number_x [1]), .B2(n921), .C1(n934), .C2(n920), 
        .A(n919), .ZN(n874) );
  OAI22_X1 U1030 ( .A1(n924), .A2(n923), .B1(n922), .B2(n936), .ZN(n872) );
  NOR2_X1 U1031 ( .A1(n935), .A2(m_ready_y), .ZN(n925) );
  OAI22_X1 U1032 ( .A1(n926), .A2(\cc/hold_state ), .B1(n925), .B2(reset), 
        .ZN(n927) );
  INV_X1 U1033 ( .A(n927), .ZN(n611) );
endmodule

