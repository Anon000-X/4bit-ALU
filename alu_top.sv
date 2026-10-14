module alu_top(
	input logic [3:0] A,
	input logic [3:0] B,
	input logic [2:0] ALUControl,
	input logic C_IN,
	
	output logic [3:0] R,
	output logic N,
	output logic Z,
	output logic C,
	output logic V
);
	logic [3:0] add_result;
	logic add_carry;
	full_adder_4bit ADD(
		.A(A),
		.B(B),
		.C_IN(C_IN),
		.S(add_result),
		.C_OUT(add_carry)
	);
	
	logic [3:0] subtract_result;
	logic sub_carry;
	full_subtractor_4bit SUB(
		.A(A),
		.B(B),
		.S(subtract_result),
		.C_OUT(sub_carry)
	);
	
	logic [3:0] and_result;
	and_4bit UND(
		.A(A),
		.B(B),
		.OUT(and_result)
	);
	
	logic [3:0] or_result;
	or_4bit LOGICAL_ADD(
		.A(A),
		.B(B),
		.OUT(or_result)
	);
	
	logic [3:0] compare_equal;
	compare_equal_4bit EQUALITY(
		.A(A),
		.B(B),
		.OUT(compare_equal)
	);
	
	logic [3:0] compare_greater;
	compare_greater_than_4_bit BIGGER(
		.A(A),
		.B(B),
		.OUT(compare_greater)
	);
	
	assign R = (ALUControl == 3'b000) ? add_result : (ALUControl == 3'b001) ? subtract_result : (ALUControl == 3'b010) ? and_result : (ALUControl == 3'b011) ? or_result : (ALUControl == 3'b100) ? compare_equal : (ALUControl == 3'b101) ? compare_greater : 4'b0000;

	assign C = (ALUControl == 3'b000) ? add_carry : (ALUControl == 3'b001) ? sub_carry : 1'b0;

	assign V = (ALUControl == 3'b000) ? (A[3] & B[3] & (~R[3])) | (~(A[3]) & ~(B[3]) & R[3]) : (ALUControl == 3'b001) ? (A[3] ^ B[3]) & (A[3] ^ R[3]) : 1'b0;
	
	assign N = R[3];
	
	assign Z = (R == 4'b0000);
	
endmodule