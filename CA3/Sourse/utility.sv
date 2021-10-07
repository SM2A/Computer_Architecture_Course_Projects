`timescale 1ns/1ns
module Adder(input[31:0] a, b, output[31:0] out);
  assign out = a + b;
endmodule

module Mux2to1_5bit(input[4:0] a, b,input select, output[4:0] out);
  assign out = select ? b : a;
endmodule

module Mux2to1_10bit(input [9:0] a, b, input select, output[9:0] out);
  assign out = select ? b : a;
endmodule

module Mux2to1_32bit(input [31:0] a, b, input select, output[31:0] out);
  assign out = select ? b : a;
endmodule

module Mux3to1_32bit(input [31:0] a, b, c, input[1:0] select, output[31:0] out);
  assign out = select[1] ? c : (select[0] ? b : a);
endmodule

module Mux4to1_32bit(input[31:0] a, b, c, d, input[1:0] select, output[31:0] out);
  assign out = select[1] ? (select[0] ? d : c) : (select[0] ? b : a);
endmodule

module ShiftLeft2(input [31:0] inp, output [31:0] out);
  assign out = {inp[29:0] , 2'b00};
endmodule

module SignExtend(input [15:0] inp, output[31:0] out);
  assign out = {{16{inp[15]}}, inp};
endmodule

module PC(input clk, rst, pc_write, input [31:0] inp, output logic[31:0] out);
  initial out = 32'b0;
  always @(posedge clk, posedge rst) begin
    if (rst) out <= 32'b0;
    else if (pc_write == 1) out <= inp;
  end
endmodule