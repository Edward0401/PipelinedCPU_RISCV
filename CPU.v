//=====================================================================
// Xgriscv_CPU
// Designer   : Zhentao He
// Adapted from and refined Professor Zhaohui Cai and Yili Gong's original code. 
// Description:
// 	As part of the project of Computer Organization Experiments, Wuhan University
// 	In June 2023
// 	A pipelined CPU with full forwarding and all hazards units. It branches in EX unit, and has the static prediction of not taken.
//  Need an extra DataMemory Control Unit in dm.v, which transforms the DMType signals to WEA signals and extend the data.
//	Without Cache.
// ====================================================================
`include "bus.v"
`include "ctrl_encode_def.v"

module CPU(
	input  clk, reset,

	input [`INST_BUS]  instr, 	 // from instructon memory
	output[`ADDR_BUS]  pcF,      // to instruction memory
	output[`ADDR_BUS]  pcW,

	input [`DATA_BUS]  readdataM, // from data memory: read data
    output[`DATA_BUS]  Addr_out,   // to data memory: address
 	output[`DATA_BUS]  writedataM,// to data memory: write data
    output	           memwriteM,	  // to data memory: write enable
	output [2:0]       DMType,

	input  [4:0]  reg_sel,    // register selection (for debug use)
    output [31:0] reg_data  // selected register data (for debug use)
);
	wire [`INST_BUS] instrF = instr;
	wire [`DATA_BUS] aluoutM;
	assign Addr_out =aluoutM;
// ====================================================================
//IF Stage
// ====================================================================
	wire jW, pcsrc, writenE, writenM;
	wire flushM = 0;
	
	// next PC logic (operates in fetch and decode)
	wire [`ADDR_BUS]	 pcplus4F, nextpcF, pcbranchD, pcadder2aD, pcadder2bD, pcbranch0D;//?
	mux2 #(`ADDR_BUS_WIDTH)	    pcsrcmux(pcplus4F, pcbranchD, pcsrc, nextpcF);
	
	// Fetch stage logic
	PC U_PC(.clk(clk), .rst(reset),.en(writenE), .NPC(nextpcF), .PC(pcF),.this_pc(pcW),.pcplus4(pcplus4F));

///////////////////////////////////////////////////////////////////////////////////
	// IF/ID pipeline registers
///////////////////////////////////////////////////////////////////////////////////
	wire [`INST_BUS]	instrD;
	wire [`ADDR_BUS]	pcD, pcplus4D;
	wire flushD = pcsrc; 
	wire regwriteW;

	//Install IF/ID
        IFID IFIDReg(clk,reset,writenE,flushD,pcF,pcD,pcplus4F,pcplus4D,instrF,instrD);

