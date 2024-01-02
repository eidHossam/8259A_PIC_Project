module Priority_Resolver (
    // Inputs
    input [7:0] maskedInterruptRequest, 
    input [7:0] ISR, 
    // Outputs
    output reg [7:0] interruptVector       // Vector indicating the highest priority interrupt
);
    integer i;
    reg [7:0] tempMaskedInterruptRequest; // Intermediate variable to avoid conflict
    reg foundInterrupt; // Flag to indicate if an interrupt is found

    // Check for active interrupt
    always @* begin
        tempMaskedInterruptRequest = maskedInterruptRequest; // Copy the input to the intermediate variable
        if (|tempMaskedInterruptRequest) begin
            // Determine the highest priority interrupt vector
            // In this example, simply select the lowest active interrupt
            foundInterrupt = 0; // Initialize flag
            for (i = 0; i < 8; i = i + 1) begin
                if (tempMaskedInterruptRequest[i] & ~foundInterrupt) begin
                  if((~ISR) || (1 << i < ISR)) begin
                    interruptVector = 1<<i;
                    foundInterrupt = 1; // Set the flag to indicate that an interrupt is found
                  end
                end
            end
        end
        else begin
            interruptVector = 0; // Default vector when no interrupt is active
        end
    end
    
    
endmodule
