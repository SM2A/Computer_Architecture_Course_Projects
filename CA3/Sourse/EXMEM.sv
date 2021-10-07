`timescale 1ns/1ns
module EX_MEM(input clk, zero, Reg_Write_o, Mem_Read_o, Mem_Write_o, Mem_to_Reg_o, input[4:0] dstsel, input[31:0] addout, ALU_Result, dst2, output logic Reg_Write_in, Mem_Read, Mem_Write, Mem_to_Reg_in, output logic [4:0] Reg_Dst, output logic [31:0] Jump_Dst, Address, Write_Data);
  always @(posedge clk) begin
    Address <= ALU_Result;
    Jump_Dst <= addout;
    Mem_Read <= Mem_Read_o;
    Mem_Write <= Mem_Write_o;
    Mem_to_Reg_in <= Mem_to_Reg_o;
    Reg_Dst <= dstsel;
    Reg_Write_in <= Reg_Write_o;
    Write_Data <= dst2;
  end
endmodule
    
