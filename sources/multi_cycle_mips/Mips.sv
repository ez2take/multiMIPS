/**
 * MIPS CPUモジュール
 */
module Mips
  (input logic clk, reset, 	// clock,reset
   output logic [31:0] memoryAddress, writeData, //
   output logic MemWriteEnable,		 // 
   input logic [31:0] readData,
	output 	logic [31:0]	PC,
	output logic [1:0] ALUsourceB,
	output logic [3:0] dbgOpstate,
	output logic [5:0] opField,
	output logic InstrLatch);			//

   logic [5:0] functField;//,opField, ; // op field ,funct field of a instruction
   logic [1:0] WriteDataSelector; // data will be wrote in the register file(00: R-type, 01: lw, 10: PC)
	logic [1:0] RegDst; // address going to be wrote(00: rt, 01: rd, 10: 31)
	logic       InstructionOrData;		// if memoryAddress is instruction or data address(0: instruction)
	logic       ALUsourceA; // if sourceA of ALU is rs or PC(1: rs)
   //logic [1:0] ALUsourceB; // which is the sourceB of ALU(00: register, 01: 4, 10: imm, 11: shifted imm)
   logic [1:0] PCsource;	 // which is the source of the next Program Counter(00: PC+4, 01: base relative, 10: Pesudo direct)
   logic       PCEnable;		// PC writing enable
   logic       RegWriteEnable;   // register file writing enable
   logic [2:0] ALUControl;	// 
   logic       ALUResultZero;	//
	
                  
   controller c(//input
					 clk, reset,
					 opField, functField,
					 ALUResultZero,
					 //output
					 WriteDataSelector, RegDst,
					 InstructionOrData, ALUsourceA,
					 ALUsourceB,PCsource,
					 MemWriteEnable, PCEnable, RegWriteEnable,InstrLatch,
					 ALUControl,dbgOpstate);
					 
   datapath  dp(//input
					 clk, reset,
				    WriteDataSelector, RegDst,
					 InstructionOrData, ALUsourceA,
					 ALUsourceB,PCsource,
					 PCEnable, RegWriteEnable,InstrLatch,
					 ALUControl,
					 readData,
					 //output
					 opField,functField,
					 ALUResultZero,
					 writeData,memoryAddress,PC
					 );
   
endmodule // Mips





