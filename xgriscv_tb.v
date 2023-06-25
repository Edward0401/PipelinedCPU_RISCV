//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// testbench for simulation
//
// ====================================================================
//addi,lui,sw,sb,lw, 
`include "xgriscv_defines.v"

module xgriscv_tb();
    
   reg                  clk, rstn;
   wire[`ADDR_SIZE-1:0] pcW;
    
   // instantiation of xgriscv 
   xgriscv_pipeline xgriscvp(clk, rstn, pcW);

   integer counter = 0;
   
   initial begin
      $readmemh("Test_37_Instr.dat", xgriscvp.U_imem.RAM);
      clk = 1;
      rstn = 1;
      #5 ;
      rstn = 0;
   end
   
   always begin
      #(50) clk = ~clk;
     
      if (clk == 1'b1) 
      begin
         counter = counter + 1;
      $display("clock: %d", counter);
      // $display("pc::%h", xgriscvp.pcF);
      // $display("instr:%h",xgriscvp.instr);
      // $display("pcF:%h pcD:%h pcplus4F:%h pcplus4D:%h instrF:%h instrD:%h", xgriscvp.U_CPU.pcF, xgriscvp.U_CPU.pcD, xgriscvp.U_CPU.pcplus4F, xgriscvp.U_CPU.pcplus4D, xgriscvp.U_CPU.instrF, xgriscvp.U_CPU.instrD);
      // $display("");
      // $display("writenE:%h flushE:%h rdata1D:%h srca1E:%h rdata2D:%h srcb1E:%h",xgriscvp.U_CPU.writenE, xgriscvp.U_CPU.flushE, xgriscvp.U_CPU.rdata1D, xgriscvp.U_CPU.srca1E, xgriscvp.U_CPU.rdata2D, xgriscvp.U_CPU.srcb1E);
      // $display("immoutD:%h immoutE:%h rs1D:%h rs1E:%h rs2D:%h rs2E:%h rdD:%h rdE:%h pcD:%h pcE:%h pcplus4D:%h pcplus4E:%h",xgriscvp.U_CPU.immoutD, xgriscvp.U_CPU.immoutE, xgriscvp.U_CPU.rs1D, xgriscvp.U_CPU.rs1E, xgriscvp.U_CPU.rs2D, xgriscvp.U_CPU.rs2E, xgriscvp.U_CPU.rdD, xgriscvp.U_CPU.rdE, xgriscvp.U_CPU.pcD, xgriscvp.U_CPU.pcE, xgriscvp.U_CPU.pcplus4D, xgriscvp.U_CPU.pcplus4E);
      // $display("srcaE:\t\t%h srcbE:\t\t%h", xgriscvp.U_CPU.srcaE,xgriscvp.U_CPU.srcbE);
      // $display("ALUOpE:%h",xgriscvp.U_CPU.ALUOpE);
      // $display("aluoutE:\t\t%h", xgriscvp.U_CPU.aluoutE);
      // $display("");
      // $display("srcb1E:%h srcb1M:%h aluoutE:%h aluoutM:%h srcb:%h writedataM:%h",xgriscvp.U_CPU.srcb1E, xgriscvp.U_CPU.srcb1M, xgriscvp.U_CPU.aluoutE, xgriscvp.U_CPU.aluoutM, xgriscvp.U_CPU.srcb, xgriscvp.U_CPU.writedataM);
      // $display("rdE:%h rdM:%h pcE:%h pcM:%h pcplus4E:%h pcplus4M:%h PCoutE:%h PCoutM",xgriscvp.U_CPU.rdE, xgriscvp.U_CPU.rdM, xgriscvp.U_CPU.pcE, xgriscvp.U_CPU.pcM, xgriscvp.U_CPU.pcplus4E, xgriscvp.U_CPU.pcplus4M, xgriscvp.U_CPU.PCoutE, xgriscvp.U_CPU.PCoutM);
      // $display("");
      // $display("CtrMW:%h CtrWB:%h dmoutM:%h dmoutW:%h aluoutM:%h aluoutW:%h rdM:%h rdW:%h",xgriscvp.U_CPU.CtrMW, xgriscvp.U_CPU.CtrWB, xgriscvp.U_CPU.dmoutM, xgriscvp.U_CPU.dmoutW, xgriscvp.U_CPU.aluoutM, xgriscvp.U_CPU.aluoutW, xgriscvp.U_CPU.rdM, xgriscvp.U_CPU.rdW);
      // $display("pcM:%h pcWt:%h pcplus4M:%h pcplus4W:%h PCoutM:%h PCoutW:%h",xgriscvp.U_CPU.pcM, xgriscvp.U_CPU.pcWt, xgriscvp.U_CPU.pcplus4M, xgriscvp.U_CPU.pcplus4W, xgriscvp.U_CPU.PCoutM, xgriscvp.U_CPU.PCoutW);        // //$display("r1D:\t\t%h r2D:\t\t%h", xgriscvp.U_CPU.rdata1D,xgriscvp.U_CPU.rdata2D);

      //    $display("pcw:\t\t%h", pcW);
	      //$display("rf08-11:\t %h %h %h %h", xgriscvp.U_xgriscv.dp.rf.rf[8], xgriscvp.U_xgriscv.dp.rf.rf[9], xgriscvp.U_xgriscv.dp.rf.rf[10], xgriscvp.U_xgriscv.dp.rf.rf[11]);
         //$display("rf12-15:\t %h %h %h %h", xgriscvp.U_xgriscv.dp.rf.rf[12], xgriscvp.U_xgriscv.dp.rf.rf[13], xgriscvp.U_xgriscv.dp.rf.rf[14], xgriscvp.U_xgriscv.dp.rf.rf[15]);
         if (pcW == 32'h00000878) // set to the address of the last instruction
          begin
            //$display("pcW:\t\t%h", pcW);
            //$finish;
            $stop;
          end
      end
      
   end //end always
   
endmodule
