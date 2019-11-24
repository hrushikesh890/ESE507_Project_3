// ESE-507 Project 2, Fall 2019
// This simple testbench is provided to help you in testing Project 2, Part 1.
// This testbench is not sufficient to test the full correctness of your system, it's just
// a relatively small test to help you get started.

/*package get_max;
	let max(a,b) = (a > b) ? a : b;
endpackage*/

module conv_8_4_8_1_f_rom(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [7:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 8'd4;
        1: z <= 8'd8;
        2: z <= -8'd11;
        3: z <= -8'd13;
      endcase
   end
endmodule


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
    else if ((m_addr_x < (SIZE) && (overflow == 0)) /*|| (conv_done == 1 && valid_y == 0)*/) 
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
  parameter ADDR_X = 3, ADDR_F = 2; 
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
      if ((m_addr_read_f == (2**ADDR_F - 1)) && (hold_state == 0) && en_val_y == 0 && m_valid_y == 0) begin
        m_addr_read_x <= number_x;
        number_x <= number_x + 1;
        m_addr_read_f <= 0;
        en_val_y <= 1;
        //en_acc <= 0;
      end
      if ((number_x == (2**ADDR_X - 1)) && (m_addr_read_f == (2**ADDR_F - 1)) && hold_state != 1) begin
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
  parameter ADDR_X = 3, ADDR_F = 2; 
  import get_max::*;
  input clk, reset, en_acc, clr_acc;
  input [ADDR_X-1:0] m_addr_read_x;
  input [ADDR_F-1:0] m_addr_read_f;
  output logic signed [7:0] m_data_out_y;
  input signed [7:0] m_data_x;
  input signed [7:0] m_data_f;
  logic signed [15:0] w_mult_op;
  logic signed[17:0] w_addr_op;
  logic signed[7:0] w_real_mult_op;
  logic signed[7:0] w_real_addr_op;
  logic signed[7:0] max_val = (2**7)-1;
  logic signed [7:0] min_val = -1 * (2**7);
  logic signed [7:0] prev_output;

  always_comb begin
    if (reset) begin
      w_addr_op = 0;
      w_mult_op = 0;
      w_real_mult_op = 0;
      w_real_addr_op = 0;
      prev_output = 0;
      //m_data_out_y = 0;
    end
    else if (clr_acc) begin
      w_addr_op = 0;
      w_mult_op = 0;
      w_real_mult_op = 0;
      w_real_addr_op = 0;
      prev_output = 0;
      //m_data_out_y = 0;
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
      prev_output = w_real_addr_op;
    end
   else
    w_real_addr_op = m_data_out_y;
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

module conv_8_4_8_1(clk, reset, s_data_in_x, s_valid_x, s_ready_x, m_data_out_y, m_valid_y, m_ready_y);
  input clk, reset, s_valid_x, m_ready_y;
  input signed [7:0] s_data_in_x;
  output s_ready_x, m_valid_y;
  output signed [7:0] m_data_out_y;
  logic [7:0] w_to_multx, w_to_multf;
  logic w_wr_en_x, w_conv_done, w_read_done_x;
  logic [2:0] w_to_addrx, w_read_addr_x, w_write_addr_x;
  logic [1:0] w_to_addrf, w_read_addr_f;
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
  memory #(8, 8, 3) mx (.clk(clk), .data_in(s_data_in_x), .data_out(w_to_multx), .addr(w_to_addrx), .wr_en(w_wr_en_x));
  //memory #(8, 4, 2) mf (.clk(clk), .data_in(s_data_in_f), .data_out(w_to_multf), .addr(w_to_addrf), .wr_en(w_wr_en_f));

  conv_8_4_8_1_f_rom mf(.clk(clk), .addr(w_to_addrf), .z(w_to_multf));

  memory_control_xf #(3, 8) cx (.clk(clk), .reset(reset), .s_valid_x(s_valid_x), .s_ready_x(s_ready_x), .m_addr_x(w_write_addr_x), .ready_write(w_wr_en_x), .conv_done(w_conv_done), .read_done(w_read_done_x), .valid_y(m_valid_y));

 // memory_control_xf #(2, 4) cf (.clk(clk), .reset(reset), .s_valid_x(s_valid_f), .s_ready_x(s_ready_f), .m_addr_x(w_write_addr_f), .ready_write(w_wr_en_f), .conv_done(w_conv_done), .valid_y(m_valid_y), .wait_on_another(w_read_done_x)); 

  conv_control cc(.reset(reset), .clk(clk), .m_addr_read_x(w_read_addr_x), .m_addr_read_f(w_read_addr_f), .conv_done(w_conv_done), .read_done_x(w_read_done_x), .m_valid_y(m_valid_y), .m_ready_y(m_ready_y), .en_acc(e_acc), .clr_acc(c_acc));

  convolutioner conv(.clk(clk), .reset(reset), .m_addr_read_x(w_to_addrx), .m_addr_read_f(w_to_addrf), .m_data_out_y(m_data_out_y), .en_acc(e_acc), .clr_acc(c_acc), .m_data_x(w_to_multx), .m_data_f(w_to_multf));
endmodule


module tb_conv_8_4_8_1();

    parameter T = 8;
    parameter NUMINPUTVALS = 10000;
    parameter NUMOUTPUTVALS = 6250;
    parameter INFILENAME = "tb_conv_8_4_8_1.in";
    parameter EXPFILENAME = "tb_conv_8_4_8_1.exp";

    logic clk, s_valid_x, s_ready_x, m_valid_y, m_ready_y, reset;
    logic  [T-1:0] s_data_in_x;
    logic signed [T-1:0] m_data_out_y;

    logic signed [T-1:0] inValues [NUMINPUTVALS-1:0];
    logic signed [T-1:0] expValues [NUMOUTPUTVALS-1:0];
    logic s;

    initial clk=0;
    always #5 clk = ~clk;
    
    conv_8_4_8_1 dut(.clk(clk), .reset(reset), .s_data_in_x(s_data_in_x), .s_valid_x(s_valid_x), .s_ready_x(s_ready_x), .m_data_out_y(m_data_out_y), .m_valid_y(m_valid_y), .m_ready_y(m_ready_y));

    logic rb, rb2;
    always begin
        @(posedge clk);
        #1;
        s=std::randomize(rb, rb2);
    end

    logic [31:0] j;

    always @* begin
        if (s_valid_x == 1)
            s_data_in_x = inValues[j];
        else
            s_data_in_x = 'x;
    end

    always @* begin
        if ((j>=0) && (j<NUMINPUTVALS) && (rb==1'b1))
            s_valid_x=1;
        else
            s_valid_x=0;
    end

    always @(posedge clk) begin
        if (s_valid_x && s_ready_x)
            j <= #1 j+1;
    end
  
    logic [31:0] i;
    always @* begin
        if ((i>=0) && (i<NUMOUTPUTVALS) && (rb2==1'b1))
            m_ready_y = 1;
        else
            m_ready_y = 0;
    end

    integer errors = 0;

    always @(posedge clk) begin
        if (m_ready_y && m_valid_y) begin
            if (m_data_out_y !== expValues[i]) begin
                $display($time,,"ERROR: y[%d] = %x; expected value = %x", i, m_data_out_y, expValues[i]);
                errors = errors+1;
            end
            i=i+1; 
        end 
    end

    ////////////////////////////////////////////////////////////////////////////////

    initial begin
      $readmemb(INFILENAME, inValues);
      $readmemb(EXPFILENAME, expValues);
      
        j=0; i=0;

        // Before first clock edge, initialize
        m_ready_y = 0; 
        reset = 0;
    
        // reset
        @(posedge clk); #1; reset = 1; 
        @(posedge clk); #1; reset = 0; 

        wait(i==NUMOUTPUTVALS);
        $display("Simulated %d outputs. Found %d errors.", NUMOUTPUTVALS, errors);
        $finish;
    end


endmodule

