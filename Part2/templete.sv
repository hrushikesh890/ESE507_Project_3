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

module memory_control_xf(clk, reset, s_valid_x, s_ready_x, m_addr_x, ready_write, read_done, hold_state, conv_done, valid_y);
  parameter LOGSIZE = 6, SIZE = 8;
  input clk, reset, s_valid_x, conv_done, valid_y, hold_state;
  output logic s_ready_x, read_done, ready_write;
  output logic [LOGSIZE - 1:0] m_addr_x;
  logic overflow;
  logic disable_read_done;
  int j;

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
    if (reset) begin
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
      disable_read_done <= 0;
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
    else if(hold_state)
      disable_read_done <= 1;
    else if(hold_state == 0 && disable_read_done == 1) begin
      read_done <= 0;
      disable_read_done <= 0;
    end        
  end
endmodule

module conv_control(reset, clk, m_addr_read_x, m_addr_read_f, conv_done, read_done_x, en_acc, clr_acc, hold_state, start_addr, valid_op);
  parameter ADDR_X = 3, ADDR_F = 2, LENX = 8, LENF = 4, P = 2; 
  input reset, clk, read_done_x, hold_state;
  output logic [ADDR_X-1:0] m_addr_read_x [P-1:0];
  output logic [ADDR_F-1:0] m_addr_read_f;
  output logic [ADDR_X-1:0] start_addr;
  output logic conv_done, valid_op;
  output logic [P-1:0] en_acc;
  output logic [P-1:0] clr_acc;
  logic [ADDR_X-1:0] number_x;
  int i;

  always_ff @(posedge clk) begin
    if (reset == 1) begin
      m_addr_read_f <= 0;
      for (i = 0; i < P; i++) begin
        m_addr_read_x[i] <= i;
        en_acc[i] <= 0;
        clr_acc[i] <= 1;
      end
      conv_done <= 0;
      number_x <= P;
      valid_op <= 0;
      start_addr <= 0;
    end
    else begin 
      if (read_done_x  && hold_state == 0) begin
        valid_op <= 0;
        for (i = 0; i < P; i++) begin
          en_acc[i] <= 1;
          clr_acc[i] <= 0;
        end
        for (i = 0; i < P; i++) begin
          m_addr_read_x[i] <= m_addr_read_x[i] + 1;
        end
        m_addr_read_f <= m_addr_read_f + 1;
      end
      if ((m_addr_read_f == (LENF - 1)) && (hold_state == 0)) begin
        valid_op <= 1;
        start_addr <= number_x - P;
        for (i = 0; i < P; i++) begin
          if ((number_x + i) < (LENX - LENF + 1))
            m_addr_read_x[i] <= number_x + i;
          else begin
            en_acc[i] <= 0;
            clr_acc[i] <= 1;
          end
        end
        number_x <= number_x + P;
        m_addr_read_f <= 0;
      end
      if ((number_x > (LENX - LENF + 1)) && (m_addr_read_f == (LENF - 1)) && hold_state != 1) begin
        conv_done <= 1;
        valid_op <= 1;
        for (i = 0; i < P; i++) begin
          en_acc[i] <= 0;
          clr_acc[i] <= 1;        
          m_addr_read_x[i] <= i;
        end
        m_addr_read_f <= 0;
        start_addr <= number_x - P;
        number_x <= P;
      end
      if (hold_state) begin
        for (i = 0; i < P; i++) begin
          en_acc[i] <= 0;
          clr_acc[i] <= 1;        
          m_addr_read_x[i] <= i;
        end
        m_addr_read_f <= 0;
        start_addr <= number_x - P;
        number_x <= P;
        conv_done <= 0;
      end
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
  logic signed [WIDTH-1:0] max_val = (2**(WIDTH-1))-1;
  logic signed [WIDTH-1:0] min_val = -1 * (2**(WIDTH-1));
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

module op_memory(clk, data_in, data_out, waddr, raddr, wr_en);
  parameter WIDTH=16, SIZE=64, LOGSIZE=6, P=2;
  input [WIDTH-1:0] data_in [P-1:0];
  output logic [WIDTH-1:0] data_out;
  input [LOGSIZE-1:0] waddr;
  input [LOGSIZE-1:0] raddr;
  input clk, wr_en;
  logic [SIZE-1:0][WIDTH-1:0] mem;
  int i;
  always_ff @(posedge clk) begin 
    data_out <= mem[raddr];
    if (wr_en)
      for (i = 0; i < P; i++) begin
        if (waddr + i < SIZE) begin
          mem[waddr + i] <= data_in[i];
        end
      end 
  end
endmodule

