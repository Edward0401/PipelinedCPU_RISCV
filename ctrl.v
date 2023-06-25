// `include "ctrl_encode_def.v"

//123
module ctrl(Op, Funct7, Funct3, 
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrcA,ALUSrcB, GPRSel, WDSel,DMType,rs2Zero
            );
            
   input  [6:0] Op;       // opcode
   input  [6:0] Funct7;    // funct7
   input  [2:0] Funct3;    // funct3
   
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output [5:0] EXTOp;    // control signal to signed extension
   output [4:0] ALUOp;    // ALU opertion
   output [3:0] NPCOp;    // next pc operation
   output [1:0] ALUSrcA;
   output       ALUSrcB;   // ALU source for B
   output [2:0] DMType;   //DataMemoryType(W/h/b)
   output [1:0] GPRSel;   // general purpose register selection
   output [1:0] WDSel;    // (register) write data selection
   output       rs2Zero;  // Don't need rs2;
   
  //u format
   wire i_lui    = ~Op[6]&Op[5]&Op[4]&~Op[3]&Op[2]&Op[1]&Op[0];  //0110111
   wire i_auipc  = ~Op[6]&~Op[5]&Op[4]&~Op[3]&Op[2]&Op[1]&Op[0]; //0010111
   wire utype = i_lui|i_auipc;

  // r format
    wire rtype  = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0110011
    wire i_add  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add 0000000 000
    wire i_sub  = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000
    wire i_or   = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]&~Funct3[0]; // or 0000000 110
    wire i_and  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]& Funct3[0]; // and 0000000 111
    wire i_xor  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]&~Funct3[0]; // xor 0000000 100 
    wire i_sll  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]& Funct3[0]; // sll 0000000 001 
    wire i_sra  = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // sra 0100000 101
    wire i_srl  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // srl 0000000 101 
    wire i_slt  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]&~Funct3[0]; // slt 0000000 010
    wire i_sltu = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]& Funct3[0]; // sltu 0000000 011

 // i format
   wire itype_l  = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0000011
   wire i_lb     = ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; //lb 000
   wire i_lh     = ~Funct3[2] & ~Funct3[1] &  Funct3[0]; //lh 001
   wire i_lw     = ~Funct3[2] &  Funct3[1] & ~Funct3[0]; //lw 010
   wire i_lbu    =  Funct3[2] & ~Funct3[1] & ~Funct3[0]; //lbu 100
   wire i_lhu    =  Funct3[2] & ~Funct3[1] &  Funct3[0]; //lhu 101

