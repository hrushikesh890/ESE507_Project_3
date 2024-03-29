$$ROM$$
module memory(clk, data_in, data_out, addr, wr_en);
  parameter WIDTH=16, SIZE=64, LOGSIZE=6;
  input [WIDTH-1:0] data_in;
  output logic [WIDTH-1:0] data_out;
  input [LOGSIZE-1:0] addr;
  input clk, wr_en;
  logic [SIZE-1:0][WIDTH-1:0] mem;
  always_ff @(posedge clk) begin 
    data_out <= mem[addr];
    if (wr_en)
      mem[addr] <= data_in; 
  end
endmodule

module memory_control_xf(clk, reset, s_valid_x, s_ready_x, m_addr_x, ready_write, conv_done, read_done, valid_y);
  parameter LOGSIZE = 6, SIZE = 8;
  input clk, reset, s_valid_x, conv_done, valid_y;
  output logic s_ready_x, read_done, ready_write;
  output logic [LOGSIZE - 1:0] m_addr_x;
  logic overflow;

  always_comb begin
    if (reset) begin 
      ready_write = 0;
    end
    else if (s_ready_x == 1 && s_valid_x == 1 && read_done == 0)
      ready_write = 1;
    else
      ready_write = 0;
  end

  always_comb begin
    if (reset || overflow) 
      s_ready_x = 0;
    else if ((m_addr_x < (SIZE) && (overflow == 0))) 
      s_ready_x = 1;
    else
      s_ready_x = 0;
  end

  always_ff @(posedge clk) begin
    if (reset) begin;
      m_addr_x <= 0;
      
    end
    else  if (ready_write == 1) begin
        m_addr_x <= m_addr_x + 1;
      end
    else if (conv_done == 1 && valid_y == 0) begin
          m_addr_x <= 0;
      end
    end

  always_ff @(posedge clk) begin
    if (reset) begin
      overflow <= 0;
      read_done <= 0;
    end
    else if (conv_done == 1 && ready_write == 0  && valid_y == 0) begin
      overflow <= 0;
      read_done <= 0;
    end    
    else if (m_addr_x == (SIZE-1) && (ready_write == 1)) begin
      overflow <= 1;
      read_done <= 1;
    end
  end
endmodule

module conv_control(reset, clk, m_addr_read_x, m_addr_read_f, conv_done, read_done_x, m_valid_y, m_ready_y, en_acc, clr_acc);
  parameter ADDR_X = 3, ADDR_F = 2, LENX = 8, LENF = 4; 
  input reset, clk, read_done_x, m_ready_y;
  output logic [ADDR_X-1:0] m_addr_read_x;
  output logic [ADDR_F-1:0] m_addr_read_f;
  output logic conv_done, m_valid_y, en_acc, clr_acc;
  logic hold_state, en_val_y;
  logic [ADDR_X-1:0] number_x;

  always_ff @(posedge clk) begin
    if (reset == 1) begin
      m_addr_read_f <= 0;
      m_addr_read_x <= 0;
      conv_done <= 0;
      m_valid_y <= 0;
      en_acc <= 0;
      clr_acc <= 1;
      number_x <= 1;
      en_val_y <= 0;
    end
    else begin 
      
      if (read_done_x  && hold_state == 0 && m_valid_y == 0 && en_val_y == 0) begin
        en_acc <= 1;
        clr_acc <= 0;
        m_addr_read_x <= m_addr_read_x + 1;
        m_addr_read_f <= m_addr_read_f + 1;
      end
      if ((m_addr_read_f == (LENF - 1)) && (hold_state == 0) && en_val_y == 0 && m_valid_y == 0) begin
        m_addr_read_x <= number_x;
        number_x <= number_x + 1;
        m_addr_read_f <= 0;
        en_val_y <= 1;
        //en_acc <= 0;
      end
      if ((number_x == (LENX - LENF + 1)) && (m_addr_read_f == (LENF - 1)) && hold_state != 1) begin
        conv_done <= 1;
        en_acc <= 0;        
        m_addr_read_x <= 0;
        m_addr_read_f <= 0;
        number_x <= 1;
      end
      if (en_val_y) begin
        m_valid_y <= 1;
        en_val_y <= 0;
        en_acc <= 0;
      end
      if ((m_valid_y == 1) && (m_ready_y == 0)) begin
        hold_state <= 1;
        en_acc <= 0;
      end
      else begin
        hold_state <= 0;
        en_acc <= 1;
       //clr_acc <= 0;
      end
      if ((m_valid_y == 1) && (m_ready_y == 1)) begin
        m_valid_y <= 0;
        conv_done <= 0;
        clr_acc <= 1;
      end
      if (en_val_y == 1)
        en_acc <= 0;
    end
  end
