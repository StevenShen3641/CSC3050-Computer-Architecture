module test_alu();
    reg [3:0] d, e;
    reg [31:0] c;
    initial begin
        d = 4'b0000;
        e = 4'b0101;
        c = 32'b0;
        if (c == 32'b1) begin
            $display(1);
        end
        else $display(0);

        $display("%32b", c);
    end
endmodule