// i format
    wire itype_r = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; 	//0010011
    wire i_addi  =  itype_r& ~Funct3[2]& ~Funct3[1]& ~Funct3[0]; 	// addi 000
    wire i_ori   =  itype_r& Funct3[2] &  Funct3[1]& ~Funct3[0]; 	// ori 110
    wire i_andi  =  itype_r& Funct3[2] &  Funct3[1]&  Funct3[0]; 	// andi 111
    wire i_xori  =  itype_r& Funct3[2] & ~Funct3[1]& ~Funct3[0]; 	// xori 100
    wire i_slli  =  itype_r&~Funct3[2] & ~Funct3[1]&  Funct3[0]; 	// slli 001
    wire i_srai  =  itype_r& Funct3[2] & ~Funct3[1]&  Funct3[0] & Funct7[5]; // srai 101 0100000
    wire i_srli  =  itype_r& Funct3[2] & ~Funct3[1]&  Funct3[0] &~Funct7[5]; // srai 101 0000000
    wire i_slti  =  itype_r&~Funct3[2] &  Funct3[1]& ~Funct3[0]; // srai 010
    wire i_sltiu =  itype_r&~Funct3[2] &  Funct3[1]&  Funct3[0]; // srai 011

 //jalr
	wire i_jalr =Op[6]&Op[5]&~Op[4]&~Op[3]&Op[2]&Op[1]&Op[0];//jalr 1100111

  // s format
   wire stype  = ~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//0100011
   wire i_sw   =  stype& ~Funct3[2]& Funct3[1]&~Funct3[0]; // sw 010
   wire i_sb   =  stype& ~Funct3[2]&~Funct3[1]&~Funct3[0]; // sb 000
   wire i_sh   =  stype& ~Funct3[2]&~Funct3[1]&~Funct3[0]; // sh 001

  // sb format
   wire sbtype  = Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//1100011
   wire i_beq  = sbtype& ~Funct3[2]& ~Funct3[1]&~Funct3[0]; // beq 000
   wire i_bne  = sbtype& ~Funct3[2]& ~Funct3[1]& Funct3[0]; // bne 001
   wire i_blt  = sbtype&  Funct3[2]& ~Funct3[1]&~Funct3[0]; // blt 100
   wire i_bge  = sbtype&  Funct3[2]& ~Funct3[1]& Funct3[0]; // bge 101
   wire i_bltu = sbtype&  Funct3[2]&  Funct3[1]&~Funct3[0]; // bltu 110
   wire i_bgeu = sbtype&  Funct3[2]&  Funct3[1]& Funct3[0]; // bltu 111
	
 // j format
   wire i_jal  = Op[6]& Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0];  // jal 1101111

  // generate control signals
  assign RegWrite   = rtype | itype_r | i_jalr | i_jal |utype | itype_l; // register write
  assign MemWrite   = stype;                           // memory write
  assign ALUSrcA    = i_lui ? 2'b01 :(i_jal||i_auipc ? 2'b10 : 2'b00);
  assign ALUSrcB    = itype_r | stype | i_jal | i_jalr |utype | itype_l;   // ALU B is from instruction immediate

  // signed extension
  // EXT_CTRL_ITYPE_SHAMT     6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  assign EXTOp[5]    =  i_slli|i_srai|i_srli;
  assign EXTOp[4]    =  i_ori | i_andi | i_jalr | i_xori | i_addi|i_slti|i_sltiu | itype_l;  
  assign EXTOp[3]    = stype; 
  assign EXTOp[2]    = sbtype; 
  assign EXTOp[1]    = utype;   
  assign EXTOp[0]    = i_jal;         


  
  
  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = itype_l;
  assign WDSel[1] = i_jal | i_jalr;

  // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	3'b100
  //对于Branch 还需要在EX或者MEM阶段额外判断Zero。
  assign NPCOp[0] = sbtype;
  assign NPCOp[1] = i_jal;
  assign NPCOp[2] = i_jalr;
  assign NPCOp[3] = i_jal|i_jalr; //无条件跳转,jD
  
/*
`define ALUOp_beq  5'b10010
`define ALUOp_bne  5'b00101
`define ALUOp_blt  5'b00110
`define ALUOp_bge  5'b00111
`define ALUOp_bltu 5'b01000
`define ALUOp_bgeu 5'b01001
*/
 
	assign ALUOp[0] = i_jalr|itype_l|stype|i_addi|i_add|i_ori|i_or|i_sll|i_slli|i_sra|i_srai|i_sltu|i_sltiu|i_lui|i_bne|i_bge|i_bgeu;
	assign ALUOp[1] = i_jalr|itype_l|stype|i_addi|i_add|i_and|i_andi|i_sll|i_slli|i_slt|i_slti|i_sltu|i_sltiu|i_auipc|i_blt|i_bge|i_beq;
	assign ALUOp[2] = i_andi|i_and|i_ori|i_or|i_sub|i_xor|i_xori|i_sll|i_slli|i_bne|i_blt|i_bge;
	assign ALUOp[3] = i_andi|i_and|i_ori|i_or|i_xor|i_xori|i_sll|i_slli|i_slt|i_slti|i_sltu|i_sltiu|i_bltu|i_bgeu;
	assign ALUOp[4] = i_sra|i_srai|i_srl|i_srli|i_beq;

   //DMType
   assign DMType[2]=i_lbu;
   assign DMType[1]=i_lb | i_lhu|i_sb;
   assign DMType[0]=i_lh | i_lb |i_sh| i_sb;  

   //rs2Zero
   assign rs2Zero=itype_l |itype_r | utype| i_jal;

endmodule
