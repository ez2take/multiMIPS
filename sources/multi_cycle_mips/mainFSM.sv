module mainFSM
  (input logic clk, reset,			   // clock,reset
   input logic [5:0]  opField, // code of instruction
   output logic [1:0] WriteData, //00:ALU out,01:memory,10:PC 		data to write register from 
   output logic [1:0] RegDst, //00:rt,01:rd,10:31		 				address to write register of 
   output logic 		 InstructionOrData, //0:instruction,1:data 	source of memory address input 
   output logic 		 ALUsourceA, //0:PC, 1:register
   output logic [1:0] ALUsourceB, //00:register ,01:4 ,10:sign extended imm, 11:sign extended &2bit left shifted imm
   output logic [1:0] PCsource,	  //00:PC+4, 01:base relative addressing, 10:Pseudo direct addressing
	output logic 		 MemWrite,	  //memory writing enable bit
	output logic 		 PCWrite,	  //Program Counter register writing enable bit
	output logic 		 BranchEq,
	output logic 		 BranchNotEq,
	output logic 		 RegWrite,
	output logic 		 InstrLatch,	//enable bit of rewriting instruction bus
	output logic [1:0] ALUOp,
	output logic [3:0] dbgOpstate);
	
	
   typedef enum       logic [3:0] {S0Fetch, S1Decode, S2MemAddr, S3MemRead, S4MemWriteback,
				   S5MemWrite, S6Execute, S7ALUWriteback, S8Branch, 
				   S9Addi, S10AddiWriteback, S11Jump,S12Link,S13BranchNot} state_t;
			
   parameter OPlw = 6'b100011;	// lw instruction
   parameter OPRtype = 6'b000000; // R-type instruction
   parameter OPsw = 6'b101011;	  // sw instruction
   parameter OPbeq = 6'b000100;	  // beq instruction
   parameter OPaddi = 6'b001000; // addi instruction
   parameter OPj = 6'b000010; // J instruction
	parameter OPjal = 6'b000011; // Jal
	parameter OPbne = 6'b000101; //bne
	

   state_t opState;
	assign dbgOpstate = opState;

   always_ff @(posedge clk, posedge reset)
     if (reset) opState <= S0Fetch;
     else
       case (opState)
	 S0Fetch: 
	   opState <= S1Decode;
	 S1Decode:
	   if (opField == OPlw)
	     opState <= S2MemAddr;
		else if (opField == OPsw)
		  opState <= S2MemAddr;
	   else if (opField == OPRtype)
	     opState <= S6Execute;
	   else if (opField == OPbeq)
	     opState <= S8Branch;
	   else if (opField == OPaddi)
	     opState <= S9Addi;
	   else if (opField == OPj)
	     opState <= S11Jump;
		else if (opField == OPjal)
	     opState <= S12Link;
		else if (opField == OPbne)
	     opState <= S13BranchNot;
	 S2MemAddr:
	   if (opField == OPlw)
	     opState <= S3MemRead;
	   else if (opField == OPsw)
	     opState <= S5MemWrite;
	 S3MemRead:
	   opState <= S4MemWriteback;
	 S4MemWriteback:
	   opState <= S0Fetch;
	 S5MemWrite:
	   opState <= S0Fetch;
	 S6Execute:
	   opState <= S7ALUWriteback;
	 S7ALUWriteback:
	   opState <= S0Fetch;
	 S8Branch:
	   opState <= S0Fetch;
	 S9Addi:
	   opState <= S10AddiWriteback;
	 S10AddiWriteback:
	   opState <= S0Fetch;
	 S11Jump:
		opState <= S0Fetch;
	 S12Link:
		opState <= S11Jump;
	 S13BranchNot:
		opState <= S0Fetch;
	 default:
	   opState <= S0Fetch;
       endcase // case (opState)

   always_comb
     case (opState)
       S0Fetch:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b0;	//Instruction
		 ALUsourceA				= 1'b0;	//PC
		 ALUsourceB				= 2'b01;	//4
		 PCsource				= 2'b00;	//PC+4
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b1;	//enable
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b00;	//+
	 	 InstrLatch				= 1'b0;
	 end
       S1Decode:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b0;	
		 ALUsourceA				= 1'b0;	//PC
		 ALUsourceB				= 2'b11;	//shifted and extended imm
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b00;	//+
	 	 InstrLatch				= 1'b1;	//enable
	 end
       S2MemAddr:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b0;	
		 ALUsourceA				= 1'b1;	//register	
		 ALUsourceB				= 2'b10;	//imm
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b00; //+	
	 	 InstrLatch				= 1'b0;
	 end
       S3MemRead:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b1;  //Data		
		 ALUsourceA				= 1'b0;	
		 ALUsourceB				= 2'b00;	
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b00;	
	 	 InstrLatch				= 1'b0;
	 end
       S4MemWriteback:
	 begin
	    WriteData 				= 2'b01;	//memory
		 RegDst					= 2'b00;	//rt
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b0;	
		 ALUsourceB				= 2'b00;	
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b1;	//enable
		 ALUOp					= 2'b00;
	 	 InstrLatch				= 1'b0;
	 end
       S5MemWrite:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b1;	//Data		
		 ALUsourceA				= 1'b0;	
		 ALUsourceB				= 2'b00;	
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b1;	//enable
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b00;
	 	 InstrLatch				= 1'b0;
	 end
       S6Execute:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b1;	//register	
		 ALUsourceB				= 2'b00;	//register
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b10;	//R-type
	 	 InstrLatch				= 1'b0;
	 end
       S7ALUWriteback:
	 begin
	    WriteData 				= 2'b00;	//ALUout
		 RegDst					= 2'b01;	//rd
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b0;	
		 ALUsourceB				= 2'b00;	
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b1;	//enable	
		 ALUOp					= 2'b00;
	 	 InstrLatch				= 1'b0;
	 end
       S8Branch:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b1;	//register	
		 ALUsourceB				= 2'b00;	//register
		 PCsource				= 2'b01;	//base relative addressing
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b1;	//enable	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b01;	//-
	 	 InstrLatch				= 1'b0;
	 end
       S9Addi:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b1;	//register	
		 ALUsourceB				= 2'b10;	//imm	
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b00;	//+
	 	 InstrLatch				= 1'b0;
	 end
       S10AddiWriteback:
	 begin
	    WriteData 				= 2'b00;	//ALU out
		 RegDst					= 2'b00;	//rt
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b0;	
		 ALUsourceB				= 2'b00;	
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b1;	//enable	
		 ALUOp					= 2'b00;
	 	 InstrLatch				= 1'b0;
	 end
       S11Jump:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b0;	
		 ALUsourceB				= 2'b00;	
		 PCsource				= 2'b10;	//Pesudo dierect addressing	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b1;	//enable
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b00;
	 	 InstrLatch				= 1'b0;
	 end
	    S12Link:
	 begin
	    WriteData 				= 2'b10;	//PC
		 RegDst					= 2'b10;	//31
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b0;	
		 ALUsourceB				= 2'b00;	
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b1;	//enable	
		 ALUOp					= 2'b00;
	 	 InstrLatch				= 1'b0;
	 end
	    S13BranchNot:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b1;	//register	
		 ALUsourceB				= 2'b00;	//register
		 PCsource				= 2'b01;	//base relative addressing
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b1;	//enable	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b00;
	 	 InstrLatch				= 1'b0;
	 end
       default:
	 begin
	    WriteData 				= 2'b00;
		 RegDst					= 2'b00;	
		 InstructionOrData	= 1'b0;		
		 ALUsourceA				= 1'b0;	
		 ALUsourceB				= 2'b00;	
		 PCsource				= 2'b00;	
		 MemWrite				= 1'b0;	
		 PCWrite					= 1'b0;	
		 BranchEq				= 1'b0;	
		 BranchNotEq			= 1'b0;	
		 RegWrite				= 1'b0;	
		 ALUOp					= 2'b00;
	 	 InstrLatch				= 1'b0;
	 end
     endcase // case (opState)
   
endmodule // MainController