module output_control(clk, reset, conv_done, hold_state, m_valid_y, m_ready_y, start_addr, valid_op, wr_en, write_addr);
  parameter SIZE=5, P=2, LOGSIZE=2;
  input logic clk, reset, conv_done, m_ready_y, valid_op;
  input logic [LOGSIZE-1:0] start_addr;
  output logic hold_state, m_valid_y, wr_en;
  logic [LOGSIZE-1:0] read_addr; 
  output logic [LOGSIZE-1:0] write_addr;
  always_ff  @(posedge clk) begin
    if (reset) begin
      hold_state <= 0;
      read_addr <= 0;
      write_addr <= 0;
      wr_en <= 0;
    end
    else begin
      if (valid_op && hold_state == 0) begin
        wr_en <= 1;
        if (start_addr < (SIZE-1) - P)
          write_addr <= start_addr + P;
        else begin
          write_addr <= SIZE;
          if (read_addr != SIZE-1 && conv_done)
            hold_state <= 1;
        end
      end
      else
        wr_en <= 0;

      if (m_ready_y == 1) begin
        if (read_addr < write_addr) begin
          read_addr <= read_addr + 1;
        end
      end

      if (read_addr == SIZE) begin
        read_addr <= 0;
        write_addr <= 0;
        hold_state <= 0;
      end
    end
  end

  always_comb begin
    if (reset)
      m_valid_y = 0;
    else begin
      if ((read_addr < write_addr) && m_ready_y == 1)
        m_valid_y = 1;
      else
        m_valid_y = 0;
    end
  end
endmodule

module $modnamegen$(clk, reset, s_data_in_x, s_valid_x, s_ready_x, m_data_out_y, m_valid_y, m_ready_y);
  parameter WIDTH = $WIDTH$, ADDRX = $ADDRX$, ADDRF = $ADDRF$, LENX = $N$, LENF = $M$, P=$P$, SIZE = LENX - LENF + 1, LOGSIZE = ADDRX;
  input clk, reset, s_valid_x, m_ready_y;
  input signed [WIDTH-1:0] s_data_in_x;
  output s_ready_x, m_valid_y;
  output signed [WIDTH-1:0] m_data_out_y;
  logic [WIDTH-1:0] w_to_multx [P-1 : 0];
  logic [WIDTH-1:0] w_to_multf;
  logic w_wr_en_x, w_conv_done, w_read_done_x, w_hold_state, w_wr_en, w_valid_op;
  logic [ADDRX-1:0] w_to_addrx;  
  logic [ADDRX-1:0] w_read_addr_x [P-1:0]; 
  logic [ADDRX-1:0] w_write_addr_x;
  logic [ADDRF-1:0] w_to_addrf, w_read_addr_f;
  logic [ADDRX-1:0] w_start_addr;
  logic e_acc,c_acc;
  logic [P-1:0] w_en_acc, w_clr_acc;
  logic signed [WIDTH-1:0] conv_op [P-1:0];
  logic [ADDRX-1:0] w_read_addr_op;  

  genvar i;
  generate
    for (i = 0; i < P; i++) begin
      always_comb begin
       if (w_wr_en_x == 1)
         w_to_addrx = w_write_addr_x;
        else
          w_to_addrx = w_read_addr_x[i];
        w_to_addrf = w_read_addr_f;
      end 
      memory #(WIDTH, LENX, ADDRX) mx(.clk(clk), .data_in(s_data_in_x), .data_out(w_to_multx[i]), .addr(w_to_addrx), .wr_en(w_wr_en_x));
    end
  endgenerate

  $rommodname$ mf (.clk(clk), .addr(w_to_addrf), .z(w_to_multf));

  memory_control_xf #(ADDRX, LENX) cx (.clk(clk), .reset(reset), .s_valid_x(s_valid_x), .s_ready_x(s_ready_x), .m_addr_x(w_write_addr_x), .ready_write(w_wr_en_x), .read_done(w_read_done_x), .hold_state(w_hold_state), .valid_y(m_valid_y), .conv_done(w_conv_done));

  conv_control #(ADDRX, ADDRF, LENX, LENF, P) cc(.reset(reset), .clk(clk), .m_addr_read_x(w_read_addr_x), .m_addr_read_f(w_read_addr_f), .conv_done(w_conv_done), .read_done_x(w_read_done_x), .hold_state(w_hold_state), .en_acc(e_acc), .clr_acc(c_acc), .start_addr(w_start_addr), .valid_op(w_valid_op));


  genvar j;
  generate
  	for(j = 0; j < P; j++)
  		convolutioner #(WIDTH, ADDRX, ADDRF) mac_unit(.clk(clk), .reset(reset), .m_addr_read_x(w_to_addrx[j]), .m_addr_read_f(w_to_addrf), .m_data_out_y(conv_op[j]), .en_acc(w_en_acc[j]), .clr_acc(w_clr_acc[j]), .m_data_x(w_to_multx), .m_data_f(w_to_multf));
  endgenerate

  op_memory #(WIDTH,SIZE,LOGSIZE,P) om(.clk(clk), .data_in(conv_op), .data_out(m_data_out_y), .wr_en(w_wr_en), .waddr(w_start_addr), .raddr(w_read_addr_op));

  output_control #(SIZE,P,LOGSIZE) oc(.clk(clk), .reset(reset), .conv_done(w_conv_done), .hold_state(w_hold_state), .m_valid_y(m_valid_y), .m_ready_y(m_ready_y), .start_addr(w_start_addr), .valid_op(w_valid_op), .wr_en(w_wr_en), .read_addr(w_read_addr_op));

endmodule




