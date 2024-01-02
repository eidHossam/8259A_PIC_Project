module IRR (
    input wire sensitivityMode,
    input wire [7:0] clearInterruptRequest,
    input wire [7:0] peripheralInterrupts,
    output reg [7:0] interruptRequest
);

    reg [7:0] prevPeripheralInterrupts;
    reg [7:0] assertedInterrupts;

    initial begin
        prevPeripheralInterrupts = 0;
        assertedInterrupts = 0;
    end

    always @* begin
        if (sensitivityMode == 1) begin
            // Level-sensitive handling
            assertedInterrupts = assertedInterrupts | peripheralInterrupts;
        end
        else begin
            // Edge-sensitive handling
            assertedInterrupts = assertedInterrupts | (peripheralInterrupts & ~prevPeripheralInterrupts);
        end

        assertedInterrupts = assertedInterrupts & ~clearInterruptRequest;
        interruptRequest = assertedInterrupts;
        
        // Update Previous Interrupt values
        prevPeripheralInterrupts = peripheralInterrupts;
    end

endmodule
