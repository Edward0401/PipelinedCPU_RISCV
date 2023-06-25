`include "ctrl_encode_def.v"
module EXT(
	input [31:0] instrD,
	input	[5:0]			EXTOp,

	output	reg [31:0] 	       immout);


	// immediate generate
	wire [4:0]   iimm_shamt=instrD[24:20];
	wire [11:0]  iimm = instrD[31:20];
	wire [11:0]  simm	= {instrD[31:25],instrD[11:7]};//instr[31:25, 11:7], 12 bits
	wire [11:0]  bimm	= {instrD[31],instrD[7],instrD[30:25],instrD[11:8]};//instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits
	wire [19:0]  uimm	= instrD[31:12];
	wire [19:0]  jimm	= {instrD[31],instrD[19:12],instrD[20],instrD[30:21]};
   
always  @(*) begin
	 case (EXTOp)
		`EXT_CTRL_ITYPE_SHAMT:   immout<={27'b0,iimm_shamt[4:0]};
		`EXT_CTRL_ITYPE:	immout <= {{{32-12}{iimm[11]}}, iimm[11:0]};
		`EXT_CTRL_STYPE:	immout <= {{{32-12}{simm[11]}}, simm[11:0]};
		`EXT_CTRL_BTYPE:        immout <= {{{32-13}{bimm[11]}}, bimm[11:0], 1'b0};
		`EXT_CTRL_UTYPE:	immout <= {uimm[19:0], 12'b0}; //???????????12??0
		`EXT_CTRL_JTYPE:	immout <= {{{32-21}{jimm[19]}}, jimm[19:0], 1'b0};
		default:	        immout <= 32'b0; 
	endcase
end
endmodule
