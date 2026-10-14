# 4-Bit ALU Using SystemVerilog

## Alright, Let's Start

A while ago, our Digital Design and Microprocessor lecture gave us an assignment about the ALU (Arithmetic Logic Unit). We had to build a 4-bit ALU with a 4-bit adder, a 4-bit subtractor, some logic circuits (AND and OR), comparators (EQUAL and GREATER THAN), and four flags: Carry, Overflow, Negative, and Zero.

Sounds simple enough, right? Well, there was one small decision to make before writing any code: **How the hell are we going to build this thing?**

There are two approaches to digital circuit design:

- **Top-down:** Design the ALU first, figure out what smaller modules it needs, and then implement those modules.
- **Bottom-up:** Build the smaller modules first, test them, and gradually combine them into a larger circuit.

I chose the bottom-up approach. Instead of throwing everything into one giant module and praying that it works, I decided to build the components one by one. Let's see how that went.

## 1. The Full Adder: One Bit at a Time

First, I created a **1-bit full adder**.

A full adder takes three 1-bit inputs: `A`, `B`, and `C_in` (carry-in). It produces two outputs: `S` (sum) and `C_out` (carry-out).

In other words, it adds two bits and whatever carry came from the previous stage. The equations are pretty straightforward:

```text
S     = A ^ B ^ C_in
C_out = (A & B) | (A & C_in) | (B & C_in)
```

That's it. One bit down, three inputs, two outputs. Not too scary.

### Building a Bigger Adder

But one bit isn't going to get us very far. We need to add 4-bit numbers, so we need to connect multiple full adders together.

The idea is simple: the carry-out of one stage becomes the carry-in of the next stage.

We can connect four 1-bit full adders to create a 4-bit adder. We could also build larger adders by connecting smaller ones, such as two 4-bit adders to create an 8-bit adder. This is the basic idea behind a **ripple-carry adder**.

Here's what the 4-bit addition looks like:

```text
          A_3 A_2 A_1 A_0
      +   B_3 B_2 B_1 B_0
                      C_in
    -----------------------
    C_out S_3 S_2 S_1 S_0
```

Notice that `C_in` enters the least significant bit, while the carry propagates through the adder until it reaches the final stage.

After putting everything together, we have our 4-bit full adder. Nice!

## 2. The Subtractor: Addition in Disguise

Now that we have an adder, why build a completely separate subtraction circuit from scratch?

Here's a little trick: **subtraction can be performed using addition.**

We know that:

```text
A - B = A + (-B)
```

But how do we represent a negative binary number in a digital circuit? Enter **two's complement**.

To obtain the two's complement of a binary number, we invert every bit and add 1:

```text
-B = ~B + 1
```

Therefore:

```text
A - B = A + ~B + 1
```

And look at that! We already have a full adder. All we need to do is invert the bits of `B` and set `C_in` to `1`.

```text
              A_3  A_2  A_1  A_0
        +    ~B_3 ~B_2 ~B_1 ~B_0
                             1
      ----------------------------
        C_out S_3  S_2  S_1  S_0
```

This is how I implemented the 4-bit subtractor using the adder I had already built. No need to reinvent the wheel.

One important detail: when performing unsigned subtraction this way, the final carry-out indicates **NOT BORROW**. If `C_out = 1`, no borrow occurred; if `C_out = 0`, a borrow occurred.

We'll come back to this when discussing the Carry flag.

## 3. Logic Operations: AND and OR

After all that binary arithmetic, the logic circuits are refreshingly simple.

For the AND operation, each bit of `A` is ANDed with the corresponding bit of `B`:

```text
S[i] = A[i] & B[i]
```

For the OR operation, we do the same thing with OR:

```text
S[i] = A[i] | B[i]
```

Here, `i` is the bit position from `0` to `3`.

That's pretty much it. No carry propagation, no two's complement, and no headaches. Just bitwise logic.

## 4. Comparators: Who's Bigger?

Now we need to compare two 4-bit numbers. I implemented two comparators: EQUAL and GREATER THAN.

### 4.1. EQUAL Comparator

The requirement was that the output should be `0001` if `A` equals `B`, and `0000` otherwise.

Since the result only needs to indicate TRUE or FALSE, we can force the upper three bits to zero:

```text
S[3] = 0
S[2] = 0
S[1] = 0
```

For the least significant bit, we use XNOR. Two bits produce `1` under XNOR when they are equal.

Therefore, all four pairs of bits must match:

```text
S[0] = (A[3] ~^ B[3]) & (A[2] ~^ B[2]) & (A[1] ~^ B[1]) & (A[0] ~^ B[0])
```

If every pair matches, `S[0] = 1`, and the output becomes `0001`. Otherwise, the output is `0000`.

