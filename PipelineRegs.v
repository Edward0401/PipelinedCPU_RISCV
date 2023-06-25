`include"bus.v"

// flop with reset and clear control
module floprc #(parameter WIDTH = 8)
              (input                  clk, reset, clear,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk, posedge reset)
    if (reset)      q <= 0;
    else if (clear) q <= 0;
    else            q <= d;
endmodule

// flop with reset, Enable and clear control
module flopenrc #(parameter WIDTH = 8)
                 (input                  clk, reset,
                  input                  en, clear,
                  input      [WIDTH-1:0] d, 
                  output reg [WIDTH-1:0] q);
 
  always @(posedge clk, posedge reset)
    if      (reset) q <= 0;
    else if (clear) q <= 0;
    else if (en)    q <= d;
endmodule


/**************************************************************************************************************************/
//IFID
module IFID(
	input clk,
	input rst,
	input enable,
	input flushD,
	input  [`ADDR_BUS] addr_in,
	output [`ADDR_BUS] addr_out,
	input  [`ADDR_BUS] addrplus4_in,
	output [`ADDR_BUS] addrplus4_out,
	input  [`INST_BUS] inst_in,
	output [`INST_BUS] inst_out
);
flopenrc #(`ADDR_BUS_WIDTH) ff_addr(
	clk, rst,
	enable, flushD,
	addr_in, addr_out
);//pc
flopenrc #(`ADDR_BUS_WIDTH) ff_addr_p4(
	clk, rst,
	enable, flushD,
	addrplus4_in, addrplus4_out
);//pc+4
flopenrc #(`INST_BUS_WIDTH) ff_inst(
	clk, rst,
	enable, flushD,
	inst_in, inst_out
);
endmodule // IFID

/**************************************************************************************************************************/
//IDEX
//reg SignalsD={regwriteD, memwriteD, memtoregD, lwhbD, swhbD, lunsignedD, alusrcaD, alusrcbD, aluctrlD, aluctrl1D, jD, bD, data_ram_weD};
//reg SignalsE={regwriteE, memwriteE, memtoregE, lwhbE, swhbE, luE,alusrcaE, alusrcbE, aluctrlE, aluctrl1E, jE, bE, data_ram_weE};
module IDEX(
	input clk,
	input rst,
	input enable,
	input flushE,
    input  [`DATA_BUS] rdata1D,
	output [`DATA_BUS] rdata1E,
    input  [`DATA_BUS] rdata2D,
	output [`DATA_BUS] rdata2E,
    input  [`DATA_BUS] immoutD,
	output [`DATA_BUS] immoutE,
    input  [`RFIDX_BUS] rs1D,
	output [`RFIDX_BUS] rs1E,
    input  [`RFIDX_BUS] rs2D,
	output [`RFIDX_BUS] rs2E,
	input  [`RFIDX_BUS] rdD,
	output [`RFIDX_BUS] rdE,
    input  [`ADDR_BUS] pcD,
	output [`ADDR_BUS] pcE,
	input  [`ADDR_BUS] pcplus4D,
	output [`ADDR_BUS] pcplus4E,
    input  [21:0]      SignalsD,
    output [21:0]      SignalsE
);
flopenrc #(`DATA_BUS_WIDTH) 	rs1dataDE(clk, rst, enable, flushE, rdata1D, rdata1E);        // rs1.data
flopenrc #(`DATA_BUS_WIDTH) 	rs2dataDE(clk, rst, enable, flushE, rdata2D, rdata2E);        // rs2.data
flopenrc #(`DATA_BUS_WIDTH) 	immDE    (clk, rst, enable, flushE, immoutD, immoutE);       //imm
flopenrc #(`RFIDX_WIDTH)  	rs1numDE(clk, rst, enable, flushE, rs1D, rs1E);              // rs1.number
flopenrc #(`RFIDX_WIDTH)  	rs2numDE(clk, rst, enable, flushE, rs2D, rs2E);              // rs2.number
flopenrc #(`RFIDX_WIDTH)  	rdnumDE(clk, rst, enable, flushE, rdD, rdE);                 // rd.number
flopenrc #(`ADDR_BUS_WIDTH)	pcDE(clk, rst, enable, flushE, pcD, pcE);                 // pc
flopenrc #(`ADDR_BUS_WIDTH)	pcp4DE(clk, rst, enable, flushE, pcplus4D, pcplus4E);     // pc+4
flopenrc #(22) SignalsDE(clk, rst, enable, flushE, SignalsD, SignalsE);                //Signals                  
endmodule //IDEX

