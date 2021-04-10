/**
 * メモリ・モジュール
 */
module Memory
  (input logic clk, writeEnable, // クロック、メモリ書き込みイネーブル
   input logic [31:0]  address, writeData, // メモリ・アドレス(ワード単位指定)、書き込み値
   output logic [31:0] readData);	  // 読み込み値
	
	
	IP_RAM32_128 ram(address[8:2],clk,writeData,writeEnable,readData);
endmodule // Memory
