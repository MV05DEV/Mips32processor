module pipe_MIPS32 (clk1,clk2);
input clk1, clk2;
reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B, EX_MEM_cond;
reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;

reg [31:0] register [0:31];
reg [31:0] memory [0:1023];
parameter ADD = 6'b000000, SUB = 6'b000001, AND = 6'b000010, OR = 6'b000011, SLT=6'b000100,
           MUL = 6'b000101, SW = 6'b000110, ORI = 6'b000111, SLTI = 6'b001000,
           LW = 6'b001001, ADDI = 6'b001010, BEQ = 6'b001011, BNE = 6'b001100,
           JUMP = 6'b001101, HLT=6'b111111;
parameter RR_ALU=3'b000, RM_Alu=3'b001, LOAD=3'b010, STORE=3'b011, BRANCH=3'b100, HALT=3'b101; 
reg HALTED;
reg TAKEN_BRANCH;
initial begin
    HALTED=0;
    TAKEN_BRANCH=0; 
    PC = 0; 
end
always @(posedge clk1) begin
    if(HALTED==0) begin
        if(((EX_MEM_IR[31:26] == BEQ) && (EX_MEM_cond == 1))||
           ((EX_MEM_IR[31:26] == BNE) && (EX_MEM_cond == 0))) begin
            IF_ID_IR <= #2 memory[EX_MEM_ALUOut];
            TAKEN_BRANCH <= #2 1'b1;
            IF_ID_NPC <= #2 EX_MEM_ALUOut + 1;
            PC<= #2 EX_MEM_ALUOut + 1;
        end else begin
            IF_ID_IR<= #2 memory[PC];
            IF_ID_NPC <= #2 PC + 1;
            PC <= PC + 1;
        end
    end
    
end
always @(posedge clk2) begin
    if(HALTED==0) begin
        if (IF_ID_IR[25:21]==5'b00000) ID_EX_A<=0; 
        else ID_EX_A <= #2 register[IF_ID_IR[25:21]];
        if (IF_ID_IR[20:16]==5'b00000) ID_EX_B<=0; 
        else ID_EX_B <= #2 register[IF_ID_IR[20:16]];
        ID_EX_IR <= #2 IF_ID_IR;
        ID_EX_NPC <= #2 IF_ID_NPC;
        ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};
        case (IF_ID_IR[31:26])      
            ADD, SUB, AND, OR, SLT, MUL: ID_EX_type <= #2 RR_ALU;
            ADDI, ORI, SLTI: ID_EX_type <= #2 RM_Alu;
            LW: ID_EX_type <= #2 LOAD;
            SW: ID_EX_type <= #2 STORE;
            BEQ, BNE: ID_EX_type <= #2 BRANCH;
            HLT: ID_EX_type <= #2 HALT;
        endcase
    end
    
end
always @(posedge clk1) begin
    if (HALTED==0) begin
        EX_MEM_type<=#2 ID_EX_type;
        EX_MEM_IR <= #2 ID_EX_IR;
        TAKEN_BRANCH <= #2 1'b0;
        case (ID_EX_type)
            RR_ALU: begin
                case (ID_EX_IR[31:26])
                    ADD: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
                    SUB: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
                    AND: EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
                    OR: EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
                    SLT: EX_MEM_ALUOut <= #2 (ID_EX_A < ID_EX_B) ? 1 : 0;
                    MUL: EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
                endcase
                
            end
            
            RM_Alu: begin
                $display("IMM Execute: Instruction = %h |A = %0d | Immediate = %0d (0x%h)", ID_EX_IR,ID_EX_A, ID_EX_Imm, ID_EX_Imm);
                case (ID_EX_IR[31:26])
                    ADDI: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                    ORI:  EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_Imm;
                    SLTI: EX_MEM_ALUOut <= #2 (ID_EX_A < ID_EX_Imm) ? 1 : 0;
                    default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
                endcase
            end

            
            LOAD: begin
                EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                EX_MEM_B <= #2 ID_EX_B; 
            end
            
            STORE: begin
                EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm; 
                EX_MEM_B <= #2 ID_EX_B;
            end
            
            BRANCH: begin
                EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm; 
                if (ID_EX_IR[31:26] == BEQ) begin
                    EX_MEM_cond <= #2 (ID_EX_A == ID_EX_B); 
                end else if (ID_EX_IR[31:26] == BNE) begin
                    EX_MEM_cond <= #2 (ID_EX_A != ID_EX_B); 
                end else begin
                    EX_MEM_cond <= #2 1'b0; 
                end
            end
        endcase      
    end
    
end
always @(posedge clk2) begin
    if (HALTED==0) begin
        MEM_WB_type<= #2EX_MEM_type;
        MEM_WB_IR <= #2 EX_MEM_IR;
        case (EX_MEM_type)
            RR_ALU, RM_Alu: begin
                MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
                MEM_WB_LMD <= #2 32'hxxxxxxxx; 
            end
            
            LOAD: begin
                MEM_WB_ALUOut <= #2 EX_MEM_ALUOut; 
                MEM_WB_LMD <= #2 memory[EX_MEM_ALUOut]; 
            end
            
            STORE: if (TAKEN_BRANCH ==0) begin
                memory[EX_MEM_ALUOut] <= #2 EX_MEM_B; 
                
            end
        endcase    
    end
    
end
always @(posedge clk1) begin
    if (TAKEN_BRANCH==0) begin
        
        case (MEM_WB_type)      
            RR_ALU: begin
                register[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut;
            
            end

            RM_Alu: begin
                register[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut;
            end

            LOAD: begin
                register[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;
            end

            HALT: begin
                HALTED <= #2 1'b1; 
            end
        endcase
    end
    
end
    
endmodule