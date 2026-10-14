module full_subtractor_4bit(
	input logic [3:0] A,
	input logic [3:0] B,
	output logic [3:0] S,
	output logic C_OUT
);
	logic [3:0] B_BAR;
	assign B_BAR = ~B;
	
	full_adder_4bit result(
		.A(A),
		.B(B_BAR),
		.C_IN(1'b1),
		.S(S),
		.C_OUT(C_OUT)
	);
endmodule