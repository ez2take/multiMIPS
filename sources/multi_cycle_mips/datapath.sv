
module datapath(  input logic clk,reset,
					   input logic [1:0] WriteData_Sel, // which data will be wrote in the register file(00: R-type, 01: lw, 10: PC)
						input logic [1:0] RegDst_Sel, // which is the address of the register going to be wrote in(00: rt, 01: rd, 10: 31)
						input logic       InstructionOrData_Sel,		// if memory address is instruction or data address(0: instruction)
						input logic       ALUsourceA_Sel, // if sourceA of ALU is rs or PC(1: rs)
						input logic [1:0] ALUsourceB_Sel, // which is the sourceB of ALU(00: register, 01: 4, 10: imm, 11: shifted imm)
						input logic [1:0] PCsource_Sel,	// which is the source of the next Program Counter(00: PC+4, 01: base relative, 10: Pesudo direct)
						input logic       PCWrite_Enable,	// PC writing enable
						input logic       RegWrite_Enable,   // register file writing enable
						input logic 	  InstrLatch,		//rewriting instruction 32bit bus
						input logic [2:0] ALUControl,	// 
						input logic [31:0]  ReadData,	//
						
						output logic [5:0] opField,functField,
						output logic 		 ALUResultZero,
						output logic [31:0]WriteData,
						output logic [31:0]memoryAddress,
						output 	logic [31:0]	PC
						);
	
	logic [31:0]	memreadBus;		//instruction or data (input)
	logic [31:0]	instrBus;		//latched instruction bus
	logic [4:0]		regwriteAddress;
	logic [31:0]	regwriteData;
	logic	[31:0]	regread1_decode;
	logic	[31:0]	regread2_decode;
	logic	[31:0]	regread1;
	logic [31:0]   regread2;
	logic [31:0]	ALUsourceA;
	logic [31:0]	ALUsourceB;

	logic [31:0]	ALUResult;
	logic [31:0]	nextPC;
	logic [31:0]	imm;
	logic [31:0]	shiftedimm;
	logic [27:0]	PesudoAddress;
	logic [31:0]	JumpAddress;
	logic [31:0]	ALUOut;
	
	//around memory(i/o)
	assign memreadBus = ReadData;
	assign WriteData   = regread2;
	assign opField = instrBus[31:26];
	assign functField = instrBus[5:0];
	latch_bus #(32) instrlatch(memreadBus,InstrLatch,instrBus);
	mux2 #(32) IorDmux(PC,ALUOut,InstructionOrData_Sel,memoryAddress);
	
	//around register file
	regfile registerfile(//input
						clk,RegWrite_Enable,
						instrBus[25:21],instrBus[20:16],
						regwriteAddress,regwriteData,
						//output
						regread1_decode,regread2_decode);
	
	mux3 #(5)  regwAdmux(instrBus[20:16],instrBus[15:11],5'b11111,
									 RegDst_Sel,regwriteAddress);
	mux3 #(32) regwDamux(ALUOut,memreadBus,PC,
									 WriteData_Sel,regwriteData);
	signext	  immextender(instrBus[15:0],imm);
	sl2  #(32) immshifter(imm,shiftedimm);		  
	flopr #(32)		 r1ff(clk,reset,regread1_decode,regread1);
	flopr #(32)		 r2ff(clk,reset,regread2_decode,regread2);
	
	//around ALU
	alu32		  ALU(//input
						ALUsourceA,ALUsourceB,ALUControl,
						//output
						ALUResult,ALUResultZero);
						
	mux2	#(32)srcAmux(PC,regread1,ALUsourceA_Sel,ALUsourceA);
	mux4	#(32)srcBmux(regread2,32'b100,imm,shiftedimm,ALUsourceB_Sel,ALUsourceB);
	flopr #(32)		aluoutff(clk,reset,ALUResult,ALUOut);
	
	//around Program Counter
	flopre #(32)	PCff(clk,reset,PCWrite_Enable,nextPC,PC);
	mux3	#(32)		nextPCmux(ALUResult,ALUOut,JumpAddress,PCsource_Sel,nextPC);
	assign JumpAddress = {PC[31:28],memreadBus[25:0],2'b00};
	
	
endmodule




