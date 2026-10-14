module and_4bit(
	input [3:0] A,
	input [3:0] B,
	output [3:0] OUT
);
	assign OUT =  A & B;
endmodule