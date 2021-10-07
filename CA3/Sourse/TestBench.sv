`timescale 1ns/1ns
module TestBench();
  logic clk = 0, rst;
  mips UUT(clk, rst);
  always #10 clk = ~clk;
  initial begin
    rst = 1;
    #4 rst = 0;
    #20000 $stop;
  end
endmodule