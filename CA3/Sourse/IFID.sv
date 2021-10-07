`timescale 1ns/1ns
module IF_ID(input clk, rst, IFID_write, flush, input [31:0] pc_add, instruction, output logic [31:0] reg_in, pc_4);
  always @(posedge clk, posedge rst) begin
    if (rst) pc_4 <= 32'b0;
    else begin if (IFID_write) begin reg_in <= instruction; pc_4 <= pc_add; end if (flush) reg_in <=32'b0; end
  end
endmodule