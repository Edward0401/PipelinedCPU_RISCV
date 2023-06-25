`include "ctrl_encode_def.v"
// data memory
module dm(clk, DMWr, addr, din, dout,DMType,pc,addr_raw); //DM_Controller
   input          clk;
   input          DMWr;
   input  [2:0]   DMType;
   input  [11:2]  addr; //8KB
   input  [31:0]  din;
   input  [31:0]  pc;
   input  [31:0]  addr_raw;
   output [31:0]  dout;
   
   wire [3:0] wea;
   assign wea[0]=(DMType<=4)&&DMWr;
   assign wea[1]=(DMType<=2)&&DMWr;
   assign wea[2]=(DMType==0)&&DMWr;
   assign wea[3]=wea[2];
   wire [`DATA_BUS] dout_raw;
   wire [`DATA_BUS] din_processed;
   dmem real_dm(.clk(clk),.wea(wea),.addr(addr_raw),.wd(din_processed),.rd(dout_raw));

//    reg [31:0] dmem[2047:0];
   
   //write logic
//    always @(*/*posedge clk*/)
//       if (DMWr) begin
// 	case(DMType)
// 	`dm_word:begin
//         //dout_raw <= din;
// 		din_processed <= din;
// 	end
// 	`dm_halfword:begin
// 		din_processed <= {{16{din[15]}}, din[15:0]};
// 	end
// 	`dm_halfword_unsigned:begin
// 		din_processed  <= din[15:0];
// 	end
// 	`dm_byte:begin
// 		din_processed  <= {{24{din[7]}}, din[7:0]};
// 	end
// 	`dm_byte_unsigned:begin
// 		din_processed  <= din[7:0];
// 	end
// 	endcase
//         $display("pc = %h: dataaddr = %h, memdata = %h", pc,addr_raw, din_processed); 
//     end
	assign din_processed[7:0] = din[7:0];
	assign din_processed[15:8] = (DMType==`dm_byte_unsigned)?8'b0:((DMType==`dm_byte)?{8{din[7]}}:din[15:8]);
	assign din_processed[31:16] = (DMType==`dm_halfword_unsigned)?16'b0:((DMType==`dm_halfword)?{16{din[15]}}:din[31:16]);
   
   //read logic
//    reg    [31:0]  dtmp;
//    always @(*) begin
// 		case(DMType)
// 			`dm_word: dtmp <= dout_raw;
// 			`dm_halfword: dtmp <= {{16{dout_raw[15]}},dout_raw[15:0]};
// 			`dm_halfword_unsigned: dtmp <= {16'b0,dout_raw[15:0]};
// 			`dm_byte: dtmp <= {{24{dout_raw[7]}},dout_raw[7:0]};
// 			`dm_byte_unsigned: dtmp <= {24'b0,dout_raw[7:0]};
// 		endcase
// 		$display("pc = %h: dataaddr = %h, readdata = %h", pc,addr_raw, dout_raw); 
//     end
//       assign dout = dtmp;
	assign dout[7:0] = dout_raw[7:0];
	assign dout[15:8] = (DMType==`dm_byte_unsigned)?8'b0:((DMType==`dm_byte)?{8{dout_raw[7]}}:dout_raw[15:8]);
	assign dout[31:16] = (DMType==`dm_halfword_unsigned||DMType==`dm_byte_unsigned)?16'b0
                        :( (DMType==`dm_halfword)?{16{dout_raw[15]}}:
                           ((DMType==`dm_byte)?{16{dout_raw[7]}}:dout_raw[31:16])
                        );
endmodule

module dmem(input           	      clk,
			input  [3:0]			  wea,
			input  [`ADDR_BUS]		  addr,
            input  [`DATA_BUS]        wd,
            output [`DATA_BUS]        rd);

  reg  [7:0] RAM[8191:0];
  reg [31:0] rtmp;
  always @(*) 
		rtmp <= {RAM[addr+3],RAM[addr+2],RAM[addr+1],RAM[addr]};

  assign rd = rtmp; // word aligned

  always @(posedge clk)
      begin
		if(wea[0])
			RAM[addr] <= wd[7:0];
		if(wea[1])
			RAM[addr+1] <= wd[15:8];
		if(wea[2])
			RAM[addr+2] <= wd[23:16];
		if(wea[3])
			RAM[addr+3] <= wd[31:24];
		end
endmodule
