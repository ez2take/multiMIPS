module controller(input logic clk,reset,
						input logic [5:0]op,funct,
                  input logic zero,
                  output logic [1:0] WriteData,RegDst,
                  output logic InstructionOrData,ALUsourceA,
                  output logic [1:0] ALUsourceB,PCsource,
                  output logic MemWrite,PCEn,RegWrite,InstrLatch,
                  output logic [2:0] ALUControl,output logic [3:0] dbgOpstate);
    logic [1:0]ALUOp;
    logic      BranchEq,BranchNotEq,PCWrite;

    mainFSM mf(clk,reset,op,
					WriteData,RegDst,
					InstructionOrData,ALUsourceA,
					ALUsourceB,PCsource,
					MemWrite,
					PCWrite,BranchEq,BranchNotEq,
					RegWrite,InstrLatch,
                    ALUOp,dbgOpstate);
					
    aludec  ad(funct,ALUOp,ALUControl);

    assign PCEn = (BranchEq & zero) | (BranchNotEq & ~zero) | PCWrite;

endmodule