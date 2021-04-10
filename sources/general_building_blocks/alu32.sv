module alu32(input  logic [31:0] a,b,
            input  logic [2:0] control,
            output logic [31:0] y,
            output logic zero);
    
    logic [31:0] b_sel,sum;
    assign b_sel = (control[2])? ~b:b;
    assign sum = a + b_sel + control[2];
    always_comb
        case(control[1:0])
            2'b00 : y = a & b_sel;
            2'b01 : y = a | b_sel;
            2'b10 : y = sum;
            2'b11 : y = sum[31];
        endcase
    assign zero = (y == 32'b0)? 1'b1:1'b0;
endmodule