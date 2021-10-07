module data_path (clk,rst,jr,jump,alu_src,pc_src,reg_write,mem_to_reg,alu_operation,reg_dst,write_data,
                  instruction,data_in,instruction_address,data_address,data_out,zero);
    
    input [2:0]alu_operation;
    input [31:0]instruction,data_in;
    input [1:0]reg_dst , write_data;
    input clk , rst , jr , jump , alu_src , pc_src , reg_write , mem_to_reg;

    output zero;
    output [31:0]instruction_address , data_address,data_out;

    wire [4:0] mux_1_out;
    wire [27:0]shl_out_28;
    wire [31:0]shl_out_32;
    wire [31:0]pc_out , alu_out;
    wire [31:0]sign_extend_out , read_data_1 , read_data_2 , adder_1_out , adder_2_out;
    wire [31:0]mux_2_out , mux_3_out , mux_4_out , mux_5_out , mux_6_in , mux_6_out , mux_7_out;

    assign data_out = read_data_2; // data to write to memro file
    assign data_address = alu_out; // address of data to write to memry file
    assign instruction_address = pc_out; // PC
    assign mux_6_in = {adder_1_out[31:28],shl_out_28}; // combine wires

    shl_2 shl2(sign_extend_out,shl_out_32); // shift left by 2 (*=4)
    shl_e shle(instruction[25:0],shl_out_28); // shift left by 2 and extend from 26 to 28 (*=4)

    adder #(32) adder_1(pc_out,32'd4,1'b0,adder_1_out); // add instruction by 4
    adder #(32) adder_2(adder_1_out,shl_out_32,1'b0,adder_2_out); // branch instruction adder 

    register #(32) pc(clk,mux_7_out,1'b1,rst,pc_out); // PC
    register_file reg_file(clk,reg_write,instruction[25:21],instruction[20:16],mux_1_out,mux_5_out,read_data_1,read_data_2); // registe file

    alu _alu_(read_data_1,mux_2_out,alu_operation,zero,alu_out); // ALU
    sign_extend #(16) sgn_ext(instruction[15:0],sign_extend_out); // sign extend

    mux3to1 #(32) mux_5(mux_4_out,adder_1_out,alu_out,write_data,mux_5_out); // input data to write to register file
    mux3to1 #(5)  mux_1(instruction[20:16],instruction[15:11],5'b11111,reg_dst,mux_1_out); // input register address to write data to register file 

    mux2to1 #(32) mux_6(mux_6_in,read_data_1,jr,mux_6_out); // JR - jump register - mux
    mux2to1 #(32) mux_7(mux_3_out,mux_6_out,jump,mux_7_out); // J - jump - mux
    mux2to1 #(32) mux_4(alu_out,data_in,mem_to_reg,mux_4_out); // data feed to register file mux
    mux2to1 #(32) mux_3(adder_1_out,adder_2_out,pc_src,mux_3_out); // PC source mex - (PC + 4 , J , Jr)
    mux2to1 #(32) mux_2(read_data_2,sign_extend_out,alu_src,mux_2_out); // ALU source mux

endmodule

module controller (zero,opcode,function_,operation,mem_to_reg,reg_write,alu_src,memread,memwrite,pc_src,
                   jr,jump,reg_dst,write_data);

    input zero;
    input [5:0]opcode , function_;

    output pc_src;
    output [2:0]operation;
    output reg [1:0]reg_dst , write_data;
    output reg mem_to_reg , reg_write , alu_src , memread , memwrite , jr , jump;

    reg branch , branch_not_equal;
    reg [1:0]alu_operation;

    mux3to1 #(1) mux_8 (1'b0,~zero,zero,{branch,branch_not_equal},pc_src); // Branch - Branch not equal

    alu_ctl aluctl(alu_operation,function_,operation);

    always @(opcode) begin
        branch = 0 ; mem_to_reg = 0 ; reg_write = 0 ; alu_src = 0 ; memread = 0 ; memwrite = 0 ; alu_operation = 0 ;
        jr = 0 ; jump = 0 ; reg_dst = 0 ; write_data = 0 ; branch_not_equal = 0 ;
        case (opcode)
            6'b000000 : begin // R-Type - SLT - JR
                if (operation == 3'b001) begin jr = 1'b1 ; jump = 1'b1 ; end // JR - jump register
                else begin reg_dst = 2'b01 ; reg_write = 1 ; alu_operation = 2'b10 ; end // R-Type
            end 
            6'b001000 : begin reg_write = 1 ; alu_src = 1 ; end // ADDI - add immediate
            6'b100011 : begin alu_src = 1 ; mem_to_reg = 1 ; reg_write = 1 ; memread = 1 ; end // LW - load word
            6'b101011 : begin alu_src = 1 ; memwrite = 1 ; end // SW - store word
            6'b000010 : begin jump = 1 ; end // J - jump
            6'b000011 : begin reg_dst = 2'b10 ; write_data = 2'b01 ; jump = 1 ; end // JAL - jump and link
            6'b000100 : begin branch = 1 ; alu_operation = 2'b01 ; end  // BEQ - brand equal
            6'b000101 : begin branch_not_equal = 1 ; alu_operation = 2'b01 ; end // BNE - branch not equal
            6'b001010 : begin reg_write = 1 ; alu_src = 1 ; alu_operation = 2'b11 ; write_data = 2'b10 ; end // SLTI - set on less than immediate
        endcase
    end

endmodule

module mips (clk,rst,instruction,data_in,memread,memwrite,instruction_address,data_address,data_out);
    
    input clk , rst ;
    input [31:0]instruction , data_in;

    output memread , memwrite;
    output [31:0]instruction_address , data_address , data_out;

    wire [2:0]alu_operation;
    wire [1:0]reg_dst , write_data;
    wire mem_to_reg , alu_src , pc_src , reg_write , zero , jr , jump;

    data_path dp(clk,rst,jr,jump,alu_src,pc_src,reg_write,mem_to_reg,alu_operation,reg_dst,write_data,
                 instruction,data_in,instruction_address,data_address,data_out,zero);

    controller ct(zero,instruction[31:26],instruction[5:0],alu_operation,mem_to_reg,reg_write,alu_src,memread,memwrite,
                  pc_src,jr,jump,reg_dst,write_data);

endmodule

module processor (clk , rst);
    
    input clk , rst;

    wire memread , memwrite;
    wire [31:0]instruction , instruction_address , data_address , data_in , data_out;

    instruction_memory im(instruction_address,instruction); // Instructions
    data_memory dm(clk,data_address,data_out,data_in,memwrite,memread); // Data
    mips process(clk,rst,instruction,data_in,memread,memwrite,instruction_address,data_address,data_out); // Processing unit

endmodule
