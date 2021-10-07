`timescale 1 ns/1ns
module DataMemory(input clk, Mem_Read, Mem_Write, input [31:0] Address, Write_Data, output logic[31:0] Read_Data);
  logic [31:0] data[0:7999];
  initial $readmemb("numbers.txt", data, 250);
  always@(posedge clk) begin if(Mem_Write) data[Address[31:2]] <= Write_Data; end
  assign Read_Data = (Mem_Read) ? data[Address[31:2]] : 32'bz;
endmodule
    
module InstructionMemory(input [31:0] address, output logic [31:0] instruction);
  logic [31:0] data[0:199];
  initial $readmemb("Instruction.txt", data);
  assign instruction = data[address[31:2]];
endmodule

module RegisterFile(input clk, Reg_Write, input[4:0] Read_Reg1, Read_Reg2, Write_Reg, input[31:0] Write_Data, output equal, output logic [31:0] Read_Data1, Read_Data2);          
  logic [31:0] Registers [0:31];
  initial Registers[0] = 32'b0;
  always@(negedge clk) begin if (Reg_Write) Registers[Write_Reg] <= Write_Data; end 
  assign Read_Data1 = Registers[Read_Reg1];
  assign Read_Data2 = Registers[Read_Reg2];
  assign equal = (Read_Data1 == Read_Data2) ? 1 : 0;
endmodule  