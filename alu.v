`include "ctrl_encode_def.v"
`include "bus.v"

module alu(
   input  signed [31:0] A, B,
   input         [4:0]  ALUOp,
   input         [`ADDR_BUS] PC,
   output signed [31:0] C_out,
   output Zero,
   output       	Overflow,
   output           Lt,
   output           Ge
);
   reg [31:0] C;
   integer    i;
       
   always @( * ) begin
      case ( ALUOp )
`ALUOp_nop:C=A;	//00000
`ALUOp_lui:C=B; //00001
`ALUOp_auipc:C=PC+B; //00010
`ALUOp_add:C=A+B;	//00011
`ALUOp_sub:C=A-B;	//00100
`ALUOp_beq:C={31'b0,(A==B)};//10010
`ALUOp_bne:C={31'b0,(A!=B)};	//00101
`ALUOp_blt:C={31'b0,(A<B)};	//00110
`ALUOp_bge:C={31'b0,(A>=B)};	//00111
`ALUOp_bltu:C={31'b0,($unsigned(A)<$unsigned(B))};	//01000
`ALUOp_bgeu:C={31'b0,($unsigned(A)>=$unsigned(B))};	//01001
`ALUOp_slt:C={31'b0,(A<B)};				//01010
`ALUOp_sltu:C={31'b0,($unsigned(A)<$unsigned(B))};	//01011
`ALUOp_xor:C=A^B;	//01100
`ALUOp_or:C=A|B;	//01101
`ALUOp_and:C=A&B;	//01110
`ALUOp_sll:C=A<<B;	//01111
`ALUOp_srl:C=A>>B;	//10000
`ALUOp_sra:C=A>>>B;	//10001
      endcase
      //$display("B = 0x%8X", B); // used for debug
   end // end always
   assign Zero = (C == 32'b0);
   assign Overflow = ( A[31]&&B[31]|| ( (A[31]||B[31])&&!C[31] ) )?1:0;
   assign Lt =  C[`DATA_BUS_WIDTH-1];
   assign Ge = ~C[`DATA_BUS_WIDTH-1];
assign C_out=C;
endmodule
    