endmodule

module convolutioner(clk, reset, m_addr_read_x, m_addr_read_f, m_data_out_y, en_acc, clr_acc, m_data_x, m_data_f);
  parameter WIDTH = 8,ADDR_X = 3, ADDR_F = 2; 
  input clk, reset, en_acc, clr_acc;
  input [ADDR_X-1:0] m_addr_read_x;
  input [ADDR_F-1:0] m_addr_read_f;
  output logic signed [WIDTH-1:0] m_data_out_y;
  input signed [WIDTH-1:0] m_data_x;
  input signed [WIDTH-1:0] m_data_f;
  logic signed [2*WIDTH-1:0] w_mult_op;
  logic signed [(2*WIDTH-1)+ADDR_F:0] w_addr_op;
  logic signed [WIDTH-1:0] w_real_mult_op;
  logic signed [WIDTH-1:0] w_real_addr_op;
  logic signed [WIDTH-1:0] max_val;
  logic signed [WIDTH-1:0] min_val;
  assign max_val = (2**(WIDTH-1))-1;
  assign min_val = -1 * (2**(WIDTH-1));
  logic signed [WIDTH-1:0] prev_output;

  always_comb begin
    if (reset) begin
      w_addr_op = 0;
      w_mult_op = 0;
      w_real_mult_op = 0;
      w_real_addr_op = 0;
    end
    else if (clr_acc) begin
      w_addr_op = 0;
      w_mult_op = 0;
      w_real_mult_op = 0;
      w_real_addr_op = 0;
    end
    else if (en_acc) begin
      w_mult_op = m_data_x * m_data_f;
      if(w_mult_op > max_val)
      	w_real_mult_op = max_val;
      else if(w_mult_op < min_val)
      	w_real_mult_op = min_val;
      else
      	w_real_mult_op = w_mult_op;
      w_addr_op = w_real_mult_op + prev_output;
      if(w_addr_op > max_val)
      	w_real_addr_op = max_val;
      else if(w_addr_op < min_val)
      	w_real_addr_op = min_val;
      else
      	w_real_addr_op = w_addr_op;
    end
   else
    w_real_addr_op = m_data_out_y;
  end

  always_ff @(posedge clk) begin
    if(reset || clr_acc)
      prev_output <= 0;
    else if(en_acc)
      prev_output <= w_real_addr_op;
    else
      prev_output <= 0;
  end

  always_ff @(posedge clk) begin
    if (reset || (clr_acc == 1) || w_real_addr_op <= 0)
    	m_data_out_y <= 0;
    else if (en_acc)
    	m_data_out_y <= w_real_addr_op;
    else
    	m_data_out_y <= m_data_out_y;
  end
endmodule

module $modnamegen$(clk, reset, s_data_in_x, s_valid_x, s_ready_x, m_data_out_y, m_valid_y, m_ready_y);
  parameter WIDTH = $WIDTH$, ADDRX = $ADDRX$, ADDRF = $ADDRF$, LENX = $N$, LENF = $M$, P=$P$, SIZE = LENX - LENF + 1, LOGSIZE = ADDRX;
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
  memory #(WIDTH, LENX, ADDRX) mx (.clk(clk), .data_in(s_data_in_x), .data_out(w_to_multx), .addr(w_to_addrx), .wr_en(w_wr_en_x));

  $rommodname$ mf(.clk(clk), .addr(w_to_addrf), .z(w_to_multf));

  memory_control_xf #(ADDRX, LENX) cx (.clk(clk), .reset(reset), .s_valid_x(s_valid_x), .s_ready_x(s_ready_x), .m_addr_x(w_write_addr_x), .ready_write(w_wr_en_x), .conv_done(w_conv_done), .read_done(w_read_done_x), .valid_y(m_valid_y));

  conv_control #(ADDRX, ADDRF, LENX, LENF) cc(.reset(reset), .clk(clk), .m_addr_read_x(w_read_addr_x), .m_addr_read_f(w_read_addr_f), .conv_done(w_conv_done), .read_done_x(w_read_done_x), .m_valid_y(m_valid_y), .m_ready_y(m_ready_y), .en_acc(e_acc), .clr_acc(c_acc));

  convolutioner #(WIDTH, ADDRX, ADDRF) conv(.clk(clk), .reset(reset), .m_addr_read_x(w_to_addrx), .m_addr_read_f(w_to_addrf), .m_data_out_y(m_data_out_y), .en_acc(e_acc), .clr_acc(c_acc), .m_data_x(w_to_multx), .m_data_f(w_to_multf));
endmodule