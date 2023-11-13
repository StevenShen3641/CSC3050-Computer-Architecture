module test_alu();
    reg signed [3:0] a, b;
    reg [3:0] d, e;
    reg [31:0] c;
    initial begin
        b = 4'b1100;
        d = 4'b0111;
        e = 4'b1001;
        c = {{16{1'b1}}, 16'b0};
        $display("%4b", $signed(d) - $signed(e));
        $display("%4b", d - e);
    end
endmodule