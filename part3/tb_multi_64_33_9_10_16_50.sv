module multi_64_33_9_10_16_50(clk, reset, s_data_in_x, s_valid_x, s_ready_x, m_data_out_y, m_valid_y, m_ready_y);
parameter WIDTH = 16;
input clk, reset, s_valid_x, m_ready_y;
input signed [WIDTH-1:0] s_data_in_x;
output s_ready_x, m_valid_y;
output signed [WIDTH-1:0] m_data_out_y;

logic l1_valid, l1_ready, l2_valid, l2_ready;
logic signed [WIDTH-1:0] l1_data;
logic signed [WIDTH-1:0] l2_data;

layer1_64_33_16_32 m1(.clk(clk), .reset(reset), .s_data_in_x(s_data_in_x), .s_valid_x(s_valid_x), .s_ready_x(s_ready_x), .m_data_out_y(l1_data), .m_valid_y(l1_valid), .m_ready_y(l1_ready)); 
layer2_32_9_16_12 m2(.clk(clk), .reset(reset), .s_data_in_x(l1_data), .s_valid_x(l1_valid), .s_ready_x(l1_ready), .m_data_out_y(l2_data), .m_valid_y(l2_valid), .m_ready_y(l2_ready));
layer3_24_10_16_5 m3(.clk(clk), .reset(reset), .s_data_in_x(l2_data), .s_valid_x(l2_valid), .s_ready_x(l2_ready), .m_data_out_y(m_data_out_y), .m_valid_y(m_valid_y), .m_ready_y(m_ready_y));

endmodule
module tb_multi_64_33_9_10_16_50();

    parameter T = 16;
    parameter NUMINPUTVALS = 9984;
    parameter NUMOUTPUTVALS = 2340;
    parameter INFILENAME = "tb_multi_64_33_9_10_16_50.in";
    parameter EXPFILENAME = "tb_multi_64_33_9_10_16_50.exp";

    logic clk, s_valid_x, s_ready_x, m_valid_y, m_ready_y, reset;
    logic  [T-1:0] s_data_in_x;
    logic signed [T-1:0] m_data_out_y;

    logic signed [T-1:0] inValues [NUMINPUTVALS-1:0];
    logic signed [T-1:0] expValues [NUMOUTPUTVALS-1:0];
    logic s;

    initial clk=0;
    always #5 clk = ~clk;
    
    multi_64_33_9_10_16_50 dut(clk, reset, s_data_in_x, s_valid_x, s_ready_x, m_data_out_y, m_valid_y, m_ready_y);

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
