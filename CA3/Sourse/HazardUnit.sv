`timescale 1ns/1ns
module HazardUnit(input IDEX_mem_Read, input[4:0] IDEX_Rt, Rs, Rt, input [5:0] OPC, output logic IFID_write, hazard, pc_write);
  initial{IFID_write, hazard, pc_write} = 3'b111;
  always @(IDEX_mem_Read, Rs, Rt, IDEX_Rt) begin
    hazard = 1'b1;
    pc_write = 1'b1;
    IFID_write = 1'b1;
    if(IDEX_mem_Read) begin if((IDEX_Rt == Rt && OPC == 6'b0) || IDEX_Rt == Rs) begin {IFID_write, hazard, pc_write} = 3'b0; end end
  end
endmodule
