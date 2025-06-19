module testpipeline;

    reg clk1, clk2;
    integer k;

    pipe_MIPS32 uut (
        .clk1(clk1),
        .clk2(clk2)
    );

    
    initial begin
        clk1 = 0; clk2 = 0;
        repeat(200) begin
            #5 clk1 = ~clk1;
            #5 clk2 = ~clk2;
        end
    end

   
    initial begin
       
        for (k = 0; k < 6; k = k + 1)
            uut.register[k] = k;

        uut.memory[0]  = 32'h2801000a; 
        uut.memory[1]  = 32'h28010014; 
        uut.memory[2]  = 32'h28010019; 
        uut.memory[3]  = 32'h0ce77800; 
        uut.memory[4]  = 32'h0ce77800; 
        uut.memory[5]  = 32'h00222000; 
        uut.memory[6]  = 32'h0ce77800; 
        uut.memory[7]  = 32'h00832800; 
        uut.memory[12] = 32'hfc000000; 
        #1500;
        for (k = 0; k < 6; k = k + 1)
            $display("Register %2d: %2d,", k, uut.register[k]);
    end
    initial begin
        $dumpfile("testpipeline.vcd");
        $dumpvars(0, uut);
        #1600;
        $finish;
    end

endmodule
