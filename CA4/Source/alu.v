module ALU (a,b,alop,out);

    input [7:0]a,b;
    input [2:0]alop;
    output reg [7:0]out;

    always @(a,b,alop) begin
        case (alop)
            3'b000 : out = a + b; 
            3'b001 : out = a - b; 
            3'b010 : out = a & b; 
            3'b011 : out = ~a; 
        endcase
    end
    
endmodule
