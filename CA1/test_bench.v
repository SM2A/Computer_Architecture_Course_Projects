`timescale 1ns/1ns

module TB_STD();
    
    reg clk = 0 , start = 0;
    reg [11:0]AQ;
    reg [5:0]DIV;

    reg [11:0]ALL_AQ[0:7];
    reg [5:0]ALL_DIV[0:7];

    wire ready;
    wire [5:0]remainder;
    wire [5:0]quotient;

    divider test(clk,start,AQ,DIV,remainder,quotient,ready);

    integer i = 0;

    always #25 clk = ~clk;
    initial begin

        ALL_AQ[0]  = 12'b000001001011; // Q = 001100 ; R = 000011
        ALL_DIV[0] = 6'b000110;

        ALL_AQ[1]  = 12'b001011110001; // Q = 011001 ; R = 011100
        ALL_DIV[1] = 6'b011101;

        ALL_AQ[2]  = 12'b000011110000; // Q = 011000 ; R = 000000
        ALL_DIV[2] = 6'b001010;

        ALL_AQ[3]  = 12'b001000011000; // Q = 011111 ; R = 001001
        ALL_DIV[3] = 6'b010001;

        ALL_AQ[4]  = 12'b001111011111; // Q = 011111 ; R = 011110
        ALL_DIV[4] = 6'b011111;

        ALL_AQ[5]  = 12'b000000011111; // Q = 000001 ; R = 000000
        ALL_DIV[5] = 6'b011111;

        ALL_AQ[6]  = 12'b000000011111; // Q = 011111 ; R = 000000
        ALL_DIV[6] = 6'b000001;

        ALL_AQ[7]  = 12'b000000011111; // Q = 001111 ; R = 000001
        ALL_DIV[7] = 6'b000010;

        for (i = 0 ; i < 8 ; i = i + 1 ) begin
            AQ = ALL_AQ[i];
            DIV = ALL_DIV[i];
            #100 start = 1;
            #100 start = 0;
            #2300 ;
        end
        #500 $stop;
    end

endmodule

module TB_TA();
    
    reg clk = 0 , start = 0;
    reg [11:0]AQ = 12'b000000011111;
    reg [5:0]DIV = 6'b000010;

    wire ready;
    wire [5:0]remainder;
    wire [5:0]quotient;

    divider test(clk,start,AQ,DIV,remainder,quotient,ready);

    always #25 clk = ~clk;
    initial begin
        #100 start = 1;
        #100 start = 0;
        #2500 $stop;
    end

endmodule
