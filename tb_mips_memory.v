`timescale 1ns / 1ps

module tb_mips_memory;
    reg clk1, clk2;
    integer k;

    // Instantiate the processor
    pipe_MIPS32 mips (
        .clk1(clk1), 
        .clk2(clk2)
    );

    // Unified Clock Generation
    initial begin
        clk1 = 0; 
        clk2 = 0;
        // Generating two-phase clock as per your requirements
        forever begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end

    // Unified Initialization and Program Loading
    initial begin
        // 1. Initialize Processor State
        mips.PC = 0;
        mips.HALTED = 0;
        mips.TAKEN_BRANCH = 0;

        // 2. Initialize Register File: Reg[k] = k
        for (k = 0; k < 32; k = k + 1) begin
            mips.Reg[k] = k;
        end

        // 3. Load Program into Instruction Memory
        mips.Mem[0] = 32'h28010078;    // ADDI  R1, R0, 120 (Sets base address)
        mips.Mem[1] = 32'h0ce77800;    // dummy (OR R12, R12, R12) - NOP
        mips.Mem[2] = 32'h20220000;    // LW    R2, 0(R1) (Loads 85 into R2)
        mips.Mem[3] = 32'h0ce77800;    // dummy (OR R12, R12, R12) - NOP
        mips.Mem[4] = 32'h2842002d;    // ADDI  R2, R2, 45 (R2 = 85 + 45 = 130)
        mips.Mem[5] = 32'h0ce77800;    // dummy (OR R12, R12, R12) - NOP
        mips.Mem[6] = 32'h24220001;    // SW    R2, 1(R1) (Stores 130 at Mem[121])
        mips.Mem[7] = 32'hfc000000;    // HLT

        // 4. Load Initial Data into Data Memory
        mips.Mem[120] = 85; 

        // 5. Simulation Control and Display
        $dumpfile("mips.vcd");
        $dumpvars(0, tb_mips_memory);
        
        #500; // Wait for pipeline to finish
        $display("--- SIMULATION RESULTS ---");
        $display("Mem[120] (Initial): %d", mips.Mem[120]);
        $display("Mem[121] (Result) : %d", mips.Mem[121]);
        $display("--------------------------");
        
        #50 $finish;
    end

endmodule