module multi_8_4_3_2_8_10();
   // this module should instantiate three convolution modules and wire them together
endmodule
module layer1_8_4_8_1();
   // your stuff here!
endmodule

module layer1_8_4_8_1_f_rom(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [7:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 8'd7;
        1: z <= 8'd5;
        2: z <= -8'd5;
        3: z <= -8'd6;
      endcase
   end
endmodule

module layer2_5_3_8_1();
   // your stuff here!
endmodule

module layer2_5_3_8_1_f_rom(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [7:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 8'd6;
        1: z <= -8'd3;
        2: z <= 8'd11;
      endcase
   end
endmodule

module layer3_3_2_8_1();
   // your stuff here!
endmodule

module layer3_3_2_8_1_f_rom(clk, addr, z);
   input clk;
   input [0:0] addr;
   output logic signed [7:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 8'd3;
        1: z <= 8'd12;
      endcase
   end
endmodule

