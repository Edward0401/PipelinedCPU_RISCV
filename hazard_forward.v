`include "bus.v"
module hazard (
    input clk, 
    input [1:0]WDSel, 
    input[`RFIDX_BUS] rdE, input[`RFIDX_BUS] rs1D, input[`RFIDX_BUS] rs2D, 
    input writenM,
    output reg writen
    );//load from memory and then use the value, should stall 1 cycle.
	always @ *
	if((WDSel == 2'b01) && (rdE == rs1D || rdE == rs2D) && writenM)
		writen <= 1'b0;
	else
		writen <= 1'b1;
endmodule

module forward (input regwriteM, input[`RFIDX_WIDTH-1:0] rdM, input[`RFIDX_WIDTH-1:0] rs1E, input[`RFIDX_WIDTH-1:0] rs2E,
				input regwriteW, input[`RFIDX_WIDTH-1:0] rdW, output reg[1:0] forwardA, output reg[1:0] forwardB);
	always@*	begin
		forwardA=2'b00;
		forwardB=2'b00;
		if(regwriteM&&rdM!=0)	begin
			if(rdM == rs1E)	forwardA=2'b10;
			if(rdM == rs2E) forwardB=2'b10;
		end
		if(regwriteW&&rdW!=0)	begin
			if(!(regwriteM&&(rdM!=0)&&rdM==rs1E)
				&& rdW == rs1E)	forwardA=2'b01;
			if(!(regwriteM&&(rdM!=0)&&rdM==rs2E)
				&& rdW == rs2E) forwardB=2'b01;
		end
	end
endmodule
