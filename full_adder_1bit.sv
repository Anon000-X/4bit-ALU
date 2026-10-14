module full_adder_1bit(
	input logic  A,
	input logic  B,
	input logic C_IN,
	output logic S,
	output logic C_OUT
);
	assign S = A ^ B ^ C_IN;
	assign C_OUT = (A & B) | (A & C_IN) | (B & C_IN);
endmodule