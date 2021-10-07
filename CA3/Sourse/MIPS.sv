`timescale 1ns/1ns
module mips(input clk, rst);
  logic equal, flush, MemRead, MemWrite, Mem_to_Reg, Reg_Write, Reg_Dst ,zero;
  logic [1:0] ALU_src, ALU_op, branch, pc_src;
  logic [2:0] ALU_operation;
  logic [5:0] function_ , OP_C;
  ALU_crtl ALU_C(ALU_op, function_, ALU_operation);
  Controller CU(equal, OP_C, flush, MemRead, MemWrite, Mem_to_Reg, Reg_Dst, Reg_Write, ALU_op, ALU_src, branch, pc_src);
  Datapath DP(clk, rst, flush, MemRead, MemWrite, Mem_to_Reg, Reg_Dst, Reg_Write, ALU_src, pc_src, ALU_operation, equal, zero, function_, OP_C);
endmodule

module Controller(input equal, input[5:0] opcode, output logic flush, Mem_Read, Mem_Write, Mem_to_Reg, Reg_Dst, Reg_Write, output logic [1:0] ALU_op , ALU_src, branch, Pc_src);
  initial Pc_src = 2'b00;
  always @(opcode) begin
    ALU_op = 2'b00; ALU_src = 2'b00; branch = 2'b00; flush = 1'b0; Mem_Read = 1'b0; Mem_Write = 1'b0; Mem_to_Reg = 1'b0; Reg_Dst = 1'b0; Reg_Write = 1'b0; Pc_src = 2'b00;
    case(opcode)
      6'b000000: begin ALU_op = 2'b10; Reg_Dst = 1'b1; Reg_Write = 1'b1; end //Rtype
      6'b001000: begin ALU_src = 2'b01; Reg_Write = 1'b1; end // addi
      6'b001010: begin ALU_src = 2'b01; ALU_op = 2'b11; Reg_Write = 1'b1; end // slti
      6'b100011: begin ALU_src = 2'b01; Mem_Read = 1;Mem_to_Reg = 1; Reg_Write = 1'b1; end // lw
      6'b101011: begin ALU_src = 2'b01;  Mem_Write = 1; end // sw
      6'b000010: begin flush = 1'b1; Pc_src = 2'b10; end // J
      6'b000011: begin Mem_to_Reg = 1; Reg_Dst = 1; Pc_src = 2'b10; end  // jal
      6'b000110: begin Pc_src = 2'b11; end // jr
      6'b000100: begin ALU_op = 2'b01; branch = 2'b01; if (equal) begin flush = 1'b1; Pc_src = 2'b01; end end // beq
      6'b000101: begin ALU_op = 2'b01; branch = 2'b10; if (~equal) begin flush = 1'b1; Pc_src = 2'b01; end end // bne
    endcase
  end
endmodule

module Datapath(input clk, rst, flush, Mem_Read_c, Mem_Write_c, Mem_to_Reg_c, Reg_Dst_c, Reg_Write_c, input[1:0] ALU_src_c, pc_src, input [2:0] ALU_operation_c, output equal, zero, output [5:0] function_ , opcode);
  logic forward, hazard, IFID_write, mem_to_reg_in, mem_read_out, mem_write_out, mem_to_reg_out, mem_read, mem_write, mem_to_reg, pc_write, reg_write, reg_dst, reg_write_out, reg_write_in;
  logic [1:0] alu_src, forwardA, forwardB, sel_src2;
  logic [2:0] alu_operation;
  logic [4:0] dst_1, dst_2, dstsel, regdst, Rs, Write_Reg, write1, write2;
  logic [5:0] OPC_out;
  logic [9:0] ctrl, ctrl_out;
  logic [31:0] four = {29'b0, 3'b100};
  logic [31:0] address, addout, ALUResult, A, B, d1, d2, instruction, jpc, jumpdst, jump_address, memdata, Read_Data1, Read_Data2, Read_Data, regdata, regin,
  Pcin, Pcout, pcadd, pc4, seout, shin, shout, Write_Data, Write_memData;
  
  assign ctrl = {Reg_Write_c,ALU_src_c,Mem_Read_c,Mem_Write_c, Mem_to_Reg_c,Reg_Dst_c,ALU_operation_c};
  assign function_ = regin[5:0];
  assign jump_address = {pc4[31:28], regin[25:0], 2'b0};
  assign opcode = regin[31:26];
  assign sel_src2 = forward ? forwardB : alu_src;
  Adder add1(four, Pcout, pcadd);
  Adder add2(pc4, shout, addout);
  ALU alu_M(A, B, alu_operation, zero, ALUResult);
  DataMemory DM(clk, mem_read, mem_write, address, Write_memData, Read_Data);
  EX_MEM EXM(clk, zero, reg_write_out, mem_read_out, mem_write_out, mem_to_reg_out, dstsel, addout, ALUResult, d2, reg_write_in, mem_read, mem_write,
   mem_to_reg_in, regdst, jumpdst, address, Write_memData);
  ForwardingUnit fu(reg_write_in, reg_write, Rs, dst_1, regdst, Write_Reg, OPC_out, forward, forwardA, forwardB);
  HazardUnit hu(mem_read_out, dst_1, regin[25:21], regin[20:16], regin[31:26], IFID_write, hazard, pc_write);
  ID_EX ID_M(clk, ctrl_out[9], ctrl_out[6], ctrl_out[5], ctrl_out[4], ctrl_out[3], ctrl_out[8:7], ctrl_out[2:0], regin[20:16], regin[15:11], regin[25:21], regin[31:26],
   pc4, Read_Data1, Read_Data2, seout, reg_dst, reg_write_out, mem_read_out, mem_write_out, mem_to_reg_out, alu_src, alu_operation, dst_1, dst_2, Rs, OPC_out, jpc, d1, d2, shin);
  IF_ID IF_M(clk, rst, IFID_write, flush , pcadd, instruction, regin, pc4);
  InstructionMemory IM(Pcout, instruction);
  MEM_WB MWB(clk, reg_write_in, mem_to_reg_in, regdst, address, Read_Data , reg_write, mem_to_reg, Write_Reg, memdata, regdata);
  Mux2to1_5bit M2_15(dst_1, dst_2, reg_dst, dstsel);
  Mux2to1_10bit m2_10(10'b0, ctrl, hazard, ctrl_out);
  Mux2to1_32bit m2_32(regdata, memdata, mem_to_reg, Write_Data);
  Mux3to1_32bit m3_32(d1, Write_Data, address, forwardA, A);
  Mux3to1_32bit m3_32_(pcadd, addout, jump_address, pc_src, Pcin);
  Mux4to1_32bit m4_32(d2, shin, Write_Data, address,sel_src2, B);
  PC PC_m(clk, rst, pc_write, Pcin, Pcout);
  RegisterFile RF(clk, reg_write, regin[25:21], regin[20:16] , Write_Reg, Write_Data, equal, Read_Data1, Read_Data2);
  ShiftLeft2 SL2(seout, shout);
  SignExtend SE(regin[15:0], seout);

endmodule