Simple enough.

### 4.2. GREATER THAN Comparator

Next up: checking whether `A` is greater than `B`.

The output follows the same convention:

- `0001` if `A > B`
- `0000` otherwise

Again, the upper three bits are always zero. The only difference is the logic for `S[0]`.

For unsigned binary numbers, we compare the bits starting from the most significant bit. If the current bits differ, the number with a `1` at that position is larger. If they are equal, we move to the next bit.

Using that principle, the Boolean expression becomes:

```text
S[0] = (A[3] & ~B[3]) | ((A[3] ~^ B[3]) & (A[2] & ~B[2])) | ((A[3] ~^ B[3]) & (A[2] ~^ B[2]) & (A[1] & ~B[1])) | ((A[3] ~^ B[3]) & (A[2] ~^ B[2]) & (A[1] ~^ B[1]) & (A[0] & ~B[0]))
```

Yeah, that expression is getting a little ridiculous. But the idea is actually quite intuitive: check whether `A` is greater at the first bit position where the two numbers differ.

With that, both comparators are done!

## 5. The Flags: Four Little Indicators

We've built the arithmetic and logic circuits, along with the comparators. Now it's time to deal with the flags.

These flags tell us something about the result of an operation without requiring us to inspect every output bit manually.

### 5.1. Zero Flag (Z)

This one's easy.

The Zero flag is set when the result is exactly `0000`. In other words, all four result bits must be zero.

```text
Z = ~(S[3] | S[2] | S[1] | S[0])
```

If any result bit is `1`, then `Z = 0`. Otherwise, `Z = 1`.

### 5.2. Negative Flag (N)

For 4-bit signed two's-complement numbers, the most significant bit indicates the sign:

- `0`: non-negative
- `1`: negative

Therefore:

```text
N = S[3]
```

One thing to remember: this interpretation applies to the result when it is treated as a **signed two's-complement number**. For unsigned arithmetic, that same bit is simply the most significant bit.

### 5.3. Carry Flag (C)

The Carry flag is a little more interesting because its meaning depends on the operation.

For addition, we can use the final carry-out directly:

```text
C = C_out
```

For unsigned addition, this indicates that the result exceeded the range representable by 4 bits.

For subtraction implemented using two's complement, the carry-out has a slightly different interpretation. It indicates **NOT BORROW**:

- `C = 1`: no borrow occurred
- `C = 0`: a borrow occurred

In my implementation, I kept `C` as the carry-out signal for both addition and subtraction. This means the subtraction Carry flag represents NOT BORROW rather than BORROW.

### 5.4. Overflow Flag (V)

Finally, the Overflow flag. This one is important when working with **signed arithmetic**.

Remember that a 4-bit signed two's-complement number can only represent values from `-8` to `+7`. If an arithmetic operation produces a result outside this range, signed overflow occurs.

For addition, overflow happens when `A` and `B` have the same sign, but the result has a different sign.

For example:

```text
  0111  (+7)
+ 0001  (+1)
------
  1000  (-8, interpreted as signed)
```

The actual mathematical result is `+8`, but `+8` cannot be represented using 4-bit signed two's complement. The sign bit flips, so overflow occurs.

The Boolean expression is:

```text
V = ~(A[3] ^ B[3]) & (A[3] ^ S[3])
```

For subtraction, overflow happens when `A` and `B` have different signs, and the result has a different sign from `A`.

The expression becomes:

```text
V = (A[3] ^ B[3]) & (A[3] ^ S[3])
```

These two equations cover the signed overflow conditions for addition and subtraction, respectively.

And there we have it: all four flags are accounted for.

## 6. How to Run the Testbench

I used **Intel Quartus Prime** to work on the design, and a SystemVerilog simulation testbench to check whether the ALU behaved as expected.

To run the project, install Quartus Prime and follow its setup instructions. Then open the project, make sure the required SystemVerilog source files and testbench are included, and configure the simulator.

The exact simulation steps depend on your Quartus and simulator versions, so check the relevant tutorial for your setup.

Don't just trust the code because it compiles, though. Run the testbench and check the results. An ALU that compiles successfully but gives the wrong answer is still a broken ALU.

## 7. What's Next?

And there you have it: a 4-bit ALU built from smaller, reusable SystemVerilog modules.

Will this revolutionize computer engineering? Absolutely not.

Can it do anything particularly useful on its own? Not really. It's a tiny ALU with a grand total of four bits to work with.

But hey, everyone has to start somewhere.

My next plan is to add registers and gradually upgrade this design into a 32-bit ALU. That would be a much more interesting project, and hopefully a lot more useful than this little piece of digital junk.

For now, though, I'm happy that the thing works.

Thank you for reading!
