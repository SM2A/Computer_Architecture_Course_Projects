`timescale 1ns/1ns

module testbench ();
    
    reg clk = 0 , rst = 1;
    
    processor test(clk,rst);

    always #10 clk = ~clk;
    initial begin
        #20 rst = 0;
        #5000 $stop;
    end

endmodule
