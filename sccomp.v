module xgriscv_pipeline(clk, rstn, pcW);
   input          clk;
   input          rstn;
   output [31:0]  pcW;
   wire [31:0]    pcF;      
   wire [31:0]    instr;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   reg  [4:0]  reg_sel;
   wire [31:0] reg_data;
   wire [2:0]     DMType;
       
  // instantiation of single-cycle CPU   
   CPU U_CPU(
         .clk(clk),                 // input:  cpu clock
         .reset(rstn),                 // input:  reset
         .instr(instr),             // input:  instruction
         .readdataM(dm_dout),        // input:  data to cpu  
         .memwriteM(MemWrite),       // output: memory write signal
         .pcF(pcF),                   // output: PC
         .pcW(pcW),
         .Addr_out(dm_addr),          // output: address from cpu to memory
         .writedataM(dm_din),        // output: data from cpu to memory
         .reg_sel(reg_sel),         // input:  register selection
         .reg_data(reg_data),        // output: register data
	      .DMType(DMType)
         );
         
  // instantiation of data memory  
   dm    U_DM(
         .clk(clk),           // input:  cpu clock
         .DMWr(MemWrite),     // input:  ram write
         .addr(dm_addr[11:2]), // input:  ram address,8KB
         .din(dm_din),        // input:  data to ram
         .dout(dm_dout),       // output: data from ram
	 .DMType(DMType),      // input: DataMemoryType
	 .pc(pcF),
	 .addr_raw(dm_addr)
     );
         
  // instantiation of intruction memory (used for simulation)
   im    U_imem ( 
      .addr(pcF[11:2]),     // input:  rom address,8KB
      .dout(instr)        // output: instruction
   );
   //assign pcW=pc-4;
endmodule
