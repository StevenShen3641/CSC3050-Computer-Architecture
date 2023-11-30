module RegisterFile(
	input wire clk,
	// read channel A1
	input wire [4:0] a1,
	output wire [31:0] rd1,
	// read channel A2
	input wire [4:0] a2,
	output wire [31:0] rd2,
	// write channel A3
	input wire we3,
	input wire [4:0] a3,
	input wire [31:0] wd3
   );
	
	reg [31:0] regfile[1:31];
	
	always @(negedge clk) begin
		if (we3 && a3 != 0) begin
			regfile[a3] <= wd3;
		end
	end
	
	assign rd1 = (a1 == 0) ? 0 : regfile[a1];
	assign rd2 = (a2 == 0) ? 0 : regfile[a2];

endmodule
