`timescale 1ns/1ns
module ALU(input[31:0] inp1, inp2, input[2:0] ALU_operation, output logic zero, output logic [31:0] out);
  logic [31:0]sub;
  always @(inp1, inp2, ALU_operation) begin
    {out, zero} = 33'b0;
    sub = inp1 - inp2;
    case (ALU_operation)
      3'b010: out = inp1 + inp2;
      3'b110: out = sub;
      3'b111: out = (sub[31]) ? 32'd1 : 32'd0;
      default : out <= 32'b00000000000000000000000000000000;
    endcase
    if (out == 32'd0) zero = 1;
  end
endmodule 

module ALU_crtl(input [1:0] ALUop, input[5:0] function_, output logic[2:0] ALU_operation);
  always @(ALUop, function_) begin
    case(ALUop)
      2'b00: ALU_operation = 3'b010; // lw , sw
      2'b01: ALU_operation = 3'b110; // beq , bne
      2'b11: ALU_operation = 3'b111; // slti
      2'b10: begin // Rtype
        case(function_)
          6'b100000: ALU_operation = 3'b010; // add
          6'b100010: ALU_operation = 3'b110; // sub
          6'b101010: ALU_operation = 3'b111; // slt
          default: ALU_operation = 3'b000;
        endcase
      end
      default: ALU_operation = 3'b000;
    endcase
  end
endmodule