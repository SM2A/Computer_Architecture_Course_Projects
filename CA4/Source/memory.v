module register (clk,pin,ld,rst,pout);
    
    parameter N = 8;
    input clk;
    input ld;
    input rst;
    input [N-1:0]pin;
    output reg [N-1:0]pout;

    always @(posedge clk) begin
        if(rst) pout <= 0;
        else begin
            if (ld) pout <= pin;
            else pout <= pout;
        end
    end

endmodule

module memory (clk,address,write_data,read_data,memwrite,memread);

    input clk , memwrite , memread;
    input [4:0]address;
    input [7:0]write_data;
    output reg [7:0]read_data;

    reg [7:0]data[31:0];

    always @(posedge clk) begin
        if (memwrite) data[address] <= write_data;
        if (memread) read_data <= data[address];
    end

    initial $readmemb("memory.mem",data);
    
endmodule

module stack (clk,push,pop,tos,d_in,d_out);

    input [7:0]d_in;
    input clk,push,pop,tos;
    output reg [7:0]d_out;

    reg [4:0]top;
    reg [7:0]data[31:0];

    initial top = 0;

    always @(clk) begin
        if (tos) d_out = data[top-1];
        if (push) begin data[top] = d_in ; top = top + 1; end
        if (pop)  begin top = top - 1 ; d_out = data[top]; end
    end

    initial $readmemb("stack.mem",data);
    
endmodule
