module data_path (clk,aq,div,reg_ld,reg_rst,shift_ld,shift_s,cnt_ld,cnt_rst,cnt_en,cnt_co,
                    shift_rst,shift_cin,shift_en,remainder,quotient,is_pos,shift_ld_select);

    input clk;
    input [11:0]aq;
    input [5:0]div;
    input reg_ld;
    input reg_rst;
    input shift_ld;
    input shift_s;
    input shift_rst;
    input shift_cin;
    input shift_en;
    input shift_ld_select;
    input cnt_ld;
    input cnt_rst;
    input cnt_en;

    output [5:0]remainder;
    output [5:0]quotient;
    output is_pos;
    output cnt_co;
    
    wire [5:0]reg_out;
    wire [5:0]add_sub_out;
    wire [11:0]shift_out;
    wire [11:0]shift_in;

    reg [2:0]cnt_start = 3'b110;
    reg add_sub_s = 0;
    reg cnt_select = 0;

    counter #(3) cnt (.clk(clk),.pin(cnt_start),.select(cnt_select),.ld(cnt_ld),.rst(cnt_rst),.en(cnt_en),.pout(),.co(cnt_co));
    mux2to1 #(12) mux(aq,{add_sub_out,shift_out[5:0]},shift_ld_select,shift_in);  
    shift_register #(12) AQ(clk,shift_in,shift_s,shift_cin,shift_ld,shift_rst,shift_en,shift_out);
    register #(6) divisor(clk,div,reg_ld,reg_rst,reg_out);
    add_sub #(6) sub(shift_out[11:6],div,add_sub_s,add_sub_out);
    is_positive #(6) isp(add_sub_out,is_pos);

    assign remainder = shift_out[11:6];
    assign quotient = shift_out[5:0];

endmodule

module controller (start_div,is_pos,clk,reg_ld,reg_rst,shift_ld,shift_s,shift_rst,shift_cin,
                    shift_en,ready,shift_ld_select,cnt_ld,cnt_rst,cnt_en,cnt_co);
    
    input start_div;
    input is_pos;
    input cnt_co;
    input clk;

    output reg reg_ld;
    output reg reg_rst;
    output reg shift_ld;
    output reg shift_s;
    output reg shift_rst;
    output reg shift_cin;
    output reg shift_en;
    output reg shift_ld_select;
    output reg ready;
    output reg cnt_ld;
    output reg cnt_rst;
    output reg cnt_en;

    reg [3:0] ps , ns;

    parameter [3:0] idle = 0 , init = 1 , start = 2 , shl = 3 , sub = 4 , check = 5 , pos = 6 , pos_post = 7 ,
                    pos_post2 = 8 , neg = 9 , result = 10 , done = 11;

    always @(ps,start_div) begin
        ns = idle;
        case (ps)
            idle : ns = start_div ? init : idle;
            init : ns = start_div ? init : start;
            start : ns = shl;
            shl : ns = sub;
            sub : ns = check;
            check : ns = is_pos ? pos : neg;
            pos : ns = pos_post;
            pos_post : ns = pos_post2;
            pos_post2 : ns = result;
            neg : ns = result;
            result : ns = cnt_co ? done : shl;
            done : ns = idle;
            default: ns = idle; 
        endcase
    end

    always @(ps) begin
        reg_ld = 0 ; reg_rst = 0 ; shift_ld = 0 ; shift_s = 1 ; shift_rst = 0 ; cnt_en = 0 ;
        shift_cin = 0 ; shift_en = 0 ; ready = 0 ; shift_ld_select = 0 ; cnt_ld = 0 ; cnt_rst = 0 ;
        case (ps)
            init : begin reg_rst = 1 ; shift_rst = 1 ; cnt_rst = 1; end
            start : begin reg_ld = 1 ; shift_ld = 1; cnt_ld = 1; end
            shl : begin shift_s = 1 ; shift_cin = 0 ; shift_en = 1 ; cnt_en = 1; end
            pos : begin shift_s = 0 ; shift_cin = 0 ; shift_en = 1; end
            pos_post : begin shift_s = 1 ; shift_cin = 1 ; shift_en = 1; end
            pos_post2 : begin shift_ld_select = 1 ; shift_ld = 1; end
            done :  begin ready = 1; end 
        endcase
    end

    always @(posedge clk) begin
        ps <= ns;
    end

endmodule

module divider (clk,start,aq,div,remainder,quotient,ready);
    
    input clk,start;
    input [11:0]aq;
    input [5:0]div;

    output [5:0]remainder;
    output [5:0]quotient;
    output ready;

    wire reg_ld,reg_rst,shift_ld,shift_s,shift_rst,shift_cin,shift_en,is_pos,shift_ld_select,cnt_ld,cnt_rst,cnt_en,cnt_co;

    data_path dp(.clk(clk),.aq(aq),.div(div),.reg_ld(reg_ld),.reg_rst(reg_rst),.shift_ld(shift_ld),.shift_s(shift_s),
                 .cnt_ld(cnt_ld),.cnt_rst(cnt_rst),.cnt_en(cnt_en),.cnt_co(cnt_co),.shift_rst(shift_rst),
                 .shift_cin(shift_cin),.shift_en(shift_en),.remainder(remainder),.quotient(quotient),.is_pos(is_pos),
                 .shift_ld_select(shift_ld_select));

    controller ct(.start_div(start),.is_pos(is_pos),.clk(clk),.reg_ld(reg_ld),.reg_rst(reg_rst),.shift_ld(shift_ld),
                  .shift_s(shift_s),.shift_rst(shift_rst),.shift_cin(shift_cin),.shift_en(shift_en),.ready(ready),
                  .shift_ld_select(shift_ld_select),.cnt_ld(cnt_ld),.cnt_rst(cnt_rst),.cnt_en(cnt_en),.cnt_co(cnt_co));

endmodule
