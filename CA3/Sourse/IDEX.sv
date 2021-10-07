`timescale 1ns/1ns
module ID_EX (input clk, Reg_Write_in, Mem_Read_in, Mem_Write_in, Mem_to_Reg_in, Reg_Dst_in, input[1:0] ALU_src_in, input [2:0] ALU_operation_in, input[4:0] write_1, write_2, Rs_in, input [5:0] OP_C, input [31:0] pc_4, Read_Data_1, Read_Data_2, se_out,
              output logic Reg_Dst, Reg_Write_out, Mem_Read_out, Mem_Write_out, Mem_to_Reg_out, output logic [1:0] ALU_src, output logic [2:0] ALU_operation, output logic [4:0] dst_1, dst_2, Rs, output logic [5:0] op_code , output logic [31:0] jump_c, data_1, data_2, sh_in);
  always @(posedge clk) begin
    ALU_src <= ALU_src_in;
    ALU_operation <= ALU_operation_in;
    data_1 <= Read_Data_1;
    data_2 <= Read_Data_2;
    dst_1 <= write_1;
    dst_2 <= write_2;
    jump_c <= pc_4;
    Mem_Read_out <= Mem_Read_in;
    Mem_Write_out <= Mem_Write_in;
    Mem_to_Reg_out <= Mem_to_Reg_in;
    op_code <= OP_C;
    Reg_Dst <= Reg_Dst_in;
    Rs <= Rs_in;
    Reg_Write_out <= Reg_Write_in;
    sh_in <= se_out;   
  end
endmodule 
