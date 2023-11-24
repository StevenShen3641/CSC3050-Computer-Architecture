`timescale 1ns/1ps
module test_CPU();
parameter T = 20;
reg clk;
reg rst_f;
wire is_display;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars;
  end

//初始化时钟
initial begin
    rst_f = 1'b1;
    clk = 1'b1;
    #10
    clk = 1'b0;
    rst_f = 1'b0;
    forever #(T/2) clk = ~clk;
end
initial begin
        #20000 $stop;
end
CPU uut(
    .clk (clk ),
    .rst_f(rst_f)
);
endmodule

