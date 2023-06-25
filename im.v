
// instruction memory
module im(input  [11:2]  addr,
            output [31:0] dout );

  reg  [31:0] RAM[2047:0]; //8KB


  assign dout = RAM[addr]; // word aligned
endmodule  
