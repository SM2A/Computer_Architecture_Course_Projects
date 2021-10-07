module instruction_memory (address , instruction);

    input [31:0]address;
    output [31:0]instruction;

    reg [7:0]data[65535:0];

    assign instruction = {data[address+0],data[address+1],data[address+2],data[address+3]};

    initial $readmemb("instruction_memory.mem",data);
    // initial $readmemb("test.mem",data);
    
endmodule

module data_memory (clk,address,write_data,read_data,memwrite,memread);

    input clk , memwrite , memread;
    input [31:0]address;
    input [31:0]write_data;
    output [31:0]read_data;

    reg [7:0]data[65535:0];

    always @(posedge clk) begin
        if (memwrite) {data[address+0],data[address+1],data[address+2],data[address+3]} <= write_data;
    end

    assign read_data = (memread) ? {data[address+0],data[address+1],data[address+2],data[address+3]} : 32'bz;

    initial $readmemb("data_memory.mem",data);
    
endmodule

module register_file (clk,reg_write,read_reg_1,read_reg_2,write_reg,write_data,read_data_1,read_data_2);
    
    input reg_write , clk;
    input [31:0] write_data;
    input [4:0] read_reg_1 , read_reg_2 , write_reg;
    output [31:0] read_data_1 , read_data_2;

    reg [31:0]data[31:0];

    always @(posedge clk) begin
        if (reg_write) data[write_reg] <= write_data;
    end

    assign read_data_1 = data[read_reg_1];
    assign read_data_2 = data[read_reg_2];

    initial data[0] = 0;

endmodule