/**************************************************************************************************************************/
//EXMEM
//CtrE={writenE,regwriteE, memwriteE, memtoregE, lwhbE, luE, swhbE, jE, bE, data_ram_weE};
//CtrM={writenM,regwriteM, memwriteM, memtoregM, lwhbM, luM, swhbM, jM, bM, data_ram_weM};
module EXMEM(
	input clk,
	input reset,
	input flushM,
	input  [14:0] CtrE,
	output [14:0] CtrM,
	input  [`DATA_BUS] srcb1E,
	output [`DATA_BUS] srcb1M,
	input  [`DATA_BUS] aluoutE,
	output [`DATA_BUS] aluoutM,
	input  [`DATA_BUS] srcb,
	output [`DATA_BUS] writedataM,
	input  [`RFIDX_BUS] rdE,
	output [`RFIDX_BUS] rdM,
	input  [`ADDR_BUS] pcE,
	output [`ADDR_BUS] pcM,
	input  [`ADDR_BUS] pcplus4E,
	output [`ADDR_BUS] pcplus4M,
	input  [`ADDR_BUS] PCoutE,
	output [`ADDR_BUS] PCoutM
);
floprc #(15) 		  SignalsEM	(clk, reset, flushM,CtrE,CtrM);//Signals
floprc #(`DATA_BUS_WIDTH) regM		(clk, reset, flushM,srcb1E,srcb1M);//???
floprc #(`DATA_BUS_WIDTH) ALU_OutEM	(clk, reset, flushM, aluoutE, aluoutM);	   //ALU_Out
floprc #(`DATA_BUS_WIDTH) MemWDataEM	(clk, reset, flushM, srcb, writedataM);    //MemWriteData
floprc #(`RFIDX_WIDTH) 	  RdNumEM	(clk, reset, flushM, rdE, rdM);		   //rd.num
floprc #(`ADDR_BUS_WIDTH) pcEM		(clk, reset, flushM, pcE, pcM);            // pc
floprc #(`ADDR_BUS_WIDTH) pcp4EM	(clk, reset, flushM, pcplus4E, pcplus4M);  // pc+4
floprc #(`ADDR_BUS_WIDTH) PCOutEM	(clk, reset, flushM, PCoutE, PCoutM);      //pcOut
endmodule//EXMEM

/**************************************************************************************************************************/
//MEMWB
//CtrM={regwriteM, memtoregM, jM, bM};
//CtrW={regwriteW, memtoregW, jW, bW};
module MEMWB(
	input clk,
	input reset,
	input flushW,
	input  [4:0] CtrMW,
	output [4:0] CtrWB,
	input  [`DATA_BUS] dmoutM,
	output [`DATA_BUS] dmoutW,
	input  [`DATA_BUS] aluoutM,
	output [`DATA_BUS] aluoutW,
	input  [`RFIDX_BUS] rdM,
	output [`RFIDX_BUS] rdW,
	input  [`ADDR_BUS] pcM,
	output [`ADDR_BUS] pcWt,
	input  [`ADDR_BUS] pcplus4M,
	output [`ADDR_BUS] pcplus4W,
	input  [`ADDR_BUS] PCoutM,
	output [`ADDR_BUS] PCoutW
);
floprc #(5) 		        SignalsMW(clk, reset, flushW, CtrMW, CtrWB);//Ctr Signals
floprc #(`DATA_BUS_WIDTH)   DMOutMW(clk, reset, flushW, dmoutM, dmoutW);   //Data memory output
floprc #(`DATA_BUS_WIDTH)   pr1W(clk, reset, flushW, aluoutM, aluoutW);	   //ALU_OUT
floprc #(`RFIDX_WIDTH)      pr2W(clk, reset, flushW, rdM, rdW);		   //Rd.num
floprc #(`ADDR_BUS_WIDTH)   pr3W(clk, reset, flushW, pcM, pcWt);            // pc
floprc #(`ADDR_BUS_WIDTH)   pr4W(clk, reset, flushW, pcplus4M, pcplus4W);  // pc+4
floprc #(`ADDR_BUS_WIDTH)   regpcW(clk, reset, flushW, PCoutM, PCoutW);	   //PCOut: To support jalr
endmodule//MEMWB
