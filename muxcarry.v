module muxcarry (first_in,second_in,sel,out_mux);
input first_in,second_in;
input [55:0] sel;
output out_mux ;
assign out_mux = (sel=="CARRYIN") ? first_in : (sel=="OPMODE5") ? second_in : 0;
endmodule 