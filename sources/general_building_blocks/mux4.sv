module mux4 #(parameter WIDTH = 8)
				(input logic [WIDTH-1:0] d0,d1,d2,d3,
				 input logic [1:0] s,
				 output logic [WIDTH-1:0] y);
		logic [WIDTH-1:0] a,b;
		mux2 #(WIDTH) mux2_a(d0,d1,s[0],a);
		mux2 #(WIDTH) mux2_b(d2,d3,s[0],b);
		mux2 #(WIDTH) mux2_c(a,b,s[1],y);
endmodule