module full_adder_4bit(
	input logic [3:0] A,
	input logic [3:0] B,
	input logic C_IN,
	output logic [3:0] S,
	output logic C_OUT
);

	logic C_MIDDLE;
	full_adder_2bit FA10(
		.A(A[1:0]),
		.B(B[1:0]),
		.C_IN(C_IN),
		.S(S[1:0]),
		.C_OUT(C_MIDDLE)
	);
	
	full_adder_2bit FA32(
		.A(A[3:2]),
		.B(B[3:2]),
		.C_IN(C_MIDDLE),
		.S(S[3:2]),
		.C_OUT(C_OUT)
	);
endmodule