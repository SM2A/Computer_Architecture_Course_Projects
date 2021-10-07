module sign_extend (in , out);

    parameter N = 16;
    input [N-1:0]in;
    output [(2*N)-1:0]out;

    assign out = {{((2*N)-1){in[N-1]}},in};
    
endmodule

module mux2to1 (a,b,s,w);

    parameter N = 8;
    input [N-1:0]a;
    input [N-1:0]b;
    input s;
    output [N-1:0]w;

    assign w = (s==1'b0) ? a : b; 
    
endmodule

module mux3to1 (a,b,c,s,w);

    parameter N = 8;
    input [N-1:0]a;
    input [N-1:0]b;
    input [N-1:0]c;
    input [1:0]s;
    output reg [N-1:0]w;

    always @(a,b,c,s) begin
        case (s)
            2'b00 : w = a; 
            2'b01 : w = b; 
            2'b10 : w = c; 
        endcase
    end
    
endmodule

module adder (a,b,cin,result,cout);
    
    parameter N = 8;
    input [N-1:0]a;
    input [N-1:0]b;
    input cin;
    output cout;
    output [N-1:0]result;
    
    assign {cout,result} = a + b + cin; 

endmodule

module shl_e (in , out);

    input [25:0]in;
    output [27:0]out;

    assign out = {in , 2'b00};
    
endmodule

module shl_2 (in , out);

    input [31:0]in;
    output [31:0]out;

    assign out = in << 2;
    
endmodule

module register (clk,pin,ld,rst,pout);
    
    parameter N = 8;
    input clk;
    input ld;
    input rst;
    input [N-1:0]pin;
    output reg [N-1:0]pout;

    always @(posedge clk) begin
        if(rst) pout <= 0;
        else pout <= pin;
    end

endmodule
