module muxbinput (first_in,second_in,sel,out_mux);
input [17:0] first_in,second_in;
input [55:0] sel;
output [17:0] out_mux ;
reg [17:0] out_mux_tmp;
reg [55:0] sel_tmp;
always @(*) begin
sel_tmp=sel;
if(sel_tmp[47:0]=="DIRECT") begin
    out_mux_tmp=first_in;
end    
else if(sel_tmp[55:0]=="CASCADE") begin
    out_mux_tmp=second_in;
end
else begin
    out_mux_tmp=0;
end
end
assign out_mux=out_mux_tmp;
endmodule 