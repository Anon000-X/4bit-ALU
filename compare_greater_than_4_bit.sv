module compare_greater_than_4_bit(
	input logic [3:0] A,
	input logic [3:0] B,
	output logic [3:0] OUT 
);

	assign OUT[3] = 0;
	assign OUT[2] = 0;
	assign OUT[1] = 0;
	assign OUT[0] = (A[3] & ~B[3]) | ((A[3] ~^ B[3]) & (A[2] & ~B[2])) | ((A[3] ~^ B[3]) & (A[2] ~^ B[2]) & (A[1] & ~B[1])) | ((A[3] ~^ B[3]) & (A[2] ~^ B[2]) & (A[1] ~^ B[1]) & (A[0] & ~B[0]));
endmodule