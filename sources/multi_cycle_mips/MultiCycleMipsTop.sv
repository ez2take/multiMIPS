/**
 * マルチサイクル版MIPSマシン
 */
module MultiCycleMipsTop
  (input logic clk, reset,	// clock,reset
   output logic [31:0] writeData, memoryAddress, // メモリ書き込み値、メモリアドレス
   output logic        memoryWriteEnable,output 	logic [31:0]	PC,
	output logic [31:0] readData,output logic [1:0] ALUsourceB,
	output logic [3:0] dbgOpstate,output logic [5:0] dbgopField,
   output logic dbgInstrLatch);	// メモリ読み込み); // メモリ書き込みイネーブル

   
   // プロセッサとメモリをインスタンス化
   Mips mips(clk, reset, memoryAddress, writeData, memoryWriteEnable,
				 readData,PC,ALUsourceB,dbgOpstate,dbgopField,dbgInstrLatch);
   Memory mem(clk, memoryWriteEnable, memoryAddress, writeData, readData);

endmodule // MipsMCTop