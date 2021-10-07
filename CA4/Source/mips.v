module datapath (clk,pc_ld,ins_ld,data_ld,a_ld,b_ld,jump,address_s,data_s,pcp,memwrite,memread,push,pop,tos,rst,alop,opcode,zero);
    
    input [2:0]alop;
    input clk,pc_ld,ins_ld,data_ld,a_ld,b_ld,jump,address_s,data_s,pcp,memwrite,memread,push,pop,tos,rst;

    output zero;
    output [2:0]opcode;

    wire [4:0]pc_in,pc_out,address,u_address;
    wire [7:0]mem_out,instruction,mdr_out,d_in,d_out,a,b,alu_a,alu_b,alu_out,res_out;

    register #(8) ir(clk,mem_out,ins_ld,rst,instruction);
    register #(8) mdr(clk,mem_out,data_ld,rst,mdr_out);
    register #(8) ar(clk,d_out,a_ld,rst,a);
    register #(8) br(clk,d_out,b_ld,rst,b);
    register #(8) alu_reg(clk,alu_out,1'b1,rst,res_out);
    register #(5) pc(clk,pc_in,pc_ld,rst,pc_out);

    ALU alu_(alu_a,alu_b,alop,alu_out);
    stack stack_(clk,push,pop,tos,d_in,d_out);
    memory mem(clk,address,a,mem_out,memwrite,memread);

    assign zero = (a==8'b00000000);
    assign opcode = instruction[7:5];
    assign u_address = instruction[4:0];
    assign alu_a = pcp ? pc_out : a;
    assign alu_b = pcp ? 1 : b;
    assign d_in = data_s ? mdr_out : res_out;
    assign pc_in = jump ? u_address : alu_out;
    assign address = address_s ? u_address : pc_out;

endmodule

module controller (clk,rst,zero,opcode,alop,pc_ld,ins_ld,data_ld,a_ld,b_ld,jump,address_s,data_s,pcp,memwrite,memread,push,pop,tos);
    
    input clk,rst,zero;
    input [2:0]opcode;
    
    output reg [2:0]alop;
    output reg pc_ld,ins_ld,data_ld,a_ld,b_ld,jump,address_s,data_s,pcp,memwrite,memread,push,pop,tos;

    reg [3:0]ps,ns;

    always @(ps,zero,opcode,posedge clk) begin
        case(ps)
            0 : ns <= 1;
            1 : ns <= 2;
            2 : begin
                case(opcode)
                    3'b000 : ns <= 3;
                    3'b001 : ns <= 3;
                    3'b010 : ns <= 3;
                    3'b011 : ns <= 5;
                    3'b100 : ns <= 8;
                    3'b101 : ns <= 11;
                    3'b110 : ns <= 13;
                    3'b111 : ns <= 3;
                endcase
            end
            3 : begin
                    if(opcode == 3'b111) ns <= zero ? 13 : 0;
                    else ns <= 4;
            end
            4 : ns <= 6;
            5 : ns <= 6;
            6 : ns <= 7;
            7 : ns <= 0;
            8 : ns <= 9;
            9 : ns <= 10;
            10 : ns <= 0;
            11 : ns <= 12;
            12 : ns <= 0;
            13 : ns <= 0;
            default: ns <= 0;
        endcase
    end

    always @(ps) begin
        pc_ld = 0 ; ins_ld = 0 ; data_ld = 0 ; a_ld = 0 ; b_ld = 0 ; jump = 0 ; address_s = 0 ;
        pcp = 0 ; memwrite = 0 ; memread = 0 ; push = 0 ; pop = 0 ; tos = 0 ; alop = 0 ; data_s = 0 ;

        case(ps)
            0 : memread <= 1;
            1 : begin pc_ld = 1 ; pcp = 1 ; ins_ld = 1 ; end
            3 : begin pop = 1 ; a_ld = 1 ; end
            4 : begin b_ld = 1 ; pop = 1 ; alop = (opcode == 3'b111) ? 0 : opcode ; end 
            5 : begin pop = 1 ; a_ld = 1 ; alop = 3'b011; end
            7 : push = 1;
            8 : begin address_s = 1 ; memread = 1 ; end
            9 : data_ld = 1;
            10 : begin push = 1 ; data_s = 1 ; end
            11 : begin pop = 1 ; a_ld = 1 ; address_s = 1 ; end
            12 : begin memwrite = 1 ; address_s = 1 ; end
            13 : begin jump = 1 ; pc_ld = 1 ; end
        endcase
    end

    always @(posedge clk) begin
        if (rst) ps = 0;
        else ps <= ns;
    end

endmodule

module mips (clk , rst);

    input clk , rst;

    wire [2:0]alop,opcode;
    wire zero,pc_ld,ins_ld,data_ld,a_ld,b_ld,jump,address_s,data_s,pcp,memwrite,memread,push,pop,tos;

    datapath dp(.clk(clk),.pc_ld(pc_ld),.ins_ld(ins_ld),.data_ld(data_ld),.a_ld(a_ld),.b_ld(b_ld),.jump(jump),
                .address_s(address_s),.data_s(data_s),.pcp(pcp),.memwrite(memwrite),.memread(memread),.push(push),
                .pop(pop),.tos(tos),.rst(rst),.alop(alop),.opcode(opcode),.zero(zero));

    controller ct(.clk(clk),.rst(rst),.zero(zero),.opcode(opcode),.alop(alop),.pc_ld(pc_ld),.ins_ld(ins_ld),
                  .data_ld(data_ld),.a_ld(a_ld),.b_ld(b_ld),.jump(jump),.address_s(address_s),.data_s(data_s),
                  .pcp(pcp),.memwrite(memwrite),.memread(memread),.push(push),.pop(pop),.tos(tos));

endmodule
