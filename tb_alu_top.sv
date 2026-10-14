`timescale 1ns/1ps

module tb_alu_top;

    // Inputs
    logic [3:0] A;
    logic [3:0] B;
    logic [2:0] ALUControl;
    logic C_IN;

    // Outputs
    logic [3:0] R;
    logic N;
    logic Z;
    logic C;
    logic V;

    // DUT
    alu_top DUT (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .C_IN(C_IN),
        .R(R),
        .N(N),
        .Z(Z),
        .C(C),
        .V(V)
    );

    // Task dùng để kiểm tra kết quả
    task automatic check_result(
        input logic [3:0] expected_R,
        input logic expected_N,
        input logic expected_Z,
        input logic expected_C,
        input logic expected_V
    );
        begin
            #1;

            assert (R === expected_R)
                else $error("R WRONG: expected=%b, got=%b",
                            expected_R, R);

            assert (N === expected_N)
                else $error("N WRONG: expected=%b, got=%b",
                            expected_N, N);

            assert (Z === expected_Z)
                else $error("Z WRONG: expected=%b, got=%b",
                            expected_Z, Z);

            assert (C === expected_C)
                else $error("C WRONG: expected=%b, got=%b",
                            expected_C, C);

            assert (V === expected_V)
                else $error("V WRONG: expected=%b, got=%b",
                            expected_V, V);
        end
    endtask


    initial begin

        // ============================================================
        // ADD
        // ============================================================

        // Test 1: 7 + 9 = 16 -> 4'b0000, Carry = 1
        // 7  = 0111
        // 9  = 1001
        //      ----
        //     1 0000
        // Signed: 7 + (-7) = 0 -> no overflow
        A = 4'b0111;
        B = 4'b1001;
        C_IN = 1'b0;
        ALUControl = 3'b000;

        check_result(
            4'b0000,   // R
            1'b0,      // N
            1'b1,      // Z
            1'b1,      // C
            1'b0       // V
        );


        // Test 2: 7 + 3 = 10 -> Overflow
        // Signed 4-bit:
        //  0111 = +7
        //  0011 = +3
        //  ----
        //  1010 = -6
        //
        // Hai số dương cộng nhau nhưng kết quả âm => V = 1
        A = 4'b0111;
        B = 4'b0011;
        C_IN = 1'b0;
        ALUControl = 3'b000;

        check_result(
            4'b1010,   // R
            1'b1,      // N
            1'b0,      // Z
            1'b0,      // C
            1'b1       // V
        );


        // ============================================================
        // SUB
        // ============================================================

        // Test 3: 5 - 3 = 2 -> No borrow
        // 0101 - 0011 = 0010
        //
        // C = 1 vì không có borrow
        A = 4'b0101;
        B = 4'b0011;
        C_IN = 1'b0;
        ALUControl = 3'b001;

        check_result(
            4'b0010,   // R
            1'b0,      // N
            1'b0,      // Z
            1'b1,      // C = no borrow
            1'b0       // V
        );


        // Test 4: 3 - 5 = -2 -> Borrow
        // 0011 - 0101 = 1110 (-2)
        //
        // Borrow xảy ra => C = 0
        A = 4'b0011;
        B = 4'b0101;
        C_IN = 1'b0;
        ALUControl = 3'b001;

        check_result(
            4'b1110,   // R = -2
            1'b1,      // N
            1'b0,      // Z
            1'b0,      // C = borrow
            1'b0       // V
        );


        // ============================================================
        // AND
        // ============================================================

        // Test 5: 1100 AND 1010 = 1000
        A = 4'b1100;
        B = 4'b1010;
        C_IN = 1'b0;
        ALUControl = 3'b010;

        check_result(
            4'b1000,
            1'b1,      // N
            1'b0,      // Z
            1'b0,      // C
            1'b0       // V
        );


        // ============================================================
        // OR
        // ============================================================

        // Test 6: 0100 OR 0011 = 0111
        A = 4'b0100;
        B = 4'b0011;
        C_IN = 1'b0;
        ALUControl = 3'b011;

        check_result(
            4'b0111,
            1'b0,      // N
            1'b0,      // Z
            1'b0,      // C
            1'b0       // V
        );


        // ============================================================
        // COMPARISON
        // ============================================================

        // Test 7: A = B
        // 0101 == 0101 -> 0001
        A = 4'b0101;
        B = 4'b0101;
        C_IN = 1'b0;
        ALUControl = 3'b100;

        check_result(
            4'b0001,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );


        // Test 8: A > B
        // 1000 > 0011 -> 0001
        A = 4'b1000;
        B = 4'b0011;
        C_IN = 1'b0;
        ALUControl = 3'b101;

        check_result(
            4'b0001,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );


        // Test 9: A < B
        // 0011 < 1000 -> 0000
        A = 4'b0011;
        B = 4'b1000;
        C_IN = 1'b0;
        ALUControl = 3'b101;

        check_result(
            4'b0000,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );


        $display("====================================");
        $display("ALL ALU TESTS PASSED!");
        $display("====================================");

        $finish;
    end

endmodule