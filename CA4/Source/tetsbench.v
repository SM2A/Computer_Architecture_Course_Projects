`timescale 1ns/1ns

module testbench ();
    
    reg clk = 0 , rst = 1;

    mips test(clk,rst);

    always #10 clk = ~clk;
    initial begin
        #20 rst = 0;
        #10000 $stop;
    end

endmodule
