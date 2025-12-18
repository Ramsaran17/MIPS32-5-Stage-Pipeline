`timescale 1ns / 1ps

module tb_mips_factorial;
    reg clk1, clk2;
    integer k;

    // Instantiate the processor
    pipe_MIPS32 mips (
        .clk1(clk1), 
        .clk2(clk2)
    );

    // Two-phase clock generation
    initial begin
        clk1 = 0; clk2 = 0;
        forever begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end

    initial begin
        // 1. Initialize Processor State
        mips.PC = 0;
        mips.HALTED = 0;
        mips.TAKEN_BRANCH = 0;

        // 2. Initialize Register File: Reg[k] = k
        for (k = 0; k < 32; k = k + 1)
            mips.Reg[k] = k;

        // 3. Load Factorial Program (from your images)
        mips.Mem[0]  = 32'h280a00c8; // ADDI  R10, R0, 200 (Base Address)
        mips.Mem[1]  = 32'h28020001; // ADDI  R2, R0, 1     (Product = 1)
        mips.Mem[2]  = 32'h0e0e0000; // dummy (OR R20, R20, R20)
        mips.Mem[3]  = 32'h21430000; // LW    R3, 0(R10)    (Load N from Mem[200])
        mips.Mem[4]  = 32'h0e0e0000; // dummy
        // --- LOOP START ---
        mips.Mem[5]  = 32'h14431000; // MUL   R2, R2, R3    (Product = Product * N)
        mips.Mem[6]  = 32'h2c630001; // SUBI  R3, R3, 1     (N = N - 1)
        mips.Mem[7]  = 32'h0e0e0000; // dummy
        mips.Mem[8]  = 32'h3460fffc; // BNEQZ R3, Loop      (-4 offset to Mem[5])
        mips.Mem[9]  = 32'h2542fffe; // SW    R2, -2(R10)   (Store result in Mem[198])
        mips.Mem[10] = 32'hfc000000; // HLT

        // 4. Input: Find factorial of 7
        mips.Mem[200] = 7; 

        // 5. Simulation Monitor
        $display("Factorial Calculation Started for N = %d", mips.Mem[200]);
        
        // Wait for loop to complete (Factorial of 7 takes many cycles)
        #2500; 

        $display("--- FACTORIAL RESULTS ---");
        $display("Input N (Mem[200]): %d", mips.Mem[200]);
        $display("Result  (Mem[198]): %d", mips.Mem[198]);
        $display("--------------------------");
        
        #100 $finish;
    end

endmodule