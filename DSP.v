module DSP (A,B,D,C,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
//defining the parameters with setting their default values:
parameter A0REG=0;
parameter A1REG=1;
parameter B0REG=0;
parameter B1REG=1;
parameter CREG=1;
parameter DREG=1;
parameter MREG=1; 
parameter PREG=1;
parameter CARRYINREG=1;
parameter CARRYOUTREG=1;
parameter OPMODEREG=1;
parameter CARRYINSEL="OPMODE5";
parameter B_INPUT="DIRECT";
parameter RSTTYPE="SYNC";
/////////////////////////////////////////////////////////////
//defining the in/out data ports
input [17:0] A,B,BCIN,D;
input [47:0] C;
input CARRYIN;
wire Carry_Cascade;
output [47:0] P;
output CARRYOUT,CARRYOUTF;
output [35:0] M;
wire [47:0] P_ff;
wire CARRYOUT_ff;
wire [35:0] M_ff;
//////////////////////////////////////////////////////////////
//defining the control input ports
input CLK;
input [7:0] OPMODE;
//////////////////////////////////////////////////////////////
//defining the clock enable ports
input CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP;
//////////////////////////////////////////////////////////////
//defining the reset input ports
input RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
//////////////////////////////////////////////////////////////
//defining the cascade ports
input [47:0] PCIN;
output [47:0] PCOUT;
output [17:0] BCOUT;
//////////////////////////////////////////////////////////////
//generating the A and B first stage pipelines
wire [17:0] A0_ff;
wire [17:0] B0_ff;
wire [17:0] A0_tmp,Bin_tmp,B0_tmp;

muxbinput mbin (.first_in(B),.second_in(BCIN),.sel(B_INPUT),.out_mux(Bin_tmp));

generate  if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(18)) A0(.data(A),.clk(CLK),.s_rst(RSTA),.enable(CEA),.out(A0_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
        a_rst_dff #(.REGWIDTH(18)) A0(.data(A),.clk(CLK),.a_rst(RSTA),.enable(CEA),.out(A0_ff));
    end
endgenerate
mux #(.WIDTH(18)) mA0 (.first_in(A0_ff),.second_in(A),.sel(A0REG),.out_mux(A0_tmp));
generate if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(18)) B0 (.data(Bin_tmp),.clk(CLK),.s_rst(RSTB),.enable(CEB),.out(B0_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
        a_rst_dff #(.REGWIDTH(18)) B0 (.data(Bin_tmp),.clk(CLK),.a_rst(RSTB),.enable(CEB),.out(B0_ff));
    end
endgenerate
mux #(.WIDTH(18)) mB0 (.first_in(B0_ff),.second_in(Bin_tmp),.sel(B0REG),.out_mux(B0_tmp));
///////////////////////////////////////////////////////////////
//generating the first stage pipelines for other inputs
wire [47:0] C_ff,C0_tmp;
wire [17:0] D_ff,D0_tmp;
wire [7:0] OPMODE_ff,OPMODE_tmp;
wire CARRYIN_ff,CARRYIN_tmp;
muxcarry mcarryin (.first_in(CARRYIN),.second_in(OPMODE_tmp[5]),.sel(CARRYINSEL),.out_mux(Carry_Cascade));
generate if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(48)) C0(.data(C),.clk(CLK),.s_rst(RSTC),.enable(CEC),.out(C_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
        a_rst_dff #(.REGWIDTH(48)) C0(.data(C),.clk(CLK),.a_rst(RSTC),.enable(CEC),.out(C_ff)); 
    end
endgenerate
mux #(.WIDTH(48)) mC0 (.first_in(C_ff),.second_in(C),.sel(CREG),.out_mux(C0_tmp));
//****************************************************************************************************//
generate 
    if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(18)) D0(.data(D),.clk(CLK),.s_rst(RSTD),.enable(CED),.out(D_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
        a_rst_dff #(.REGWIDTH(18)) D0(.data(D),.clk(CLK),.a_rst(RSTD),.enable(CED),.out(D_ff)); 
    end
endgenerate
mux #(.WIDTH(18)) mD0 (.first_in(D_ff),.second_in(D),.sel(DREG),.out_mux(D0_tmp));
//****************************************************************************************************//
generate if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(8)) OPMODE0(.data(OPMODE),.clk(CLK),.s_rst(RSTOPMODE),.enable(CEOPMODE),.out(OPMODE_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
        a_rst_dff #(.REGWIDTH(8)) OPMODE0(.data(OPMODE),.clk(CLK),.a_rst(RSTOPMODE),.enable(CEOPMODE),.out(OPMODE_ff)); 
    end
endgenerate
mux #(.WIDTH(8)) mOPMODE0 (.first_in(OPMODE_ff),.second_in(OPMODE),.sel(OPMODEREG),.out_mux(OPMODE_tmp));
//****************************************************************************************************//
generate  if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(1)) CARRYIN0(.data(Carry_Cascade),.clk(CLK),.s_rst(RSTCARRYIN),.enable(CECARRYIN),.out(CARRYIN_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
        a_rst_dff #(.REGWIDTH(1)) CARRYIN0(.data(Carry_Cascade),.clk(CLK),.a_rst(RSTCARRYIN),.enable(CECARRYIN),.out(CARRYIN_ff)); 
    end
endgenerate
mux mCARRYIN0 (.first_in(CARRYIN_ff),.second_in(Carry_Cascade),.sel(CARRYINREG),.out_mux(CARRYIN_tmp));
//////////////////////////////////////////////////////////////////////////
//defining the second pipeline stages for A and B
//for A
wire [17:0] A1_ff ;
wire [17:0] A1_tmp;
generate  if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(18)) A1(.data(A0_tmp),.clk(CLK),.s_rst(RSTA),.enable(CEA),.out(A1_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
        a_rst_dff #(.REGWIDTH(18)) A1(.data(A0_tmp),.clk(CLK),.a_rst(RSTA),.enable(CEA),.out(A1_ff));
    end
endgenerate
mux #(.WIDTH(18)) mA1 (.first_in(A1_ff),.second_in(A0_tmp),.sel(A1REG),.out_mux(A1_tmp));
//for B
//firstly
//defining inner wires for the pre-adder/subtractor output and the first operand entering the multiplier
wire [17:0] pre_add_out= (OPMODE_tmp[6]) ? (D0_tmp-B0_tmp) : (D0_tmp+B0_tmp) ;
//////////////////////////////////////////////////////////////////////////
//then,...
wire [17:0] first_op_mult, B1_tmp;
assign first_op_mult = (OPMODE_tmp[4]) ?  (pre_add_out) : (B0_tmp) ;
wire [17:0] B1_ff;
generate if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(18)) B1(.data(first_op_mult),.clk(CLK),.s_rst(RSTB),.enable(CEB),.out(B1_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
        a_rst_dff #(.REGWIDTH(18)) B1(.data(first_op_mult),.clk(CLK),.a_rst(RSTB),.enable(CEB),.out(B1_ff));
    end
endgenerate
mux #(.WIDTH(18)) mB1 (.first_in(B1_ff),.second_in(first_op_mult),.sel(B1REG),.out_mux(B1_tmp));
//executing the BCOUT output
assign BCOUT=B1_tmp;
/////////////////////////////////////////////////////////////////////////
//Executing the M output
wire [35:0] M_tmp;
assign M_tmp= (B1_tmp*A1_tmp);
generate if (RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(36)) M0(.data(M_tmp),.clk(CLK),.s_rst(RSTM),.enable(CEM),.out(M_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
         a_rst_dff #(.REGWIDTH(36)) M0(.data(M_tmp),.clk(CLK),.s_rst(RSTM),.enable(CEM),.out(M_ff));
    end
endgenerate
mux #(.WIDTH(36)) mM0 (.first_in(M_ff),.second_in(M_tmp),.sel(MREG),.out_mux(M));
/////////////////////////////////////////////////////////////////////////
//Implementation of the X multiplexer
reg [47:0] X;
always @(*) begin
    case(OPMODE_tmp[1:0])
    2'b00:X=0;
    2'b01:X={{12{M[35]}},M};
    2'b10:X=P;
    2'b11:X={D0_tmp[11:0],A1_tmp,B1_tmp}; 
    endcase
end
/////////////////////////////////////////////////////////////////////////
//Implementation of the Z multiplexer
reg [47:0] Z;
always @(*) begin
    case(OPMODE_tmp[3:2])
    2'b00:Z=0;
    2'b01:Z=PCIN;
    2'b10:Z=P;
    2'b11:Z=C0_tmp;
    endcase
end
/////////////////////////////////////////////////////////////////////////
//Implementation of the post-adder/subtractor
//And the execution of the P, PCOUT, CARRYOUT and CARRYOUTF outputs
wire [47:0] P_tmp;
wire CARRYOUT_tmp;
assign {CARRYOUT_tmp,P_tmp}= (OPMODE_tmp[7]) ? (Z-(X+CARRYIN_tmp)) : (Z+X+CARRYIN_tmp) ;
generate if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(48)) P0(.data(P_tmp),.clk(CLK),.s_rst(RSTP),.enable(CEP),.out(P_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
         a_rst_dff #(.REGWIDTH(48)) P0(.data(P_tmp),.clk(CLK),.s_rst(RSTP),.enable(CEP),.out(P_ff));
    end
endgenerate
mux #(.WIDTH(48)) mP0 (.first_in(P_ff),.second_in(P_tmp),.sel(PREG),.out_mux(P));
assign PCOUT=P;
generate if(RSTTYPE=="SYNC") begin
        s_rst_dff #(.REGWIDTH(1)) CARRYOUT0(.data(CARRYOUT_tmp),.clk(CLK),.s_rst(RSTCARRYIN),.enable(CECARRYIN),.out(CARRYOUT_ff));
    end
    else if(RSTTYPE=="ASYNC") begin
        a_rst_dff #(.REGWIDTH(1)) CARRYOUT0(.data(CARRYOUT_tmp),.clk(CLK),.a_rst(RSTCARRYIN),.enable(CECARRYIN),.out(CARRYOUT_ff)); 
    end
endgenerate
mux #(.WIDTH(1)) mCARRYOUT0 (.first_in(CARRYOUT_ff),.second_in(CARRYOUT_tmp),.sel(CARRYOUTREG),.out_mux(CARRYOUT));
assign CARRYOUTF=CARRYOUT;
endmodule 