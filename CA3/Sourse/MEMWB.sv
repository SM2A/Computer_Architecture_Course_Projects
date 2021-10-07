`timescale 1ns/1ns
module MEM_WB(input clk, Reg_Write_in, Mem_to_Reg_in, input [4:0] reg_dst, input[31:0] Address, Read_Data, output logic Reg_Write_out, Mem_to_Reg_out, output logic [4:0] Write_Reg, output logic [31:0] mem_data, reg_data);
  always @(posedge clk) begin
    Mem_to_Reg_out <= Mem_to_Reg_in;
    mem_data <= Read_Data;
    Reg_Write_out <= Reg_Write_in;
    reg_data <= Address;
    Write_Reg <= reg_dst;
  end
endmodule