// ====================================================================
//ID Stage
// ====================================================================   

	// from controller
	wire [5:0] EXTOp;
	//wire       jalD, jalrD, jD, bD, ->Decode from NPCOpD
	wire [3:0] NPCOpD;
	wire [4:0] ALUOpD;
	wire [1:0]	alusrcaD;
	wire		alusrcbD;
	wire		memwriteD;
	wire [1:0]	lwhbD, swhbD;
	wire [1:0] WDSelD; //memtoregD
	wire       regwriteD;
	wire [2:0] DMTypeD;
	wire 		rs2ZeroD;
	
  	// to controller
	wire       zeroE, ltE;

	wire jD   =NPCOpD[3];//when jal /jalr, jD=1
	wire jalrD=NPCOpD[2];
	wire jalD =NPCOpD[1];
	wire bD   =NPCOpD[0]; //when SB_type, bD=1
	
	// Decode stage logic
    wire  [`RFIDX_BUS]  rs1D    = instrD[19:15];
	wire  [`RFIDX_BUS] rs2D	= rs2ZeroD?5'b00000:instrD[24:20];//When don't use rs2, rs2=0 -> for forwarding and hazard detection;
	wire  [6:0]  opD 	= instrD[6:0];
	wire  [4:0]  rdD     = instrD[11:7];
	wire  [2:0]  funct3D = instrD[14:12];
	wire  [6:0]  funct7D = instrD[31:25];
	wire  [11:0] immD    = instrD[31:20];

	// immediate generate
	wire [`DATA_BUS]	immoutD;
	wire [`DATA_BUS]	rdata1D, rdata2D, wdataW;
	wire [`RFIDX_BUS]	waddrW;

	EXT U_EXT(
			.instrD(instrD), .EXTOp(EXTOp), 
			.immout(immoutD)
    );

	// register file (operates in decode and writeback)
	RF U_RF(
            .clk(clk), .rst(reset),
            .RFWr(regwriteW), 
            .A1(rs1D), .A2(rs2D), .A3(waddrW), 
            .WD(wdataW), 
            .RD1(rdata1D), .RD2(rdata2D),
            .pc(pcW)
            //.reg_sel(reg_sel),
            //.reg_data(reg_data)
    );

	wire [1:0]  GPRSel;
	// instantiation of control unit
	ctrl U_ctrl(
		.Op(opD), .Funct7(funct7D), .Funct3(funct3D), 
		.RegWrite(regwriteD), .MemWrite(memwriteD),
		.EXTOp(EXTOp), .ALUOp(ALUOpD), .NPCOp(NPCOpD), 
		.ALUSrcA(alusrcaD),.ALUSrcB(alusrcbD), 
		.GPRSel(GPRSel), 
		.WDSel(WDSelD), .DMType(DMTypeD), .rs2Zero(rs2ZeroD)
	);

///////////////////////////////////////////////////////////////////////////////////
	// ID/EX pipeline registers
///////////////////////////////////////////////////////////////////////////////////
	wire [`DATA_BUS]	srca1E, srcb1E, immoutE, srcaE, srcbE, aluoutE;
	wire [`RFIDX_BUS]   rdE, rs1E, rs2E;
	wire [`ADDR_BUS] 	pcE, pcplus4E;
	wire [21:0] SignalsD,SignalsE;
	wire [4:0] ALUOpE;
	wire flushE= pcsrc | ~writenE; //When writenE==0 ,flushE<-1
	assign SignalsD={regwriteD, memwriteD, WDSelD, lwhbD, swhbD, jalD, alusrcaD, alusrcbD, ALUOpD, jD, bD, DMTypeD};
	//Install ID/EX
	IDEX IDEXReg
	(clk,reset,writenE,flushE,
	rdata1D,srca1E,rdata2D,srcb1E,immoutD,immoutE,rs1D,rs1E,rs2D,rs2E,
	rdD,rdE,pcD,pcE,pcplus4D,pcplus4E,SignalsD,SignalsE
	);
	wire regwriteE=SignalsE[21]; wire memwriteE=SignalsE[20]; wire [1:0] WDSelE=SignalsE[19:18];	
	wire [1:0] lwhbE=SignalsE[17:16];  wire [1:0] swhbE=SignalsE[15:14];  wire jalE=SignalsE[13];
	wire [1:0] alusrcaE=SignalsE[12:11];wire alusrcbE=SignalsE[10]; assign ALUOpE=SignalsE[9:5];
	wire jE=SignalsE[4];	wire bE=SignalsE[3];	wire [2:0] DMTypeE=SignalsE[2:0];

	wire[1:0]	forwardA, forwardB;
	wire[`DATA_BUS] srca, srcb;
	mux3 #(`DATA_BUS_WIDTH)	fA(srca1E, wdataW, /*aluoutW*/ aluoutM, forwardA, srca);//
	mux3 #(`DATA_BUS_WIDTH)	fB(srcb1E, wdataW, /*aluoutW*/ aluoutM, forwardB, srcb);//

// ====================================================================
//EX Stage
// ====================================================================
	mux3 #(`DATA_BUS_WIDTH)  srcamux(srca, 0, pcE, alusrcaE, srcaE);     // alu src a mux
	mux2 #(`DATA_BUS_WIDTH)  srcbmux(srcb, immoutE, alusrcbE, srcbE);			 // alu src b mux
	wire[`ADDR_BUS_WIDTH-1:0] PCoutE;

//need a more complex alu
	alu u_alu(
   .A(srcaE), .B(srcbE),
   .ALUOp(ALUOpE),
   .PC(pcW),
   .C_out(aluoutE),
   .Zero(zeroE),
   .Overflow(overflowE),
   .Lt(ltE),
   .Ge(geE)
);
	pc_imm U_pc_imm (pcE, immoutE, PCoutE);//adder
		
	wire B; //when bE=1, bxx instructions
	assign B = bE & aluoutE[0];//only when is true
	mux2 #(`DATA_BUS_WIDTH) brmux(aluoutE, PCoutE, B|jalE, pcbranchD);			 // pcsrc mux	

	assign pcsrc = jE | B;

	hazard U_hazard(.clk(clk), .WDSel(WDSelE), .rdE(rdE), .rs1D(rs1D), .rs2D(rs2D), .writenM(writenM), .writen(writenE));
	
