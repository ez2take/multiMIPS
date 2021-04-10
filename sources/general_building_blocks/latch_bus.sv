module latch_bus #(parameter WIDTH = 8)
            (input logic [WIDTH-1:0] d,
             input logic  en,
             output logic [WIDTH-1:0] y);
    always_latch
        if(en) y <= d;
endmodule