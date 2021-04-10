// Modelsim-Altera requires a timescale directive
`timescale 1 ns / 100 ps
module test1_multimips();
    logic clk;
    logic reset;

    logic [31:0] writedata, dataadr;
    logic        memwrite;
	 logic [31:0]	PC,readData;
	 logic [1:0] ALUsourceB;
	 logic [3:0] dbgOpstate;
	 logic [5:0] dbgopField;
     logic dbgOPFieldWrite;
    //instance
    MultiCycleMipsTop dut (clk, reset, writedata, dataadr, memwrite,
						PC,readData,ALUsourceB,dbgOpstate,dbgopField,dbgOPFieldWrite);

    //initiallize
    initial 
        begin
            reset <= 1; #22;reset<= 0;
        end
    
    //produce clk
    always
        begin
            clk<=1; #5; clk <= 0; #5;
        end
    
    //check the result
    always @(negedge clk)
        begin 
            if(memwrite) begin
                if(dataadr === 80 & writedata === 7) begin
                    $display("simulation succeeded");
                    $finish;
                end else if(dataadr !== 80) begin
                    $display("simulation failed");
                    $finish;
                end
            end
        end
endmodule