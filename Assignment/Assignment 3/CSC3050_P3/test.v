module test_alu();
    reg [31:0] d, e;
    reg [31:0] c;
    initial begin
        d = 32'b11111111_11111111_10000000_00000000;
        e = 32'b01111111_11111111_11111111_11111111;
        if ($signed(e) < $signed(d))
            c = 1;
        $display(c);
    end
endmodule