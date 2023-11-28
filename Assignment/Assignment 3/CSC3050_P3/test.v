module test_alu();
    reg [15:0] d;
    reg [31:0] e;
    initial begin
        d = 59904;
        e = $signed(d);
        $display(e[15:0]);
    end
endmodule