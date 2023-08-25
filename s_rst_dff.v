//a d-flipflop with an synchronous reset
module s_rst_dff (data,clk,s_rst,enable,out);
//defining a parameter for the data and output width
parameter REGWIDTH=1;
////////////////////////////////////////////////////
input [REGWIDTH-1:0] data;
input s_rst,clk,enable;
output [REGWIDTH-1:0] out;
reg [REGWIDTH-1:0] out_tmp;
always @(posedge clk ) begin
    if(s_rst) begin
        out_tmp<=0;
    end
    else if(enable) begin
        out_tmp<=data;
    end
end
assign out=out_tmp;
endmodule 