///////////////////////////////////////////////////////////////////////////////////
	// EX/MEM pipeline registers
///////////////////////////////////////////////////////////////////////////////////
	// for control signals
	wire 		regwriteM,jM, bM ;
	wire [1:0] WDSelM;
	wire [2:0] DMTypeM;
	wire [1:0] lwhbM, swhbM;
	wire [`DATA_BUS] srcb1M;
	wire [`ADDR_BUS] PCoutM, pcM;
	// for data
	wire [`ADDR_BUS]	pcplus4M;
 	wire [`RFIDX_BUS]	 rdM;
	
	wire [14:0] CtrE={writenE,regwriteE, memwriteE, WDSelE, lwhbE,1'b0, swhbE, jE, bE, DMTypeE};
	wire [14:0] CtrM;
	EXMEM EXMEMReg
	(clk,reset,flushM,
	CtrE,CtrM,srcb1E,srcb1M,aluoutE,aluoutM,srcb,writedataM,rdE,rdM,pcE,
	pcM,pcplus4E,pcplus4M,PCoutE,PCoutM
	);
	assign writenM=CtrM[14];assign regwriteM=CtrM[13];assign  memwriteM=CtrM[12];assign  WDSelM=CtrM[11:10]; 
	assign lwhbM=CtrM[9:8]; assign  swhbM=CtrM[6:5];assign  jM=CtrM[4];
	assign bM=CtrM[3];assign DMTypeM=CtrM[2:0];
	
// ====================================================================
//MEM Stage
// ====================================================================
	wire [`DATA_BUS] dmoutM;
	//ĺŚćä˝żç¨ĺ¤ćĽDM,ččĺ¨ć­¤ĺ¤ĺ˘ĺ DMTypeč˝ŹćĽĺ?
	assign dmoutM = readdataM;
	assign DMType = DMTypeM;
	//Use 'assign' in dm.v 
	// assign dout[7:0] = dout_raw[7:0];
	// assign dout[15:8] = (DMType==`dm_byte_unsigned)?8'b0:((DMType==`dm_byte)?{8{dout_raw[7]}}:dout_raw[15:8]);
	// assign dout[31:16] = (DMType==`dm_halfword_unsigned||DMType==`dm_byte_unsigned)?16'b0
    //                     :( (DMType==`dm_halfword)?{16{dout_raw[15]}}:
    //                        ((DMType==`dm_byte)?{16{dout_raw[7]}}:dout_raw[31:16])
    //                     ); 

///////////////////////////////////////////////////////////////////////////////////
  	// MEM/WB pipeline registers
///////////////////////////////////////////////////////////////////////////////////
  wire[`RFIDX_BUS]	 rdW;
  wire[`ADDR_BUS]	 pcplus4W;
  wire[`ADDR_BUS] PCoutW;
  wire[`DATA_BUS] aluoutW, dmoutW;

  forward U_forward(regwriteM, rdM, rs1E, rs2E, regwriteW, rdW, forwardA, forwardB);
  wire [4:0]CtrMW={regwriteM, WDSelM, jM, bM};
  wire [4:0]CtrWB;
  wire [`ADDR_BUS] pcWt;
  MEMWB MEMWBReg(
	clk,reset,1'b0/*flushW*/,
	CtrMW,CtrWB,dmoutM,dmoutW,aluoutM,aluoutW,rdM,rdW,
	pcM,pcWt,pcplus4M,pcplus4W,PCoutM,PCoutW
);
assign regwriteW=CtrWB[4];wire [1:0] WDSelW=CtrWB[3:2];assign jW=CtrWB[1];wire bW=CtrWB[0];

// ====================================================================
//WB Stage
// ====================================================================
	mux3 #(`DATA_BUS_WIDTH) wdatamux(aluoutW, dmoutW, pcplus4W,WDSelW,wdataW);	
	assign waddrW = rdW;//register destination
endmodule