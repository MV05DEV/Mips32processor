# MIPS32 5-Stage Pipelined Processor Simulation in Verilog

This project implements a simplified 32-bit MIPS processor using a 5-stage pipeline architecture in Verilog. The pipeline includes basic instruction decoding, ALU execution, memory operations, and register write-back. A testbench (`testpipeline`) is also included to simulate and verify instruction execution with waveform generation support.

---

##  Architecture Overview

This processor is a basic **5-stage pipelined MIPS CPU** with the following stages:

1. **IF (Instruction Fetch)**  
2. **ID (Instruction Decode)**  
3. **EX (Execute)**  
4. **MEM (Memory Access)**  
5. **WB (Write Back)**  

Each stage is implemented using pipeline registers:
- `IF_ID`, `ID_EX`, `EX_MEM`, `MEM_WB`

---

##  Files

| File | Description |
|------|-------------|
| `pipe_MIPS32.v` | Main processor module implementing 5-stage pipelining |
| `testpipeline.v` | Testbench for simulating and verifying the processor |
| `testpipeline.vcd` | Waveform dump generated from simulation (can be opened in GTKWave) |

---

## 💻 Supported Instructions

| Instruction | Opcode (6-bit) | Type | Function |
|------------|----------------|------|----------|
| `ADD`      | 000000         | R    | Reg + Reg |
| `SUB`      | 000001         | R    | Reg - Reg |
| `AND`      | 000010         | R    | Bitwise AND |
| `OR`       | 000011         | R    | Bitwise OR |
| `SLT`      | 000100         | R    | Set on Less Than |
| `MUL`      | 000101         | R    | Multiply |
| `ADDI`     | 001010         | I    | Reg + Immediate |
| `ORI`      | 000111         | I    | Bitwise OR with Immediate |
| `SLTI`     | 001000         | I    | Set if Reg < Immediate |
| `LW`       | 001001         | I    | Load Word |
| `SW`       | 000110         | I    | Store Word |
| `BEQ`      | 001011         | I    | Branch if Equal |
| `BNE`      | 001100         | I    | Branch if Not Equal |
| `HLT`      | 111111         | -    | Halt the processor |
