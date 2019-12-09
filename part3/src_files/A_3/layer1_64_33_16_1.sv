module layer1_64_33_16_1_f_rom(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd237;
        1: z <= 16'd169;
        2: z <= 16'd225;
        3: z <= -16'd82;
        4: z <= -16'd15;
        5: z <= -16'd134;
        6: z <= 16'd51;
        7: z <= 16'd226;
        8: z <= 16'd15;
        9: z <= -16'd36;
        10: z <= 16'd200;
        11: z <= 16'd150;
        12: z <= -16'd143;
        13: z <= -16'd24;
        14: z <= 16'd110;
        15: z <= -16'd46;
        16: z <= 16'd18;
        17: z <= 16'd219;
        18: z <= 16'd178;
        19: z <= 16'd187;
        20: z <= 16'd231;
        21: z <= 16'd150;
        22: z <= 16'd208;
        23: z <= 16'd181;
        24: z <= 16'd32;
        25: z <= -16'd247;
        26: z <= 16'd188;
        27: z <= -16'd242;
        28: z <= -16'd210;
        29: z <= -16'd55;
        30: z <= 16'd170;
        31: z <= -16'd190;
        32: z <= -16'd142;
      endcase
   end
endmodule


module layer1_64_33_16_1(clk, reset, s_data_in_x, s_valid_x, s_ready_x, m_data_out_y, m_valid_y, m_ready_y);
  parameter WIDTH = 16, ADDRX = 6, ADDRF = 6, LENX = 64, LENF = 33, P=1, SIZE = LENX - LENF + 1, LOGSIZE = ADDRX;
  input clk, reset, s_valid_x, m_ready_y;
  input signed [WIDTH-1:0] s_data_in_x;
  output s_ready_x, m_valid_y;
  output signed [WIDTH-1:0] m_data_out_y;
  logic [WIDTH-1:0] w_to_multx, w_to_multf;
  logic w_wr_en_x, w_conv_done, w_read_done_x;
  logic [ADDRX-1:0] w_to_addrx, w_read_addr_x, w_write_addr_x;
  logic [ADDRF-1:0] w_to_addrf, w_read_addr_f;
  logic e_acc,c_acc;

  always_comb begin
    if (w_wr_en_x == 1)
      w_to_addrx = w_write_addr_x;
    else
      w_to_addrx = w_read_addr_x;
    if (w_wr_en_x == 1)
      w_to_addrf = 0;
    else
      w_to_addrf = w_read_addr_f;
  end
  memory1 #(WIDTH, LENX, ADDRX) mx (.clk(clk), .data_in(s_data_in_x), .data_out(w_to_multx), .addr(w_to_addrx), .wr_en(w_wr_en_x));

  layer1_64_33_16_1_f_rom mf(.clk(clk), .addr(w_to_addrf), .z(w_to_multf));

  memory_control_xf1 #(ADDRX, LENX) cx (.clk(clk), .reset(reset), .s_valid_x(s_valid_x), .s_ready_x(s_ready_x), .m_addr_x(w_write_addr_x), .ready_write(w_wr_en_x), .conv_done(w_conv_done), .read_done(w_read_done_x), .valid_y(m_valid_y));

  conv_control1 #(ADDRX, ADDRF, LENX, LENF) cc(.reset(reset), .clk(clk), .m_addr_read_x(w_read_addr_x), .m_addr_read_f(w_read_addr_f), .conv_done(w_conv_done), .read_done_x(w_read_done_x), .m_valid_y(m_valid_y), .m_ready_y(m_ready_y), .en_acc(e_acc), .clr_acc(c_acc));

  convolutioner1 #(WIDTH, ADDRX, ADDRF) conv(.clk(clk), .reset(reset), .m_addr_read_x(w_to_addrx), .m_addr_read_f(w_to_addrf), .m_data_out_y(m_data_out_y), .en_acc(e_acc), .clr_acc(c_acc), .m_data_x(w_to_multx), .m_data_f(w_to_multf));
endmodule