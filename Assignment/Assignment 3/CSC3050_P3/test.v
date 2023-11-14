module test_alu();
    reg [3:0] d, e;
    reg [31:0] c;
    initial begin
        d = 4'b0101;
        c = $signed(d);

        $display("%32b", c);
    end
endmodule