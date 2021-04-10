module sl2#(parameter WIDTH = 8)
			 (input logic [WIDTH-1:0] a,
           output logic [WIDTH-1:0] y);

    assign y = {a[WIDTH-3:0], 2'b00};
endmodule