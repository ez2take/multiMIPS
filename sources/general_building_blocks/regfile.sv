
module regfile(input logic clk,
               input logic we3,
               input logic [4:0] ra1,ra2,wa3,
               input logic [31:0] wd3,
               output logic [31:0] rd1,rd2);
    
    logic [31:0] rf[31:0];

    //this is a register file with 3 ports
    //first and second ports are for reading
    //third port is for writing at the positive edge of clk
    //register 0 is connected to 0
    //!! pipeline proccessor will use the negative edge of clk for writing 

    always_ff @(posedge clk)
        if(we3) rf[wa3] <= wd3;
    
    assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule