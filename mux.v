module mux (first_in,second_in,sel,out_mux);
parameter WIDTH=1;
input [WIDTH-1:0] first_in,second_in;
input  sel;//it was set to one bit only because it can afford only two values 1 or 0
output [WIDTH-1:0] out_mux ;
assign out_mux = (sel==1) ? first_in :  second_in;
endmodule 