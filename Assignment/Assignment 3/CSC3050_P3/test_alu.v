// `include "alu.v"

`timescale 1ns/1ps

module test_alu();
    reg[31:0] instruction, regA, regB;
    wire[31:0] result;
    wire[2:0] flags;

    alu test(
        .instruction (instruction),
        .regA (regA),
        .regB (regB),
        .result (result), 
        .flags (flags)
    );

    initial begin
        $monitor("Time: %3d.\n Instruction: %32b\n regA: %32b, regB: %32b\n result: %32b, flags: %3b\n",
        $time, instruction, regA, regB, result, flags);

        // addu
        #1
        $display("addu");
        instruction = 32'b000000_00000_00001_00000_00000_100001;
        regA = 32'b1;
        regB = 32'b11111111_11111111_11111111_11111110; 

        // addiu
        #1
        $display("addiu");
        instruction = 32'b001001_00000_00001_0111111111111111;
        regA = 32'b01111111_11111111_11111111_11111111;
        regB = 32'b1;

    end

endmodule
