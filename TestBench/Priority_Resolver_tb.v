module Priority_Resolver_tb;

    // Inputs
    reg [7:0] maskedInterruptRequest;
    reg [7:0] ISR;

    // Outputs
    wire [7:0] interruptVector;

    // Instantiate the Priority_Resolver module
    Priority_Resolver uut (
        .maskedInterruptRequest(maskedInterruptRequest),
        .ISR(ISR),
        .interruptVector(interruptVector)
    );

    // Initial block to apply test vectors
    initial begin
        // Test case 1: No interrupt is active
        maskedInterruptRequest = 8'b00000000;
        ISR = 8'b00000000;
        #10;
        // Expected results: No interrupt, vector = 0
        $display("Test Case 1: interruptVector=%b", interruptVector);

        // Test case 2: Interrupt 3 is active, ISR indicates interrupt 3 is being handled
        maskedInterruptRequest = 8'b00001000;
        ISR = 8'b00001000;
        #10;
        // Expected results: No interrupt, vector = 0 (ISR indicates interrupt 3 is being handled)
        $display("Test Case 2: interruptVector=%b", interruptVector);

        // Test case 3: Interrupt 5 is active, ISR indicates interrupt 3 is being handled
        maskedInterruptRequest = 8'b00100000;
        ISR = 8'b00001000;
        #10;
        // Expected results: Interrupt 5, vector = 00100000 (higher priority than ISR)
        $display("Test Case 3: interruptVector=%b", interruptVector);
        
        maskedInterruptRequest = 8'b00000010;
        ISR = 8'b00001000;
        #10;
        // Expected results: Interrupt 5, vector = 00100000 (higher priority than ISR)
        $display("Test Case 3: interruptVector=%b", interruptVector);

        // Add more test cases as needed

        // Stop simulation
        $stop;
    end

endmodule
