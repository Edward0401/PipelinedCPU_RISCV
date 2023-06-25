`include "bus.v"
module PC( clk, rst,en, NPC, PC,this_pc,pcplus4);
  input              clk;
  input              rst;
  input              en;
  input       [31:0] NPC;
  output reg  [31:0] PC;
  output reg  [31:0] this_pc;
  output [31:0] pcplus4;
  
  PCPlus4 U_PCPlus4(PC, pcplus4);
  
  initial
    begin
        PC <= 32'h0000_0000;
        this_pc<=PC;
end
  
  
  always @(posedge clk, posedge rst) begin
    this_pc<=PC;
    //$display("PC%h",PC);
    //$display("NPC%h",NPC);
    if (rst) 
      PC <= 32'h0000_0000;
//      PC <= 32'h0000_3000;
    else if(en)
      PC <= NPC;
end
endmodule

//Simplified from NPC module in single cycle cpu.
module PCPlus4(PC,pcplus4);
   input  [31:0] PC;        // pc
   output reg [31:0] pcplus4;   // pc+4
   wire [31:0] PCPLUS4;
   assign PCPLUS4 = PC + 4; // pc + 4
   always @(*) begin
        pcplus4 = PCPLUS4;
   end // end always
endmodule

module pc_imm(input [`ADDR_BUS] pcE,input [`DATA_BUS]immoutE,output reg [31:0] PCoutE);//adder
  wire [`ADDR_BUS] PCPLUS;   
  assign PCPLUS = pcE + immoutE; // pc + 4
  always @(*) begin
       PCoutE = PCPLUS;
  end // end always
endmodule

