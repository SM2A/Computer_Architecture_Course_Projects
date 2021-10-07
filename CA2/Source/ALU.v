module alu_ctl (alu_operation , function_ , operation);

    input [1:0]alu_operation;
    input [5:0]function_;
    output reg [2:0]operation;

    always @(alu_operation , function_) begin
        operation <= 0;
        case(alu_operation)
            2'b00 : operation <= 3'b010; // LW , SW
            2'b01 : operation <= 3'b110; // BEQ , BNE
            2'b11 : operation <= 3'b111; // SLTI
            2'b10 : begin
                case(function_)
                    6'b100000 : operation <= 3'b010; // ADD
                    6'b100011 : operation <= 3'b110; // SUB
                    6'b101010 : operation <= 3'b111; // SLT
                    6'b001000 : operation <= 3'b001; // JR
                    default   : operation <= 3'b000;
                endcase
            end
        endcase
    end
     
endmodule

module alu (a,b,operation,zero,result);
    
    input [31:0]a;
    input [31:0]b;
    input [2:0]operation;
    output reg zero;
    output reg [31:0]result;

    reg [31:0]check;

    always @(a,b,operation) begin
        zero = 0;
        check = a - b;
        case (operation)
            3'b010 : result = a + b;
            3'b110 : result = check;
            3'b111 : result =  (check[31]) ? 32'd1 : 32'd0;
            default : result <= 32'b00000000000000000000000000000000;
        endcase
        if (result == 32'd0) zero = 1;
    end

endmodule
