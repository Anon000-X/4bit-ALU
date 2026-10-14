module full_adder_2bit(
	input logic [1:0] A,
	input logic [1:0] B,
	input logic C_IN,
	output logic [1:0] S,
	output logic C_OUT
);
	logic C1;
	full_adder_1bit FA0(
		.A(A[0]),
		.B(B[0]),
		.C_IN(C_IN),
		.S(S[0]),
		.C_OUT(C1)
	);
	
	full_adder_1bit FA1(
		.A(A[1]),
		.B(B[1]),
		.C_IN(C1),
		.S(S[1]),
		.C_OUT(C_OUT)
	);
	
endmodule